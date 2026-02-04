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
