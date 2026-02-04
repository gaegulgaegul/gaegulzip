import { describe, it, expect, vi, beforeEach } from 'vitest';
import { createGitHubIssue } from '../../../src/modules/qna/github';
import { ExternalApiException, NotFoundException, BusinessException } from '../../../src/utils/errors';

// Octokit 인스턴스 모킹
const mockOctokit = {
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
} as any;

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

      const result = await createGitHubIssue(mockOctokit, {
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

    it('should throw ExternalApiException on 401 error', async () => {
      const error = new Error('Bad credentials') as any;
      error.status = 401;

      mockOctokit.rest.issues.create.mockRejectedValue(error);

      await expect(
        createGitHubIssue(mockOctokit, {
          owner: 'org',
          repo: 'repo',
          title: 'Title',
          body: 'Body',
          labels: ['qna'],
        })
      ).rejects.toThrow(ExternalApiException);
    });

    it('should throw NotFoundException on 404 error', async () => {
      const error = new Error('Not Found') as any;
      error.status = 404;

      mockOctokit.rest.issues.create.mockRejectedValue(error);

      await expect(
        createGitHubIssue(mockOctokit, {
          owner: 'org',
          repo: 'repo',
          title: 'Title',
          body: 'Body',
          labels: ['qna'],
        })
      ).rejects.toThrow(NotFoundException);
    });

    it('should throw BusinessException on 422 error', async () => {
      const error = new Error('Validation Failed') as any;
      error.status = 422;

      mockOctokit.rest.issues.create.mockRejectedValue(error);

      await expect(
        createGitHubIssue(mockOctokit, {
          owner: 'org',
          repo: 'repo',
          title: 'Title',
          body: 'Body',
          labels: ['qna'],
        })
      ).rejects.toThrow(BusinessException);
    });

    it('should throw ExternalApiException on 429 error', async () => {
      const error = new Error('API rate limit exceeded') as any;
      error.status = 429;

      mockOctokit.rest.issues.create.mockRejectedValue(error);

      await expect(
        createGitHubIssue(mockOctokit, {
          owner: 'org',
          repo: 'repo',
          title: 'Title',
          body: 'Body',
          labels: ['qna'],
        })
      ).rejects.toThrow(ExternalApiException);
    });

    it('should throw ExternalApiException on other errors', async () => {
      const error = new Error('Internal Server Error') as any;
      error.status = 500;

      mockOctokit.rest.issues.create.mockRejectedValue(error);

      await expect(
        createGitHubIssue(mockOctokit, {
          owner: 'org',
          repo: 'repo',
          title: 'Title',
          body: 'Body',
          labels: ['qna'],
        })
      ).rejects.toThrow(ExternalApiException);
    });
  });
});
