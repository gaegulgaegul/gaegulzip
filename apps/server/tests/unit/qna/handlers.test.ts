import { describe, it, expect, vi, beforeEach } from 'vitest';
import { Request, Response } from 'express';
import { submitQuestion } from '../../../src/modules/qna/handlers';
import * as services from '../../../src/modules/qna/services';
import * as qnaProbe from '../../../src/modules/qna/qna.probe';

vi.mock('../../../src/modules/qna/services');
vi.mock('../../../src/modules/qna/qna.probe');

describe('QnA Handlers', () => {
  let mockReq: Partial<Request>;
  let mockRes: Partial<Response>;

  beforeEach(() => {
    mockReq = {
      body: {},
      user: undefined,
    };
    mockRes = {
      status: vi.fn().mockReturnThis(),
      json: vi.fn(),
    };
    vi.clearAllMocks();
  });

  describe('submitQuestion', () => {
    it('should submit question with authenticated user', async () => {
      mockReq.body = {
        appCode: 'wowa',
        title: '운동 강도 조절',
        body: '운동 강도를 어떻게 조절하나요?',
      };
      (mockReq as any).user = { userId: 123, appId: 1 };

      vi.mocked(services.createQuestion).mockResolvedValue({
        questionId: 1,
        issueNumber: 1347,
        issueUrl: 'https://github.com/gaegulzip-org/wowa-issues/issues/1347',
        createdAt: '2026-02-04T10:00:00Z',
      });

      await submitQuestion(mockReq as Request, mockRes as Response);

      expect(services.createQuestion).toHaveBeenCalledWith({
        appCode: 'wowa',
        userId: 123,
        title: '운동 강도 조절',
        body: '운동 강도를 어떻게 조절하나요?',
      });

      expect(qnaProbe.questionSubmitted).toHaveBeenCalledWith({
        questionId: 1,
        appCode: 'wowa',
        userId: 123,
        issueNumber: 1347,
      });

      expect(mockRes.status).toHaveBeenCalledWith(201);
      expect(mockRes.json).toHaveBeenCalledWith({
        questionId: 1,
        issueNumber: 1347,
        issueUrl: 'https://github.com/gaegulzip-org/wowa-issues/issues/1347',
        createdAt: '2026-02-04T10:00:00Z',
      });
    });

    it('should submit question with anonymous user', async () => {
      mockReq.body = {
        appCode: 'wowa',
        title: '질문',
        body: '내용',
      };
      (mockReq as any).user = undefined; // 비인증 사용자

      vi.mocked(services.createQuestion).mockResolvedValue({
        questionId: 2,
        issueNumber: 1348,
        issueUrl: 'https://github.com/gaegulzip-org/wowa-issues/issues/1348',
        createdAt: '2026-02-04T11:00:00Z',
      });

      await submitQuestion(mockReq as Request, mockRes as Response);

      expect(services.createQuestion).toHaveBeenCalledWith({
        appCode: 'wowa',
        userId: null, // 익명 사용자
        title: '질문',
        body: '내용',
      });

      expect(qnaProbe.questionSubmitted).toHaveBeenCalledWith({
        questionId: 2,
        appCode: 'wowa',
        userId: null,
        issueNumber: 1348,
      });

      expect(mockRes.status).toHaveBeenCalledWith(201);
    });

    it('should throw validation error for missing title', async () => {
      mockReq.body = {
        appCode: 'wowa',
        body: '내용',
      };

      await expect(
        submitQuestion(mockReq as Request, mockRes as Response)
      ).rejects.toThrow(); // Zod 에러
    });

    it('should throw validation error for missing body', async () => {
      mockReq.body = {
        appCode: 'wowa',
        title: '제목',
      };

      await expect(
        submitQuestion(mockReq as Request, mockRes as Response)
      ).rejects.toThrow(); // Zod 에러
    });

    it('should throw validation error for missing appCode', async () => {
      mockReq.body = {
        title: '제목',
        body: '내용',
      };

      await expect(
        submitQuestion(mockReq as Request, mockRes as Response)
      ).rejects.toThrow(); // Zod 에러
    });
  });
});
