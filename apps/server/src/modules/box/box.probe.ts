import { logger } from '../../utils/logger';

/**
 * 박스 생성 성공 (INFO)
 * @param data - 박스 생성 정보 (boxId, name, region, createdBy)
 */
export const created = (data: {
  boxId: number;
  name: string;
  region: string;
  createdBy: number;
}) => {
  logger.info({
    boxId: data.boxId,
    name: data.name,
    region: data.region,
    createdBy: data.createdBy,
  }, 'Box created successfully');
};

/**
 * 박스 가입 성공 (INFO)
 * @param data - 가입 정보 (boxId, userId)
 */
export const memberJoined = (data: {
  boxId: number;
  userId: number;
}) => {
  logger.info({
    boxId: data.boxId,
    userId: data.userId,
  }, 'User joined box');
};

/**
 * 박스 변경 (기존 박스 자동 탈퇴) (INFO)
 * @param data - 박스 변경 정보 (userId, previousBoxId, newBoxId)
 */
export const boxSwitched = (data: {
  userId: number;
  previousBoxId: number;
  newBoxId: number;
}) => {
  logger.info({
    userId: data.userId,
    previousBoxId: data.previousBoxId,
    newBoxId: data.newBoxId,
  }, 'User switched box');
};

/**
 * 박스 검색 실행 (DEBUG)
 * @param data - 검색 조건 및 결과 수
 */
export const searchExecuted = (data: { keyword: string; resultCount: number }) => {
  logger.debug({
    keyword: data.keyword,
    resultCount: data.resultCount,
  }, 'Box search executed');
};

/**
 * 박스 생성 실패 (ERROR)
 * @param data - 실패 정보 (userId, name, error)
 */
export const creationFailed = (data: { userId: number; name: string; error: string }) => {
  logger.error({
    userId: data.userId,
    name: data.name,
    error: data.error,
  }, 'Box creation failed');
};

/**
 * 트랜잭션 롤백 (WARN)
 * @param data - 롤백 정보 (userId, reason)
 */
export const transactionRolledBack = (data: { userId: number; reason: string }) => {
  logger.warn({
    userId: data.userId,
    reason: data.reason,
  }, 'Box creation transaction rolled back');
};
