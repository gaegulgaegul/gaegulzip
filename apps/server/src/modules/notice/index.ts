import { Router } from 'express';
import * as handlers from './handlers';
import { requireAdmin } from '../../middleware/admin-auth';

const router = Router();

/**
 * 공지사항 목록 조회 (사용자)
 * @route GET /notices
 * @query { page?: number, limit?: number, category?: string, pinnedOnly?: boolean }
 * @returns 200: { items, totalCount, page, limit, hasNext }
 */
router.get('/', handlers.listNotices);

/**
 * 읽지 않은 공지 개수 조회 (사용자)
 * @route GET /notices/unread-count
 * @returns 200: { unreadCount: number }
 */
router.get('/unread-count', handlers.getUnreadCount);

/**
 * 공지사항 상세 조회 (사용자)
 * @route GET /notices/:id
 * @returns 200: 공지사항 상세
 */
router.get('/:id', handlers.getNotice);

/**
 * 공지사항 작성 (관리자)
 * @route POST /notices
 * @headers { X-Admin-Secret: string }
 * @body { title, content, category?, isPinned? }
 * @returns 201: 생성된 공지사항
 */
router.post('/', requireAdmin, handlers.createNotice);

/**
 * 공지사항 수정 (관리자)
 * @route PUT /notices/:id
 * @headers { X-Admin-Secret: string }
 * @body { title?, content?, category?, isPinned? }
 * @returns 200: 수정된 공지사항
 */
router.put('/:id', requireAdmin, handlers.updateNotice);

/**
 * 공지사항 삭제 (관리자)
 * @route DELETE /notices/:id
 * @headers { X-Admin-Secret: string }
 * @returns 204: No Content
 */
router.delete('/:id', requireAdmin, handlers.deleteNotice);

/**
 * 공지사항 고정/해제 (관리자)
 * @route PATCH /notices/:id/pin
 * @headers { X-Admin-Secret: string }
 * @body { isPinned: boolean }
 * @returns 200: { id, title, isPinned, updatedAt }
 */
router.patch('/:id/pin', requireAdmin, handlers.pinNotice);

export default router;
