import { logger } from '../../utils/logger';

/**
 * 공지사항 생성 성공 (관리자)
 * @param data - 생성된 공지사항 정보
 */
export const created = (data: {
  noticeId: number;
  authorId: number | null;
  appCode: string;
  title: string;
}) => {
  logger.info({
    noticeId: data.noticeId,
    authorId: data.authorId,
    appCode: data.appCode,
    title: data.title,
  }, 'Notice created');
};

/**
 * 공지사항 수정 (관리자)
 * @param data - 수정된 공지사항 정보
 */
export const updated = (data: {
  noticeId: number;
  authorId: number | null;
  appCode: string;
}) => {
  logger.info({
    noticeId: data.noticeId,
    authorId: data.authorId,
    appCode: data.appCode,
  }, 'Notice updated');
};

/**
 * 공지사항 삭제 (관리자)
 * @param data - 삭제된 공지사항 정보
 */
export const deleted = (data: {
  noticeId: number;
  authorId: number | null;
  appCode: string;
}) => {
  logger.info({
    noticeId: data.noticeId,
    authorId: data.authorId,
    appCode: data.appCode,
  }, 'Notice deleted (soft)');
};

/**
 * 공지사항 고정/해제 (관리자)
 * @param data - 고정/해제 정보
 */
export const pinToggled = (data: {
  noticeId: number;
  isPinned: boolean;
  authorId: number | null;
}) => {
  logger.info({
    noticeId: data.noticeId,
    isPinned: data.isPinned,
    authorId: data.authorId,
  }, 'Notice pin toggled');
};

/**
 * 공지사항 상세 조회 (사용자)
 * @param data - 조회 정보
 */
export const viewed = (data: {
  noticeId: number;
  userId: number;
}) => {
  logger.info({
    noticeId: data.noticeId,
    userId: data.userId,
  }, 'Notice viewed');
};

/**
 * 공지사항 찾기 실패
 * @param data - 실패 정보
 */
export const notFound = (data: {
  noticeId: number;
  appCode: string;
}) => {
  logger.warn({
    noticeId: data.noticeId,
    appCode: data.appCode,
  }, 'Notice not found or deleted');
};
