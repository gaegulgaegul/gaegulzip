import { RequestHandler } from 'express';
import { AuthenticatedRequest } from '../auth/types';
import { createBox, getCurrentBox, searchBoxes, joinBox as joinBoxService, getBoxById, getBoxMembers } from './services';
import { createBoxSchema, searchBoxQuerySchema, boxIdParamsSchema } from './validators';

/**
 * 박스 생성 핸들러
 * @route POST /boxes
 */
export const create: RequestHandler = async (req, res) => {
  const { userId } = (req as AuthenticatedRequest).user;
  const { name, region, description } = createBoxSchema.parse(req.body);

  const box = await createBox({
    name,
    region,
    description,
    createdBy: userId,
  });

  // 생성자를 자동으로 멤버로 등록 (단일 박스 정책: 기존 박스 자동 탈퇴)
  const membership = await joinBoxService({ boxId: box.id, userId });

  res.status(201).json({ box, membership });
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
 * 박스 검색 핸들러
 * @route GET /boxes/search
 */
export const search: RequestHandler = async (req, res) => {
  const { name, region } = searchBoxQuerySchema.parse(req.query);

  const boxes = await searchBoxes({ name, region });

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
