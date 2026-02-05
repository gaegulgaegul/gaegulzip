# 기술 아키텍처 설계: 푸시 알림 (서버 측)

## 개요

푸시 알림 기능의 서버 측 확장 설계입니다. 기존 FCM 발송 인프라를 기반으로 **사용자별 알림 수신 기록(Receipt) 관리**, **읽음 상태 처리**, **앱 내 알림 목록 API**를 추가하여 완전한 Push Notification 시스템을 구축합니다.

**핵심 설계 원칙**:
- 기존 `push_alerts` 테이블은 발송 이력 전용으로 유지
- 새로운 `push_notification_receipts` 테이블로 사용자별 수신 기록 관리
- 앱별 데이터 격리 (appId 기반 스코핑)
- 인증된 사용자만 자신의 알림 접근 가능 (보안)

## 기존 구현 현황

### 구현 완료 (유지)

| 영역 | 파일 | 설명 |
|------|------|------|
| 디바이스 토큰 관리 | `schema.ts`, `services.ts`, `handlers.ts` | CRUD, Upsert, 소프트 삭제 |
| 알림 발송 | `handlers.ts`, `fcm.ts`, `services.ts` | 단건/다건/전체 발송, 배치 처리 |
| 발송 이력 | `schema.ts` (`push_alerts`) | 발송 통계, 성공/실패 건수 |
| 무효 토큰 정리 | `services.ts`, `fcm.ts` | 자동 비활성화 |
| 운영 로그 | `push.probe.ts` | Domain Probe 패턴 |

### 보안 개선 필요

| 항목 | 현재 상태 | 필요 조치 |
|------|----------|----------|
| `POST /push/send` | ❌ 인증 없음 | ✅ 관리자 인증/인가 추가 |
| `GET /push/notifications` | ❌ 인증 없음 | ✅ 제거 또는 관리자 전용 |
| `GET /push/notifications/:id` | ❌ 인증 없음 | ✅ 제거 또는 관리자 전용 |

## 신규 기능 설계

### 1. 데이터베이스 스키마 변경

#### 1-1. 신규 테이블: push_notification_receipts

**목적**: 사용자별 알림 수신 기록 및 읽음 상태 관리

```typescript
// apps/server/src/modules/push-alert/schema.ts

/**
 * 푸시 알림 수신 기록 테이블 (사용자별 알림 목록 및 읽음 상태)
 */
export const pushNotificationReceipts = pgTable('push_notification_receipts', {
  /** 고유 ID */
  id: serial('id').primaryKey(),
  /** 앱 ID (외래키, FK 제약조건 없음) */
  appId: integer('app_id').notNull(),
  /** 사용자 ID (외래키, FK 제약조건 없음) */
  userId: integer('user_id').notNull(),
  /** 발송 이력 ID (push_alerts 참조, FK 제약조건 없음) */
  alertId: integer('alert_id').notNull(),
  /** 알림 제목 (빠른 조회를 위한 비정규화) */
  title: varchar('title', { length: 255 }).notNull(),
  /** 알림 본문 (빠른 조회를 위한 비정규화) */
  body: varchar('body', { length: 1000 }).notNull(),
  /** 커스텀 데이터 (JSON, 빠른 조회를 위한 비정규화) */
  data: jsonb('data').default({}),
  /** 이미지 URL (빠른 조회를 위한 비정규화) */
  imageUrl: varchar('image_url', { length: 500 }),
  /** 읽음 상태 (기본값: false) */
  isRead: boolean('is_read').notNull().default(false),
  /** 읽은 시간 (null = 읽지 않음) */
  readAt: timestamp('read_at'),
  /** 수신 시간 */
  receivedAt: timestamp('received_at').defaultNow().notNull(),
  /** 생성 시간 */
  createdAt: timestamp('created_at').defaultNow().notNull(),
}, (table) => ({
  appIdIdx: index('idx_push_notification_receipts_app_id').on(table.appId),
  userIdIdx: index('idx_push_notification_receipts_user_id').on(table.userId),
  alertIdIdx: index('idx_push_notification_receipts_alert_id').on(table.alertId),
  isReadIdx: index('idx_push_notification_receipts_is_read').on(table.isRead),
  receivedAtIdx: index('idx_push_notification_receipts_received_at').on(table.receivedAt),
  // 복합 인덱스: 사용자별 알림 목록 조회 최적화
  userAppReceivedIdx: index('idx_push_notification_receipts_user_app_received')
    .on(table.userId, table.appId, table.receivedAt),
}));
```

**설계 근거**:
- **비정규화**: `title`, `body`, `data`, `imageUrl`을 복사하여 `push_alerts` 조인 없이 빠른 조회 가능
- **앱별 격리**: `appId`로 앱별 알림 분리 (멀티테넌트)
- **복합 인덱스**: `(userId, appId, receivedAt)` 인덱스로 사용자 알림 목록 조회 성능 최적화
- **읽음 상태**: `isRead` boolean + `readAt` timestamp 조합 (읽은 시간 추적)

#### 1-2. 마이그레이션

```bash
cd apps/server
pnpm drizzle-kit generate
pnpm drizzle-kit migrate
```

**마이그레이션 파일 예시**:
```sql
-- Create push_notification_receipts table
CREATE TABLE push_notification_receipts (
  id SERIAL PRIMARY KEY,
  app_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  alert_id INTEGER NOT NULL,
  title VARCHAR(255) NOT NULL,
  body VARCHAR(1000) NOT NULL,
  data JSONB DEFAULT '{}',
  image_url VARCHAR(500),
  is_read BOOLEAN NOT NULL DEFAULT false,
  read_at TIMESTAMP,
  received_at TIMESTAMP NOT NULL DEFAULT NOW(),
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_push_notification_receipts_app_id ON push_notification_receipts(app_id);
CREATE INDEX idx_push_notification_receipts_user_id ON push_notification_receipts(user_id);
CREATE INDEX idx_push_notification_receipts_alert_id ON push_notification_receipts(alert_id);
CREATE INDEX idx_push_notification_receipts_is_read ON push_notification_receipts(is_read);
CREATE INDEX idx_push_notification_receipts_received_at ON push_notification_receipts(received_at);
CREATE INDEX idx_push_notification_receipts_user_app_received ON push_notification_receipts(user_id, app_id, received_at);
```

### 2. 비즈니스 로직 설계

#### 2-1. 알림 발송 시 Receipt 생성 (기존 코드 수정)

**파일**: `apps/server/src/modules/push-alert/handlers.ts` - `sendPush` 함수

**수정 위치**: FCM 발송 성공 후, Alert 상태 업데이트 전

```typescript
// 기존 코드:
// 6. 메시지 발송
const result = await sendToMultipleDevices(fcmInstance, tokens, message);

// 7. Invalid token 처리
if (result.invalidTokens.length > 0) {
  // ... (기존 로직 유지)
}

// ✅ 신규 추가: 8. Receipt 생성 (각 대상 사용자별 1개 레코드)
await createReceiptsForUsers({
  appId: app.id,
  alertId: alert.id,
  userIds: targetUserIds,
  title,
  body,
  data,
  imageUrl,
});

// 9. Alert 상태 업데이트 (기존 로직)
await updateAlertStatus(alert.id, { ... });
```

**설계 근거**:
- FCM 발송 성공 여부와 관계없이 Receipt 생성 (사용자는 앱에서 알림 목록 확인 가능)
- 디바이스가 없는 사용자도 Receipt 생성 (나중에 디바이스 등록 시 알림 확인 가능)
- 배치 INSERT로 성능 최적화

#### 2-2. 신규 Service 함수

**파일**: `apps/server/src/modules/push-alert/services.ts`

```typescript
import { pushNotificationReceipts } from './schema';

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
  const receipts = data.userIds.map((userId) => ({
    appId: data.appId,
    userId,
    alertId: data.alertId,
    title: data.title,
    body: data.body,
    data: data.data || {},
    imageUrl: data.imageUrl,
    isRead: false,
    readAt: null,
    receivedAt: now,
    createdAt: now,
  }));

  // 배치 INSERT (성능 최적화)
  const inserted = await db.insert(pushNotificationReceipts).values(receipts).returning();

  return inserted;
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

  let query = db
    .select()
    .from(pushNotificationReceipts)
    .where(
      and(
        eq(pushNotificationReceipts.userId, userId),
        eq(pushNotificationReceipts.appId, appId)
      )
    );

  // 읽지 않은 알림만 필터링
  if (options?.unreadOnly) {
    query = query.where(eq(pushNotificationReceipts.isRead, false));
  }

  const results = await query
    .orderBy(desc(pushNotificationReceipts.receivedAt))
    .limit(limit)
    .offset(offset);

  return results;
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
 * 알림 읽음 처리
 */
export const markNotificationAsRead = async (
  id: number,
  userId: number,
  appId: number
): Promise<boolean> => {
  const now = new Date();

  const updated = await db
    .update(pushNotificationReceipts)
    .set({
      isRead: true,
      readAt: now,
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
```

**설계 근거**:
- **권한 검증**: 모든 쿼리에 `userId`, `appId` 조건 포함 (다른 사용자 알림 접근 불가)
- **앱별 격리**: `appId` 필터로 앱별 알림 분리
- **성능**: 복합 인덱스 활용 (`user_id`, `app_id`, `received_at`)

### 3. API 엔드포인트 설계

#### 3-1. 신규 API 목록

| 메서드 | 경로 | 인증 | 설명 |
|--------|------|------|------|
| GET | `/push/notifications/me` | ✅ | 내 알림 목록 조회 |
| PATCH | `/push/notifications/:id/read` | ✅ | 알림 읽음 처리 |
| GET | `/push/notifications/unread-count` | ✅ | 읽지 않은 알림 개수 |

#### 3-2. 신규 Validator

**파일**: `apps/server/src/modules/push-alert/validators.ts`

```typescript
/**
 * 알림 목록 조회 쿼리 스키마 (인증된 사용자용)
 */
export const listMyNotificationsSchema = z.object({
  limit: z.coerce.number().int().positive().max(100).default(20),
  offset: z.coerce.number().int().min(0).default(0),
  unreadOnly: z.coerce.boolean().optional(),
});

export type ListMyNotificationsQuery = z.infer<typeof listMyNotificationsSchema>;
```

#### 3-3. 신규 Handler

**파일**: `apps/server/src/modules/push-alert/handlers.ts`

```typescript
import { count } from 'drizzle-orm';
import {
  findNotificationsByUser,
  countUnreadNotifications,
  markNotificationAsRead,
  findNotificationById,
} from './services';
import * as pushProbe from './push.probe';

/**
 * 내 알림 목록 조회 핸들러 (인증 필요)
 * @param req - Express 요청 객체 (query: { limit?, offset?, unreadOnly? }, user: { userId, appId })
 * @param res - Express 응답 객체
 * @returns 200: 알림 목록
 */
export const listMyNotifications = async (req: Request, res: Response) => {
  const { limit, offset, unreadOnly } = listMyNotificationsSchema.parse(req.query);
  const { userId, appId } = (req as any).user as { userId: number; appId: number };

  logger.debug({ userId, appId, limit, offset, unreadOnly }, 'Listing user notifications');

  const notifications = await findNotificationsByUser(userId, appId, {
    limit,
    offset,
    unreadOnly,
  });

  res.json({
    notifications: notifications.map((n) => ({
      id: n.id,
      title: n.title,
      body: n.body,
      data: n.data,
      imageUrl: n.imageUrl,
      isRead: n.isRead,
      readAt: n.readAt?.toISOString() ?? null,
      receivedAt: n.receivedAt.toISOString(),
    })),
    total: notifications.length,
  });
};

/**
 * 읽지 않은 알림 개수 조회 핸들러 (인증 필요)
 * @param req - Express 요청 객체 (user: { userId, appId })
 * @param res - Express 응답 객체
 * @returns 200: 읽지 않은 알림 개수
 */
export const getUnreadCount = async (req: Request, res: Response) => {
  const { userId, appId } = (req as any).user as { userId: number; appId: number };

  const unreadCount = await countUnreadNotifications(userId, appId);

  res.json({
    unreadCount,
  });
};

/**
 * 알림 읽음 처리 핸들러 (인증 필요)
 * @param req - Express 요청 객체 (params: { id }, user: { userId, appId })
 * @param res - Express 응답 객제
 * @returns 200: 읽음 처리 성공
 */
export const markAsRead = async (req: Request, res: Response) => {
  const idParam = req.params.id;
  const id = parseInt(Array.isArray(idParam) ? idParam[0] : idParam, 10);
  const { userId, appId } = (req as any).user as { userId: number; appId: number };

  logger.debug({ id, userId, appId }, 'Marking notification as read');

  // 권한 검증 포함 읽음 처리
  const success = await markNotificationAsRead(id, userId, appId);

  if (!success) {
    throw new NotFoundException('Notification', id);
  }

  pushProbe.notificationRead({
    notificationId: id,
    userId,
    appId,
  });

  res.json({
    success: true,
  });
};
```

**응답 형식 예시**:

```json
// GET /push/notifications/me?limit=20&offset=0
{
  "notifications": [
    {
      "id": 1,
      "title": "새 메시지",
      "body": "새로운 메시지가 도착했습니다",
      "data": { "type": "message", "messageId": "123" },
      "imageUrl": "https://example.com/image.png",
      "isRead": false,
      "readAt": null,
      "receivedAt": "2026-02-04T10:30:00Z"
    }
  ],
  "total": 1
}

// GET /push/notifications/unread-count
{
  "unreadCount": 5
}

// PATCH /push/notifications/1/read
{
  "success": true
}
```

**에러 응답**:

```json
// 404 Not Found (권한 없거나 존재하지 않는 알림)
{
  "error": {
    "code": "NOT_FOUND",
    "message": "Notification 1을(를) 찾을 수 없습니다"
  }
}
```

#### 3-4. 라우터 업데이트

**파일**: `apps/server/src/modules/push-alert/index.ts`

```typescript
import { Router } from 'express';
import { authenticate } from '../../middleware/auth';
import {
  registerDevice,
  listDevices,
  deactivateDevice,
  sendPush,
  listAlerts,
  getAlert,
  listMyNotifications,  // ✅ 신규
  getUnreadCount,       // ✅ 신규
  markAsRead,           // ✅ 신규
} from './handlers';

const router = Router();

// 디바이스 토큰 관리 (인증 필요)
router.post('/devices', authenticate, registerDevice);
router.get('/devices', authenticate, listDevices);
router.delete('/devices/:id', authenticate, deactivateDevice);

// 알림 발송 (관리자 전용 - 인증/인가 추가 필요)
router.post('/send', authenticate, sendPush);  // ✅ authenticate 추가

// ✅ 신규: 사용자 알림 API (인증 필요)
router.get('/notifications/me', authenticate, listMyNotifications);
router.get('/notifications/unread-count', authenticate, getUnreadCount);
router.patch('/notifications/:id/read', authenticate, markAsRead);

// 관리자용 발송 이력 조회 (인증/인가 추가 필요)
router.get('/notifications', authenticate, listAlerts);  // ✅ authenticate 추가
router.get('/notifications/:id', authenticate, getAlert);  // ✅ authenticate 추가

export default router;
```

**주의**: `/notifications/me` 라우트는 `/notifications/:id`보다 **먼저** 등록해야 함 (Express 라우터 우선순위)

### 4. 운영 로그 추가

**파일**: `apps/server/src/modules/push-alert/push.probe.ts`

```typescript
/**
 * 알림 수신 기록 생성 (발송 시)
 */
export const receiptsCreated = (data: {
  alertId: number;
  appId: number;
  userCount: number;
}) => {
  logger.info('Notification receipts created', {
    alertId: data.alertId,
    appId: data.appId,
    userCount: data.userCount,
  });
};

/**
 * 알림 읽음 처리
 */
export const notificationRead = (data: {
  notificationId: number;
  userId: number;
  appId: number;
}) => {
  logger.info('Notification marked as read', {
    notificationId: data.notificationId,
    userId: data.userId,
    appId: data.appId,
  });
};
```

**sendPush 핸들러에서 호출**:

```typescript
// Receipt 생성 후
const receipts = await createReceiptsForUsers({ ... });

pushProbe.receiptsCreated({
  alertId: alert.id,
  appId: app.id,
  userCount: targetUserIds.length,
});
```

### 5. 에러 처리

**기존 에러 클래스 재사용**:
- `NotFoundException`: 알림 미발견, 권한 없음
- `ValidationException`: 잘못된 입력 (Zod에서 자동 처리)

**신규 에러 코드**: 없음 (기존 코드로 충분)

**에러 시나리오**:

| 시나리오 | HTTP 상태 | 에러 코드 | 메시지 |
|---------|----------|----------|--------|
| 권한 없는 알림 접근 | 404 | NOT_FOUND | "Notification {id}을(를) 찾을 수 없습니다" |
| 다른 앱의 알림 접근 | 404 | NOT_FOUND | "Notification {id}을(를) 찾을 수 없습니다" |
| 인증되지 않은 요청 | 401 | INVALID_TOKEN | "유효하지 않은 토큰입니다" |
| 잘못된 쿼리 파라미터 | 400 | VALIDATION_ERROR | Zod 에러 메시지 |

**에러 처리 플로우**:

```
1. authenticate 미들웨어 → INVALID_TOKEN (401)
2. Zod 스키마 검증 → VALIDATION_ERROR (400)
3. Service 함수 권한 검증 → NOT_FOUND (404)
4. Global Error Handler → 일관된 응답 형식
```

### 6. 성능 최적화 전략

#### 6-1. 인덱스 전략

**복합 인덱스 활용**:
```sql
-- 사용자별 알림 목록 조회 (가장 빈번한 쿼리)
CREATE INDEX idx_push_notification_receipts_user_app_received
ON push_notification_receipts(user_id, app_id, received_at);

-- 읽지 않은 알림 필터링
CREATE INDEX idx_push_notification_receipts_is_read
ON push_notification_receipts(is_read);
```

**쿼리 최적화**:
- `WHERE user_id = ? AND app_id = ? ORDER BY received_at DESC` → 복합 인덱스 활용
- `WHERE user_id = ? AND app_id = ? AND is_read = false` → 복합 인덱스 + is_read 인덱스

#### 6-2. 배치 INSERT

**Receipt 생성 시 배치 처리**:
```typescript
// 1000명 대상 발송 시 1000개 레코드를 1번의 INSERT로 처리
const receipts = userIds.map((userId) => ({ ... }));
await db.insert(pushNotificationReceipts).values(receipts);  // Bulk insert
```

**성능 목표**:
- 1000명 대상 Receipt 생성: 1초 이내
- 사용자 알림 목록 조회 (20개): 100ms 이내

#### 6-3. 비정규화

**push_alerts 조인 회피**:
- `title`, `body`, `data`, `imageUrl`을 `push_notification_receipts`에 복사
- 알림 목록 조회 시 단일 테이블 스캔으로 성능 향상
- 트레이드오프: 저장 공간 증가 (허용 가능)

#### 6-4. 페이지네이션

**기본값**:
- `limit`: 20 (최대 100)
- `offset`: 0

**무한 스크롤 대응**:
- 클라이언트는 `offset` 증가시키며 페이지네이션
- 서버는 `LIMIT`, `OFFSET` SQL 문법으로 처리

### 7. 보안 설계

#### 7-1. 인증/인가 강화

**기존 엔드포인트 보안 개선**:

| 엔드포인트 | 변경 전 | 변경 후 |
|-----------|---------|---------|
| `POST /push/send` | 인증 없음 | ✅ `authenticate` 미들웨어 추가 |
| `GET /push/notifications` | 인증 없음 | ✅ `authenticate` 미들웨어 추가 (관리자 전용) |
| `GET /push/notifications/:id` | 인증 없음 | ✅ `authenticate` 미들웨어 추가 (관리자 전용) |

**추가 권한 검증 (향후 고려)**:
```typescript
// apps/server/src/middleware/admin-auth.ts
export const adminOnly = (req: Request, res: Response, next: NextFunction) => {
  const user = (req as any).user;

  // appMetadata에서 관리자 여부 확인 (예시)
  if (user.appMetadata?.role !== 'admin') {
    throw new UnauthorizedException('Admin access required', 'FORBIDDEN');
  }

  next();
};

// 사용 예시
router.post('/send', authenticate, adminOnly, sendPush);
```

#### 7-2. 데이터 격리

**앱별 격리**:
- 모든 쿼리에 `appId` 조건 포함
- JWT 토큰에서 추출한 `appId`로 필터링
- 다른 앱의 데이터 접근 불가

**사용자별 격리**:
- 알림 조회 시 `userId`, `appId` 모두 검증
- 다른 사용자의 알림 접근 불가 (404 응답)

#### 7-3. 민감 정보 보호

**로그 필터링**:
- 알림 내용(`title`, `body`)은 로그에 포함하지 않음 (개인정보 가능성)
- 운영 로그에는 ID, userId, appId만 기록

```typescript
// ❌ 나쁜 예시
logger.info('Notification created', {
  title: notification.title,  // 개인정보 포함 가능
  body: notification.body,    // 개인정보 포함 가능
});

// ✅ 좋은 예시
logger.info('Notification created', {
  notificationId: notification.id,
  userId: notification.userId,
  appId: notification.appId,
});
```

### 8. 데이터 정합성

#### 8-1. Receipt 생성 시점

**타이밍**: FCM 발송 성공 후 즉시

**트랜잭션 고려**:
```typescript
// 현재: 별도 트랜잭션 없음 (단순성 우선)
await sendToMultipleDevices(fcmInstance, tokens, message);
await createReceiptsForUsers({ ... });  // 별도 실행

// 향후 개선 (필요 시):
await db.transaction(async (tx) => {
  const result = await sendToMultipleDevices(...);
  await tx.insert(pushNotificationReceipts).values(...);
  await tx.update(pushAlerts).set(...);
});
```

**실패 시나리오**:
- FCM 발송 성공 → Receipt 생성 실패: 재시도 로직 없음 (로그만 기록)
- FCM 발송 실패 → Receipt 생성 안 함

#### 8-2. 읽음 상태 동기화

**멱등성 보장**:
```typescript
// 동일 알림 여러 번 읽음 처리해도 안전
await markNotificationAsRead(id, userId, appId);  // 첫 번째 호출: isRead = true, readAt = now
await markNotificationAsRead(id, userId, appId);  // 두 번째 호출: 기존 값 유지
```

**동시성 제어**:
- PostgreSQL의 행 레벨 잠금으로 자동 처리
- 중복 읽음 처리 요청 시 마지막 요청만 적용

### 9. 확장 가능성

#### 9-1. 향후 추가 기능

| 기능 | 우선순위 | 구현 방법 |
|------|---------|----------|
| 알림 전체 읽음 처리 | 중간 | `UPDATE ... WHERE user_id = ? AND is_read = false` |
| 알림 삭제 (소프트 삭제) | 낮음 | `deleted_at` 컬럼 추가 |
| 알림 카테고리/타입별 필터링 | 낮음 | `category` 컬럼 추가 |
| 알림 검색 | 낮음 | Full-text search 인덱스 |
| 알림 만료 정책 (30일) | 중간 | 배치 작업으로 오래된 레코드 삭제 |

#### 9-2. 스케일링 전략

**데이터베이스 파티셔닝** (대용량 시):
```sql
-- receivedAt 기준 월별 파티셔닝
CREATE TABLE push_notification_receipts_2026_02 PARTITION OF push_notification_receipts
FOR VALUES FROM ('2026-02-01') TO ('2026-03-01');
```

**캐싱 전략** (읽기 부하 높은 경우):
- 읽지 않은 알림 개수: Redis 캐시 (TTL: 1분)
- 최근 20개 알림: Redis 캐시 (TTL: 5분)

### 10. 테스트 전략

#### 10-1. 단위 테스트

**Service 함수 테스트**:
```typescript
// tests/unit/push-alert/services.test.ts
describe('createReceiptsForUsers', () => {
  it('should create receipts for all target users', async () => {
    const result = await createReceiptsForUsers({
      appId: 1,
      alertId: 1,
      userIds: [1, 2, 3],
      title: 'Test',
      body: 'Test body',
    });

    expect(result).toHaveLength(3);
    expect(result[0].userId).toBe(1);
  });

  it('should return empty array for empty userIds', async () => {
    const result = await createReceiptsForUsers({
      appId: 1,
      alertId: 1,
      userIds: [],
      title: 'Test',
      body: 'Test body',
    });

    expect(result).toHaveLength(0);
  });
});

describe('markNotificationAsRead', () => {
  it('should mark notification as read', async () => {
    const success = await markNotificationAsRead(1, 1, 1);
    expect(success).toBe(true);
  });

  it('should return false for non-existent notification', async () => {
    const success = await markNotificationAsRead(9999, 1, 1);
    expect(success).toBe(false);
  });

  it('should prevent access to other user notification', async () => {
    const success = await markNotificationAsRead(1, 999, 1);
    expect(success).toBe(false);
  });
});
```

**Handler 테스트**:
```typescript
// tests/unit/push-alert/handlers.test.ts
import { vi } from 'vitest';
import * as pushProbe from '../../../src/modules/push-alert/push.probe';

vi.mock('../../../src/modules/push-alert/push.probe');

describe('listMyNotifications', () => {
  it('should return user notifications', async () => {
    const mockReq = {
      query: { limit: '20', offset: '0' },
      user: { userId: 1, appId: 1 },
    };
    const mockRes = {
      json: vi.fn(),
    };

    await listMyNotifications(mockReq as any, mockRes as any);

    expect(mockRes.json).toHaveBeenCalledWith({
      notifications: expect.any(Array),
      total: expect.any(Number),
    });
  });
});

describe('markAsRead', () => {
  it('should log notification read event', async () => {
    const mockReq = {
      params: { id: '1' },
      user: { userId: 1, appId: 1 },
    };
    const mockRes = {
      json: vi.fn(),
    };

    await markAsRead(mockReq as any, mockRes as any);

    expect(pushProbe.notificationRead).toHaveBeenCalled();
    expect(mockRes.json).toHaveBeenCalledWith({ success: true });
  });
});
```

#### 10-2. 통합 테스트 (권장)

**전체 플로우 테스트**:
```typescript
// tests/integration/push-alert-flow.test.ts
describe('Push Notification Flow', () => {
  it('should create receipt and allow user to read', async () => {
    // 1. 알림 발송
    const sendRes = await request(app)
      .post('/push/send')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        appCode: 'wowa',
        userId: 1,
        title: 'Test',
        body: 'Test body',
      });

    expect(sendRes.status).toBe(200);

    // 2. 사용자 알림 목록 조회
    const listRes = await request(app)
      .get('/push/notifications/me')
      .set('Authorization', `Bearer ${userToken}`);

    expect(listRes.status).toBe(200);
    expect(listRes.body.notifications).toHaveLength(1);
    expect(listRes.body.notifications[0].isRead).toBe(false);

    // 3. 알림 읽음 처리
    const readRes = await request(app)
      .patch(`/push/notifications/${listRes.body.notifications[0].id}/read`)
      .set('Authorization', `Bearer ${userToken}`);

    expect(readRes.status).toBe(200);

    // 4. 읽음 상태 확인
    const listRes2 = await request(app)
      .get('/push/notifications/me')
      .set('Authorization', `Bearer ${userToken}`);

    expect(listRes2.body.notifications[0].isRead).toBe(true);
  });
});
```

### 11. 문서화

#### 11-1. OpenAPI (Swagger) 업데이트

**신규 엔드포인트 추가**:
```yaml
# apps/server/src/swagger.yaml (또는 코드 내 주석)

/push/notifications/me:
  get:
    summary: 내 알림 목록 조회
    tags:
      - Push Notifications
    security:
      - BearerAuth: []
    parameters:
      - name: limit
        in: query
        schema:
          type: integer
          default: 20
          maximum: 100
      - name: offset
        in: query
        schema:
          type: integer
          default: 0
      - name: unreadOnly
        in: query
        schema:
          type: boolean
    responses:
      '200':
        description: 알림 목록
        content:
          application/json:
            schema:
              type: object
              properties:
                notifications:
                  type: array
                  items:
                    $ref: '#/components/schemas/Notification'
                total:
                  type: integer

/push/notifications/unread-count:
  get:
    summary: 읽지 않은 알림 개수
    tags:
      - Push Notifications
    security:
      - BearerAuth: []
    responses:
      '200':
        description: 읽지 않은 알림 개수
        content:
          application/json:
            schema:
              type: object
              properties:
                unreadCount:
                  type: integer

/push/notifications/{id}/read:
  patch:
    summary: 알림 읽음 처리
    tags:
      - Push Notifications
    security:
      - BearerAuth: []
    parameters:
      - name: id
        in: path
        required: true
        schema:
          type: integer
    responses:
      '200':
        description: 읽음 처리 성공
        content:
          application/json:
            schema:
              type: object
              properties:
                success:
                  type: boolean
      '404':
        description: 알림을 찾을 수 없음
```

#### 11-2. server-catalog.md 업데이트

**파일**: `docs/wowa/server-catalog.md`

```markdown
### FCM 푸시 알림 (Push Alert)

- **상태**: ✅ 완료 (Receipt 기능 추가)
- **신규 기능**:
  - ✅ 사용자별 알림 수신 기록 (push_notification_receipts)
  - ✅ 읽음 상태 관리
  - ✅ 앱 내 알림 목록 API
  - ✅ 읽지 않은 알림 개수 API
- **API 엔드포인트**:
  | 메서드 | 경로 | 인증 | 설명 |
  |--------|------|------|------|
  | ... (기존 엔드포인트) |
  | GET | `/push/notifications/me` | ✅ | 내 알림 목록 |
  | GET | `/push/notifications/unread-count` | ✅ | 읽지 않은 개수 |
  | PATCH | `/push/notifications/:id/read` | ✅ | 읽음 처리 |
- **DB 테이블**: `push_device_tokens`, `push_alerts`, `push_notification_receipts` (신규)
```

## 작업 분배 계획

### Senior Developer 작업 (우선순위 순)

1. **스키마 정의 및 마이그레이션**
   - `schema.ts`에 `pushNotificationReceipts` 테이블 추가
   - `pnpm drizzle-kit generate && pnpm drizzle-kit migrate` 실행
   - 마이그레이션 검증 (로컬 DB)

2. **Service 함수 구현**
   - `services.ts`에 신규 함수 추가:
     - `createReceiptsForUsers`
     - `findNotificationsByUser`
     - `countUnreadNotifications`
     - `markNotificationAsRead`
     - `findNotificationById`
   - 단위 테스트 작성 (`tests/unit/push-alert/services.test.ts`)

3. **Handler 구현**
   - `handlers.ts`에 신규 핸들러 추가:
     - `listMyNotifications`
     - `getUnreadCount`
     - `markAsRead`
   - `sendPush` 핸들러 수정 (Receipt 생성 로직 추가)
   - 단위 테스트 작성 (`tests/unit/push-alert/handlers.test.ts`)

4. **Validator 추가**
   - `validators.ts`에 `listMyNotificationsSchema` 추가

5. **라우터 업데이트**
   - `index.ts`에 신규 라우트 추가
   - 기존 라우트에 `authenticate` 미들웨어 추가

6. **운영 로그 추가**
   - `push.probe.ts`에 `receiptsCreated`, `notificationRead` 함수 추가

7. **통합 테스트**
   - 전체 플로우 검증 (`tests/integration/push-alert-flow.test.ts`)

### Junior Developer 작업 (선택)

- OpenAPI 문서 업데이트 (`swagger.yaml` 또는 코드 주석)
- `server-catalog.md` 업데이트

### 작업 의존성

```
마이그레이션 → Service 함수 → Handler → 라우터 → 테스트
```

**예상 소요 시간**: Senior 3-4시간

## 검증 기준

### 기능 검증

- [ ] 알림 발송 시 Receipt가 대상 사용자별로 생성됨
- [ ] 사용자는 자신의 앱 알림만 조회 가능 (다른 앱/사용자 알림 접근 불가)
- [ ] 읽지 않은 알림 개수가 정확히 표시됨
- [ ] 알림 읽음 처리 후 `isRead = true`, `readAt` 업데이트됨
- [ ] 페이지네이션이 정상 작동함 (limit, offset)
- [ ] `unreadOnly=true` 필터링이 정상 작동함

### 보안 검증

- [ ] 인증되지 않은 요청은 401 응답
- [ ] 다른 사용자의 알림 접근 시 404 응답 (권한 오류 노출 방지)
- [ ] 다른 앱의 알림 접근 시 404 응답
- [ ] `/push/send` 엔드포인트에 인증 적용됨

### 성능 검증

- [ ] 1000명 대상 Receipt 생성: 1초 이내
- [ ] 알림 목록 조회 (20개): 100ms 이내
- [ ] 복합 인덱스가 쿼리에서 활용됨 (`EXPLAIN` 확인)

### 코드 품질

- [ ] Express 컨벤션 준수 (handler, service, validator 분리)
- [ ] API Response 가이드 준수 (camelCase, null 처리, ISO-8601)
- [ ] 예외 처리 가이드 준수 (AppException 계층, 추적 가능한 메시지)
- [ ] 로깅 가이드 준수 (Domain Probe 패턴, 민감 정보 제외)
- [ ] Drizzle ORM 패턴 준수 (FK 없음, 컬럼 주석)
- [ ] 단위 테스트 작성 완료

## 참고 자료

- **기존 분석**: `docs/core/fcm-push-notification.md`
- **서버 카탈로그**: `docs/wowa/server-catalog.md`
- **API 응답 설계**: `.claude/guide/server/api-response-design.md`
- **예외 처리**: `.claude/guide/server/exception-handling.md`
- **로깅**: `.claude/guide/server/logging-best-practices.md`
- **User Story**: `docs/wowa/push-alert/user-story.md`

## 마이그레이션 체크리스트

1. [ ] 로컬 환경에서 마이그레이션 실행 및 검증
2. [ ] Staging 환경 배포 전 백업
3. [ ] Staging 환경 마이그레이션 및 smoke test
4. [ ] Production 배포 전 롤백 계획 수립
5. [ ] Production 마이그레이션 (off-peak 시간대)
6. [ ] Production 모니터링 (에러 로그, 쿼리 성능)

## 향후 개선 사항 (Backlog)

| 우선순위 | 항목 | 설명 |
|---------|------|------|
| 높음 | 관리자 인가 미들웨어 | `/push/send` 엔드포인트에 Role 기반 인가 추가 |
| 중간 | 알림 만료 정책 | 30일 이상 된 Receipt 자동 삭제 배치 작업 |
| 중간 | 알림 전체 읽음 처리 | `PATCH /push/notifications/mark-all-read` API |
| 낮음 | 알림 카테고리/타입 필터링 | `category` 컬럼 추가 및 필터링 |
| 낮음 | 알림 검색 | Full-text search 인덱스 추가 |
| 낮음 | 알림 삭제 (소프트) | `deleted_at` 컬럼 추가 |

## 요약

### 신규 추가 사항

1. **테이블**: `push_notification_receipts` (사용자별 알림 수신 기록)
2. **API**: `GET /push/notifications/me`, `GET /push/notifications/unread-count`, `PATCH /push/notifications/:id/read`
3. **Service**: `createReceiptsForUsers`, `findNotificationsByUser`, `countUnreadNotifications`, `markNotificationAsRead`
4. **보안**: 모든 사용자 대상 API에 `authenticate` 미들웨어 추가

### 수정 사항

1. **sendPush 핸들러**: FCM 발송 후 Receipt 생성 로직 추가
2. **라우터**: 기존 관리자 API에 인증 미들웨어 추가

### 핵심 설계 결정

- **비정규화**: 알림 내용을 Receipt에 복사하여 조회 성능 최적화
- **앱별 격리**: 모든 쿼리에 `appId` 조건 포함
- **권한 검증**: Service 함수 레벨에서 `userId`, `appId` 검증
- **배치 INSERT**: 대량 사용자 대상 발송 시 성능 최적화

이 설계를 따르면 안전하고 확장 가능한 Push Notification 시스템을 구축할 수 있습니다.
