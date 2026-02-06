import { describe, it, expect, vi, beforeEach } from 'vitest';
import { Request, Response } from 'express';
import jwt from 'jsonwebtoken';

// ─── Constants ──────────────────────────────────────────────────

const ADMIN_SECRET = 'test-admin-secret-that-is-at-least-32-chars-long';
// 실제 비밀번호 '921221'의 SHA-256 해시
const REAL_PASSWORD = '921221';

// ─── Mocks ──────────────────────────────────────────────────────

vi.mock('../../../src/config/env', () => ({
  env: {
    ADMIN_SECRET: 'test-admin-secret-that-is-at-least-32-chars-long',
  },
}));

vi.mock('../../../src/utils/logger', () => ({
  logger: { debug: vi.fn(), info: vi.fn(), warn: vi.fn(), error: vi.fn() },
}));

// ─── Lazy imports (after mocks) ─────────────────────────────────

import { adminLogin } from '../../../src/middleware/admin-auth';

// ─── adminLogin handler ─────────────────────────────────────────

describe('adminLogin handler', () => {
  let req: Partial<Request>;
  let res: Partial<Response>;

  beforeEach(() => {
    req = { body: {} };
    res = {
      status: vi.fn().mockReturnThis(),
      json: vi.fn(),
    };
    vi.clearAllMocks();
  });

  it('should throw ValidationException when password is missing', async () => {
    req.body = {};

    await expect(adminLogin(req as Request, res as Response, vi.fn())).rejects.toThrow(
      '비밀번호를 입력해주세요.'
    );
  });

  it('should throw UnauthorizedException for wrong password', async () => {
    req.body = { password: 'wrong-password' };

    await expect(adminLogin(req as Request, res as Response, vi.fn())).rejects.toThrow(
      '비밀번호가 올바르지 않습니다.'
    );
  });

  it('should return JWT token with 7-day expiry for correct password', async () => {
    req.body = { password: REAL_PASSWORD };

    await adminLogin(req as Request, res as Response, vi.fn());

    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ token: expect.any(String) })
    );

    // Verify the token is valid and has correct payload/expiry
    const { token } = (res.json as any).mock.calls[0][0];
    const decoded = jwt.verify(token, ADMIN_SECRET) as any;
    expect(decoded.role).toBe('admin');

    // Token should expire in ~7 days (allow 10s tolerance)
    const expectedExp = Math.floor(Date.now() / 1000) + 60 * 60 * 24 * 7;
    expect(decoded.exp).toBeGreaterThan(expectedExp - 10);
    expect(decoded.exp).toBeLessThanOrEqual(expectedExp + 10);
  });
});
