import { describe, it, expect, vi, beforeEach } from 'vitest';
import { createBox } from '../../../src/modules/box/services';
import { db } from '../../../src/config/database';

vi.mock('../../../src/config/database', () => ({
  db: {
    select: vi.fn(),
    insert: vi.fn(),
    update: vi.fn(),
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
});
