import { Router } from 'express';
import * as handlers from './handlers';
import { authenticate } from '../../middleware/auth';

const router = Router();

/**
 * 디바이스 토큰 등록 (인증 필요)
 * @route POST /push/devices
 * @body { token: string, platform: string, deviceId?: string }
 * @returns 201: { id, token, platform, isActive, lastUsedAt, createdAt }
 */
router.post('/devices', authenticate, handlers.registerDevice);

/**
 * 사용자의 디바이스 목록 조회 (인증 필요)
 * @route GET /push/devices
 * @returns 200: { devices: [...] }
 */
router.get('/devices', authenticate, handlers.listDevices);

/**
 * 디바이스 토큰 비활성화 (인증 필요)
 * @route DELETE /push/devices/:id
 * @returns 204: No Content
 */
router.delete('/devices/:id', authenticate, handlers.deactivateDevice);

/**
 * 푸시 알림 발송 (관리자용, 인증 필요)
 * @route POST /push/send
 * @body { appCode: string, userId?: number, userIds?: number[], targetType?: 'all', title: string, body: string, data?: object, imageUrl?: string }
 * @returns 200: { alertId, sentCount, failedCount, status }
 */
router.post('/send', authenticate, handlers.sendPush);

// ─── 사용자 알림 API (인증 필요) ────────────────────────────────────

/**
 * 내 알림 목록 조회 (인증 필요)
 * @route GET /push/notifications/me
 * @query { limit?: number, offset?: number, unreadOnly?: boolean }
 * @returns 200: { notifications: [...], total: number }
 */
router.get('/notifications/me', authenticate, handlers.listMyNotifications);

/**
 * 읽지 않은 알림 개수 조회 (인증 필요)
 * @route GET /push/notifications/unread-count
 * @returns 200: { unreadCount: number }
 */
router.get('/notifications/unread-count', authenticate, handlers.getUnreadCount);

/**
 * 알림 읽음 처리 (인증 필요)
 * @route PATCH /push/notifications/:id/read
 * @returns 200: { success: true }
 */
router.patch('/notifications/:id/read', authenticate, handlers.markAsRead);

// ─── 관리자용 발송 이력 API (인증 필요) ─────────────────────────────

/**
 * 푸시 알림 이력 조회 (관리자용, 인증 필요)
 * @route GET /push/notifications
 * @query { appCode: string, limit?: number, offset?: number }
 * @returns 200: { alerts: [...], total: number }
 */
router.get('/notifications', authenticate, handlers.listAlerts);

/**
 * 푸시 알림 상세 조회 (관리자용, 인증 필요)
 * @route GET /push/notifications/:id
 * @query { appCode: string }
 * @returns 200: { id, title, body, ... }
 */
router.get('/notifications/:id', authenticate, handlers.getAlert);

export default router;
