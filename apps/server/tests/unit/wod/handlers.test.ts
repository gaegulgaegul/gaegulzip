import { describe, it, expect, vi, beforeEach } from 'vitest';
import {
  registerWodHandler,
  getWodsByDateHandler,
  createProposalHandler,
  getProposalsHandler,
  approveProposalHandler,
  rejectProposalHandler,
  selectWodHandler,
  getSelectionsHandler,
} from '../../../src/modules/wod/handlers';
import { Request, Response } from 'express';

vi.mock('../../../src/modules/wod/services');
vi.mock('../../../src/modules/wod/validators', async (importOriginal) => {
  const actual = await importOriginal<typeof import('../../../src/modules/wod/validators')>();
  return {
    ...actual,
  };
});

describe('WOD Handlers', () => {
  let req: Partial<Request>;
  let res: Partial<Response>;

  beforeEach(() => {
    req = {
      body: {},
      params: {},
      query: {},
      user: undefined,
    };
    res = {
      json: vi.fn(),
      status: vi.fn().mockReturnThis(),
    };
    vi.clearAllMocks();
  });

  // ─── Phase 2: WOD Handlers ─────────────────────────

  describe('registerWodHandler', () => {
    it('should register WOD with valid data', async () => {
      const { registerWod } = await import('../../../src/modules/wod/services');

      const mockWod = {
        id: 100,
        boxId: 1,
        date: '2026-02-03',
        programData: {
          type: 'AMRAP',
          timeCap: 15,
          movements: [{ name: 'Pull-up', reps: 10 }],
        },
        rawText: 'AMRAP 15min\n10 Pull-ups',
        isBase: true,
        createdBy: 42,
        createdAt: new Date(),
        updatedAt: new Date(),
        comparisonResult: 'identical',
      };

      vi.mocked(registerWod).mockResolvedValue(mockWod as any);

      req.body = {
        boxId: 1,
        date: '2026-02-03',
        programData: {
          type: 'AMRAP',
          timeCap: 15,
          movements: [{ name: 'Pull-up', reps: 10 }],
        },
        rawText: 'AMRAP 15min\n10 Pull-ups',
      };
      (req as any).user = { userId: 42, appId: 1 };

      await registerWodHandler(req as Request, res as Response, vi.fn());

      expect(registerWod).toHaveBeenCalledWith(
        expect.objectContaining({ createdBy: 42, boxId: 1 })
      );
      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith(mockWod);
    });

    it('should auto-set isBase=true for first WOD', async () => {
      const { registerWod } = await import('../../../src/modules/wod/services');

      const mockWod = {
        id: 100,
        boxId: 1,
        date: '2026-02-03',
        programData: {
          type: 'ForTime',
          rounds: 3,
          movements: [{ name: 'Deadlift', reps: 21 }],
        },
        rawText: '3 rounds\n21 Deadlifts',
        isBase: true,
        createdBy: 42,
        createdAt: new Date(),
        updatedAt: new Date(),
        comparisonResult: 'identical',
      };

      vi.mocked(registerWod).mockResolvedValue(mockWod as any);

      req.body = {
        boxId: 1,
        date: '2026-02-03',
        programData: {
          type: 'ForTime',
          rounds: 3,
          movements: [{ name: 'Deadlift', reps: 21 }],
        },
        rawText: '3 rounds\n21 Deadlifts',
      };
      (req as any).user = { userId: 42, appId: 1 };

      await registerWodHandler(req as Request, res as Response, vi.fn());

      expect(res.status).toHaveBeenCalledWith(201);
      const jsonArg = vi.mocked(res.json)!.mock.calls[0][0] as any;
      expect(jsonArg.isBase).toBe(true);
    });

    it('should throw ValidationException for invalid programData', async () => {
      req.body = {
        boxId: 1,
        date: '2026-02-03',
        programData: { type: 'AMRAP' },
        rawText: 'AMRAP 15min',
      };
      (req as any).user = { userId: 42, appId: 1 };

      // Zod validation에서 movements 필드 누락으로 실패
      await expect(
        registerWodHandler(req as Request, res as Response, vi.fn())
      ).rejects.toThrow();
    });
  });

  describe('getWodsByDateHandler', () => {
    it('should return Base and Personal WODs for date', async () => {
      const { getWodsByDate } = await import('../../../src/modules/wod/services');

      const mockResult = {
        baseWod: {
          id: 100,
          boxId: 1,
          date: '2026-02-03',
          programData: { type: 'AMRAP', timeCap: 15, movements: [{ name: 'Pull-up', reps: 10 }] },
          rawText: 'AMRAP 15min',
          isBase: true,
          createdBy: 123,
          createdAt: new Date(),
          updatedAt: new Date(),
        },
        personalWods: [
          {
            id: 101,
            boxId: 1,
            date: '2026-02-03',
            programData: { type: 'ForTime', rounds: 5, movements: [{ name: 'Deadlift', reps: 21 }] },
            rawText: '5 rounds',
            isBase: false,
            createdBy: 456,
            createdAt: new Date(),
            updatedAt: new Date(),
            comparisonResult: 'different',
          },
        ],
      };

      vi.mocked(getWodsByDate).mockResolvedValue(mockResult as any);

      req.params = { boxId: '1', date: '2026-02-03' };

      await getWodsByDateHandler(req as Request, res as Response, vi.fn());

      expect(getWodsByDate).toHaveBeenCalledWith({ boxId: 1, date: '2026-02-03' });
      expect(res.json).toHaveBeenCalledWith(mockResult);
    });

    it('should return empty arrays when no WODs', async () => {
      const { getWodsByDate } = await import('../../../src/modules/wod/services');

      const mockResult = {
        baseWod: null,
        personalWods: [],
      };

      vi.mocked(getWodsByDate).mockResolvedValue(mockResult);

      req.params = { boxId: '1', date: '2026-02-03' };

      await getWodsByDateHandler(req as Request, res as Response, vi.fn());

      expect(res.json).toHaveBeenCalledWith({
        baseWod: null,
        personalWods: [],
      });
    });
  });

  // ─── Phase 3: Proposal Handlers ────────────────────

  describe('createProposalHandler', () => {
    it('should create proposal with valid data', async () => {
      const { createProposal } = await import('../../../src/modules/wod/services');

      const mockProposal = {
        id: 50,
        baseWodId: 100,
        proposedWodId: 101,
        status: 'pending',
        proposedAt: new Date(),
        resolvedAt: null,
        resolvedBy: null,
      };

      vi.mocked(createProposal).mockResolvedValue(mockProposal as any);

      req.body = { baseWodId: 100, proposedWodId: 101 };

      await createProposalHandler(req as Request, res as Response, vi.fn());

      expect(createProposal).toHaveBeenCalledWith({ baseWodId: 100, proposedWodId: 101 });
      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith(mockProposal);
    });
  });

  describe('approveProposalHandler', () => {
    it('should approve when Base creator', async () => {
      const { approveProposal } = await import('../../../src/modules/wod/services');

      const mockApprovedProposal = {
        id: 50, baseWodId: 100, proposedWodId: 101,
        status: 'approved' as const, proposedAt: new Date(), resolvedAt: new Date(), resolvedBy: 123,
      };
      vi.mocked(approveProposal).mockResolvedValue(mockApprovedProposal);

      req.params = { proposalId: '50' };
      (req as any).user = { userId: 123, appId: 1 };

      await approveProposalHandler(req as Request, res as Response, vi.fn());

      expect(approveProposal).toHaveBeenCalledWith(50, 123);
      expect(res.json).toHaveBeenCalledWith(mockApprovedProposal);
    });

    it('should throw UnauthorizedApprovalException for non-creator', async () => {
      const { approveProposal } = await import('../../../src/modules/wod/services');
      const { BusinessException } = await import('../../../src/utils/errors');

      vi.mocked(approveProposal).mockRejectedValue(
        new BusinessException('Only Base WOD creator can approve changes')
      );

      req.params = { proposalId: '50' };
      (req as any).user = { userId: 456, appId: 1 };

      await expect(
        approveProposalHandler(req as Request, res as Response, vi.fn())
      ).rejects.toThrow(BusinessException);
    });

    it('should throw ProposalNotFoundException for invalid id', async () => {
      const { approveProposal } = await import('../../../src/modules/wod/services');
      const { NotFoundException } = await import('../../../src/utils/errors');

      vi.mocked(approveProposal).mockRejectedValue(
        new NotFoundException('ProposedChange', 999)
      );

      req.params = { proposalId: '999' };
      (req as any).user = { userId: 123, appId: 1 };

      await expect(
        approveProposalHandler(req as Request, res as Response, vi.fn())
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('rejectProposalHandler', () => {
    it('should reject with valid id', async () => {
      const { rejectProposal } = await import('../../../src/modules/wod/services');

      const mockRejectedProposal = {
        id: 50, baseWodId: 100, proposedWodId: 101,
        status: 'rejected' as const, proposedAt: new Date(), resolvedAt: new Date(), resolvedBy: 123,
      };
      vi.mocked(rejectProposal).mockResolvedValue(mockRejectedProposal);

      req.params = { proposalId: '50' };
      (req as any).user = { userId: 123, appId: 1 };

      await rejectProposalHandler(req as Request, res as Response, vi.fn());

      expect(rejectProposal).toHaveBeenCalledWith(50, 123);
      expect(res.json).toHaveBeenCalledWith(mockRejectedProposal);
    });
  });

  // ─── Phase 4: Selection Handlers ───────────────────

  describe('selectWodHandler', () => {
    it('should select WOD with valid data', async () => {
      const { selectWod } = await import('../../../src/modules/wod/services');

      const mockSelection = {
        id: 200,
        userId: 42,
        wodId: 100,
        boxId: 1,
        date: '2026-02-03',
        snapshotData: { type: 'AMRAP', timeCap: 15, movements: [{ name: 'Pull-up', reps: 10 }] },
        createdAt: new Date(),
      };

      vi.mocked(selectWod).mockResolvedValue(mockSelection as any);

      req.params = { wodId: '100' };
      req.body = { boxId: 1, date: '2026-02-03' };
      (req as any).user = { userId: 42, appId: 1 };

      await selectWodHandler(req as Request, res as Response, vi.fn());

      expect(selectWod).toHaveBeenCalledWith(
        expect.objectContaining({ userId: 42, wodId: 100, boxId: 1, date: '2026-02-03' })
      );
      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith(mockSelection);
    });

    it('should throw NotFoundException for invalid WOD', async () => {
      const { selectWod } = await import('../../../src/modules/wod/services');
      const { NotFoundException } = await import('../../../src/utils/errors');

      vi.mocked(selectWod).mockRejectedValue(
        new NotFoundException('WOD', 999)
      );

      req.params = { wodId: '999' };
      req.body = { boxId: 1, date: '2026-02-03' };
      (req as any).user = { userId: 42, appId: 1 };

      await expect(
        selectWodHandler(req as Request, res as Response, vi.fn())
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('getSelectionsHandler', () => {
    it('should return selections for date range', async () => {
      const { getSelections } = await import('../../../src/modules/wod/services');

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

      vi.mocked(getSelections).mockResolvedValue(mockSelections as any);

      req.query = { startDate: '2026-02-01', endDate: '2026-02-28' };
      (req as any).user = { userId: 42, appId: 1 };

      await getSelectionsHandler(req as Request, res as Response, vi.fn());

      expect(getSelections).toHaveBeenCalledWith({
        userId: 42,
        startDate: '2026-02-01',
        endDate: '2026-02-28',
      });
      expect(res.json).toHaveBeenCalledWith({
        selections: mockSelections,
        totalCount: 1,
      });
    });

    it('should return selections without date range', async () => {
      const { getSelections } = await import('../../../src/modules/wod/services');

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

      vi.mocked(getSelections).mockResolvedValue(mockSelections as any);

      req.query = {};
      (req as any).user = { userId: 42, appId: 1 };

      await getSelectionsHandler(req as Request, res as Response, vi.fn());

      expect(getSelections).toHaveBeenCalledWith({
        userId: 42,
        startDate: undefined,
        endDate: undefined,
      });
      expect(res.json).toHaveBeenCalledWith({
        selections: mockSelections,
        totalCount: 2,
      });
    });
  });
});
