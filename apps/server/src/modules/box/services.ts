import { db } from '../../config/database';
import { boxes, boxMembers } from './schema';
import { eq, and, ilike, or, sql } from 'drizzle-orm';
import { CreateBoxInput, JoinBoxInput, SearchBoxInput, BoxWithMemberCount } from './types';
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
 * 박스 검색 (name/region ILIKE 검색)
 * @param input - 검색 조건 (name, region)
 * @returns 박스 목록 (memberCount 포함)
 */
export async function searchBoxes(input: SearchBoxInput): Promise<BoxWithMemberCount[]> {
  // 둘 다 없으면 빈 배열 반환 (전체 목록 제공 안 함)
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
