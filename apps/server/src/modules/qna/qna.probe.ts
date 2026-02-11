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
 * @param data - 레포 소유자, 레포 이름, 에러 메시지
 */
export const rateLimitWarning = (data: {
  owner: string;
  repo: string;
  message: string;
}) => {
  logger.warn(
    {
      owner: data.owner,
      repo: data.repo,
      message: data.message,
    },
    'GitHub API rate limit exceeded'
  );
};

/**
 * GitHub API 에러 (ERROR)
 * @param data - 레포 소유자, 레포 이름, 에러 메시지, 상태 코드, 응답 데이터
 */
export const githubApiError = (data: {
  owner: string;
  repo: string;
  error: string;
  statusCode: number;
  responseData?: unknown;
}) => {
  logger.error(
    {
      owner: data.owner,
      repo: data.repo,
      error: data.error,
      statusCode: data.statusCode,
      responseData: data.responseData,
    },
    'GitHub API error occurred'
  );
};

/**
 * QnA 설정 찾기 실패 (WARN)
 * @param data - 앱 코드, 찾지 못한 리소스 이름
 */
export const configNotFound = (data: {
  appCode: string;
  resource: string;
}) => {
  logger.warn(
    {
      appCode: data.appCode,
      resource: data.resource,
    },
    'QnA config not found'
  );
};

