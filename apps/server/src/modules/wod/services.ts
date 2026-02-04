import { db } from '../../config/database';
import { wods, proposedChanges, wodSelections } from './schema';
import { eq, and, gte, lte } from 'drizzle-orm';
import { RegisterWodInput, WodWithComparison, WodsByDateResult, CreateProposalInput, ProposedChange, SelectWodInput, WodSelection, GetSelectionsInput } from './types';
import { NotFoundException, BusinessException, ValidationException } from '../../utils/errors';
import { compareWods } from './comparison';
import { programDataSchema } from './validators';

/**
 * WOD 등록 비즈니스 로직
 * @param data - WOD 등록 데이터
 * @returns 등록된 WOD (comparisonResult 포함)
 */
export async function registerWod(data: RegisterWodInput): Promise<WodWithComparison> {
  // 0. programData 구조 검증
  const parsed = programDataSchema.safeParse(data.programData);
  if (!parsed.success) {
    throw new ValidationException(parsed.error.issues[0]?.message ?? 'Invalid programData');
  }

  // 1. Base WOD 존재 여부 확인
  const [existingBase] = await db
    .select()
    .from(wods)
    .where(
      and(
        eq(wods.boxId, data.boxId),
        eq(wods.date, data.date),
        eq(wods.isBase, true)
      )
    );

  // 2. Base가 없으면 현재 WOD를 Base로 지정
  const isBase = !existingBase;

  // 3. WOD 생성
  const [newWod] = await db
    .insert(wods)
    .values({
      boxId: data.boxId,
      date: data.date,
      programData: data.programData as any,
      rawText: data.rawText,
      isBase,
      createdBy: data.createdBy,
    })
    .returning();

  // 4. Base WOD가 없으면 comparisonResult는 'identical'
  if (!existingBase) {
    return {
      ...newWod,
      programData: newWod.programData as any,
      createdAt: newWod.createdAt!,
      updatedAt: newWod.updatedAt!,
      comparisonResult: 'identical',
    };
  }

  // 5. Personal WOD인 경우 Base와 비교
  const comparisonResult = compareWods(
    existingBase.programData as any,
    data.programData
  );

  // 6. 'different'인 경우 자동으로 Proposal 생성
  if (comparisonResult === 'different') {
    await createProposal({
      baseWodId: existingBase.id,
      proposedWodId: newWod.id,
    });
  }

  return {
    ...newWod,
    programData: newWod.programData as any,
    createdAt: newWod.createdAt!,
    updatedAt: newWod.updatedAt!,
    comparisonResult,
  };
}

/**
 * 날짜별 WOD 조회
 * @param params - boxId, date
 * @returns Base WOD + Personal WODs
 */
export async function getWodsByDate(params: {
  boxId: number;
  date: string;
}): Promise<WodsByDateResult> {
  // 1. Base WOD 조회
  const [baseWod] = await db
    .select()
    .from(wods)
    .where(
      and(
        eq(wods.boxId, params.boxId),
        eq(wods.date, params.date),
        eq(wods.isBase, true)
      )
    );

  // 2. Personal WODs 조회
  const personalWods = await db
    .select()
    .from(wods)
    .where(
      and(
        eq(wods.boxId, params.boxId),
        eq(wods.date, params.date),
        eq(wods.isBase, false)
      )
    );

  // 3. Personal WODs에 comparisonResult 추가
  const personalWodsWithComparison = personalWods.map(personal => {
    const comparisonResult = baseWod
      ? compareWods(baseWod.programData as any, personal.programData as any)
      : 'identical';

    return {
      ...personal,
      programData: personal.programData as any,
      createdAt: personal.createdAt!,
      updatedAt: personal.updatedAt!,
      comparisonResult,
    };
  });

  return {
    baseWod: baseWod ? { ...baseWod, programData: baseWod.programData as any, createdAt: baseWod.createdAt!, updatedAt: baseWod.updatedAt! } : null,
    personalWods: personalWodsWithComparison,
  };
}

/**
 * 변경 제안 생성
 * @param data - 제안 데이터 (baseWodId, proposedWodId)
 * @returns 생성된 제안 객체
 */
export async function createProposal(data: CreateProposalInput): Promise<ProposedChange> {
  const [proposal] = await db
    .insert(proposedChanges)
    .values({
      baseWodId: data.baseWodId,
      proposedWodId: data.proposedWodId,
      status: 'pending',
    })
    .returning();

  return {
    ...proposal,
    status: proposal.status as 'pending' | 'approved' | 'rejected',
    proposedAt: proposal.proposedAt!,
    resolvedAt: proposal.resolvedAt || null,
    resolvedBy: proposal.resolvedBy || null,
  };
}

/**
 * 변경 승인
 * @param proposalId - 제안 ID
 * @param approverId - 승인자 사용자 ID
 * @throws NotFoundException 제안이 존재하지 않을 때
 * @throws BusinessException Base WOD 생성자가 아닐 때
 */
export async function approveProposal(
  proposalId: number,
  approverId: number
): Promise<void> {
  // 1. 제안 조회
  const [proposal] = await db
    .select()
    .from(proposedChanges)
    .where(eq(proposedChanges.id, proposalId));

  if (!proposal) {
    throw new NotFoundException('ProposedChange', proposalId);
  }

  // 2. Base WOD 등록자 확인
  const [baseWod] = await db
    .select()
    .from(wods)
    .where(eq(wods.id, proposal.baseWodId));

  if (baseWod.createdBy !== approverId) {
    throw new BusinessException('Only Base WOD creator can approve changes');
  }

  // 3. 트랜잭션으로 Base 교체
  await db.transaction(async (tx) => {
    // 3-1. 기존 Base WOD → Personal로 강등
    await tx
      .update(wods)
      .set({ isBase: false })
      .where(eq(wods.id, proposal.baseWodId));

    // 3-2. 제안된 Personal WOD → Base로 승격
    await tx
      .update(wods)
      .set({ isBase: true })
      .where(eq(wods.id, proposal.proposedWodId));

    // 3-3. 제안 상태 업데이트
    await tx
      .update(proposedChanges)
      .set({
        status: 'approved',
        resolvedAt: new Date(),
        resolvedBy: approverId,
      })
      .where(eq(proposedChanges.id, proposalId));
  });
}

/**
 * 변경 거부
 * @param proposalId - 제안 ID
 * @param rejecterId - 거부자 사용자 ID
 * @throws NotFoundException 제안이 존재하지 않을 때
 * @throws BusinessException Base WOD 생성자가 아닐 때
 */
export async function rejectProposal(
  proposalId: number,
  rejecterId: number
): Promise<void> {
  // 1. 제안 조회
  const [proposal] = await db
    .select()
    .from(proposedChanges)
    .where(eq(proposedChanges.id, proposalId));

  if (!proposal) {
    throw new NotFoundException('ProposedChange', proposalId);
  }

  // 2. Base WOD 등록자 확인
  const [baseWod] = await db
    .select()
    .from(wods)
    .where(eq(wods.id, proposal.baseWodId));

  if (baseWod.createdBy !== rejecterId) {
    throw new BusinessException('Only Base WOD creator can reject changes');
  }

  // 3. 제안 상태 업데이트
  await db
    .update(proposedChanges)
    .set({
      status: 'rejected',
      resolvedAt: new Date(),
      resolvedBy: rejecterId,
    })
    .where(eq(proposedChanges.id, proposalId));
}

/**
 * WOD 선택 비즈니스 로직 (불변 스냅샷 저장)
 * @param data - 선택 데이터 (userId, wodId, boxId, date)
 * @returns 생성된 선택 객체
 * @throws NotFoundException WOD가 존재하지 않을 때
 */
export async function selectWod(data: SelectWodInput): Promise<WodSelection> {
  // 1. WOD 조회
  const [wod] = await db
    .select()
    .from(wods)
    .where(eq(wods.id, data.wodId));

  if (!wod) {
    throw new NotFoundException('WOD', data.wodId);
  }

  // 2. 스냅샷 데이터 복사 (불변성 보장)
  const snapshotData = JSON.parse(JSON.stringify(wod.programData));

  // 3. 선택 저장 (UNIQUE 제약조건으로 멱등성 보장)
  const [selection] = await db
    .insert(wodSelections)
    .values({
      userId: data.userId,
      wodId: data.wodId,
      boxId: data.boxId,
      date: data.date,
      snapshotData: snapshotData as any,
    })
    .onConflictDoUpdate({
      target: [wodSelections.userId, wodSelections.boxId, wodSelections.date],
      set: {
        wodId: data.wodId,
        snapshotData: snapshotData as any,
        createdAt: new Date(),
      },
    })
    .returning();

  return {
    ...selection,
    snapshotData: selection.snapshotData as any,
    createdAt: selection.createdAt!,
  };
}

/**
 * 사용자의 WOD 선택 기록 조회
 * @param input - 조회 조건 (userId, startDate, endDate)
 * @returns 선택 목록
 */
export async function getSelections(input: GetSelectionsInput): Promise<WodSelection[]> {
  const conditions = [eq(wodSelections.userId, input.userId)];

  if (input.startDate) {
    conditions.push(gte(wodSelections.date, input.startDate));
  }

  if (input.endDate) {
    conditions.push(lte(wodSelections.date, input.endDate));
  }

  const selections = await db
    .select()
    .from(wodSelections)
    .where(and(...conditions));

  return selections.map(s => ({
    ...s,
    snapshotData: s.snapshotData as any,
    createdAt: s.createdAt!,
  }));
}
