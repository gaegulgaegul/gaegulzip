export type WodType = 'AMRAP' | 'ForTime' | 'EMOM' | 'Strength' | 'Custom';
export type WeightUnit = 'kg' | 'lb' | 'bw';
export type ComparisonResult = 'identical' | 'similar' | 'different';
export type ProposalStatus = 'pending' | 'approved' | 'rejected';

/**
 * WOD 이벤트 타입 (Phase 5 알림용)
 */
export enum WodEventType {
  /** 오늘의 WOD가 등록되었습니다 */
  WOD_REGISTERED = 'WOD_REGISTERED',
  /** 오늘 WOD가 다르게 등록된 것 같습니다 */
  WOD_DIFFERENCE_DETECTED = 'WOD_DIFFERENCE_DETECTED',
  /** Base WOD가 변경되었습니다 */
  BASE_WOD_CHANGED = 'BASE_WOD_CHANGED',
}

export interface Movement {
  name: string;
  reps?: number;
  weight?: number;
  unit?: WeightUnit;
  distance?: number;
  distanceUnit?: string;
  duration?: number;
  notes?: string;
}

export interface ProgramData {
  type: WodType;
  timeCap?: number;
  rounds?: number;
  movements: Movement[];
  notes?: string;
}

export interface Wod {
  id: number;
  boxId: number;
  date: string;
  programData: ProgramData;
  rawText: string;
  isBase: boolean;
  createdBy: number;
  createdAt: Date;
  updatedAt: Date;
}

export interface WodWithComparison extends Wod {
  comparisonResult: ComparisonResult;
}

export interface RegisterWodInput {
  boxId: number;
  date: string;
  programData: ProgramData;
  rawText: string;
  createdBy: number;
}

export interface WodsByDateResult {
  baseWod: Wod | null;
  personalWods: WodWithComparison[];
}

export interface ProposedChange {
  id: number;
  baseWodId: number;
  proposedWodId: number;
  status: ProposalStatus;
  proposedAt: Date;
  resolvedAt: Date | null;
  resolvedBy: number | null;
}

export interface CreateProposalInput {
  baseWodId: number;
  proposedWodId: number;
}

export interface WodSelection {
  id: number;
  userId: number;
  wodId: number;
  boxId: number;
  date: string;
  snapshotData: ProgramData;
  createdAt: Date;
}

export interface SelectWodInput {
  userId: number;
  wodId: number;
  boxId: number;
  date: string;
}

export interface GetSelectionsInput {
  userId: number;
  startDate?: string;
  endDate?: string;
}

export interface GetProposalsInput {
  baseWodId?: number;
  status?: ProposalStatus;
}
