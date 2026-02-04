import { Octokit } from '@octokit/rest';
import { ExternalApiException, NotFoundException, BusinessException } from '../../utils/errors';
import { logger } from '../../utils/logger';

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
    const { data: issue } = await octokit.rest.issues.create({
      owner: params.owner,
      repo: params.repo,
      title: params.title,
      body: params.body,
      labels: params.labels,
    });

    return {
      issueNumber: issue.number,
      issueUrl: issue.html_url,
      createdAt: issue.created_at,
    };
  } catch (error: any) {
    // Octokit 에러는 error.status로 HTTP 상태코드 확인 가능
    const status = error.status || 500;
    const message = error.message || 'Unknown error';

    logger.error(
      {
        status,
        message,
        owner: params.owner,
        repo: params.repo,
        error: error.response?.data || error,
      },
      'GitHub API error'
    );

    // HTTP 상태코드별 처리
    if (status === 401 || status === 403) {
      // 인증 실패 또는 권한 부족 (서버 설정 오류)
      throw new ExternalApiException('GitHub', error);
    }

    if (status === 404) {
      // 레포지토리 없음 또는 접근 권한 없음
      throw new NotFoundException('GitHub Repository', `${params.owner}/${params.repo}`);
    }

    if (status === 422) {
      // 유효성 검증 실패 (제목 누락 등)
      throw new BusinessException(`GitHub validation error: ${message}`, 'GITHUB_VALIDATION_ERROR');
    }

    if (status === 429) {
      // Rate Limit 초과 (throttling 플러그인이 재시도하지만, 최종 실패 시)
      throw new ExternalApiException('GitHub', {
        message: 'GitHub API rate limit exceeded. Please try again later.',
      });
    }

    // 기타 에러
    throw new ExternalApiException('GitHub', error);
  }
};
