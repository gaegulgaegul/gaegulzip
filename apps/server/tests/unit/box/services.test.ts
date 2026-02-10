import { describe, it, expect, vi, beforeEach } from 'vitest';
import { createBox, joinBox, getBoxById } from '../../../src/modules/box/services';
import { db } from '../../../src/config/database';
import { NotFoundException, BusinessException } from '../../../src/utils/errors';

vi.mock('../../../src/config/database', () => ({
  db: {
    select: vi.fn(),
    insert: vi.fn(),
    update: vi.fn(),
    delete: vi.fn(),
    transaction: vi.fn(),
  },
}));

describe('Box Services', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('createBox', () => {
    it('should create box with valid data', async () => {
      const mockBox = {
        id: 1,
        name: 'CrossFit Seoul',
        region: '서울 강남구',
        description: 'Best gym',
        createdBy: 123,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      vi.mocked(db.insert).mockReturnValue({
        values: vi.fn().mockReturnValue({
          returning: vi.fn().mockResolvedValue([mockBox]),
        }),
      } as any);

      const result = await createBox({
        name: 'CrossFit Seoul',
        region: '서울 강남구',
        description: 'Best gym',
        createdBy: 123,
      });

      expect(result).toMatchObject({
        id: 1,
        name: 'CrossFit Seoul',
        description: 'Best gym',
        createdBy: 123,
      });
      expect(db.insert).toHaveBeenCalled();
    });
  });

  describe('joinBox', () => {
    it('should join box with valid boxId', async () => {
      const mockBox = { id: 1, name: 'CrossFit Seoul' };
      const mockMember = {
        id: 5,
        boxId: 1,
        userId: 42,
        role: 'member',
        joinedAt: new Date(),
      };

      // 박스 존재 확인
      vi.mocked(db.select).mockReturnValueOnce({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockReturnValue({
            limit: vi.fn().mockResolvedValue([mockBox]),
          }),
        }),
      } as any);

      // 같은 박스 멤버십 확인 (없음)
      vi.mocked(db.select).mockReturnValueOnce({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockReturnValue({
            limit: vi.fn().mockResolvedValue([]),
          }),
        }),
      } as any);

      // 다른 박스 멤버십 확인 (없음)
      vi.mocked(db.select).mockReturnValueOnce({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockReturnValue({
            limit: vi.fn().mockResolvedValue([]),
          }),
        }),
      } as any);

      // 멤버 삽입
      vi.mocked(db.insert).mockReturnValue({
        values: vi.fn().mockReturnValue({
          returning: vi.fn().mockResolvedValue([mockMember]),
        }),
      } as any);

      const result = await joinBox({ boxId: 1, userId: 42 });

      expect(result.membership).toMatchObject({
        boxId: 1,
        userId: 42,
        role: 'member',
      });
      expect(result.previousBoxId).toBeNull();
    });

    it('should throw NotFoundException for non-existent box', async () => {
      vi.mocked(db.select).mockReturnValueOnce({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockReturnValue({
            limit: vi.fn().mockResolvedValue([]),
          }),
        }),
      } as any);

      await expect(joinBox({ boxId: 999, userId: 42 }))
        .rejects.toThrow(NotFoundException);
    });

    it('should return existing membership when joining same box', async () => {
      const mockBox = { id: 1, name: 'CrossFit Seoul' };
      const existingMember = { id: 5, boxId: 1, userId: 42, role: 'member', joinedAt: new Date() };

      // 박스 존재 확인
      vi.mocked(db.select).mockReturnValueOnce({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockReturnValue({
            limit: vi.fn().mockResolvedValue([mockBox]),
          }),
        }),
      } as any);

      // 같은 박스에 이미 가입됨
      vi.mocked(db.select).mockReturnValueOnce({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockReturnValue({
            limit: vi.fn().mockResolvedValue([existingMember]),
          }),
        }),
      } as any);

      const result = await joinBox({ boxId: 1, userId: 42 });
      expect(result.membership).toMatchObject({ boxId: 1, userId: 42 });
      expect(result.previousBoxId).toBeNull();
    });

    it('should auto-leave previous box when joining new box', async () => {
      const newBox = { id: 2, name: 'CrossFit Pangyo' };
      const existingMembership = { id: 3, boxId: 1, userId: 42, role: 'member' };
      const newMember = { id: 6, boxId: 2, userId: 42, role: 'member', joinedAt: new Date() };

      // 박스 존재 확인
      vi.mocked(db.select).mockReturnValueOnce({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockReturnValue({
            limit: vi.fn().mockResolvedValue([newBox]),
          }),
        }),
      } as any);

      // 같은 박스 가입 여부 (다른 박스)
      vi.mocked(db.select).mockReturnValueOnce({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockReturnValue({
            limit: vi.fn().mockResolvedValue([]),
          }),
        }),
      } as any);

      // 기존 다른 박스 멤버십 확인
      vi.mocked(db.select).mockReturnValueOnce({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockReturnValue({
            limit: vi.fn().mockResolvedValue([existingMembership]),
          }),
        }),
      } as any);

      // 기존 멤버십 삭제
      vi.mocked(db.delete).mockReturnValue({
        where: vi.fn().mockResolvedValue(undefined),
      } as any);

      // 새 멤버 삽입
      vi.mocked(db.insert).mockReturnValue({
        values: vi.fn().mockReturnValue({
          returning: vi.fn().mockResolvedValue([newMember]),
        }),
      } as any);

      const result = await joinBox({ boxId: 2, userId: 42 });

      expect(result.membership).toMatchObject({ boxId: 2, userId: 42 });
      expect(result.previousBoxId).toBe(1);
      expect(db.delete).toHaveBeenCalled();
    });

    it('should set role to member by default', async () => {
      const mockBox = { id: 1, name: 'CrossFit Seoul' };
      const mockMember = {
        id: 5,
        boxId: 1,
        userId: 42,
        role: 'member',
        joinedAt: new Date(),
      };

      // 박스 존재 확인
      vi.mocked(db.select).mockReturnValueOnce({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockReturnValue({
            limit: vi.fn().mockResolvedValue([mockBox]),
          }),
        }),
      } as any);

      // 같은 박스 멤버십 확인 (없음)
      vi.mocked(db.select).mockReturnValueOnce({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockReturnValue({
            limit: vi.fn().mockResolvedValue([]),
          }),
        }),
      } as any);

      // 다른 박스 멤버십 확인 (없음)
      vi.mocked(db.select).mockReturnValueOnce({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockReturnValue({
            limit: vi.fn().mockResolvedValue([]),
          }),
        }),
      } as any);

      // 멤버 삽입
      vi.mocked(db.insert).mockReturnValue({
        values: vi.fn().mockReturnValue({
          returning: vi.fn().mockResolvedValue([mockMember]),
        }),
      } as any);

      const result = await joinBox({ boxId: 1, userId: 42 });
      expect(result.membership.role).toBe('member');
    });
  });

  describe('getBoxById', () => {
    it('should return box details by id', async () => {
      const mockResult = [
        {
          id: 1,
          name: 'CrossFit Seoul',
          region: '서울 강남구',
          description: 'Best gym',
          createdBy: 123,
          createdAt: new Date(),
          updatedAt: new Date(),
          memberCount: 0,
        },
      ];

      vi.mocked(db.select).mockReturnValue({
        from: vi.fn().mockReturnValue({
          leftJoin: vi.fn().mockReturnValue({
            where: vi.fn().mockReturnValue({
              groupBy: vi.fn().mockResolvedValue(mockResult),
            }),
          }),
        }),
      } as any);

      const result = await getBoxById(1);

      expect(result).toMatchObject({
        id: 1,
        name: 'CrossFit Seoul',
      });
    });

    it('should throw NotFoundException for non-existent id', async () => {
      vi.mocked(db.select).mockReturnValue({
        from: vi.fn().mockReturnValue({
          leftJoin: vi.fn().mockReturnValue({
            where: vi.fn().mockReturnValue({
              groupBy: vi.fn().mockResolvedValue([]),
            }),
          }),
        }),
      } as any);

      await expect(getBoxById(999)).rejects.toThrow(NotFoundException);
    });

    it('should include memberCount in response', async () => {
      const mockResult = [
        {
          id: 1,
          name: 'CrossFit Seoul',
          region: '서울 강남구',
          description: 'Best gym',
          createdBy: 123,
          createdAt: new Date(),
          updatedAt: new Date(),
          memberCount: 15,
        },
      ];

      vi.mocked(db.select).mockReturnValue({
        from: vi.fn().mockReturnValue({
          leftJoin: vi.fn().mockReturnValue({
            where: vi.fn().mockReturnValue({
              groupBy: vi.fn().mockResolvedValue(mockResult),
            }),
          }),
        }),
      } as any);

      const result = await getBoxById(1);

      expect(result).toHaveProperty('memberCount', 15);
    });
  });

  describe('searchBoxes', () => {
    it('should search boxes by name (ILIKE)', async () => {
      const { searchBoxes } = await import('../../../src/modules/box/services');
      const mockBoxes = [
        { id: 1, name: 'CrossFit Seoul', region: '서울 강남구', description: 'Best gym', memberCount: 15 },
        { id: 2, name: 'CrossFit Seoul South', region: '서울 서초구', description: null, memberCount: 8 },
      ];

      vi.mocked(db.select).mockReturnValue({
        from: vi.fn().mockReturnValue({
          leftJoin: vi.fn().mockReturnValue({
            where: vi.fn().mockReturnValue({
              groupBy: vi.fn().mockResolvedValue(mockBoxes),
            }),
          }),
        }),
      } as any);

      const result = await searchBoxes({ name: 'seoul' });

      expect(result).toHaveLength(2);
      expect(result[0]).toHaveProperty('memberCount');
    });

    it('should search boxes by region (ILIKE)', async () => {
      const { searchBoxes } = await import('../../../src/modules/box/services');
      const mockBoxes = [
        { id: 1, name: 'CrossFit Seoul', region: '서울 강남구', description: null, memberCount: 10 },
      ];

      vi.mocked(db.select).mockReturnValue({
        from: vi.fn().mockReturnValue({
          leftJoin: vi.fn().mockReturnValue({
            where: vi.fn().mockReturnValue({
              groupBy: vi.fn().mockResolvedValue(mockBoxes),
            }),
          }),
        }),
      } as any);

      const result = await searchBoxes({ region: '강남' });

      expect(result).toHaveLength(1);
      expect(result[0].region).toContain('강남');
    });

    it('should search boxes by name and region (AND)', async () => {
      const { searchBoxes } = await import('../../../src/modules/box/services');
      const mockBoxes = [
        { id: 1, name: 'CrossFit Seoul', region: '서울 강남구', description: null, memberCount: 12 },
      ];

      vi.mocked(db.select).mockReturnValue({
        from: vi.fn().mockReturnValue({
          leftJoin: vi.fn().mockReturnValue({
            where: vi.fn().mockReturnValue({
              groupBy: vi.fn().mockResolvedValue(mockBoxes),
            }),
          }),
        }),
      } as any);

      const result = await searchBoxes({ name: 'seoul', region: '강남' });

      expect(result).toHaveLength(1);
    });

    it('should return empty array when no query params', async () => {
      const { searchBoxes } = await import('../../../src/modules/box/services');

      const result = await searchBoxes({});

      expect(result).toEqual([]);
      expect(db.select).not.toHaveBeenCalled();
    });

    it('should include memberCount in search results', async () => {
      const { searchBoxes } = await import('../../../src/modules/box/services');
      const mockBoxes = [
        { id: 1, name: 'CrossFit Seoul', region: '서울 강남구', description: null, memberCount: 20 },
      ];

      vi.mocked(db.select).mockReturnValue({
        from: vi.fn().mockReturnValue({
          leftJoin: vi.fn().mockReturnValue({
            where: vi.fn().mockReturnValue({
              groupBy: vi.fn().mockResolvedValue(mockBoxes),
            }),
          }),
        }),
      } as any);

      const result = await searchBoxes({ name: 'seoul' });

      expect(result[0]).toHaveProperty('memberCount');
      expect(typeof result[0].memberCount).toBe('number');
    });

    it('should return empty array when no match', async () => {
      const { searchBoxes } = await import('../../../src/modules/box/services');

      vi.mocked(db.select).mockReturnValue({
        from: vi.fn().mockReturnValue({
          leftJoin: vi.fn().mockReturnValue({
            where: vi.fn().mockReturnValue({
              groupBy: vi.fn().mockResolvedValue([]),
            }),
          }),
        }),
      } as any);

      const result = await searchBoxes({ name: 'nonexistent' });

      expect(result).toEqual([]);
    });
  });

  describe('searchBoxes with keyword (통합 검색)', () => {
    it('should return empty array for empty keyword', async () => {
      const { searchBoxes } = await import('../../../src/modules/box/services');

      const result = await searchBoxes({ keyword: '' });

      expect(result).toEqual([]);
      expect(db.select).not.toHaveBeenCalled();
    });

    it('should search boxes by keyword in name (ILIKE OR)', async () => {
      const { searchBoxes } = await import('../../../src/modules/box/services');
      const mockBoxes = [
        { id: 1, name: 'CrossFit Seoul', region: '서울 강남구', description: null, memberCount: 15 },
      ];

      vi.mocked(db.select).mockReturnValue({
        from: vi.fn().mockReturnValue({
          leftJoin: vi.fn().mockReturnValue({
            where: vi.fn().mockReturnValue({
              groupBy: vi.fn().mockResolvedValue(mockBoxes),
            }),
          }),
        }),
      } as any);

      const result = await searchBoxes({ keyword: 'CrossFit' });

      expect(result).toHaveLength(1);
      expect(result[0].name).toContain('CrossFit');
    });

    it('should search boxes by keyword in region (ILIKE OR)', async () => {
      const { searchBoxes } = await import('../../../src/modules/box/services');
      const mockBoxes = [
        { id: 1, name: 'CrossFit Seoul', region: '서울 강남구', description: null, memberCount: 10 },
        { id: 2, name: 'Busan Box', region: '서울 서초구', description: null, memberCount: 5 },
      ];

      vi.mocked(db.select).mockReturnValue({
        from: vi.fn().mockReturnValue({
          leftJoin: vi.fn().mockReturnValue({
            where: vi.fn().mockReturnValue({
              groupBy: vi.fn().mockResolvedValue(mockBoxes),
            }),
          }),
        }),
      } as any);

      const result = await searchBoxes({ keyword: '서울' });

      expect(result).toHaveLength(2);
    });

    it('should be case insensitive', async () => {
      const { searchBoxes } = await import('../../../src/modules/box/services');
      const mockBoxes = [
        { id: 1, name: 'CrossFit Seoul', region: '서울 강남구', description: null, memberCount: 12 },
      ];

      vi.mocked(db.select).mockReturnValue({
        from: vi.fn().mockReturnValue({
          leftJoin: vi.fn().mockReturnValue({
            where: vi.fn().mockReturnValue({
              groupBy: vi.fn().mockResolvedValue(mockBoxes),
            }),
          }),
        }),
      } as any);

      const result = await searchBoxes({ keyword: 'crossfit' });

      expect(result).toHaveLength(1);
    });

    it('should include memberCount in results', async () => {
      const { searchBoxes } = await import('../../../src/modules/box/services');
      const mockBoxes = [
        { id: 1, name: 'CrossFit Seoul', region: '서울 강남구', description: null, memberCount: 42 },
      ];

      vi.mocked(db.select).mockReturnValue({
        from: vi.fn().mockReturnValue({
          leftJoin: vi.fn().mockReturnValue({
            where: vi.fn().mockReturnValue({
              groupBy: vi.fn().mockResolvedValue(mockBoxes),
            }),
          }),
        }),
      } as any);

      const result = await searchBoxes({ keyword: '강남' });

      expect(result[0]).toHaveProperty('memberCount', 42);
      expect(typeof result[0].memberCount).toBe('number');
    });

    it('should handle whitespace in keyword (trim)', async () => {
      const { searchBoxes } = await import('../../../src/modules/box/services');
      const mockBoxes = [
        { id: 1, name: 'CrossFit Seoul', region: '서울 강남구', description: null, memberCount: 8 },
      ];

      vi.mocked(db.select).mockReturnValue({
        from: vi.fn().mockReturnValue({
          leftJoin: vi.fn().mockReturnValue({
            where: vi.fn().mockReturnValue({
              groupBy: vi.fn().mockResolvedValue(mockBoxes),
            }),
          }),
        }),
      } as any);

      const result = await searchBoxes({ keyword: '  CrossFit  ' });

      expect(result).toHaveLength(1);
    });
  });

  describe('getCurrentBox', () => {
    it('should return current box when user has membership', async () => {
      const { getCurrentBox } = await import('../../../src/modules/box/services');
      const mockResult = [
        {
          id: 1,
          name: 'CrossFit Seoul',
          region: '서울 강남구',
          description: 'Best gym',
          memberCount: 15,
          joinedAt: new Date(),
        },
      ];

      vi.mocked(db.select).mockReturnValue({
        from: vi.fn().mockReturnValue({
          leftJoin: vi.fn().mockReturnValue({
            where: vi.fn().mockResolvedValue(mockResult),
          }),
        }),
      } as any);

      const result = await getCurrentBox(42);

      expect(result).not.toBeNull();
      expect(result).toHaveProperty('id', 1);
      expect(result).toHaveProperty('memberCount');
      expect(result).toHaveProperty('joinedAt');
    });

    it('should return null when user has no membership', async () => {
      const { getCurrentBox } = await import('../../../src/modules/box/services');

      vi.mocked(db.select).mockReturnValue({
        from: vi.fn().mockReturnValue({
          leftJoin: vi.fn().mockReturnValue({
            where: vi.fn().mockResolvedValue([]),
          }),
        }),
      } as any);

      const result = await getCurrentBox(999);

      expect(result).toBeNull();
    });

    it('should include memberCount in response', async () => {
      const { getCurrentBox } = await import('../../../src/modules/box/services');
      const mockResult = [
        {
          id: 1,
          name: 'CrossFit Seoul',
          region: '서울 강남구',
          description: null,
          memberCount: 25,
          joinedAt: new Date(),
        },
      ];

      vi.mocked(db.select).mockReturnValue({
        from: vi.fn().mockReturnValue({
          leftJoin: vi.fn().mockReturnValue({
            where: vi.fn().mockResolvedValue(mockResult),
          }),
        }),
      } as any);

      const result = await getCurrentBox(42);

      expect(result).toHaveProperty('memberCount', 25);
    });

    it('should include joinedAt timestamp', async () => {
      const { getCurrentBox } = await import('../../../src/modules/box/services');
      const joinedDate = new Date('2026-01-01');
      const mockResult = [
        {
          id: 1,
          name: 'CrossFit Seoul',
          region: '서울 강남구',
          description: null,
          memberCount: 10,
          joinedAt: joinedDate,
        },
      ];

      vi.mocked(db.select).mockReturnValue({
        from: vi.fn().mockReturnValue({
          leftJoin: vi.fn().mockReturnValue({
            where: vi.fn().mockResolvedValue(mockResult),
          }),
        }),
      } as any);

      const result = await getCurrentBox(42);

      expect(result).toHaveProperty('joinedAt', joinedDate);
    });
  });

  describe('getBoxMembers', () => {
    it('should list all members of a box', async () => {
      const { getBoxMembers } = await import('../../../src/modules/box/services');
      const mockMembers = [
        { id: 1, boxId: 1, userId: 42, role: 'member', joinedAt: new Date() },
        { id: 2, boxId: 1, userId: 43, role: 'member', joinedAt: new Date() },
      ];

      vi.mocked(db.select).mockReturnValue({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockResolvedValue(mockMembers),
        }),
      } as any);

      const result = await getBoxMembers(1);

      expect(result).toHaveLength(2);
      expect(result[0]).toHaveProperty('userId');
      expect(result[0]).toHaveProperty('role');
    });

    it('should include joinedAt timestamp', async () => {
      const { getBoxMembers } = await import('../../../src/modules/box/services');
      const joinedDate = new Date('2026-01-15');
      const mockMembers = [
        { id: 1, boxId: 1, userId: 42, role: 'member', joinedAt: joinedDate },
      ];

      vi.mocked(db.select).mockReturnValue({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockResolvedValue(mockMembers),
        }),
      } as any);

      const result = await getBoxMembers(1);

      expect(result[0]).toHaveProperty('joinedAt', joinedDate);
    });

    it('should return empty array for box with no members', async () => {
      const { getBoxMembers } = await import('../../../src/modules/box/services');

      vi.mocked(db.select).mockReturnValue({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockResolvedValue([]),
        }),
      } as any);

      const result = await getBoxMembers(999);

      expect(result).toEqual([]);
    });
  });

  describe('createBoxWithMembership (트랜잭션)', () => {
    it('should create box and add creator as member in transaction', async () => {
      const { createBoxWithMembership } = await import('../../../src/modules/box/services');
      const mockBox = {
        id: 1,
        name: 'CrossFit Seoul',
        region: '서울 강남구',
        description: 'Best gym',
        createdBy: 123,
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      const mockMember = {
        id: 10,
        boxId: 1,
        userId: 123,
        role: 'member',
        joinedAt: new Date(),
      };

      // Mock 트랜잭션
      const mockTx = {
        insert: vi.fn().mockReturnValue({
          values: vi.fn().mockReturnValue({
            returning: vi.fn()
              .mockResolvedValueOnce([mockBox])  // 박스 생성
              .mockResolvedValueOnce([mockMember]), // 멤버 등록
          }),
        }),
        select: vi.fn().mockReturnValue({
          from: vi.fn().mockReturnValue({
            where: vi.fn().mockReturnValue({
              limit: vi.fn().mockResolvedValue([]), // 기존 멤버십 없음
            }),
          }),
        }),
        delete: vi.fn(),
      };

      vi.mocked(db.transaction).mockImplementation(async (callback) => {
        return await callback(mockTx as any);
      });

      const result = await createBoxWithMembership({
        name: 'CrossFit Seoul',
        region: '서울 강남구',
        description: 'Best gym',
        createdBy: 123,
      });

      expect(result.box).toMatchObject({
        id: 1,
        name: 'CrossFit Seoul',
        createdBy: 123,
      });
      expect(result.membership).toMatchObject({
        boxId: 1,
        userId: 123,
        role: 'member',
      });
      expect(result.previousBoxId).toBeNull();
      expect(db.transaction).toHaveBeenCalled();
    });

    it('should remove previous membership when creating new box', async () => {
      const { createBoxWithMembership } = await import('../../../src/modules/box/services');
      const existingMembership = { id: 5, boxId: 3, userId: 123, role: 'member' };
      const mockBox = {
        id: 10,
        name: 'New Box',
        region: '서울 서초구',
        description: null,
        createdBy: 123,
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      const mockMember = {
        id: 15,
        boxId: 10,
        userId: 123,
        role: 'member',
        joinedAt: new Date(),
      };

      const mockTx = {
        insert: vi.fn().mockReturnValue({
          values: vi.fn().mockReturnValue({
            returning: vi.fn()
              .mockResolvedValueOnce([mockBox])
              .mockResolvedValueOnce([mockMember]),
          }),
        }),
        select: vi.fn().mockReturnValue({
          from: vi.fn().mockReturnValue({
            where: vi.fn().mockReturnValue({
              limit: vi.fn().mockResolvedValue([existingMembership]), // 기존 멤버십 있음
            }),
          }),
        }),
        delete: vi.fn().mockReturnValue({
          where: vi.fn().mockResolvedValue(undefined),
        }),
      };

      vi.mocked(db.transaction).mockImplementation(async (callback) => {
        return await callback(mockTx as any);
      });

      const result = await createBoxWithMembership({
        name: 'New Box',
        region: '서울 서초구',
        createdBy: 123,
      });

      expect(result.previousBoxId).toBe(3);
      expect(mockTx.delete).toHaveBeenCalled();
      expect(result.box.id).toBe(10);
      expect(result.membership.boxId).toBe(10);
    });

    it('should return previousBoxId correctly', async () => {
      const { createBoxWithMembership } = await import('../../../src/modules/box/services');
      const existingMembership = { id: 7, boxId: 42, userId: 999, role: 'member' };
      const mockBox = { id: 50, name: 'Test Box', region: 'Test Region', description: null, createdBy: 999, createdAt: new Date(), updatedAt: new Date() };
      const mockMember = { id: 20, boxId: 50, userId: 999, role: 'member', joinedAt: new Date() };

      const mockTx = {
        insert: vi.fn().mockReturnValue({
          values: vi.fn().mockReturnValue({
            returning: vi.fn()
              .mockResolvedValueOnce([mockBox])
              .mockResolvedValueOnce([mockMember]),
          }),
        }),
        select: vi.fn().mockReturnValue({
          from: vi.fn().mockReturnValue({
            where: vi.fn().mockReturnValue({
              limit: vi.fn().mockResolvedValue([existingMembership]),
            }),
          }),
        }),
        delete: vi.fn().mockReturnValue({
          where: vi.fn().mockResolvedValue(undefined),
        }),
      };

      vi.mocked(db.transaction).mockImplementation(async (callback) => {
        return await callback(mockTx as any);
      });

      const result = await createBoxWithMembership({
        name: 'Test Box',
        region: 'Test Region',
        createdBy: 999,
      });

      expect(result.previousBoxId).toBe(42);
    });
  });
});
