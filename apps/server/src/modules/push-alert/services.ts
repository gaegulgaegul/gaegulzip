import { db } from '../../config/database';
import { pushDeviceTokens, pushAlerts, pushNotificationReceipts } from './schema';
import { users } from '../auth/schema';
import { eq, and, inArray, desc, count } from 'drizzle-orm';

/**
 * 디바이스 토큰 등록 또는 업데이트
 */
export const upsertDevice = async (data: {
  userId: number;
  appId: number;
  token: string;
  platform: string;
  deviceId?: string;
}) => {
  const now = new Date();

  // 기존 토큰 조회
  const existing = await db
    .select()
    .from(pushDeviceTokens)
    .where(
      and(
        eq(pushDeviceTokens.userId, data.userId),
        eq(pushDeviceTokens.appId, data.appId),
        eq(pushDeviceTokens.token, data.token)
      )
    )
    .limit(1);

  if (existing[0]) {
    // Update
    const updated = await db
      .update(pushDeviceTokens)
      .set({
        platform: data.platform,
        deviceId: data.deviceId,
        isActive: true,
        lastUsedAt: now,
        updatedAt: now,
      })
      .where(eq(pushDeviceTokens.id, existing[0].id))
      .returning();

    return updated[0];
  }

  // Insert
  const inserted = await db
    .insert(pushDeviceTokens)
    .values({
      userId: data.userId,
      appId: data.appId,
      token: data.token,
      platform: data.platform,
      deviceId: data.deviceId,
      isActive: true,
      lastUsedAt: now,
      createdAt: now,
      updatedAt: now,
    })
    .returning();

  return inserted[0];
};

/**
 * 사용자의 디바이스 목록 조회
 */
export const findDevicesByUserId = async (userId: number, appId: number) => {
  return await db
    .select()
    .from(pushDeviceTokens)
    .where(and(eq(pushDeviceTokens.userId, userId), eq(pushDeviceTokens.appId, appId)))
    .orderBy(desc(pushDeviceTokens.lastUsedAt));
};

/**
 * 다중 사용자의 활성 디바이스 조회
 */
export const findActiveDevicesByUserIds = async (userIds: number[], appId: number) => {
  if (userIds.length === 0) {
    return [];
  }

  return await db
    .select()
    .from(pushDeviceTokens)
    .where(
      and(
        inArray(pushDeviceTokens.userId, userIds),
        eq(pushDeviceTokens.appId, appId),
        eq(pushDeviceTokens.isActive, true)
      )
    );
};

/**
 * 디바이스 비활성화
 */
export const deactivateDevice = async (id: number, userId: number, appId: number) => {
  const updated = await db
    .update(pushDeviceTokens)
    .set({
      isActive: false,
      updatedAt: new Date(),
    })
    .where(
      and(
        eq(pushDeviceTokens.id, id),
        eq(pushDeviceTokens.userId, userId),
        eq(pushDeviceTokens.appId, appId)
      )
    )
    .returning();

  return updated[0] || null;
};

/**
 * 토큰으로 디바이스 비활성화
 *
 * @param token - FCM 디바이스 토큰
 * @param appId - 앱 ID
 * @param userId - 사용자 ID (지정 시 소유권 검증)
 */
export const deactivateDeviceByToken = async (token: string, appId: number, userId?: number) => {
  const conditions = [eq(pushDeviceTokens.token, token), eq(pushDeviceTokens.appId, appId)];
  if (userId !== undefined) {
    conditions.push(eq(pushDeviceTokens.userId, userId));
  }

  await db
    .update(pushDeviceTokens)
    .set({
      isActive: false,
      updatedAt: new Date(),
    })
    .where(and(...conditions));
};

/**
 * Alert 레코드 생성
 */
export const createAlert = async (data: {
  appId: number;
  userId?: number;
  title: string;
  body: string;
  data?: Record<string, any>;
  imageUrl?: string;
  targetType: string;
  targetUserIds?: number[];
}) => {
  const inserted = await db
    .insert(pushAlerts)
    .values({
      appId: data.appId,
      userId: data.userId,
      title: data.title,
      body: data.body,
      data: data.data || {},
      imageUrl: data.imageUrl,
      targetType: data.targetType,
      targetUserIds: data.targetUserIds || [],
      status: 'pending',
      sentCount: 0,
      failedCount: 0,
      createdAt: new Date(),
    })
    .returning();

  return inserted[0];
};

/**
 * Alert 상태 업데이트
 */
export const updateAlertStatus = async (
  id: number,
  data: {
    status: string;
    sentCount: number;
    failedCount: number;
    errorMessage?: string;
  }
) => {
  const updated = await db
    .update(pushAlerts)
    .set({
      status: data.status,
      sentCount: data.sentCount,
      failedCount: data.failedCount,
      errorMessage: data.errorMessage,
      sentAt: data.status === 'completed' ? new Date() : undefined,
    })
    .where(eq(pushAlerts.id, id))
    .returning();

  return updated[0];
};

/**
 * Alert 목록 조회 (페이지네이션)
 */
export const findAlerts = async (appId: number, limit: number = 50, offset: number = 0) => {
  const results = await db
    .select()
    .from(pushAlerts)
    .where(eq(pushAlerts.appId, appId))
    .orderBy(desc(pushAlerts.createdAt))
    .limit(limit)
    .offset(offset);

  return results;
};

/**
 * Alert 전체 개수 조회
 */
export const countAlerts = async (appId: number): Promise<number> => {
  const result = await db
    .select({ count: count() })
    .from(pushAlerts)
    .where(eq(pushAlerts.appId, appId));

  return result[0]?.count || 0;
};

/**
 * 단일 Alert 조회
 */
export const findAlertById = async (id: number, appId: number) => {
  const result = await db
    .select()
    .from(pushAlerts)
    .where(and(eq(pushAlerts.id, id), eq(pushAlerts.appId, appId)))
    .limit(1);

  return result[0] || null;
};

/**
 * 전체 발송용: 앱의 모든 활성 사용자 ID 목록 조회
 */
export const getAllActiveUserIds = async (appId: number): Promise<number[]> => {
  const result = await db
    .select({ userId: users.id })
    .from(users)
    .where(eq(users.appId, appId));

  return result.map((row) => row.userId);
};

// ─── 알림 수신 기록 (Receipt) ───────────────────────────────────────

/**
 * 알림 수신 기록 생성 (발송 시 대상 사용자별 1개 레코드 생성)
 */
export const createReceiptsForUsers = async (data: {
  appId: number;
  alertId: number;
  userIds: number[];
  title: string;
  body: string;
  data?: Record<string, any>;
  imageUrl?: string;
}) => {
  if (data.userIds.length === 0) {
    return [];
  }

  const now = new Date();
  const BATCH_SIZE = 1000;
  const allInserted: (typeof pushNotificationReceipts.$inferSelect)[] = [];

  for (let i = 0; i < data.userIds.length; i += BATCH_SIZE) {
    const batch = data.userIds.slice(i, i + BATCH_SIZE);
    const receipts = batch.map((userId) => ({
      appId: data.appId,
      userId,
      alertId: data.alertId,
      title: data.title,
      body: data.body,
      data: data.data || {},
      imageUrl: data.imageUrl,
      isRead: false,
      receivedAt: now,
      createdAt: now,
    }));

    const inserted = await db.insert(pushNotificationReceipts).values(receipts).returning();
    allInserted.push(...inserted);
  }

  return allInserted;
};

/**
 * 사용자의 알림 목록 조회 (인증된 사용자 전용)
 */
export const findNotificationsByUser = async (
  userId: number,
  appId: number,
  options?: {
    limit?: number;
    offset?: number;
    unreadOnly?: boolean;
  }
) => {
  const limit = options?.limit || 20;
  const offset = options?.offset || 0;

  const conditions = [
    eq(pushNotificationReceipts.userId, userId),
    eq(pushNotificationReceipts.appId, appId),
  ];

  if (options?.unreadOnly) {
    conditions.push(eq(pushNotificationReceipts.isRead, false));
  }

  const results = await db
    .select()
    .from(pushNotificationReceipts)
    .where(and(...conditions))
    .orderBy(desc(pushNotificationReceipts.receivedAt))
    .limit(limit)
    .offset(offset);

  return results;
};

/**
 * 사용자 알림 전체 개수 조회 (페이지네이션용)
 */
export const countNotificationsByUser = async (
  userId: number,
  appId: number,
  options?: { unreadOnly?: boolean }
): Promise<number> => {
  const conditions = [
    eq(pushNotificationReceipts.userId, userId),
    eq(pushNotificationReceipts.appId, appId),
  ];

  if (options?.unreadOnly) {
    conditions.push(eq(pushNotificationReceipts.isRead, false));
  }

  const result = await db
    .select({ count: count() })
    .from(pushNotificationReceipts)
    .where(and(...conditions));

  return result[0]?.count || 0;
};

/**
 * 읽지 않은 알림 개수 조회 (배지 표시용)
 */
export const countUnreadNotifications = async (userId: number, appId: number): Promise<number> => {
  const result = await db
    .select({ count: count() })
    .from(pushNotificationReceipts)
    .where(
      and(
        eq(pushNotificationReceipts.userId, userId),
        eq(pushNotificationReceipts.appId, appId),
        eq(pushNotificationReceipts.isRead, false)
      )
    );

  return result[0]?.count || 0;
};

/**
 * 알림 읽음 처리 (멱등성 보장)
 */
export const markNotificationAsRead = async (
  id: number,
  userId: number,
  appId: number
): Promise<boolean> => {
  const updated = await db
    .update(pushNotificationReceipts)
    .set({
      isRead: true,
      readAt: new Date(),
    })
    .where(
      and(
        eq(pushNotificationReceipts.id, id),
        eq(pushNotificationReceipts.userId, userId),
        eq(pushNotificationReceipts.appId, appId)
      )
    )
    .returning();

  return updated.length > 0;
};

/**
 * 알림 상세 조회 (권한 검증 포함)
 */
export const findNotificationById = async (
  id: number,
  userId: number,
  appId: number
) => {
  const result = await db
    .select()
    .from(pushNotificationReceipts)
    .where(
      and(
        eq(pushNotificationReceipts.id, id),
        eq(pushNotificationReceipts.userId, userId),
        eq(pushNotificationReceipts.appId, appId)
      )
    )
    .limit(1);

  return result[0] || null;
};
