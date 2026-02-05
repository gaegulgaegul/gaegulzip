import { logger } from '../../utils/logger';

/**
 * 질문 제출 성공 로그 (INFO)
 * @param data - 질문 ID, 앱 코드, 사용자 ID, Issue 번호
 */
export const questionSubmitted = (data: {
  questionId: number;
  appCode: string;
  userId: number | null;
  issueNumber: number;
}) => {
  logger.info(
    {
      questionId: data.questionId,
      appCode: data.appCode,
      userId: data.userId ?? 'anonymous',
      issueNumber: data.issueNumber,
    },
    'Question submitted to GitHub'
  );
};

/**
 * GitHub API Rate Limit 경고 (WARN)
 * @param data - 앱 코드, 남은 요청 수, 리셋 시각
 */
export const rateLimitWarning = (data: {
  appCode: string;
  remaining: number;
  resetAt: string;
}) => {
  logger.warn(
    {
      appCode: data.appCode,
      remaining: data.remaining,
      resetAt: data.resetAt,
    },
    'GitHub API rate limit approaching'
  );
};

/**
 * GitHub API 에러 (ERROR)
 * @param data - 앱 코드, 에러 메시지, 상태 코드
 */
export const githubApiError = (data: {
  appCode: string;
  error: string;
  statusCode: number;
}) => {
  logger.error(
    {
      appCode: data.appCode,
      error: data.error,
      statusCode: data.statusCode,
    },
    'GitHub API error occurred'
  );
};

