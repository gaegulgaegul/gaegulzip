import { Request, Response, RequestHandler } from 'express';
import { registerWod, getWodsByDate, createProposal, approveProposal, rejectProposal, selectWod, getSelections } from './services';
import { registerWodSchema, createProposalSchema, selectWodSchema } from './validators';

/**
 * WOD 등록 핸들러
 * POST /wods
 */
export const registerWodHandler: RequestHandler = async (req, res) => {
  const validatedData = registerWodSchema.parse(req.body);
  const { userId } = (req as any).user;

  const wod = await registerWod({
    ...validatedData,
    createdBy: userId,
  });

  res.status(201).json(wod);
};

/**
 * 날짜별 WOD 조회 핸들러
 * GET /wods/:boxId/:date
 */
export const getWodsByDateHandler: RequestHandler = async (req, res) => {
  const boxId = parseInt(req.params.boxId as string, 10);
  const date = req.params.date as string;

  const result = await getWodsByDate({ boxId, date });

  res.json(result);
};

/**
 * 변경 제안 생성 핸들러
 * POST /wods/proposals
 */
export const createProposalHandler: RequestHandler = async (req, res) => {
  const validatedData = createProposalSchema.parse(req.body);

  const proposal = await createProposal(validatedData);

  res.status(201).json(proposal);
};

/**
 * 변경 승인 핸들러
 * POST /wods/proposals/:proposalId/approve
 */
export const approveProposalHandler: RequestHandler = async (req, res) => {
  const proposalId = parseInt(req.params.proposalId as string, 10);
  const { userId } = (req as any).user;

  await approveProposal(proposalId, userId);

  res.json({ approved: true });
};

/**
 * 변경 거부 핸들러
 * POST /wods/proposals/:proposalId/reject
 */
export const rejectProposalHandler: RequestHandler = async (req, res) => {
  const proposalId = parseInt(req.params.proposalId as string, 10);
  const { userId } = (req as any).user;

  await rejectProposal(proposalId, userId);

  res.json({ rejected: true });
};

/**
 * WOD 선택 핸들러
 * POST /wods/:wodId/select
 */
export const selectWodHandler: RequestHandler = async (req, res) => {
  const wodId = parseInt(req.params.wodId as string, 10);
  const { userId } = (req as any).user;
  const validatedData = selectWodSchema.parse(req.body);

  const selection = await selectWod({
    userId,
    wodId,
    ...validatedData,
  });

  res.status(201).json(selection);
};

/**
 * 내 WOD 선택 기록 조회 핸들러
 * GET /wods/selections
 */
export const getSelectionsHandler: RequestHandler = async (req, res) => {
  const { userId } = (req as any).user;
  const startDate = req.query.startDate as string | undefined;
  const endDate = req.query.endDate as string | undefined;

  const selections = await getSelections({
    userId,
    startDate,
    endDate,
  });

  res.json({ selections, totalCount: selections.length });
};
