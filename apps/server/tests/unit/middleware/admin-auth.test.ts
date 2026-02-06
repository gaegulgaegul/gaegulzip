import { describe, it, expect, vi, beforeEach } from 'vitest';
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

// ─── Mocks ──────────────────────────────────────────────────────

vi.mock('../../../src/config/env', () => ({
  env: { ADMIN_SECRET: 'test-admin-secret-that-is-at-least-32-chars-long' },
}));

vi.mock('../../../src/utils/logger', () => ({
  logger: { debug: vi.fn(), info: vi.fn(), warn: vi.fn(), error: vi.fn() },
}));

// ─── Lazy imports (after mocks) ─────────────────────────────────

import { requireAdmin } from '../../../src/middleware/admin-auth';

// ─── Helpers ────────────────────────────────────────────────────

const ADMIN_SECRET = 'test-admin-secret-that-is-at-least-32-chars-long';

function makeToken(payload: object, expiresIn: string = '7d'): string {
  return jwt.sign(payload, ADMIN_SECRET, { expiresIn });
}

// ─── requireAdmin middleware ────────────────────────────────────

describe('requireAdmin middleware', () => {
  let req: Partial<Request>;
  let res: Partial<Response>;
  let next: NextFunction;

  beforeEach(() => {
    req = { headers: {} };
    res = {};
    next = vi.fn();
    vi.clearAllMocks();
  });

  it('should call next with UnauthorizedException when no Authorization header', async () => {
    await requireAdmin(req as Request, res as Response, next);

    expect(next).toHaveBeenCalledWith(
      expect.objectContaining({ statusCode: 401 })
    );
  });

  it('should call next with UnauthorizedException when Authorization is not Bearer', async () => {
    req.headers = { authorization: 'Basic abc123' };

    await requireAdmin(req as Request, res as Response, next);

    expect(next).toHaveBeenCalledWith(
      expect.objectContaining({ statusCode: 401 })
    );
  });

  it('should call next with UnauthorizedException for invalid token', async () => {
    req.headers = { authorization: 'Bearer invalid-token' };

    await requireAdmin(req as Request, res as Response, next);

    expect(next).toHaveBeenCalledWith(
      expect.objectContaining({ statusCode: 401 })
    );
  });

  it('should call next with UnauthorizedException for expired token', async () => {
    const token = jwt.sign({ role: 'admin' }, ADMIN_SECRET, { expiresIn: '-1s' });
    req.headers = { authorization: `Bearer ${token}` };

    await requireAdmin(req as Request, res as Response, next);

    expect(next).toHaveBeenCalledWith(
      expect.objectContaining({ statusCode: 401, code: 'EXPIRED_TOKEN' })
    );
  });

  it('should call next with UnauthorizedException when token signed with wrong secret', async () => {
    const token = jwt.sign({ role: 'admin' }, 'wrong-secret-key-that-is-32-chars!!');
    req.headers = { authorization: `Bearer ${token}` };

    await requireAdmin(req as Request, res as Response, next);

    expect(next).toHaveBeenCalledWith(
      expect.objectContaining({ statusCode: 401 })
    );
  });

  it('should call next() without error for valid admin token', async () => {
    const token = makeToken({ role: 'admin' });
    req.headers = { authorization: `Bearer ${token}` };

    await requireAdmin(req as Request, res as Response, next);

    expect(next).toHaveBeenCalledWith();
  });
});
