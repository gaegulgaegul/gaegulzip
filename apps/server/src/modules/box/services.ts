import { db } from '../../config/database';
import { boxes, boxMembers } from './schema';
import { eq, and, ilike, or, sql } from 'drizzle-orm';
import { CreateBoxInput, JoinBoxInput, SearchBoxInput, BoxWithMemberCount, CreateBoxResponse, BoxMember, BoxMemberRole } from './types';
import { NotFoundException, BusinessException } from '../../utils/errors';
import * as boxProbe from './box.probe';

/**
 * 박스 생성
 * @param data - 박스 생성 데이터
 * @returns 생성된 박스 객체
 */
export async function createBox(data: CreateBoxInput) {
  const [box] = await db.insert(boxes).values({
    name: data.name,
    region: data.region,
    description: data.description ?? null,
    createdBy: data.createdBy,
  }).returning();

  boxProbe.created({ boxId: box.id, name: box.name, region: box.region, createdBy: box.createdBy });

  return box;
}

/**
 * 박스 가입 (단일 박스 정책: 기존 박스 자동 탈퇴)
 * @param data - 가입 데이터 (boxId, userId)
 * @returns 멤버 객체 및 이전 박스 ID
 * @throws NotFoundException 박스가 존재하지 않을 때
 */
export async function joinBox(data: JoinBoxInput) {
  // 1. 박스 존재 확인
  const [box] = await db.select().from(boxes).where(eq(boxes.id, data.boxId)).limit(1);
  if (!box) {
    throw new NotFoundException('Box', data.boxId);
  }

  // 2. 같은 박스에 이미 가입되어 있으면 기존 멤버십 반환 (멱등성)
  const [existingSameBox] = await db.select().from(boxMembers)
    .where(and(eq(boxMembers.boxId, data.boxId), eq(boxMembers.userId, data.userId)))
    .limit(1);
  if (existingSameBox) {
    return {
      membership: existingSameBox,
      previousBoxId: null,
    };
  }

  // 3. 다른 박스에 가입되어 있으면 자동 탈퇴 (단일 박스 정책)
  const [existingOtherBox] = await db.select().from(boxMembers)
    .where(eq(boxMembers.userId, data.userId))
    .limit(1);

  let previousBoxId: number | null = null;
  if (existingOtherBox) {
    previousBoxId = existingOtherBox.boxId;
    await db.delete(boxMembers).where(eq(boxMembers.id, existingOtherBox.id));
  }

  // 4. 새 멤버 등록
  const [member] = await db.insert(boxMembers).values({
    boxId: data.boxId,
    userId: data.userId,
  }).returning();

  if (previousBoxId) {
    boxProbe.boxSwitched({ userId: data.userId, previousBoxId, newBoxId: data.boxId });
  } else {
    boxProbe.memberJoined({ boxId: data.boxId, userId: data.userId });
  }

  return {
    membership: member,
    previousBoxId,
  };
}

/**
 * 박스 상세 조회
 * @param boxId - 박스 ID
 * @returns 박스 객체 (memberCount 포함)
 * @throws NotFoundException 박스가 존재하지 않을 때
 */
export async function getBoxById(boxId: number) {
  const results = await db
    .select({
      id: boxes.id,
      name: boxes.name,
      region: boxes.region,
      description: boxes.description,
      createdBy: boxes.createdBy,
      createdAt: boxes.createdAt,
      updatedAt: boxes.updatedAt,
      memberCount: sql<number>`COALESCE(COUNT(${boxMembers.id}), 0)`,
    })
    .from(boxes)
    .leftJoin(boxMembers, eq(boxes.id, boxMembers.boxId))
    .where(eq(boxes.id, boxId))
    .groupBy(boxes.id);

  if (results.length === 0) {
    throw new NotFoundException('Box', boxId);
  }

  return results[0];
}

/**
 * 박스 검색 (통합 키워드 검색 또는 개별 name/region 검색)
 *
 * keyword가 제공되면 name OR region ILIKE 검색을 수행합니다.
 * keyword가 없으면 기존 name/region AND 검색을 수행합니다 (하위 호환성).
 *
 * @param input - 검색 조건 (keyword 또는 name/region)
 * @param input.keyword - 통합 검색 키워드 (name, region에서 OR 검색)
 * @param input.name - 박스 이름 검색어 (keyword 없을 때 사용)
 * @param input.region - 지역 검색어 (keyword 없을 때 사용)
 * @returns 박스 목록 (memberCount 포함)
 */
export async function searchBoxes(input: SearchBoxInput): Promise<BoxWithMemberCount[]> {
  // keyword 우선 처리 (통합 검색)
  if (input.keyword !== undefined) {
    const trimmedKeyword = input.keyword.trim();

    // 빈 키워드는 빈 배열 반환
    if (!trimmedKeyword) {
      return [];
    }

    // name OR region ILIKE 검색
    const results = await db
      .select({
        id: boxes.id,
        name: boxes.name,
        region: boxes.region,
        description: boxes.description,
        memberCount: sql<number>`COALESCE(COUNT(${boxMembers.id}), 0)`,
      })
      .from(boxes)
      .leftJoin(boxMembers, eq(boxes.id, boxMembers.boxId))
      .where(
        or(
          ilike(boxes.name, `%${trimmedKeyword}%`),
          ilike(boxes.region, `%${trimmedKeyword}%`)
        )
      )
      .groupBy(boxes.id);

    return results as BoxWithMemberCount[];
  }

  // 기존 name/region 개별 검색 (하위 호환성)
  if (!input.name && !input.region) {
    return [];
  }

  // WHERE 조건 구성
  const conditions = [];
  if (input.name) {
    conditions.push(ilike(boxes.name, `%${input.name}%`));
  }
  if (input.region) {
    conditions.push(ilike(boxes.region, `%${input.region}%`));
  }

  // 박스 조회 + memberCount 집계
  const results = await db
    .select({
      id: boxes.id,
      name: boxes.name,
      region: boxes.region,
      description: boxes.description,
      memberCount: sql<number>`COALESCE(COUNT(${boxMembers.id}), 0)`,
    })
    .from(boxes)
    .leftJoin(boxMembers, eq(boxes.id, boxMembers.boxId))
    .where(and(...conditions))
    .groupBy(boxes.id);

  return results as BoxWithMemberCount[];
}

/**
 * 내 현재 박스 조회 (userId로 현재 박스 조회)
 * @param userId - 사용자 ID
 * @returns 현재 박스 정보 (memberCount, joinedAt 포함) 또는 null
 */
export async function getCurrentBox(userId: number) {
  const results = await db
    .select({
      id: boxes.id,
      name: boxes.name,
      region: boxes.region,
      description: boxes.description,
      memberCount: sql<number>`COALESCE((
        SELECT COUNT(*) FROM ${boxMembers} WHERE ${boxMembers.boxId} = ${boxes.id}
      ), 0)`,
      joinedAt: boxMembers.joinedAt,
    })
    .from(boxMembers)
    .leftJoin(boxes, eq(boxMembers.boxId, boxes.id))
    .where(eq(boxMembers.userId, userId));

  if (results.length === 0) {
    return null;
  }

  return results[0];
}

/**
 * 박스 멤버 목록 조회
 * @param boxId - 박스 ID
 * @returns 멤버 목록
 */
export async function getBoxMembers(boxId: number) {
  const members = await db
    .select()
    .from(boxMembers)
    .where(eq(boxMembers.boxId, boxId));

  return members;
}

/**
 * 박스 생성 + 생성자 자동 멤버 등록 (트랜잭션)
 *
 * 박스 생성과 멤버 등록을 단일 트랜잭션으로 처리하여 데이터 정합성을 보장합니다.
 * 단일 박스 정책: 사용자가 이미 다른 박스에 가입되어 있으면 자동으로 탈퇴합니다.
 *
 * @param data - 박스 생성 데이터
 * @param data.name - 박스 이름 (2-255자)
 * @param data.region - 박스 지역 (2-255자)
 * @param data.description - 박스 설명 (선택, 최대 1000자)
 * @param data.createdBy - 생성자 사용자 ID
 * @returns 생성된 박스, 멤버십, 이전 박스 ID (없으면 null)
 * @throws 트랜잭션 실패 시 전체 롤백
 */
export async function createBoxWithMembership(data: CreateBoxInput): Promise<CreateBoxResponse> {
  return await db.transaction(async (tx) => {
    // 1. 박스 생성
    const [box] = await tx.insert(boxes).values({
      name: data.name,
      region: data.region,
      description: data.description ?? null,
      createdBy: data.createdBy,
    }).returning();

    // 2. 기존 박스 멤버십 확인 및 삭제 (단일 박스 정책)
    const [existingMembership] = await tx.select()
      .from(boxMembers)
      .where(eq(boxMembers.userId, data.createdBy))
      .limit(1);

    let previousBoxId: number | null = null;
    if (existingMembership) {
      previousBoxId = existingMembership.boxId;
      await tx.delete(boxMembers).where(eq(boxMembers.id, existingMembership.id));
    }

    // 3. 생성자를 새 박스의 멤버로 등록
    const [rawMembership] = await tx.insert(boxMembers).values({
      boxId: box.id,
      userId: data.createdBy,
      role: 'member',
    }).returning();

    const membership: BoxMember = {
      ...rawMembership,
      role: rawMembership.role as BoxMemberRole,
    };

    // 4. 로깅
    if (previousBoxId) {
      boxProbe.boxSwitched({
        userId: data.createdBy,
        previousBoxId,
        newBoxId: box.id,
      });
    } else {
      boxProbe.created({
        boxId: box.id,
        name: box.name,
        region: box.region,
        createdBy: box.createdBy,
      });
      boxProbe.memberJoined({
        boxId: box.id,
        userId: data.createdBy,
      });
    }

    return { box, membership, previousBoxId };
  });
}
