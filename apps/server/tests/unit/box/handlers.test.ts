import { describe, it, expect, vi, beforeEach } from 'vitest';
import { create, getMyBox, search, join, getById, getMembers } from '../../../src/modules/box/handlers';
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
    it('should create box with transaction and set createdBy to authenticated user', async () => {
      const { createBoxWithMembership } = await import('../../../src/modules/box/services');

      const mockResult = {
        box: {
          id: 1,
          name: 'CrossFit Seoul',
          region: '서울 강남구',
          description: null,
          createdBy: 42,
          createdAt: new Date(),
          updatedAt: new Date(),
        },
        membership: {
          id: 1,
          boxId: 1,
          userId: 42,
          role: 'member' as const,
          joinedAt: new Date(),
        },
        previousBoxId: null,
      };

      vi.mocked(createBoxWithMembership).mockResolvedValue(mockResult);

      req.body = { name: 'CrossFit Seoul', region: '서울 강남구' };
      (req as any).user = { userId: 42, appId: 1 };

      await create(req as Request, res as Response);

      expect(createBoxWithMembership).toHaveBeenCalledWith(
        expect.objectContaining({ createdBy: 42, region: '서울 강남구' })
      );
      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith(mockResult);
    });

    it('should create box with membership in transaction', async () => {
      const { createBoxWithMembership } = await import('../../../src/modules/box/services');

      const mockResult = {
        box: {
          id: 3,
          name: 'CrossFit Pangyo',
          region: '경기 성남시 분당구',
          description: 'Pangyo station exit 2',
          createdBy: 123,
          createdAt: new Date(),
          updatedAt: new Date(),
        },
        membership: {
          id: 10,
          boxId: 3,
          userId: 123,
          role: 'member' as const,
          joinedAt: new Date(),
        },
        previousBoxId: null,
      };

      vi.mocked(createBoxWithMembership).mockResolvedValue(mockResult);

      req.body = { name: 'CrossFit Pangyo', region: '경기 성남시 분당구', description: 'Pangyo station exit 2' };
      (req as any).user = { userId: 123, appId: 1 };

      await create(req as Request, res as Response);

      expect(createBoxWithMembership).toHaveBeenCalledWith(expect.objectContaining({
        name: 'CrossFit Pangyo',
        region: '경기 성남시 분당구',
        createdBy: 123,
      }));
      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith(mockResult);
    });
  });

  describe('getMyBox', () => {
    it('should return current box when user has membership', async () => {
      const { getCurrentBox } = await import('../../../src/modules/box/services');

      const mockBox = {
        id: 1,
        name: 'CrossFit Seoul',
        region: '서울 강남구',
        description: null,
        memberCount: 15,
        joinedAt: new Date(),
      };

      vi.mocked(getCurrentBox).mockResolvedValue(mockBox);

      (req as any).user = { userId: 42 };

      await getMyBox(req as Request, res as Response);

      expect(getCurrentBox).toHaveBeenCalledWith(42);
      expect(res.json).toHaveBeenCalledWith({ box: mockBox });
    });

    it('should return null when user has no membership', async () => {
      const { getCurrentBox } = await import('../../../src/modules/box/services');

      vi.mocked(getCurrentBox).mockResolvedValue(null);

      (req as any).user = { userId: 99 };

      await getMyBox(req as Request, res as Response);

      expect(res.json).toHaveBeenCalledWith({ box: null });
    });
  });

  describe('search', () => {
    it('should search boxes by keyword query param', async () => {
      const { searchBoxes } = await import('../../../src/modules/box/services');

      const mockBoxes = [
        { id: 1, name: 'CrossFit Seoul', region: '서울 강남구', description: null, memberCount: 10 },
      ];

      vi.mocked(searchBoxes).mockResolvedValue(mockBoxes);

      req.query = { keyword: '강남' };

      await search(req as Request, res as Response);

      expect(searchBoxes).toHaveBeenCalledWith({ keyword: '강남' });
      expect(res.json).toHaveBeenCalledWith({ boxes: mockBoxes });
    });

    it('should search boxes by name query param (backward compatibility)', async () => {
      const { searchBoxes } = await import('../../../src/modules/box/services');

      const mockBoxes = [
        { id: 1, name: 'CrossFit Seoul', region: '서울 강남구', description: null, memberCount: 10 },
      ];

      vi.mocked(searchBoxes).mockResolvedValue(mockBoxes);

      req.query = { name: 'seoul' };

      await search(req as Request, res as Response);

      expect(searchBoxes).toHaveBeenCalledWith({ name: 'seoul' });
      expect(res.json).toHaveBeenCalledWith({ boxes: mockBoxes });
    });

    it('should search boxes by region query param (backward compatibility)', async () => {
      const { searchBoxes } = await import('../../../src/modules/box/services');

      const mockBoxes = [
        { id: 1, name: 'CrossFit Seoul', region: '서울 강남구', description: null, memberCount: 10 },
      ];

      vi.mocked(searchBoxes).mockResolvedValue(mockBoxes);

      req.query = { region: '강남' };

      await search(req as Request, res as Response);

      expect(searchBoxes).toHaveBeenCalledWith({ region: '강남' });
      expect(res.json).toHaveBeenCalledWith({ boxes: mockBoxes });
    });

    it('should return empty array when no query params', async () => {
      const { searchBoxes } = await import('../../../src/modules/box/services');

      vi.mocked(searchBoxes).mockResolvedValue([]);

      req.query = {};

      await search(req as Request, res as Response);

      expect(searchBoxes).toHaveBeenCalledWith({});
      expect(res.json).toHaveBeenCalledWith({ boxes: [] });
    });
  });

  describe('join', () => {
    it('should join box with valid boxId', async () => {
      const { joinBox } = await import('../../../src/modules/box/services');

      const mockResult = {
        membership: {
          id: 5,
          boxId: 1,
          userId: 42,
          role: 'member',
          joinedAt: new Date(),
        },
        previousBoxId: null,
      };

      vi.mocked(joinBox).mockResolvedValue(mockResult);

      req.params = { boxId: '1' };
      (req as any).user = { userId: 42 };

      await join(req as Request, res as Response);

      expect(joinBox).toHaveBeenCalledWith({ boxId: 1, userId: 42 });
      expect(res.json).toHaveBeenCalledWith(mockResult);
    });

    it('should include previousBoxId when switching boxes', async () => {
      const { joinBox } = await import('../../../src/modules/box/services');

      const mockResult = {
        membership: {
          id: 6,
          boxId: 2,
          userId: 42,
          role: 'member',
          joinedAt: new Date(),
        },
        previousBoxId: 1,
      };

      vi.mocked(joinBox).mockResolvedValue(mockResult);

      req.params = { boxId: '2' };
      (req as any).user = { userId: 42 };

      await join(req as Request, res as Response);

      expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
        previousBoxId: 1,
      }));
    });
  });

  describe('getById', () => {
    it('should return box details by id', async () => {
      const { getBoxById } = await import('../../../src/modules/box/services');

      const mockBox = {
        id: 1,
        name: 'CrossFit Seoul',
        region: '서울 강남구',
        description: 'Best gym',
        createdBy: 123,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      vi.mocked(getBoxById).mockResolvedValue(mockBox);

      req.params = { boxId: '1' };

      await getById(req as Request, res as Response);

      expect(getBoxById).toHaveBeenCalledWith(1);
      expect(res.json).toHaveBeenCalledWith({ box: mockBox });
    });

    it('should include memberCount in response', async () => {
      const { getBoxById } = await import('../../../src/modules/box/services');

      const mockBox = {
        id: 1,
        name: 'CrossFit Seoul',
        region: '서울 강남구',
        description: 'Best gym',
        memberCount: 15,
        createdBy: 123,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      vi.mocked(getBoxById).mockResolvedValue(mockBox as any);

      req.params = { boxId: '1' };

      await getById(req as Request, res as Response);

      expect(res.json).toHaveBeenCalledWith({
        box: expect.objectContaining({
          memberCount: 15,
        }),
      });
    });
  });

  describe('getMembers', () => {
    it('should list all members of a box', async () => {
      const { getBoxMembers } = await import('../../../src/modules/box/services');

      const mockMembers = [
        { id: 1, boxId: 1, userId: 42, role: 'member', joinedAt: new Date() },
        { id: 2, boxId: 1, userId: 43, role: 'member', joinedAt: new Date() },
      ];

      vi.mocked(getBoxMembers).mockResolvedValue(mockMembers);

      req.params = { boxId: '1' };

      await getMembers(req as Request, res as Response);

      expect(getBoxMembers).toHaveBeenCalledWith(1);
      expect(res.json).toHaveBeenCalledWith({ members: mockMembers, totalCount: 2 });
    });
  });
});
