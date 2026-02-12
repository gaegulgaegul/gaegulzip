import { Octokit } from '@octokit/rest';
import { RequestError } from '@octokit/request-error';
import { ExternalApiException, NotFoundException, BusinessException } from '../../utils/errors';
import { logger } from '../../utils/logger';
import * as qnaProbe from './qna.probe';

/**
 * GitHub Issue 생성 파라미터
 */
export interface CreateIssueParams {
  /** GitHub 레포지토리 소유자 (조직/사용자명) */
  owner: string;
  /** GitHub 레포지토리 이름 */
  repo: string;
  /** Issue 제목 */
  title: string;
  /** Issue 본문 */
  body: string;
  /** Issue 라벨 목록 */
  labels: string[];
}

/**
 * GitHub Issue 생성 결과
 */
export interface CreateIssueResult {
  /** GitHub Issue 번호 */
  issueNumber: number;
  /** GitHub Issue URL */
  issueUrl: string;
  /** 생성 시각 (ISO-8601) */
  createdAt: string;
}

/**
 * GitHub Issue를 생성합니다 (에러 처리 포함)
 * @param octokit - Octokit 인스턴스
 * @param params - Issue 생성 파라미터
 * @returns Issue 번호, URL, 생성 시각
 * @throws ExternalApiException - GitHub API 호출 실패 시 (401, 403, 429, 기타)
 * @throws NotFoundException - 레포지토리 찾을 수 없음 (404)
 * @throws BusinessException - GitHub 유효성 검증 실패 (422)
 */
export const createGitHubIssue = async (
  octokit: Octokit,
  params: CreateIssueParams
): Promise<CreateIssueResult> => {
  try {
    logger.debug({ owner: params.owner, repo: params.repo }, 'Creating GitHub issue');

    const { data: issue } = await octokit.rest.issues.create({
      owner: params.owner,
      repo: params.repo,
      title: params.title,
      body: params.body,
      labels: params.labels,
    });

    logger.debug({ issueNumber: issue.number }, 'GitHub issue created successfully');

    return {
      issueNumber: issue.number,
      issueUrl: issue.html_url,
      createdAt: issue.created_at,
    };
  } catch (error: unknown) {
    if (error instanceof RequestError) {
      const status = error.status;
      const message = error.message;

      qnaProbe.githubApiError({
        owner: params.owner,
        repo: params.repo,
        error: message,
        statusCode: status,
      });

      // HTTP 상태코드별 처리
      if (status === 401 || status === 403) {
        throw new ExternalApiException('GitHub', error);
      }

      if (status === 404) {
        throw new NotFoundException('GitHub Repository', `${params.owner}/${params.repo}`);
      }

      if (status === 422) {
        throw new BusinessException(`GitHub validation error: ${message}`, 'GITHUB_VALIDATION_ERROR');
      }

      if (status === 429) {
        qnaProbe.rateLimitExceeded({
          owner: params.owner,
          repo: params.repo,
          message,
        });
        throw new ExternalApiException('GitHub', {
          message: 'GitHub API rate limit exceeded. Please try again later.',
        });
      }

      throw new ExternalApiException('GitHub', error);
    }

    // 예상치 못한 에러
    const wrappedError = error instanceof Error ? error : new Error(String(error));
    throw new ExternalApiException('GitHub', wrappedError);
  }
};
