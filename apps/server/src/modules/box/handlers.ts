import { RequestHandler } from 'express';
import { AuthenticatedRequest } from '../auth/types';
import { createBoxWithMembership, getCurrentBox, searchBoxes, joinBox as joinBoxService, getBoxById, getBoxMembers } from './services';
import { createBoxSchema, searchBoxQuerySchema, boxIdParamsSchema } from './validators';
import { logger } from '../../utils/logger';

/**
 * 박스 생성 핸들러 (트랜잭션: 박스 생성 + 멤버 등록)
 * @route POST /boxes
 */
export const create: RequestHandler = async (req, res) => {
  const { userId } = (req as AuthenticatedRequest).user;
  const { name, region, description } = createBoxSchema.parse(req.body);

  logger.debug({ userId, name, region }, 'Creating box with transaction');

  const result = await createBoxWithMembership({
    name,
    region,
    description,
    createdBy: userId,
  });

  res.status(201).json(result);
};

/**
 * 내 현재 박스 조회 핸들러
 * @route GET /boxes/me
 */
export const getMyBox: RequestHandler = async (req, res) => {
  const { userId } = (req as AuthenticatedRequest).user;

  const box = await getCurrentBox(userId);

  res.json({ box });
};

/**
 * 박스 검색 핸들러 (통합 키워드 또는 개별 name/region 검색)
 * @route GET /boxes/search?keyword=... 또는 ?name=...&region=...
 */
export const search: RequestHandler = async (req, res) => {
  const { name, region, keyword } = searchBoxQuerySchema.parse(req.query);

  logger.debug({ keyword, name, region }, 'Searching boxes');

  const boxes = await searchBoxes({ name, region, keyword });

  logger.debug({ resultCount: boxes.length }, 'Search completed');

  res.json({ boxes });
};

/**
 * 박스 가입 핸들러
 * @route POST /boxes/:boxId/join
 */
export const join: RequestHandler = async (req, res) => {
  const { userId } = (req as AuthenticatedRequest).user;
  const { boxId } = boxIdParamsSchema.parse(req.params);

  const result = await joinBoxService({ boxId, userId });

  res.json(result);
};

/**
 * 박스 상세 조회 핸들러
 * @route GET /boxes/:boxId
 */
export const getById: RequestHandler = async (req, res) => {
  const { boxId } = boxIdParamsSchema.parse(req.params);

  const box = await getBoxById(boxId);

  res.json({ box });
};

/**
 * 박스 멤버 목록 조회 핸들러
 * @route GET /boxes/:boxId/members
 */
export const getMembers: RequestHandler = async (req, res) => {
  const { boxId } = boxIdParamsSchema.parse(req.params);

  const members = await getBoxMembers(boxId);

  res.json({ members, totalCount: members.length });
};
