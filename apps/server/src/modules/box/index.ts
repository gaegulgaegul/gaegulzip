import { Router } from 'express';
import * as handlers from './handlers';
import { authenticate } from '../../middleware/auth';

const router = Router();

// 모든 박스 엔드포인트는 인증 필요
router.use(authenticate);

/**
 * 내 현재 박스 조회
 * @route GET /boxes/me
 * @returns 200: { box: BoxWithMemberCount | null }
 */
router.get('/me', handlers.getMyBox);

/**
 * 박스 검색
 * @route GET /boxes/search
 * @query { name?: string, region?: string }
 * @returns 200: { boxes: BoxWithMemberCount[] }
 */
router.get('/search', handlers.search);

/**
 * 박스 생성 (자동 가입)
 * @route POST /boxes
 * @body { name: string, region: string, description?: string }
 * @returns 201: Box
 */
router.post('/', handlers.create);

/**
 * 박스 가입 (기존 박스 자동 탈퇴)
 * @route POST /boxes/:boxId/join
 * @param boxId - 박스 ID
 * @returns 200: { membership: BoxMember }
 */
router.post('/:boxId/join', handlers.join);

/**
 * 박스 상세 조회
 * @route GET /boxes/:boxId
 * @param boxId - 박스 ID
 * @returns 200: Box
 */
router.get('/:boxId', handlers.getById);

/**
 * 박스 멤버 목록 조회
 * @route GET /boxes/:boxId/members
 * @param boxId - 박스 ID
 * @returns 200: { members: BoxMember[], totalCount: number }
 */
router.get('/:boxId/members', handlers.getMembers);

export default router;
