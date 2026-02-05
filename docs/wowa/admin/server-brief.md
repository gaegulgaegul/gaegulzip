# 서버 기술 설계: Admin 어드민 관리 시스템

## 개요

wowa 앱 운영을 위한 어드민 웹 애플리케이션의 서버 API를 설계합니다. 기존 OAuth 인증과 분리된 독립적인 어드민 인증 시스템을 구축하고, 사용자 관리 및 푸시 알림 관리 기능을 제공합니다.

**핵심 설계 전략**:
- 어드민 인증은 환경변수 기반 고정 크레덴셜 사용 (OAuth와 분리)
- 세션 기반 인증 (HttpOnly 쿠키, 1시간 만료)
- 기존 push-alert 모듈 재사용 (발송 및 이력 조회)
- 사용자 상태 관리 (활성/비활성화)
- Domain Probe 패턴으로 감사 로그 기록

---

## 모듈 구조

### 디렉토리 구조

```
apps/server/src/modules/admin/
├── index.ts                  # Router export
├── handlers.ts               # Request handlers
├── schema.ts                 # Drizzle schema (admin_sessions, admin_audit_logs)
├── validators.ts             # Zod validation schemas
├── middleware.ts             # adminAuth middleware
├── admin.probe.ts            # 운영 로그 (감사 로그)
└── services.ts               # DB 조작 로직 (필요 시)
```

---

## DB 스키마 설계

### 1. users 테이블 확장

기존 `users` 테이블에 컬럼 추가:

```typescript
// apps/server/src/modules/auth/schema.ts 수정

export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  appId: integer('app_id').notNull(),
  provider: varchar('provider', { length: 20 }).notNull(),
  providerId: varchar('provider_id', { length: 100 }).notNull(),
  email: varchar('email', { length: 255 }),
  nickname: varchar('nickname', { length: 255 }),
  profileImage: varchar('profile_image', { length: 500 }),
  appMetadata: jsonb('app_metadata').default({}),
  lastLoginAt: timestamp('last_login_at'),

  // 🆕 어드민 기능 추가
  /** 사용자 활성 상태 (기본: true) */
  isActive: boolean('is_active').notNull().default(true),
  /** 비활성화 이유 (비활성화 시 필수) */
  deactivatedReason: varchar('deactivated_reason', { length: 500 }),
  /** 비활성화 시간 */
  deactivatedAt: timestamp('deactivated_at'),

  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
}, (table) => ({
  uniqueProviderUser: unique().on(table.appId, table.provider, table.providerId),
  isActiveIdx: index('idx_users_is_active').on(table.isActive), // 🆕 조회 성능 향상
}));
```

**설계 근거**:
- `isActive`: Boolean (NOT NULL) - 쿼리 성능 우수, 인덱스 활용
- `deactivatedReason`: 감사 목적, 복구 시 참고
- `deactivatedAt`: 시간 정보 (통계, 감사 로그)

### 2. admin_sessions 테이블 (새로 생성)

```typescript
// apps/server/src/modules/admin/schema.ts

export const adminSessions = pgTable('admin_sessions', {
  /** 고유 ID */
  id: serial('id').primaryKey(),
  /** 세션 토큰 해시 (bcrypt) */
  sessionHash: varchar('session_hash', { length: 255 }).notNull().unique(),
  /** 세션 ID (클라이언트 쿠키에 저장, UUID v4) */
  sessionId: varchar('session_id', { length: 36 }).notNull().unique(),
  /** 만료 시간 (1시간) */
  expiresAt: timestamp('expires_at').notNull(),
  /** 생성 시간 */
  createdAt: timestamp('created_at').defaultNow(),
}, (table) => ({
  sessionIdIdx: index('idx_admin_sessions_session_id').on(table.sessionId),
  expiresAtIdx: index('idx_admin_sessions_expires_at').on(table.expiresAt),
}));
```

**설계 근거**:
- 세션 토큰은 bcrypt 해싱 (보안)
- 클라이언트는 `sessionId`를 HttpOnly 쿠키로 저장
- 만료 시간 인덱스로 정리 쿼리 최적화

### 3. admin_audit_logs 테이블 (감사 로그)

```typescript
// apps/server/src/modules/admin/schema.ts

export const adminAuditLogs = pgTable('admin_audit_logs', {
  /** 고유 ID */
  id: serial('id').primaryKey(),
  /** 작업 타입 (user_deactivate, user_activate, tokens_revoke, push_send) */
  action: varchar('action', { length: 50 }).notNull(),
  /** 대상 사용자 ID (사용자 관련 작업) */
  targetUserId: integer('target_user_id'),
  /** 작업 상세 데이터 (JSON) */
  details: jsonb('details').default({}),
  /** 작업 시간 */
  createdAt: timestamp('created_at').defaultNow(),
}, (table) => ({
  actionIdx: index('idx_admin_audit_logs_action').on(table.action),
  targetUserIdIdx: index('idx_admin_audit_logs_target_user_id').on(table.targetUserId),
  createdAtIdx: index('idx_admin_audit_logs_created_at').on(table.createdAt),
}));
```

**설계 근거**:
- 모든 중요 관리 작업 기록
- 감사 추적 및 문제 해결에 활용
- 90일 이후 자동 삭제 (선택 사항, 배치 작업)

---

## API 엔드포인트 설계

### 인증 없이 접근 가능

#### 1. POST /admin/login

어드민 로그인 (환경변수 크레덴셜 검증)

**요청**:
```typescript
{
  username: string;   // ADMIN_USERNAME 환경변수와 비교
  password: string;   // ADMIN_PASSWORD 환경변수와 비교
}
```

**응답** (200):
```typescript
{
  sessionId: string;  // HttpOnly 쿠키로도 설정됨
  expiresAt: string;  // ISO-8601
}
```

**에러**:
- 401: 인증 정보 불일치

**동작**:
1. 환경변수 `ADMIN_USERNAME`, `ADMIN_PASSWORD`와 비교
2. 일치 시 UUID v4 세션 ID 생성
3. bcrypt 해싱 후 `admin_sessions` 저장
4. HttpOnly 쿠키에 `sessionId` 설정 (1시간 만료)
5. Probe: `adminProbe.loginSuccess()`

---

### 어드민 인증 필요 (adminAuth 미들웨어)

#### 2. POST /admin/logout

어드민 로그아웃 (세션 무효화)

**요청**: 없음 (쿠키에서 sessionId 추출)

**응답** (204): No Content

**에러**:
- 401: 세션 없음 또는 만료

**동작**:
1. 쿠키에서 `sessionId` 추출
2. `admin_sessions`에서 해당 세션 삭제
3. 쿠키 제거
4. Probe: `adminProbe.logoutSuccess()`

---

#### 3. GET /admin/users

사용자 목록 조회 (페이지네이션, 검색, 정렬)

**쿼리 파라미터**:
```typescript
{
  page?: number;           // 기본: 1
  pageSize?: number;       // 기본: 20, 최대: 100
  search?: string;         // 이메일 또는 닉네임 검색
  provider?: string;       // 제공자 필터 (kakao, naver, google, apple)
  isActive?: boolean;      // 활성 상태 필터
  sortBy?: 'createdAt' | 'lastLoginAt';  // 정렬 기준 (기본: createdAt)
  sortOrder?: 'asc' | 'desc';            // 정렬 순서 (기본: desc)
}
```

**응답** (200):
```typescript
{
  items: {
    id: number;
    email: string | null;
    nickname: string | null;
    provider: string;
    profileImage: string | null;
    isActive: boolean;
    lastLoginAt: string | null;    // ISO-8601
    createdAt: string;              // ISO-8601
  }[];
  totalCount: number;
  page: number;
  pageSize: number;
  hasNext: boolean;
}
```

**동작**:
1. 쿼리 파라미터 검증 (Zod)
2. Drizzle ORM으로 조건부 쿼리 (검색, 필터, 정렬)
3. 페이지네이션 적용

---

#### 4. GET /admin/users/:id

사용자 상세 정보 조회

**응답** (200):
```typescript
{
  id: number;
  email: string | null;
  nickname: string | null;
  provider: string;
  providerId: string;
  profileImage: string | null;
  isActive: boolean;
  deactivatedReason: string | null;
  deactivatedAt: string | null;   // ISO-8601
  lastLoginAt: string | null;     // ISO-8601
  createdAt: string;               // ISO-8601
  updatedAt: string;               // ISO-8601

  // 추가 정보
  activeTokenCount: number;        // refresh_tokens에서 카운트
  totalPushReceived: number;       // push_alerts에서 카운트
}
```

**에러**:
- 404: 사용자 없음

**동작**:
1. `users` 테이블에서 조회
2. `refresh_tokens`에서 활성 토큰 수 카운트
3. `push_alerts`에서 수신 푸시 수 카운트

---

#### 5. POST /admin/users/:id/deactivate

사용자 계정 비활성화

**요청**:
```typescript
{
  reason: string;  // 최대 500자
}
```

**응답** (200):
```typescript
{
  success: true;
  userId: number;
  deactivatedAt: string;  // ISO-8601
}
```

**에러**:
- 404: 사용자 없음
- 400: 이미 비활성화됨

**동작**:
1. `users` 테이블 업데이트: `isActive = false`, `deactivatedReason`, `deactivatedAt`
2. 해당 사용자의 모든 Refresh Token 무효화
3. 감사 로그 기록: `admin_audit_logs`
4. Probe: `adminProbe.userDeactivated(userId, reason)`

---

#### 6. POST /admin/users/:id/activate

사용자 계정 재활성화

**요청**: 없음

**응답** (200):
```typescript
{
  success: true;
  userId: number;
  activatedAt: string;  // ISO-8601
}
```

**에러**:
- 404: 사용자 없음
- 400: 이미 활성화됨

**동작**:
1. `users` 테이블 업데이트: `isActive = true`, `deactivatedReason = null`, `deactivatedAt = null`
2. 감사 로그 기록
3. Probe: `adminProbe.userActivated(userId)`

---

#### 7. POST /admin/users/:id/revoke-tokens

사용자의 모든 Refresh Token 무효화

**요청**: 없음

**응답** (200):
```typescript
{
  success: true;
  revokedCount: number;
}
```

**에러**:
- 404: 사용자 없음

**동작**:
1. `refresh_tokens` 테이블에서 해당 사용자의 모든 토큰을 `revoked = true`, `revokedAt = NOW()`로 업데이트
2. 감사 로그 기록
3. Probe: `adminProbe.tokensRevoked(userId, count)`

---

#### 8. GET /admin/dashboard/stats

대시보드 통계

**응답** (200):
```typescript
{
  totalUsers: number;                // 전체 사용자 수
  activeUsers: number;               // isActive = true
  todayNewUsers: number;             // 오늘 가입
  last7DaysNewUsers: {               // 최근 7일 일별 가입 추이
    date: string;                    // YYYY-MM-DD
    count: number;
  }[];
  providerDistribution: {            // 제공자별 비율
    provider: string;
    count: number;
    percentage: number;
  }[];
  recentPushCount: number;           // 최근 24시간 푸시 발송 수
  activeUsersLast30Days: number;     // 최근 30일 로그인 사용자 수
}
```

**동작**:
1. 각 통계를 병렬로 쿼리 (`Promise.all`)
2. 캐싱 (선택 사항, 5분 TTL)

---

#### 9. POST /admin/push/send

푸시 알림 발송 (기존 push-alert 모듈 재사용)

**요청**:
```typescript
{
  title: string;           // 최대 50자
  body: string;            // 최대 200자
  targetType: 'all' | 'specific';
  targetUserIds?: number[];  // targetType = 'specific'일 때 필수
  data?: Record<string, any>;  // 커스텀 데이터 (선택)
}
```

**응답** (200):
```typescript
{
  alertId: number;          // push_alerts.id
  targetCount: number;      // 발송 대상 수
  status: 'pending';        // 발송 시작
}
```

**에러**:
- 400: 유효성 검증 실패, 대상 없음

**동작**:
1. 기존 `POST /push/send` 핸들러 재사용 (내부 호출)
2. `targetType = 'all'`인 경우 `isActive = true`인 사용자만 대상
3. 감사 로그 기록
4. Probe: `adminProbe.pushSent(alertId, targetCount)`

---

#### 10. GET /admin/push/notifications

푸시 알림 발송 이력 (기존 모듈 재사용)

**쿼리 파라미터**:
```typescript
{
  page?: number;
  pageSize?: number;
  status?: 'pending' | 'completed' | 'failed';
}
```

**응답** (200):
```typescript
{
  items: {
    id: number;
    title: string;
    targetType: string;
    sentCount: number;
    failedCount: number;
    status: string;
    createdAt: string;  // ISO-8601
    sentAt: string | null;
  }[];
  totalCount: number;
  page: number;
  pageSize: number;
  hasNext: boolean;
}
```

**동작**:
- 기존 `GET /push/notifications` 재사용 (관리자 전용이므로 필터링 불필요)

---

#### 11. GET /admin/push/notifications/:id

푸시 알림 상세 조회 (기존 모듈 재사용)

**응답** (200):
```typescript
{
  id: number;
  title: string;
  body: string;
  targetType: string;
  targetUserIds: number[] | null;
  sentCount: number;
  failedCount: number;
  status: string;
  errorMessage: string | null;
  createdAt: string;
  sentAt: string | null;
  data: Record<string, any> | null;
}
```

**동작**:
- 기존 `GET /push/notifications/:id` 재사용

---

## Middleware 설계

### adminAuth 미들웨어

```typescript
// apps/server/src/modules/admin/middleware.ts

import { Request, Response, NextFunction } from 'express';
import { UnauthorizedException } from '../../utils/errors';
import { db } from '../../config/database';
import { adminSessions } from './schema';
import { eq, gt } from 'drizzle-orm';
import bcrypt from 'bcrypt';

/**
 * 어드민 세션 검증 미들웨어
 * HttpOnly 쿠키에서 sessionId를 추출하여 검증
 */
export const adminAuth = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    // 1. 쿠키에서 sessionId 추출
    const sessionId = req.cookies?.adminSessionId;

    if (!sessionId) {
      throw new UnauthorizedException('No admin session', 'ADMIN_SESSION_REQUIRED');
    }

    // 2. DB에서 세션 조회 (만료되지 않은 세션만)
    const [session] = await db
      .select()
      .from(adminSessions)
      .where(eq(adminSessions.sessionId, sessionId))
      .where(gt(adminSessions.expiresAt, new Date()));

    if (!session) {
      throw new UnauthorizedException('Invalid or expired admin session', 'ADMIN_SESSION_INVALID');
    }

    // 3. 세션 검증 성공 (필요 시 req.admin 설정)
    (req as any).admin = {
      sessionId: session.sessionId,
      expiresAt: session.expiresAt,
    };

    next();
  } catch (error) {
    next(error);
  }
};
```

**적용**:
```typescript
// apps/server/src/modules/admin/index.ts

import { Router } from 'express';
import * as handlers from './handlers';
import { adminAuth } from './middleware';

const router = Router();

// 인증 불필요
router.post('/login', handlers.login);

// 인증 필요 (adminAuth 미들웨어 적용)
router.post('/logout', adminAuth, handlers.logout);
router.get('/users', adminAuth, handlers.getUsers);
router.get('/users/:id', adminAuth, handlers.getUserById);
router.post('/users/:id/deactivate', adminAuth, handlers.deactivateUser);
router.post('/users/:id/activate', adminAuth, handlers.activateUser);
router.post('/users/:id/revoke-tokens', adminAuth, handlers.revokeTokens);
router.get('/dashboard/stats', adminAuth, handlers.getDashboardStats);
router.post('/push/send', adminAuth, handlers.sendPush);
router.get('/push/notifications', adminAuth, handlers.getPushNotifications);
router.get('/push/notifications/:id', adminAuth, handlers.getPushNotificationById);

export default router;
```

---

## Zod Validation Schemas

```typescript
// apps/server/src/modules/admin/validators.ts

import { z } from 'zod';

/**
 * 로그인 요청
 */
export const loginSchema = z.object({
  username: z.string().min(1, '사용자명을 입력하세요'),
  password: z.string().min(1, '비밀번호를 입력하세요'),
});

/**
 * 사용자 목록 쿼리
 */
export const getUsersQuerySchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  pageSize: z.coerce.number().int().positive().max(100).default(20),
  search: z.string().optional(),
  provider: z.enum(['kakao', 'naver', 'google', 'apple']).optional(),
  isActive: z.coerce.boolean().optional(),
  sortBy: z.enum(['createdAt', 'lastLoginAt']).default('createdAt'),
  sortOrder: z.enum(['asc', 'desc']).default('desc'),
});

/**
 * 사용자 비활성화 요청
 */
export const deactivateUserSchema = z.object({
  reason: z.string().min(1, '비활성화 이유를 입력하세요').max(500, '최대 500자까지 입력 가능합니다'),
});

/**
 * 푸시 발송 요청
 */
export const sendPushSchema = z.object({
  title: z.string().min(1).max(50, '제목은 최대 50자입니다'),
  body: z.string().min(1).max(200, '내용은 최대 200자입니다'),
  targetType: z.enum(['all', 'specific']),
  targetUserIds: z.array(z.number().int().positive()).optional(),
  data: z.record(z.any()).optional(),
}).refine(
  (data) => data.targetType === 'all' || (data.targetUserIds && data.targetUserIds.length > 0),
  { message: 'targetType이 specific일 때 targetUserIds는 필수입니다' }
);

/**
 * 푸시 목록 쿼리
 */
export const getPushNotificationsQuerySchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  pageSize: z.coerce.number().int().positive().max(100).default(20),
  status: z.enum(['pending', 'completed', 'failed']).optional(),
});
```

---

## Domain Probe 설계 (감사 로그)

```typescript
// apps/server/src/modules/admin/admin.probe.ts

import { logger } from '../../utils/logger';
import { db } from '../../config/database';
import { adminAuditLogs } from './schema';

/**
 * 어드민 로그인 성공
 */
export const loginSuccess = () => {
  logger.info('Admin logged in successfully');
};

/**
 * 어드민 로그아웃 성공
 */
export const logoutSuccess = () => {
  logger.info('Admin logged out');
};

/**
 * 사용자 비활성화 (감사 로그 + DB)
 */
export const userDeactivated = async (userId: number, reason: string) => {
  logger.warn('User account deactivated by admin', { userId, reason });

  await db.insert(adminAuditLogs).values({
    action: 'user_deactivate',
    targetUserId: userId,
    details: { reason },
  });
};

/**
 * 사용자 재활성화 (감사 로그 + DB)
 */
export const userActivated = async (userId: number) => {
  logger.info('User account activated by admin', { userId });

  await db.insert(adminAuditLogs).values({
    action: 'user_activate',
    targetUserId: userId,
    details: {},
  });
};

/**
 * 모든 토큰 무효화 (감사 로그 + DB)
 */
export const tokensRevoked = async (userId: number, count: number) => {
  logger.warn('All tokens revoked by admin', { userId, count });

  await db.insert(adminAuditLogs).values({
    action: 'tokens_revoke',
    targetUserId: userId,
    details: { revokedCount: count },
  });
};

/**
 * 푸시 알림 발송 (감사 로그 + DB)
 */
export const pushSent = async (alertId: number, targetCount: number, targetType: string) => {
  logger.info('Push notification sent by admin', { alertId, targetCount, targetType });

  await db.insert(adminAuditLogs).values({
    action: 'push_send',
    targetUserId: null,
    details: { alertId, targetCount, targetType },
  });
};
```

---

## 기존 모듈 재사용 계획

### 1. push-alert 모듈

**재사용 엔드포인트**:
- `POST /push/send` → 어드민에서 내부 호출
- `GET /push/notifications` → 어드민에서 그대로 사용
- `GET /push/notifications/:id` → 어드민에서 그대로 사용

**수정 불필요**:
- 기존 핸들러와 스키마를 그대로 사용
- 어드민 API는 `/admin/push/*`로 프록시 또는 직접 핸들러 import

**구현 방법**:
```typescript
// apps/server/src/modules/admin/handlers.ts

import * as pushHandlers from '../push-alert/handlers';

/**
 * 푸시 발송 (push-alert 모듈 재사용)
 */
export const sendPush = async (req: Request, res: Response) => {
  // 1. 검증
  const validated = sendPushSchema.parse(req.body);

  // 2. targetType = 'all'인 경우, isActive = true인 사용자만 대상
  if (validated.targetType === 'all') {
    const activeUsers = await db
      .select({ id: users.id })
      .from(users)
      .where(eq(users.isActive, true));

    if (activeUsers.length === 0) {
      throw new ValidationException('발송 대상이 없습니다');
    }

    // 내부적으로 push-alert 핸들러 호출
    req.body = {
      appCode: 'wowa',
      title: validated.title,
      body: validated.body,
      targetType: 'multiple',
      targetUserIds: activeUsers.map(u => u.id),
      data: validated.data,
    };
  } else {
    // specific인 경우 그대로 전달
    req.body = {
      appCode: 'wowa',
      title: validated.title,
      body: validated.body,
      targetType: 'multiple',
      targetUserIds: validated.targetUserIds,
      data: validated.data,
    };
  }

  // 3. push-alert 핸들러 호출
  await pushHandlers.sendPush(req, res);

  // 4. 감사 로그
  const alertId = res.locals.alertId; // push 핸들러가 설정한다고 가정
  await adminProbe.pushSent(alertId, validated.targetUserIds?.length || 0, validated.targetType);
};
```

### 2. auth 모듈

**재사용 로직**:
- Refresh Token 무효화 로직 (`revoked = true` 업데이트)

**구현 방법**:
```typescript
// apps/server/src/modules/admin/handlers.ts

export const revokeTokens = async (req: Request, res: Response) => {
  const { id } = req.params;

  // 1. 사용자 존재 확인
  const [user] = await db.select().from(users).where(eq(users.id, Number(id)));
  if (!user) {
    throw new NotFoundException('User', id);
  }

  // 2. 모든 Refresh Token 무효화
  const result = await db
    .update(refreshTokens)
    .set({ revoked: true, revokedAt: new Date() })
    .where(eq(refreshTokens.userId, user.id))
    .where(eq(refreshTokens.revoked, false));

  const count = result.rowCount || 0;

  // 3. 감사 로그
  await adminProbe.tokensRevoked(user.id, count);

  res.json({ success: true, revokedCount: count });
};
```

---

## 에러 처리 전략

### 새로운 에러 코드 추가

```typescript
// apps/server/src/utils/errors.ts 확장

export enum ErrorCode {
  // ... 기존 코드 ...

  // Admin 관련
  ADMIN_SESSION_REQUIRED = 'ADMIN_SESSION_REQUIRED',
  ADMIN_SESSION_INVALID = 'ADMIN_SESSION_INVALID',
  ADMIN_SESSION_EXPIRED = 'ADMIN_SESSION_EXPIRED',
  ADMIN_AUTH_FAILED = 'ADMIN_AUTH_FAILED',
  USER_ALREADY_DEACTIVATED = 'USER_ALREADY_DEACTIVATED',
  USER_ALREADY_ACTIVE = 'USER_ALREADY_ACTIVE',
  NO_PUSH_TARGET = 'NO_PUSH_TARGET',
}
```

### 핸들러 에러 처리

기존 Global Error Handler를 그대로 사용:
- 예외 던지기만 하고 try-catch 사용 안 함
- `UnauthorizedException`, `ValidationException`, `NotFoundException` 활용

**예시**:
```typescript
export const login = async (req: Request, res: Response) => {
  const { username, password } = loginSchema.parse(req.body);

  if (
    username !== process.env.ADMIN_USERNAME ||
    password !== process.env.ADMIN_PASSWORD
  ) {
    throw new UnauthorizedException('Invalid admin credentials', 'ADMIN_AUTH_FAILED');
  }

  // 세션 생성 로직...
};
```

---

## 환경 변수 추가

```bash
# .env

# Admin 인증
ADMIN_USERNAME=admin           # 어드민 로그인 사용자명
ADMIN_PASSWORD=secure_password # 어드민 로그인 비밀번호 (프로덕션에서 강력한 비밀번호 사용)
```

**보안 권장 사항**:
- `ADMIN_PASSWORD`는 bcrypt 해싱하여 환경변수에 저장 (선택 사항)
- 프로덕션에서는 비밀 관리 도구 (AWS Secrets Manager, Vercel Secrets 등) 사용

---

## 성능 최적화 전략

### 1. 인덱스 활용

- `users.isActive` 인덱스 추가 (활성 사용자 필터링 최적화)
- `admin_sessions.expiresAt` 인덱스로 만료 세션 정리 최적화
- `admin_audit_logs.createdAt` 인덱스로 이력 조회 최적화

### 2. 쿼리 최적화

- 대시보드 통계는 `Promise.all`로 병렬 쿼리
- 페이지네이션에서 `COUNT(*)`와 `SELECT` 분리하여 병렬 실행

### 3. 캐싱 (선택 사항)

- 대시보드 통계: 5분 TTL 캐시 (Redis 또는 메모리)
- 사용자 목록: 캐시 불필요 (실시간 데이터 필요)

---

## 마이그레이션 계획

### 1. users 테이블 확장

```bash
cd /Users/lms/dev/repository/gaegulzip/apps/server
pnpm drizzle-kit generate
pnpm drizzle-kit migrate
```

**마이그레이션 파일 예시**:
```sql
ALTER TABLE users
  ADD COLUMN is_active BOOLEAN NOT NULL DEFAULT true,
  ADD COLUMN deactivated_reason VARCHAR(500),
  ADD COLUMN deactivated_at TIMESTAMP;

CREATE INDEX idx_users_is_active ON users(is_active);
```

### 2. admin_sessions 테이블 생성

```sql
CREATE TABLE admin_sessions (
  id SERIAL PRIMARY KEY,
  session_hash VARCHAR(255) NOT NULL UNIQUE,
  session_id VARCHAR(36) NOT NULL UNIQUE,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_admin_sessions_session_id ON admin_sessions(session_id);
CREATE INDEX idx_admin_sessions_expires_at ON admin_sessions(expires_at);
```

### 3. admin_audit_logs 테이블 생성

```sql
CREATE TABLE admin_audit_logs (
  id SERIAL PRIMARY KEY,
  action VARCHAR(50) NOT NULL,
  target_user_id INTEGER,
  details JSONB DEFAULT '{}',
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_admin_audit_logs_action ON admin_audit_logs(action);
CREATE INDEX idx_admin_audit_logs_target_user_id ON admin_audit_logs(target_user_id);
CREATE INDEX idx_admin_audit_logs_created_at ON admin_audit_logs(created_at);
```

---

## 작업 분배 계획 (CTO 참조)

### Senior Developer 작업

1. **DB 스키마 설계 및 마이그레이션**
   - `apps/server/src/modules/admin/schema.ts` 작성
   - `users` 테이블 확장 (auth/schema.ts 수정)
   - `pnpm drizzle-kit generate && pnpm drizzle-kit migrate` 실행

2. **Middleware 및 Probe 작성**
   - `apps/server/src/modules/admin/middleware.ts` (adminAuth)
   - `apps/server/src/modules/admin/admin.probe.ts`

3. **Validator 작성**
   - `apps/server/src/modules/admin/validators.ts`

4. **핵심 핸들러 작성**
   - `apps/server/src/modules/admin/handlers.ts`
   - 로그인/로그아웃
   - 사용자 비활성화/활성화
   - 토큰 무효화
   - 대시보드 통계

5. **Router 설정**
   - `apps/server/src/modules/admin/index.ts`
   - `app.ts`에 `/admin` 라우터 마운트

6. **에러 코드 추가**
   - `utils/errors.ts` 확장

### Junior Developer 작업

1. **단순 CRUD 핸들러**
   - 사용자 목록 조회 (페이지네이션)
   - 사용자 상세 조회

2. **푸시 알림 프록시 핸들러**
   - `sendPush`, `getPushNotifications`, `getPushNotificationById`
   - 기존 push-alert 핸들러 재사용

3. **테스트 작성 (선택 사항)**
   - 핸들러 단위 테스트

### 작업 의존성

- Junior는 Senior의 스키마, Middleware, Validator 완성 후 시작
- Probe 작성은 Senior가 먼저 완료해야 함 (핸들러에서 사용)

---

## 검증 기준

- [ ] 어드민 로그인/로그아웃 정상 동작
- [ ] 세션 만료 시 401 에러 반환
- [ ] 사용자 비활성화 시 모든 토큰 무효화
- [ ] 비활성 사용자는 푸시 발송 대상에서 제외
- [ ] 감사 로그가 `admin_audit_logs`에 기록됨
- [ ] 대시보드 통계가 정확하게 표시됨
- [ ] 기존 push-alert 모듈과 충돌 없음
- [ ] CLAUDE.md 표준 준수 (Express 패턴, Drizzle ORM, Domain Probe)

---

## 참고 자료

- Express 핸들러 패턴: `apps/server/src/modules/auth/handlers.ts`
- Drizzle 스키마 예시: `apps/server/src/modules/auth/schema.ts`
- Domain Probe 패턴: `.claude/guide/server/logging-best-practices.md`
- API Response 설계: `.claude/guide/server/api-response-design.md`
- 예외 처리: `.claude/guide/server/exception-handling.md`

---

## 보안 고려사항

### 1. 세션 관리

- HttpOnly 쿠키로 XSS 방지
- Secure 플래그 (HTTPS 프로덕션 환경)
- SameSite 속성으로 CSRF 방지
- 1시간 만료 (짧은 세션 수명)

### 2. 환경변수 보호

- `.env` 파일은 `.gitignore`에 포함
- 프로덕션 환경변수는 Vercel Secrets 사용
- `ADMIN_PASSWORD`는 강력한 비밀번호 사용 (최소 16자, 특수문자 포함)

### 3. 감사 로그

- 모든 중요 작업 기록 (비활성화, 토큰 무효화, 푸시 발송)
- 로그 삭제 불가 (90일 이후 자동 아카이빙)

### 4. 입력 검증

- 모든 입력은 Zod로 검증
- SQL Injection 방지 (Drizzle ORM 파라미터 바인딩)

---

**다음 단계**: CTO 검토 후 Senior/Junior Developer에게 작업 분배
