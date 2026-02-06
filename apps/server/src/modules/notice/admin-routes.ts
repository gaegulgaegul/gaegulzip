import { Router } from 'express';
import * as handlers from './admin-handlers';
import { requireAdmin } from '../../middleware/admin-auth';

const router = Router();

// 모든 어드민 공지사항 라우트에 JWT 인증 적용
router.use(requireAdmin);

/**
 * 어드민 공지사항 목록 조회
 * @route GET /admin/notices?appCode=wowa
 */
router.get('/', handlers.adminListNotices);

/**
 * 어드민 공지사항 상세 조회
 * @route GET /admin/notices/:id
 */
router.get('/:id', handlers.adminGetNotice);

/**
 * 어드민 공지사항 작성
 * @route POST /admin/notices
 */
router.post('/', handlers.adminCreateNotice);

/**
 * 어드민 공지사항 수정
 * @route PUT /admin/notices/:id
 */
router.put('/:id', handlers.adminUpdateNotice);

/**
 * 어드민 공지사항 삭제
 * @route DELETE /admin/notices/:id
 */
router.delete('/:id', handlers.adminDeleteNotice);

/**
 * 어드민 공지사항 고정/해제
 * @route PATCH /admin/notices/:id/pin
 */
router.patch('/:id/pin', handlers.adminPinNotice);

export default router;
