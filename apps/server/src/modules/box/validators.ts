import { z } from 'zod';

/**
 * 박스 생성 요청 검증
 */
export const createBoxSchema = z.object({
  name: z.string().trim().min(2, '박스 이름은 2자 이상이어야 합니다').max(255),
  region: z.string().trim().min(2, '지역은 2자 이상이어야 합니다').max(255),
  description: z.string().trim().max(1000).optional(),
});

/**
 * 박스 검색 쿼리 검증
 */
export const searchBoxQuerySchema = z.object({
  name: z.string().trim().max(255).optional(),
  region: z.string().trim().max(255).optional(),
  keyword: z.string().trim().max(255).optional(),
});

/**
 * 박스 가입 요청 검증 (boxId는 URL 파라미터)
 */
export const joinBoxParamsSchema = z.object({
  boxId: z.coerce.number().int().positive(),
});

/**
 * 박스 ID 파라미터 검증
 */
export const boxIdParamsSchema = z.object({
  boxId: z.coerce.number().int().positive(),
});
