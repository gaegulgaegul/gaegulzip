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

describe('QnA Services', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('createQuestion', () => {
    it('should throw NotFoundException when app not found', async () => {
      // Mock DB - 앱 없음
      (db.select as any).mockReturnValue({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockResolvedValue([]),
        }),
      });

      await expect(
        createQuestion({
          appCode: 'invalid',
          userId: 123,
          title: '질문',
          body: '내용',
        })
      ).rejects.toThrow(NotFoundException);

      await expect(
        createQuestion({
          appCode: 'invalid',
          userId: 123,
          title: '질문',
          body: '내용',
        })
      ).rejects.toThrow('App not found: invalid');
    });

    it('should include [appCode] prefix in GitHub issue title', async () => {
      // Mock DB - apps 조회만 필요 (qnaConfig 조회 제거됨)
      (db.select as any).mockReturnValue({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockResolvedValue([{ id: 1, code: 'wowa' }]),
        }),
      });

      // Mock GitHub Issue 생성
      vi.mocked(github.createGitHubIssue).mockResolvedValue({
        issueNumber: 1347,
        issueUrl: 'https://github.com/gaegulzip-org/gaegulzip-issues/issues/1347',
        createdAt: '2026-02-04T10:00:00Z',
      });

      // Mock DB 삽입
      (db.insert as any).mockReturnValue({
        values: vi.fn().mockReturnValue({
          returning: vi.fn().mockResolvedValue([
            {
              id: 1,
              appId: 1,
              userId: 123,
              title: '질문',
              body: '내용',
              issueNumber: 1347,
              issueUrl: 'https://github.com/gaegulzip-org/gaegulzip-issues/issues/1347',
            },
          ]),
        }),
      });

      await createQuestion({
        appCode: 'wowa',
        userId: 123,
        title: '질문',
        body: '내용',
      });

      // Issue 제목에 [appCode] 접두사 포함 확인
      const issueTitle = vi.mocked(github.createGitHubIssue).mock.calls[0][1].title;
      expect(issueTitle).toBe('[wowa] 질문');
    });

    it('should create GitHub issue and save to database', async () => {
      // Mock DB - apps 조회
      (db.select as any).mockReturnValue({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockResolvedValue([{ id: 1, code: 'wowa' }]),
        }),
      });

      // Mock GitHub Issue 생성
      vi.mocked(github.createGitHubIssue).mockResolvedValue({
        issueNumber: 1347,
        issueUrl: 'https://github.com/gaegulzip-org/gaegulzip-issues/issues/1347',
        createdAt: '2026-02-04T10:00:00Z',
      });

      // Mock DB 삽입
      (db.insert as any).mockReturnValue({
        values: vi.fn().mockReturnValue({
          returning: vi.fn().mockResolvedValue([
            {
              id: 1,
              appId: 1,
              userId: 123,
              title: '질문',
              body: '내용',
              issueNumber: 1347,
              issueUrl: 'https://github.com/gaegulzip-org/gaegulzip-issues/issues/1347',
            },
          ]),
        }),
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
      // Mock DB - apps 조회
      (db.select as any).mockReturnValue({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockResolvedValue([{ id: 1, code: 'wowa' }]),
        }),
      });

      vi.mocked(github.createGitHubIssue).mockResolvedValue({
        issueNumber: 1348,
        issueUrl: 'https://github.com/gaegulzip-org/gaegulzip-issues/issues/1348',
        createdAt: '2026-02-04T11:00:00Z',
      });

      (db.insert as any).mockReturnValue({
        values: vi.fn().mockReturnValue({
          returning: vi.fn().mockResolvedValue([
            {
              id: 2,
              appId: 1,
              userId: null,
              title: '질문',
              body: '내용',
              issueNumber: 1348,
              issueUrl: 'https://github.com/gaegulzip-org/gaegulzip-issues/issues/1348',
            },
          ]),
        }),
      });

      const result = await createQuestion({
        appCode: 'wowa',
        userId: null,
        title: '질문',
        body: '내용',
      });

      expect(result).toBeDefined();
      expect(result.questionId).toBe(2);

      // Issue 본문에 "익명 사용자" 포함 확인
      const issueBody = vi.mocked(github.createGitHubIssue).mock.calls[0][1].body;
      expect(issueBody).toContain('익명 사용자');
    });

    it('should sanitize control characters from body', async () => {
      // Mock DB - apps 조회
      (db.select as any).mockReturnValue({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockResolvedValue([{ id: 1, code: 'wowa' }]),
        }),
      });

      vi.mocked(github.createGitHubIssue).mockResolvedValue({
        issueNumber: 1349,
        issueUrl: 'https://github.com/gaegulzip-org/gaegulzip-issues/issues/1349',
        createdAt: '2026-02-04T12:00:00Z',
      });

      (db.insert as any).mockReturnValue({
        values: vi.fn().mockReturnValue({
          returning: vi.fn().mockResolvedValue([
            {
              id: 3,
              appId: 1,
              userId: 123,
              title: '질문',
              body: '제어문자 포함 텍스트',
              issueNumber: 1349,
              issueUrl: 'https://github.com/gaegulzip-org/gaegulzip-issues/issues/1349',
            },
          ]),
        }),
      });

      await createQuestion({
        appCode: 'wowa',
        userId: 123,
        title: '질문',
        body: '제어문자\x00\x01\x02 포함 텍스트',
      });

      // Issue 본문에서 제어문자 제거 확인
      const issueBody = vi.mocked(github.createGitHubIssue).mock.calls[0][1].body;
      expect(issueBody).not.toContain('\x00');
      expect(issueBody).not.toContain('\x01');
      expect(issueBody).not.toContain('\x02');
      expect(issueBody).toContain('제어문자 포함 텍스트');
    });
  });
});
