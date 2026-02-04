import { z } from 'zod';

/**
 * 질문 제출 요청 스키마
 * 사용자가 제출하는 질문의 유효성을 검증합니다
 */
export const submitQuestionSchema = z.object({
  /** 앱 코드 (필수, 1-50자) */
  appCode: z.string().min(1, 'App code is required').max(50, 'App code must be 1-50 characters'),

  /** 질문 제목 (필수, 1-256자) */
  title: z.string().min(1, 'Title is required').max(256, 'Title must be 1-256 characters'),

  /** 질문 본문 (필수, 1-65536자) */
  body: z.string().min(1, 'Body is required').max(65536, 'Body must be 1-65536 characters'),
});

/**
 * 질문 제출 요청 타입
 */
export type SubmitQuestionRequest = z.infer<typeof submitQuestionSchema>;
