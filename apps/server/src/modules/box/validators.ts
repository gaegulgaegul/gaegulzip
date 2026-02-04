import { z } from 'zod';

/**
 * 박스 생성 요청 검증
 */
export const createBoxSchema = z.object({
  name: z.string().min(1, 'Box name is required').max(255),
  region: z.string().min(1, 'Region is required').max(255),
  description: z.string().optional(),
});

/**
 * 박스 검색 쿼리 검증
 */
export const searchBoxQuerySchema = z.object({
  name: z.string().optional(),
  region: z.string().optional(),
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
