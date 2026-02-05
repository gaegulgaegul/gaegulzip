import { Request, Response, RequestHandler } from 'express';
import { submitQuestionSchema } from './validators';
import { createQuestion } from './services';
import * as qnaProbe from './qna.probe';
import { logger } from '../../utils/logger';

/**
 * 질문 제출 핸들러 (선택적 인증)
 * @param req - 요청 객체 (body: { appCode, title, body })
 * @param res - 응답 객체
 * @returns 201: { questionId, issueNumber, issueUrl, createdAt } 형태의 JSON 응답
 * @throws ValidationException - 입력 검증 실패 시
 * @throws NotFoundException - 앱 또는 QnA 설정을 찾을 수 없음
 * @throws ExternalApiException - GitHub API 호출 실패
 */
export const submitQuestion: RequestHandler = async (req: Request, res: Response) => {
  const { appCode, title, body } = submitQuestionSchema.parse(req.body);
  const user = req.user;

  logger.debug({ appCode, title: title.substring(0, 50), userId: user?.userId }, 'Submitting question');

  const result = await createQuestion({
    appCode,
    userId: user?.userId ?? null,
    title,
    body,
  });

  qnaProbe.questionSubmitted({
    questionId: result.questionId,
    appCode,
    userId: user?.userId ?? null,
    issueNumber: result.issueNumber,
  });

  res.status(201).json({
    questionId: result.questionId,
    issueNumber: result.issueNumber,
    issueUrl: result.issueUrl,
    createdAt: result.createdAt,
  });
};
