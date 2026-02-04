import { describe, it, expect, vi, beforeEach } from 'vitest';
import { registerWod, getWodsByDate, createProposal, approveProposal, rejectProposal, selectWod, getSelections } from '../../../src/modules/wod/services';
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

describe('WOD Services', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('registerWod', () => {
    it('should create Personal WOD when Base exists', async () => {
      const existingBase = {
        id: 100,
        boxId: 1,
        date: '2026-02-03',
        programData: {
          type: 'AMRAP',
          timeCap: 15,
          movements: [
            { name: 'Pull-up', reps: 10 },
            { name: 'Push-up', reps: 20 },
          ],
        },
        rawText: 'AMRAP 15min\n10 Pull-ups\n20 Push-ups',
        isBase: true,
        createdBy: 123,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      const mockPersonalWod = {
        id: 101,
        boxId: 1,
        date: '2026-02-03',
        programData: {
          type: 'AMRAP',
          timeCap: 15,
          movements: [
            { name: 'Pull-up', reps: 10 },
            { name: 'Push-up', reps: 20 },
          ],
        },
        rawText: 'AMRAP 15min\n10 Pull-ups\n20 Push-ups',
        isBase: false,
        createdBy: 456,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      // Base WOD 존재
      vi.mocked(db.select).mockReturnValueOnce({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockResolvedValue([existingBase]),
        }),
      } as any);

      // Personal WOD 삽입
      vi.mocked(db.insert).mockReturnValue({
        values: vi.fn().mockReturnValue({
          returning: vi.fn().mockResolvedValue([mockPersonalWod]),
        }),
      } as any);

      const result = await registerWod({
        boxId: 1,
        date: '2026-02-03',
        programData: {
          type: 'AMRAP',
          timeCap: 15,
          movements: [
            { name: 'Pull-up', reps: 10 },
            { name: 'Push-up', reps: 20 },
          ],
        },
        rawText: 'AMRAP 15min\n10 Pull-ups\n20 Push-ups',
        createdBy: 456,
      });

      expect(result.isBase).toBe(false);
      expect(result.comparisonResult).toBe('identical');
    });

    it('should auto-create proposal when Personal WOD differs from Base', async () => {
      const existingBase = {
        id: 100,
        boxId: 1,
        date: '2026-02-03',
        programData: {
          type: 'AMRAP',
          timeCap: 15,
          movements: [
            { name: 'Pull-up', reps: 10 },
            { name: 'Push-up', reps: 20 },
          ],
        },
        rawText: 'AMRAP 15min\n10 Pull-ups\n20 Push-ups',
        isBase: true,
        createdBy: 123,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      const mockPersonalWod = {
        id: 101,
        boxId: 1,
        date: '2026-02-03',
        programData: {
          type: 'ForTime',
          rounds: 5,
          movements: [
            { name: 'Deadlift', reps: 21 },
          ],
        },
        rawText: '5 rounds\n21 Deadlifts',
        isBase: false,
        createdBy: 456,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      // Base WOD 존재
      vi.mocked(db.select).mockReturnValueOnce({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockResolvedValue([existingBase]),
        }),
      } as any);

      // Personal WOD 삽입
      vi.mocked(db.insert).mockReturnValueOnce({
        values: vi.fn().mockReturnValue({
          returning: vi.fn().mockResolvedValue([mockPersonalWod]),
        }),
      } as any);

      // Proposal 생성
      vi.mocked(db.insert).mockReturnValueOnce({
        values: vi.fn().mockReturnValue({
          returning: vi.fn().mockResolvedValue([{
            id: 50,
            baseWodId: 100,
            proposedWodId: 101,
            status: 'pending',
            proposedAt: new Date(),
            resolvedAt: null,
            resolvedBy: null,
          }]),
        }),
      } as any);

      const result = await registerWod({
        boxId: 1,
        date: '2026-02-03',
        programData: {
          type: 'ForTime',
          rounds: 5,
          movements: [
            { name: 'Deadlift', reps: 21 },
          ],
        },
        rawText: '5 rounds\n21 Deadlifts',
        createdBy: 456,
      });

      expect(result.isBase).toBe(false);
      expect(result.comparisonResult).toBe('different');
      // Proposal이 자동 생성되었는지는 db.insert가 2번 호출되었는지로 검증
      expect(db.insert).toHaveBeenCalledTimes(2);
    });

    it('should not create proposal when Personal WOD is identical to Base', async () => {
      const existingBase = {
        id: 100,
        boxId: 1,
        date: '2026-02-03',
        programData: {
          type: 'AMRAP',
          timeCap: 15,
          movements: [
            { name: 'Pull-up', reps: 10 },
            { name: 'Push-up', reps: 20 },
          ],
        },
        rawText: 'AMRAP 15min\n10 Pull-ups\n20 Push-ups',
        isBase: true,
        createdBy: 123,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      const mockPersonalWod = {
        id: 101,
        boxId: 1,
        date: '2026-02-03',
        programData: {
          type: 'AMRAP',
          timeCap: 15,
          movements: [
            { name: 'Pull-up', reps: 10 },
            { name: 'Push-up', reps: 20 },
          ],
        },
        rawText: 'AMRAP 15min\n10 Pull-ups\n20 Push-ups',
        isBase: false,
        createdBy: 456,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      // Base WOD 존재
      vi.mocked(db.select).mockReturnValueOnce({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockResolvedValue([existingBase]),
        }),
      } as any);

      // Personal WOD 삽입
      vi.mocked(db.insert).mockReturnValue({
        values: vi.fn().mockReturnValue({
          returning: vi.fn().mockResolvedValue([mockPersonalWod]),
        }),
      } as any);

      const result = await registerWod({
        boxId: 1,
        date: '2026-02-03',
        programData: {
          type: 'AMRAP',
          timeCap: 15,
          movements: [
            { name: 'Pull-up', reps: 10 },
            { name: 'Push-up', reps: 20 },
          ],
        },
        rawText: 'AMRAP 15min\n10 Pull-ups\n20 Push-ups',
        createdBy: 456,
      });

      expect(result.isBase).toBe(false);
      expect(result.comparisonResult).toBe('identical');
      // Proposal이 생성되지 않았는지는 db.insert가 1번만 호출되었는지로 검증
      expect(db.insert).toHaveBeenCalledTimes(1);
    });

    it('should create Base WOD when first for date/box', async () => {
      const mockWod = {
        id: 100,
        boxId: 1,
        date: '2026-02-03',
        programData: {
          type: 'AMRAP',
          timeCap: 15,
          movements: [
            { name: 'Pull-up', reps: 10 },
            { name: 'Push-up', reps: 20 },
          ],
        },
        rawText: 'AMRAP 15min\n10 Pull-ups\n20 Push-ups',
        isBase: true,
        createdBy: 123,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      // Base WOD 존재 여부 확인 (없음)
      vi.mocked(db.select).mockReturnValueOnce({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockResolvedValue([]),
        }),
      } as any);

      // WOD 삽입
      vi.mocked(db.insert).mockReturnValue({
        values: vi.fn().mockReturnValue({
          returning: vi.fn().mockResolvedValue([mockWod]),
        }),
      } as any);

      const result = await registerWod({
        boxId: 1,
        date: '2026-02-03',
        programData: {
          type: 'AMRAP',
          timeCap: 15,
          movements: [
            { name: 'Pull-up', reps: 10 },
            { name: 'Push-up', reps: 20 },
          ],
        },
        rawText: 'AMRAP 15min\n10 Pull-ups\n20 Push-ups',
        createdBy: 123,
      });

      expect(result).toMatchObject({
        id: 100,
        isBase: true,
      });
      expect(result.comparisonResult).toBe('identical');
    });

    it('should auto-set isBase=true for first WOD', async () => {
      const mockWod = {
        id: 100,
        boxId: 1,
        date: '2026-02-03',
        programData: { type: 'AMRAP', timeCap: 15, movements: [{ name: 'Pull-up', reps: 10 }] },
        rawText: 'AMRAP 15min',
        isBase: true,
        createdBy: 123,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      // Base WOD 존재 여부 확인 (없음)
      vi.mocked(db.select).mockReturnValueOnce({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockResolvedValue([]),
        }),
      } as any);

      // WOD 삽입
      vi.mocked(db.insert).mockReturnValue({
        values: vi.fn().mockReturnValue({
          returning: vi.fn().mockResolvedValue([mockWod]),
        }),
      } as any);

      const result = await registerWod({
        boxId: 1,
        date: '2026-02-03',
        programData: { type: 'AMRAP', timeCap: 15, movements: [{ name: 'Pull-up', reps: 10 }] },
        rawText: 'AMRAP 15min',
        createdBy: 123,
      });

      expect(result.isBase).toBe(true);
    });

    it('should validate programData structure', async () => {
      const mockWod = {
        id: 100,
        boxId: 1,
        date: '2026-02-03',
        programData: {
          type: 'ForTime',
          rounds: 5,
          movements: [{ name: 'Deadlift', reps: 21, weight: 100, weightUnit: 'kg' }],
        },
        rawText: '5 rounds\n21 Deadlifts @ 100kg',
        isBase: true,
        createdBy: 123,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      vi.mocked(db.select).mockReturnValueOnce({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockResolvedValue([]),
        }),
      } as any);

      vi.mocked(db.insert).mockReturnValue({
        values: vi.fn().mockReturnValue({
          returning: vi.fn().mockResolvedValue([mockWod]),
        }),
      } as any);

      const result = await registerWod({
        boxId: 1,
        date: '2026-02-03',
        programData: {
          type: 'ForTime',
          rounds: 5,
          movements: [{ name: 'Deadlift', reps: 21, weight: 100, weightUnit: 'kg' }],
        },
        rawText: '5 rounds\n21 Deadlifts @ 100kg',
        createdBy: 123,
      });

      expect(result.programData).toHaveProperty('type', 'ForTime');
      expect(result.programData.movements[0]).toHaveProperty('weight', 100);
    });

    it('should store rawText as-is', async () => {
      const rawText = 'AMRAP 15min\n10 Pull-ups\n20 Push-ups\n30 Air Squats';
      const mockWod = {
        id: 100,
        boxId: 1,
        date: '2026-02-03',
        programData: { type: 'AMRAP', timeCap: 15, movements: [{ name: 'Pull-up', reps: 10 }] },
        rawText,
        isBase: true,
        createdBy: 123,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      vi.mocked(db.select).mockReturnValueOnce({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockResolvedValue([]),
        }),
      } as any);

      vi.mocked(db.insert).mockReturnValue({
        values: vi.fn().mockReturnValue({
          returning: vi.fn().mockResolvedValue([mockWod]),
        }),
      } as any);

      const result = await registerWod({
        boxId: 1,
        date: '2026-02-03',
        programData: { type: 'AMRAP', timeCap: 15, movements: [{ name: 'Pull-up', reps: 10 }] },
        rawText,
        createdBy: 123,
      });

      expect(result.rawText).toBe(rawText);
    });
  });

  describe('getWodsByDate', () => {
    it('should return Base WOD for given date/box', async () => {
      const mockBaseWod = {
        id: 100,
        boxId: 1,
        date: '2026-02-03',
        programData: { type: 'AMRAP', timeCap: 15, movements: [{ name: 'Pull-up', reps: 10 }] },
        rawText: 'AMRAP 15min',
        isBase: true,
        createdBy: 123,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      // Base WOD 조회
      vi.mocked(db.select).mockReturnValueOnce({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockResolvedValue([mockBaseWod]),
        }),
      } as any);

      // Personal WODs 조회
      vi.mocked(db.select).mockReturnValueOnce({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockResolvedValue([]),
        }),
      } as any);

      const result = await getWodsByDate({ boxId: 1, date: '2026-02-03' });

      expect(result.baseWod).not.toBeNull();
      expect(result.baseWod?.id).toBe(100);
      expect(result.baseWod?.isBase).toBe(true);
    });

    it('should return Personal WODs with comparisonResult', async () => {
      const mockBaseWod = {
        id: 100,
        boxId: 1,
        date: '2026-02-03',
        programData: {
          type: 'AMRAP',
          timeCap: 15,
          movements: [{ name: 'Pull-up', reps: 10 }],
        },
        rawText: 'AMRAP 15min',
        isBase: true,
        createdBy: 123,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      const mockPersonalWods = [
        {
          id: 101,
          boxId: 1,
          date: '2026-02-03',
          programData: {
            type: 'AMRAP',
            timeCap: 15,
            movements: [{ name: 'Pull-up', reps: 10 }],
          },
          rawText: 'AMRAP 15min (identical)',
          isBase: false,
          createdBy: 456,
          createdAt: new Date(),
          updatedAt: new Date(),
        },
        {
          id: 102,
          boxId: 1,
          date: '2026-02-03',
          programData: {
            type: 'ForTime',
            rounds: 5,
            movements: [{ name: 'Deadlift', reps: 21 }],
          },
          rawText: '5 rounds (different)',
          isBase: false,
          createdBy: 789,
          createdAt: new Date(),
          updatedAt: new Date(),
        },
      ];

      // Base WOD 조회
      vi.mocked(db.select).mockReturnValueOnce({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockResolvedValue([mockBaseWod]),
        }),
      } as any);

      // Personal WODs 조회
      vi.mocked(db.select).mockReturnValueOnce({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockResolvedValue(mockPersonalWods),
        }),
      } as any);

      const result = await getWodsByDate({ boxId: 1, date: '2026-02-03' });

      expect(result.baseWod).not.toBeNull();
      expect(result.personalWods).toHaveLength(2);
      expect(result.personalWods[0].comparisonResult).toBe('identical');
      expect(result.personalWods[1].comparisonResult).toBe('different');
    });

    it('should return empty personalWods when none exist', async () => {
      const mockBaseWod = {
        id: 100,
        boxId: 1,
        date: '2026-02-03',
        programData: { type: 'AMRAP', timeCap: 15, movements: [{ name: 'Pull-up', reps: 10 }] },
        rawText: 'AMRAP 15min',
        isBase: true,
        createdBy: 123,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      vi.mocked(db.select).mockReturnValueOnce({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockResolvedValue([mockBaseWod]),
        }),
      } as any);

      vi.mocked(db.select).mockReturnValueOnce({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockResolvedValue([]),
        }),
      } as any);

      const result = await getWodsByDate({ boxId: 1, date: '2026-02-03' });

      expect(result.personalWods).toEqual([]);
    });

    it('should return null baseWod when none exist', async () => {
      // Base WOD 조회 (없음)
      vi.mocked(db.select).mockReturnValueOnce({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockResolvedValue([]),
        }),
      } as any);

      // Personal WODs 조회
      vi.mocked(db.select).mockReturnValueOnce({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockResolvedValue([]),
        }),
      } as any);

      const result = await getWodsByDate({ boxId: 1, date: '2026-02-03' });

      expect(result.baseWod).toBeNull();
    });
  });

  describe('Proposal Services', () => {
    describe('createProposal', () => {
      it('should create proposal when Personal WOD differs from Base', async () => {
        const mockProposal = {
          id: 50,
          baseWodId: 100,
          proposedWodId: 101,
          status: 'pending',
          proposedAt: new Date(),
          resolvedAt: null,
          resolvedBy: null,
        };

        vi.mocked(db.insert).mockReturnValue({
          values: vi.fn().mockReturnValue({
            returning: vi.fn().mockResolvedValue([mockProposal]),
          }),
        } as any);

        const result = await createProposal({
          baseWodId: 100,
          proposedWodId: 101,
        });

        expect(result).toMatchObject({
          id: 50,
          baseWodId: 100,
          proposedWodId: 101,
          status: 'pending',
        });
      });

      it('should set status to pending by default', async () => {
        const mockProposal = {
          id: 50,
          baseWodId: 100,
          proposedWodId: 101,
          status: 'pending',
          proposedAt: new Date(),
          resolvedAt: null,
          resolvedBy: null,
        };

        vi.mocked(db.insert).mockReturnValue({
          values: vi.fn().mockReturnValue({
            returning: vi.fn().mockResolvedValue([mockProposal]),
          }),
        } as any);

        const result = await createProposal({
          baseWodId: 100,
          proposedWodId: 101,
        });

        expect(result.status).toBe('pending');
      });
    });

    describe('approveProposal', () => {
      it('should swap Base and Personal WOD on approval', async () => {
        const mockProposal = {
          id: 50,
          baseWodId: 100,
          proposedWodId: 101,
          status: 'pending',
          proposedAt: new Date(),
          resolvedAt: null,
          resolvedBy: null,
        };

        const mockBaseWod = {
          id: 100,
          boxId: 1,
          date: '2026-02-03',
          programData: { type: 'AMRAP', timeCap: 15, movements: [{ name: 'Pull-up', reps: 10 }] },
          rawText: 'AMRAP 15min',
          isBase: true,
          createdBy: 123,
          createdAt: new Date(),
          updatedAt: new Date(),
        };

        // Proposal 조회
        vi.mocked(db.select).mockReturnValueOnce({
          from: vi.fn().mockReturnValue({
            where: vi.fn().mockResolvedValue([mockProposal]),
          }),
        } as any);

        // Base WOD 조회
        vi.mocked(db.select).mockReturnValueOnce({
          from: vi.fn().mockReturnValue({
            where: vi.fn().mockResolvedValue([mockBaseWod]),
          }),
        } as any);

        // Transaction mock
        vi.mocked(db.transaction).mockImplementation(async (callback: any) => {
          const txMock = {
            update: vi.fn().mockReturnValue({
              set: vi.fn().mockReturnValue({
                where: vi.fn().mockResolvedValue(undefined),
              }),
            }),
          };
          return callback(txMock);
        });

        await approveProposal(50, 123);

        expect(db.transaction).toHaveBeenCalled();
      });

      it('should throw NotFoundException for invalid proposal id', async () => {
        vi.mocked(db.select).mockReturnValueOnce({
          from: vi.fn().mockReturnValue({
            where: vi.fn().mockResolvedValue([]),
          }),
        } as any);

        await expect(approveProposal(999, 123))
          .rejects.toThrow(NotFoundException);
      });

      it('should throw NotFoundException for invalid proposal id', async () => {
        vi.mocked(db.select).mockReturnValueOnce({
          from: vi.fn().mockReturnValue({
            where: vi.fn().mockResolvedValue([]),
          }),
        } as any);

        await expect(rejectProposal(999, 123))
          .rejects.toThrow(NotFoundException);
      });

      it('should throw BusinessException for non-creator rejection attempt', async () => {
        const mockProposal = {
          id: 50,
          baseWodId: 100,
          proposedWodId: 101,
          status: 'pending',
          proposedAt: new Date(),
          resolvedAt: null,
          resolvedBy: null,
        };

        const mockBaseWod = {
          id: 100,
          boxId: 1,
          date: '2026-02-03',
          programData: { type: 'AMRAP', timeCap: 15, movements: [{ name: 'Pull-up', reps: 10 }] },
          rawText: 'AMRAP 15min',
          isBase: true,
          createdBy: 123,
          createdAt: new Date(),
          updatedAt: new Date(),
        };

        // Proposal 조회
        vi.mocked(db.select).mockReturnValueOnce({
          from: vi.fn().mockReturnValue({
            where: vi.fn().mockResolvedValue([mockProposal]),
          }),
        } as any);

        // Base WOD 조회
        vi.mocked(db.select).mockReturnValueOnce({
          from: vi.fn().mockReturnValue({
            where: vi.fn().mockResolvedValue([mockBaseWod]),
          }),
        } as any);

        await expect(rejectProposal(50, 456))
          .rejects.toThrow(BusinessException);
      });

      it('should update proposal status to rejected', async () => {
        const mockProposal = {
          id: 50,
          baseWodId: 100,
          proposedWodId: 101,
          status: 'pending',
          proposedAt: new Date(),
          resolvedAt: null,
          resolvedBy: null,
        };

        const mockBaseWod = {
          id: 100,
          boxId: 1,
          date: '2026-02-03',
          programData: { type: 'AMRAP', timeCap: 15, movements: [{ name: 'Pull-up', reps: 10 }] },
          rawText: 'AMRAP 15min',
          isBase: true,
          createdBy: 123,
          createdAt: new Date(),
          updatedAt: new Date(),
        };

        // Proposal 조회
        vi.mocked(db.select).mockReturnValueOnce({
          from: vi.fn().mockReturnValue({
            where: vi.fn().mockResolvedValue([mockProposal]),
          }),
        } as any);

        // Base WOD 조회
        vi.mocked(db.select).mockReturnValueOnce({
          from: vi.fn().mockReturnValue({
            where: vi.fn().mockResolvedValue([mockBaseWod]),
          }),
        } as any);

        // Update mock
        vi.mocked(db.update).mockReturnValue({
          set: vi.fn().mockReturnValue({
            where: vi.fn().mockResolvedValue(undefined),
          }),
        } as any);

        await rejectProposal(50, 123);

        expect(db.update).toHaveBeenCalled();
      });
    });

    describe('rejectProposal', () => {
      it('should throw BusinessException for non-creator approval attempt', async () => {
        const mockProposal = {
          id: 50,
          baseWodId: 100,
          proposedWodId: 101,
          status: 'pending',
          proposedAt: new Date(),
          resolvedAt: null,
          resolvedBy: null,
        };

        const mockBaseWod = {
          id: 100,
          boxId: 1,
          date: '2026-02-03',
          programData: { type: 'AMRAP', timeCap: 15, movements: [{ name: 'Pull-up', reps: 10 }] },
          rawText: 'AMRAP 15min',
          isBase: true,
          createdBy: 123,
          createdAt: new Date(),
          updatedAt: new Date(),
        };

        // Proposal 조회
        vi.mocked(db.select).mockReturnValueOnce({
          from: vi.fn().mockReturnValue({
            where: vi.fn().mockResolvedValue([mockProposal]),
          }),
        } as any);

        // Base WOD 조회
        vi.mocked(db.select).mockReturnValueOnce({
          from: vi.fn().mockReturnValue({
            where: vi.fn().mockResolvedValue([mockBaseWod]),
          }),
        } as any);

        await expect(approveProposal(50, 456))
          .rejects.toThrow(BusinessException);
      });
    });
  });

  describe('WOD Selection Services', () => {
    describe('selectWod', () => {
      it('should create selection with snapshot', async () => {
        const mockWod = {
          id: 100,
          boxId: 1,
          date: '2026-02-03',
          programData: {
            type: 'AMRAP',
            timeCap: 15,
            movements: [{ name: 'Pull-up', reps: 10 }],
          },
          rawText: 'AMRAP 15min',
          isBase: true,
          createdBy: 123,
          createdAt: new Date(),
          updatedAt: new Date(),
        };

        const mockSelection = {
          id: 200,
          userId: 42,
          wodId: 100,
          boxId: 1,
          date: '2026-02-03',
          snapshotData: mockWod.programData,
          createdAt: new Date(),
        };

        // WOD 조회
        vi.mocked(db.select).mockReturnValueOnce({
          from: vi.fn().mockReturnValue({
            where: vi.fn().mockResolvedValue([mockWod]),
          }),
        } as any);

        // Selection 삽입
        vi.mocked(db.insert).mockReturnValue({
          values: vi.fn().mockReturnValue({
            onConflictDoUpdate: vi.fn().mockReturnValue({
              returning: vi.fn().mockResolvedValue([mockSelection]),
            }),
          }),
        } as any);

        const result = await selectWod({
          userId: 42,
          wodId: 100,
          boxId: 1,
          date: '2026-02-03',
        });

        expect(result).toMatchObject({
          id: 200,
          userId: 42,
          wodId: 100,
        });
      });

      it('should copy programData to snapshotData', async () => {
        const programData = {
          type: 'AMRAP',
          timeCap: 15,
          movements: [{ name: 'Pull-up', reps: 10 }],
        };

        const mockWod = {
          id: 100,
          boxId: 1,
          date: '2026-02-03',
          programData,
          rawText: 'AMRAP 15min',
          isBase: true,
          createdBy: 123,
          createdAt: new Date(),
          updatedAt: new Date(),
        };

        const mockSelection = {
          id: 200,
          userId: 42,
          wodId: 100,
          boxId: 1,
          date: '2026-02-03',
          snapshotData: programData,
          createdAt: new Date(),
        };

        vi.mocked(db.select).mockReturnValueOnce({
          from: vi.fn().mockReturnValue({
            where: vi.fn().mockResolvedValue([mockWod]),
          }),
        } as any);

        vi.mocked(db.insert).mockReturnValue({
          values: vi.fn().mockReturnValue({
            onConflictDoUpdate: vi.fn().mockReturnValue({
              returning: vi.fn().mockResolvedValue([mockSelection]),
            }),
          }),
        } as any);

        const result = await selectWod({
          userId: 42,
          wodId: 100,
          boxId: 1,
          date: '2026-02-03',
        });

        expect(result.snapshotData).toEqual(programData);
      });

      it('should throw NotFoundException for invalid WOD id', async () => {
        vi.mocked(db.select).mockReturnValueOnce({
          from: vi.fn().mockReturnValue({
            where: vi.fn().mockResolvedValue([]),
          }),
        } as any);

        await expect(selectWod({
          userId: 42,
          wodId: 999,
          boxId: 1,
          date: '2026-02-03',
        })).rejects.toThrow(NotFoundException);
      });
    });

    describe('getSelections', () => {
      it('should return selections by date range', async () => {
        const mockSelections = [
          {
            id: 200,
            userId: 42,
            wodId: 100,
            boxId: 1,
            date: '2026-02-03',
            snapshotData: { type: 'AMRAP', timeCap: 15, movements: [{ name: 'Pull-up', reps: 10 }] },
            createdAt: new Date(),
          },
          {
            id: 201,
            userId: 42,
            wodId: 102,
            boxId: 1,
            date: '2026-02-04',
            snapshotData: { type: 'ForTime', rounds: 5, movements: [{ name: 'Deadlift', reps: 21 }] },
            createdAt: new Date(),
          },
        ];

        vi.mocked(db.select).mockReturnValue({
          from: vi.fn().mockReturnValue({
            where: vi.fn().mockResolvedValue(mockSelections),
          }),
        } as any);

        const result = await getSelections({
          userId: 42,
          startDate: '2026-02-01',
          endDate: '2026-02-28',
        });

        expect(result).toHaveLength(2);
        expect(result[0].snapshotData).toHaveProperty('type');
      });

      it('should return all selections when no date range specified', async () => {
        const mockSelections = [
          {
            id: 200,
            userId: 42,
            wodId: 100,
            boxId: 1,
            date: '2026-02-03',
            snapshotData: { type: 'AMRAP', timeCap: 15, movements: [{ name: 'Pull-up', reps: 10 }] },
            createdAt: new Date(),
          },
        ];

        vi.mocked(db.select).mockReturnValue({
          from: vi.fn().mockReturnValue({
            where: vi.fn().mockResolvedValue(mockSelections),
          }),
        } as any);

        const result = await getSelections({
          userId: 42,
        });

        expect(result).toHaveLength(1);
      });
    });
  });
});
