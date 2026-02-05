import { describe, it, expect, vi, beforeEach } from 'vitest';
import { RequestError } from '@octokit/request-error';
import { createGitHubIssue } from '../../../src/modules/qna/github';
import { ExternalApiException, NotFoundException, BusinessException } from '../../../src/utils/errors';

/**
 * Octokit mock 타입 (필요한 메서드만 정의)
 */
interface MockOctokit {
  rest: {
    issues: {
      create: ReturnType<typeof vi.fn>;
    };
  };
  log: {
    warn: ReturnType<typeof vi.fn>;
    info: ReturnType<typeof vi.fn>;
    error: ReturnType<typeof vi.fn>;
  };
}

// Octokit 인스턴스 모킹
const mockOctokit: MockOctokit = {
  rest: {
    issues: {
      create: vi.fn(),
    },
  },
  log: {
    warn: vi.fn(),
    info: vi.fn(),
    error: vi.fn(),
  },
};

/**
 * HTTP 에러 헬퍼 (RequestError 생성)
 */
const createHttpError = (message: string, status: number): RequestError =>
  new RequestError(message, status, {
    request: { method: 'POST', url: '/repos/org/repo/issues', headers: {} },
  });

const defaultParams = {
  owner: 'org',
  repo: 'repo',
  title: 'Title',
  body: 'Body',
  labels: ['qna'],
};

describe('QnA GitHub', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('createGitHubIssue', () => {
    it('should create GitHub issue successfully', async () => {
      const mockIssueData = {
        number: 1347,
        html_url: 'https://github.com/org/repo/issues/1347',
        created_at: '2026-02-04T10:00:00Z',
      };

      mockOctokit.rest.issues.create.mockResolvedValue({
        data: mockIssueData,
      });

      const result = await createGitHubIssue(mockOctokit as any, {
        owner: 'gaegulzip-org',
        repo: 'wowa-issues',
        title: '운동 강도 조절',
        body: '운동 강도를 어떻게 조절하나요?',
        labels: ['qna', 'user-question'],
      });

      expect(result).toEqual({
        issueNumber: 1347,
        issueUrl: 'https://github.com/org/repo/issues/1347',
        createdAt: '2026-02-04T10:00:00Z',
      });

      expect(mockOctokit.rest.issues.create).toHaveBeenCalledWith({
        owner: 'gaegulzip-org',
        repo: 'wowa-issues',
        title: '운동 강도 조절',
        body: '운동 강도를 어떻게 조절하나요?',
        labels: ['qna', 'user-question'],
      });
    });

    it.each([
      { status: 401, message: 'Bad credentials', expectedException: ExternalApiException },
      { status: 403, message: 'Forbidden', expectedException: ExternalApiException },
      { status: 404, message: 'Not Found', expectedException: NotFoundException },
      { status: 422, message: 'Validation Failed', expectedException: BusinessException },
      { status: 429, message: 'API rate limit exceeded', expectedException: ExternalApiException },
      { status: 500, message: 'Internal Server Error', expectedException: ExternalApiException },
    ])('should throw $expectedException.name on $status error', async ({ status, message, expectedException }) => {
      const error = createHttpError(message, status);
      mockOctokit.rest.issues.create.mockRejectedValue(error);

      await expect(
        createGitHubIssue(mockOctokit as any, defaultParams)
      ).rejects.toThrow(expectedException);
    });
  });
});
