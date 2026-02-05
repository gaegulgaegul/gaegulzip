import { db } from '../../config/database';
import { env } from '../../config/env';
import { qnaQuestions } from './schema';
import { apps } from '../auth/schema';
import { getOctokitInstance } from './octokit';
import { createGitHubIssue } from './github';
import { NotFoundException } from '../../utils/errors';
import { logger } from '../../utils/logger';
import { eq } from 'drizzle-orm';

/**
 * 질문 생성 파라미터
 */
export interface CreateQuestionParams {
  /** 앱 코드 */
  appCode: string;
  /** 사용자 ID (null = 익명 사용자) */
  userId: number | null;
  /** 질문 제목 */
  title: string;
  /** 질문 본문 */
  body: string;
}

/**
 * 질문 생성 결과
 */
export interface CreateQuestionResult {
  /** 질문 ID (로컬 DB) */
  questionId: number;
  /** GitHub Issue 번호 */
  issueNumber: number;
  /** GitHub Issue URL */
  issueUrl: string;
  /** 생성 시각 (ISO-8601) */
  createdAt: string;
}

/**
 * 사용자 입력을 새니타이징합니다 (제어 문자 제거, 탭과 개행은 유지)
 * @param input - 사용자 입력 문자열
 * @returns 새니타이징된 문자열
 */
const sanitizeInput = (input: string): string =>
  input.replace(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/g, '').trim();

/**
 * GitHub Issue 본문을 생성합니다 (질문 내용 + 메타데이터)
 * @param body - 질문 본문
 * @param metadata - 메타데이터 (userId, appCode, timestamp)
 * @returns Markdown 형식의 Issue 본문
 */
const buildIssueBody = (
  body: string,
  metadata: { userId: number | null; appCode: string; timestamp: string }
): string => {
  const sanitizedBody = sanitizeInput(body);

  const userInfo = metadata.userId
    ? `사용자 ID: ${metadata.userId}`
    : '익명 사용자';

  return [
    '## 질문 내용',
    '',
    sanitizedBody,
    '',
    '---',
    '',
    '## 메타데이터',
    '',
    `- ${userInfo}`,
    `- 앱: ${metadata.appCode}`,
    `- 작성 시각: ${metadata.timestamp}`,
    '',
    '*이 이슈는 자동 생성되었습니다.*',
  ].join('\n');
};

/**
 * 질문을 생성합니다 (GitHub Issue 생성 + DB 저장)
 * @param params - 질문 생성 파라미터
 * @returns 질문 ID, Issue 번호, Issue URL, 생성 시각
 * @throws NotFoundException - 앱을 찾을 수 없음
 * @throws ExternalApiException - GitHub API 호출 실패
 */
export const createQuestion = async (params: CreateQuestionParams): Promise<CreateQuestionResult> => {
  // 0. QnA GitHub 설정 확인
  if (!env.QNA_GITHUB_REPO_OWNER || !env.QNA_GITHUB_REPO_NAME) {
    throw new Error('QnA GitHub configuration is not set. Check QNA_GITHUB_* environment variables.');
  }

  // 1. 앱 조회
  const [app] = await db.select().from(apps).where(eq(apps.code, params.appCode));
  if (!app) {
    throw new NotFoundException('App', params.appCode);
  }

  // 2. Octokit 인스턴스 가져오기
  const octokit = getOctokitInstance();

  // 3. Issue 본문 생성
  const issueBody = buildIssueBody(params.body, {
    userId: params.userId,
    appCode: params.appCode,
    timestamp: new Date().toISOString(),
  });

  // 4. GitHub Issue 생성 (title도 새니타이징)
  const sanitizedTitle = sanitizeInput(params.title);
  const githubResult = await createGitHubIssue(octokit, {
    owner: env.QNA_GITHUB_REPO_OWNER,
    repo: env.QNA_GITHUB_REPO_NAME,
    title: `[${params.appCode}] ${sanitizedTitle}`,
    body: issueBody,
    labels: ['qna'],
  });

  // 5. DB에 질문 이력 저장
  let question;
  try {
    [question] = await db
      .insert(qnaQuestions)
      .values({
        appId: app.id,
        userId: params.userId,
        title: params.title,
        body: params.body,
        issueNumber: githubResult.issueNumber,
        issueUrl: githubResult.issueUrl,
      })
      .returning();
  } catch (error) {
    logger.error(
      {
        issueNumber: githubResult.issueNumber,
        issueUrl: githubResult.issueUrl,
        appCode: params.appCode,
        error,
      },
      'Failed to save question to DB after GitHub issue creation'
    );
    throw error;
  }

  return {
    questionId: question.id,
    issueNumber: githubResult.issueNumber,
    issueUrl: githubResult.issueUrl,
    createdAt: githubResult.createdAt,
  };
};
