import { describe, it, expect, vi, beforeEach } from 'vitest';
import { create } from '../../../src/modules/box/handlers';
import { Request, Response } from 'express';

vi.mock('../../../src/modules/box/services');

describe('Box Handlers', () => {
  let req: Partial<Request>;
  let res: Partial<Response>;

  beforeEach(() => {
    req = {
      body: {},
      user: undefined,
    };
    res = {
      json: vi.fn(),
      status: vi.fn().mockReturnThis(),
    };
    vi.clearAllMocks();
  });

  describe('create', () => {
    it('should set createdBy to authenticated user', async () => {
      const { createBox } = await import('../../../src/modules/box/services');

      const mockBox = {
        id: 1,
        name: 'CrossFit Seoul',
        description: null,
        createdBy: 42,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      vi.mocked(createBox).mockResolvedValue(mockBox);

      req.body = { name: 'CrossFit Seoul' };
      (req as any).user = { userId: 42, appId: 1 };

      await create(req as Request, res as Response);

      expect(createBox).toHaveBeenCalledWith(
        expect.objectContaining({ createdBy: 42 })
      );
      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith(mockBox);
    });
  });
});
