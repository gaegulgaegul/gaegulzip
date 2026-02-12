import { logger } from '../../utils/logger';

/**
 * 디바이스 토큰 등록 로그 (INFO)
 */
export const deviceRegistered = (data: {
  userId: number;
  appId: number;
  platform: string;
  deviceId?: string;
}) => {
  logger.info(
    {
      userId: data.userId,
      appId: data.appId,
      platform: data.platform,
      deviceId: data.deviceId,
    },
    'Device token registered'
  );
};

/**
 * 디바이스 토큰 비활성화 로그 (INFO)
 */
export const deviceDeactivated = (data: {
  deviceId: number;
  userId: number;
  appId: number;
}) => {
  logger.info(
    {
      deviceId: data.deviceId,
      userId: data.userId,
      appId: data.appId,
    },
    'Device token deactivated'
  );
};

/**
 * 토큰으로 디바이스 비활성화 로그 (로그아웃 시)
 */
export const deviceDeactivatedByToken = (data: {
  userId: number;
  appId: number;
  tokenPrefix: string;
}) => {
  logger.info(
    {
      userId: data.userId,
      appId: data.appId,
      tokenPrefix: data.tokenPrefix.length > 20
        ? data.tokenPrefix.substring(0, 20) + '...'
        : data.tokenPrefix,
    },
    'Device deactivated by token'
  );
};

/**
 * 푸시 발송 성공 로그 (INFO)
 */
export const pushSent = (data: {
  alertId: number;
  appId: number;
  targetType: string;
  sentCount: number;
  failedCount: number;
}) => {
  logger.info(
    {
      alertId: data.alertId,
      appId: data.appId,
      targetType: data.targetType,
      sentCount: data.sentCount,
      failedCount: data.failedCount,
    },
    'Push notification sent'
  );
};

/**
 * 푸시 발송 실패 로그 (ERROR)
 */
export const pushFailed = (data: {
  alertId: number;
  appId: number;
  targetType: string;
  error: string;
}) => {
  logger.error(
    {
      alertId: data.alertId,
      appId: data.appId,
      targetType: data.targetType,
      error: data.error,
    },
    'Push notification failed'
  );
};

/**
 * Invalid Token 감지 로그 (WARN)
 */
export const invalidTokenDetected = (data: {
  token: string;
  appId: number;
  userId?: number;
}) => {
  logger.warn(
    {
      token: data.token.substring(0, 20) + '...', // 토큰 일부만 로깅
      appId: data.appId,
      userId: data.userId,
    },
    'Invalid FCM token detected and deactivated'
  );
};

/**
 * 알림 수신 기록 생성 로그 (INFO)
 */
export const receiptsCreated = (data: {
  alertId: number;
  appId: number;
  userCount: number;
}) => {
  logger.info(
    {
      alertId: data.alertId,
      appId: data.appId,
      userCount: data.userCount,
    },
    'Notification receipts created'
  );
};

/**
 * 알림 읽음 처리 로그 (INFO)
 */
export const notificationRead = (data: {
  notificationId: number;
  userId: number;
  appId: number;
}) => {
  logger.info(
    {
      notificationId: data.notificationId,
      userId: data.userId,
      appId: data.appId,
    },
    'Notification marked as read'
  );
};
