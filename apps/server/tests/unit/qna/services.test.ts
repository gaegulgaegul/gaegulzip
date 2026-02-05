import { describe, it, expect, vi, beforeEach } from 'vitest';
import { createQuestion } from '../../../src/modules/qna/services';
import { NotFoundException } from '../../../src/utils/errors';
import * as github from '../../../src/modules/qna/github';
import { db } from '../../../src/config/database';

// Mock 설정
vi.mock('../../../src/config/database', () => ({
  db: {
    select: vi.fn(),
    insert: vi.fn(),
  },
}));

vi.mock('../../../src/modules/qna/github');
vi.mock('../../../src/modules/qna/octokit');

/**
 * DB select mock 헬퍼
 */
const mockDbSelect = (result: unknown[]) => {
  vi.mocked(db.select).mockReturnValue({
    from: vi.fn().mockReturnValue({
      where: vi.fn().mockResolvedValue(result),
    }),
  } as any);
};

/**
 * GitHub Issue 생성 mock 헬퍼
 */
const mockGitHubIssue = (issueNumber: number, issueUrl: string, createdAt: string) => {
  vi.mocked(github.createGitHubIssue).mockResolvedValue({
    issueNumber,
    issueUrl,
    createdAt,
  });
};

/**
 * DB insert mock 헬퍼
 */
const mockDbInsert = (result: Record<string, unknown>) => {
  vi.mocked(db.insert).mockReturnValue({
    values: vi.fn().mockReturnValue({
      returning: vi.fn().mockResolvedValue([result]),
    }),
  } as any);
};

describe('QnA Services', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('createQuestion', () => {
    it('should throw NotFoundException when app not found', async () => {
      mockDbSelect([]);

      await expect(
        createQuestion({
          appCode: 'invalid',
          userId: 123,
          title: '질문',
          body: '내용',
        })
      ).rejects.toThrow(new NotFoundException('App', 'invalid'));
    });

    it('should include [appCode] prefix in GitHub issue title', async () => {
      mockDbSelect([{ id: 1, code: 'wowa' }]);
      mockGitHubIssue(1347, 'https://github.com/gaegulzip-org/gaegulzip-issues/issues/1347', '2026-02-04T10:00:00Z');
      mockDbInsert({
        id: 1,
        appId: 1,
        userId: 123,
        title: '질문',
        body: '내용',
        issueNumber: 1347,
        issueUrl: 'https://github.com/gaegulzip-org/gaegulzip-issues/issues/1347',
      });

      await createQuestion({
        appCode: 'wowa',
        userId: 123,
        title: '질문',
        body: '내용',
      });

      const issueTitle = vi.mocked(github.createGitHubIssue).mock.calls[0][1].title;
      expect(issueTitle).toBe('[wowa] 질문');
    });

    it('should create GitHub issue and save to database', async () => {
      mockDbSelect([{ id: 1, code: 'wowa' }]);
      mockGitHubIssue(1347, 'https://github.com/gaegulzip-org/gaegulzip-issues/issues/1347', '2026-02-04T10:00:00Z');
      mockDbInsert({
        id: 1,
        appId: 1,
        userId: 123,
        title: '질문',
        body: '내용',
        issueNumber: 1347,
        issueUrl: 'https://github.com/gaegulzip-org/gaegulzip-issues/issues/1347',
      });

      const result = await createQuestion({
        appCode: 'wowa',
        userId: 123,
        title: '질문',
        body: '내용',
      });

      expect(result).toEqual({
        questionId: 1,
        issueNumber: 1347,
        issueUrl: 'https://github.com/gaegulzip-org/gaegulzip-issues/issues/1347',
        createdAt: '2026-02-04T10:00:00Z',
      });

      expect(github.createGitHubIssue).toHaveBeenCalled();
    });

    it('should handle anonymous user (userId null)', async () => {
      mockDbSelect([{ id: 1, code: 'wowa' }]);
      mockGitHubIssue(1348, 'https://github.com/gaegulzip-org/gaegulzip-issues/issues/1348', '2026-02-04T11:00:00Z');
      mockDbInsert({
        id: 2,
        appId: 1,
        userId: null,
        title: '질문',
        body: '내용',
        issueNumber: 1348,
        issueUrl: 'https://github.com/gaegulzip-org/gaegulzip-issues/issues/1348',
      });

      const result = await createQuestion({
        appCode: 'wowa',
        userId: null,
        title: '질문',
        body: '내용',
      });

      expect(result).toBeDefined();
      expect(result.questionId).toBe(2);

      const issueBody = vi.mocked(github.createGitHubIssue).mock.calls[0][1].body;
      expect(issueBody).toContain('익명 사용자');
    });

    it('should sanitize control characters from body', async () => {
      mockDbSelect([{ id: 1, code: 'wowa' }]);
      mockGitHubIssue(1349, 'https://github.com/gaegulzip-org/gaegulzip-issues/issues/1349', '2026-02-04T12:00:00Z');
      mockDbInsert({
        id: 3,
        appId: 1,
        userId: 123,
        title: '질문',
        body: '제어문자 포함 텍스트',
        issueNumber: 1349,
        issueUrl: 'https://github.com/gaegulzip-org/gaegulzip-issues/issues/1349',
      });

      await createQuestion({
        appCode: 'wowa',
        userId: 123,
        title: '질문',
        body: '제어문자\x00\x01\x02 포함 텍스트',
      });

      const issueBody = vi.mocked(github.createGitHubIssue).mock.calls[0][1].body;
      expect(issueBody).not.toContain('\x00');
      expect(issueBody).not.toContain('\x01');
      expect(issueBody).not.toContain('\x02');
      expect(issueBody).toContain('제어문자 포함 텍스트');
    });
  });
});
