import { logger } from '../../utils/logger';

/**
 * Base WOD 등록 성공 (INFO)
 * @param data - Base WOD 등록 정보
 */
export const baseWodRegistered = (data: {
  wodId: number;
  boxId: number;
  date: string;
  createdBy: number;
}) => {
  logger.info({
    wodId: data.wodId,
    boxId: data.boxId,
    date: data.date,
    createdBy: data.createdBy,
  }, 'Base WOD registered');
};

/**
 * Personal WOD 등록 성공 (INFO)
 * @param data - Personal WOD 등록 정보 (comparisonResult 포함)
 */
export const personalWodRegistered = (data: {
  wodId: number;
  boxId: number;
  date: string;
  createdBy: number;
  comparisonResult: string;
}) => {
  logger.info({
    wodId: data.wodId,
    boxId: data.boxId,
    date: data.date,
    createdBy: data.createdBy,
    comparisonResult: data.comparisonResult,
  }, 'Personal WOD registered');
};

/**
 * 변경 제안 생성 (INFO)
 * @param data - 제안 생성 정보
 */
export const proposalCreated = (data: {
  proposalId: number;
  baseWodId: number;
  proposedWodId: number;
}) => {
  logger.info({
    proposalId: data.proposalId,
    baseWodId: data.baseWodId,
    proposedWodId: data.proposedWodId,
  }, 'WOD change proposal created');
};

/**
 * 변경 승인 (INFO)
 * @param data - 승인 정보
 */
export const proposalApproved = (data: {
  proposalId: number;
  oldBaseWodId: number;
  newBaseWodId: number;
  approvedBy: number;
}) => {
  logger.info({
    proposalId: data.proposalId,
    oldBaseWodId: data.oldBaseWodId,
    newBaseWodId: data.newBaseWodId,
    approvedBy: data.approvedBy,
  }, 'WOD change proposal approved');
};

/**
 * WOD 선택 (INFO)
 * @param data - 선택 정보
 */
export const wodSelected = (data: {
  userId: number;
  wodId: number;
  boxId: number;
  date: string;
}) => {
  logger.info({
    userId: data.userId,
    wodId: data.wodId,
    boxId: data.boxId,
    date: data.date,
  }, 'User selected WOD for date');
};

/**
 * 중복 선택 시도 (WARN)
 * @param data - 중복 시도 정보
 */
export const duplicateSelectionAttempt = (data: {
  userId: number;
  boxId: number;
  date: string;
}) => {
  logger.warn({
    userId: data.userId,
    boxId: data.boxId,
    date: data.date,
  }, 'Duplicate WOD selection attempt');
};
