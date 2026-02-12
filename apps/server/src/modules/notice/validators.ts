import { z } from 'zod';

/**
 * 공지사항 목록 조회 쿼리 파라미터 검증
 */
export const listNoticesSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  category: z.string().max(50).optional(),
  pinnedOnly: z
    .enum(['true', 'false'])
    .transform((val) => val === 'true')
    .optional(),
  appCode: z.string().min(1).max(50).optional(),
});

/**
 * 공지사항 작성 요청 검증
 */
export const createNoticeSchema = z.object({
  title: z.string().min(1).max(200, '제목은 1~200자 사이여야 합니다'),
  content: z.string().min(1, '본문은 필수입니다'),
  category: z.string().max(50).optional(),
  isPinned: z.boolean().default(false),
});

/**
 * 공지사항 수정 요청 검증
 */
export const updateNoticeSchema = z.object({
  title: z.string().min(1).max(200).optional(),
  content: z.string().min(1).optional(),
  category: z.string().max(50).optional(),
  isPinned: z.boolean().optional(),
}).refine((data) => Object.keys(data).length > 0, {
  message: '최소 하나의 필드가 필요합니다',
});

/**
 * 공지사항 고정/해제 요청 검증
 */
export const pinNoticeSchema = z.object({
  isPinned: z.boolean(),
});

/**
 * 공지사항 ID 파라미터 검증
 */
export const noticeIdSchema = z.object({
  id: z.coerce.number().int().positive(),
});
