import { Router } from 'express';
import { authenticate } from '../../middleware/auth';
import { optionalAuthenticate } from '../../middleware/optional-auth';
import * as handlers from './handlers';

const router = Router();

// --- GET: 인증 선택적 (appCode query param 사용) ---

/**
 * 공지사항 목록 조회 (사용자)
 * @route GET /notices
 * @query { page?, limit?, category?, pinnedOnly?, appCode? }
 * @returns 200: { items, totalCount, page, limit, hasNext }
 */
router.get('/', optionalAuthenticate, handlers.listNotices);

/**
 * 읽지 않은 공지 개수 조회 (사용자)
 * @route GET /notices/unread-count
 * @returns 200: { unreadCount: number }
 */
router.get('/unread-count', optionalAuthenticate, handlers.getUnreadCount);

/**
 * 공지사항 상세 조회 (사용자)
 * @route GET /notices/:id
 * @returns 200: 공지사항 상세
 */
router.get('/:id', optionalAuthenticate, handlers.getNotice);

// --- POST/PUT/DELETE/PATCH: 인증 필수 ---

/**
 * 공지사항 작성 (관리자)
 * @route POST /notices
 * @body { title, content, category?, isPinned? }
 * @returns 201: 생성된 공지사항
 */
router.post('/', authenticate, handlers.createNotice);

/**
 * 공지사항 수정 (관리자)
 * @route PUT /notices/:id
 * @body { title?, content?, category?, isPinned? }
 * @returns 200: 수정된 공지사항
 */
router.put('/:id', authenticate, handlers.updateNotice);

/**
 * 공지사항 삭제 (관리자)
 * @route DELETE /notices/:id
 * @returns 204: No Content
 */
router.delete('/:id', authenticate, handlers.deleteNotice);

/**
 * 공지사항 고정/해제 (관리자)
 * @route PATCH /notices/:id/pin
 * @body { isPinned: boolean }
 * @returns 200: { id, title, isPinned, updatedAt }
 */
router.patch('/:id/pin', authenticate, handlers.pinNotice);

export default router;
