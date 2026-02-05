# 서버 기술 설계: 공지사항 (Notice)

## 개요

공지사항 기능의 서버 API 설계 문서입니다. 멀티테넌트 구조를 지원하여 `appCode`로 앱별 공지사항을 분리하고, 관리자 CRUD와 사용자 조회 API를 제공합니다.

**설계 목표**:
- appCode 기반 멀티테넌트 분리
- 기존 auth, push-alert 모듈 패턴 준수
- RESTful API 설계
- Drizzle ORM 활용
- Domain Probe 패턴으로 운영 로그 분리

## 모듈 구조

### 디렉토리 구조

```
apps/server/src/modules/notice/
├── index.ts              # Router export
├── handlers.ts           # Express request handlers
├── services.ts           # DB 로직 (필요 시)
├── schema.ts             # Drizzle 테이블 정의
├── validators.ts         # Zod 유효성 검증
├── types.ts              # TypeScript 타입
└── notice.probe.ts       # Domain Probe (운영 로그)
```

**파일별 역할**:
- **schema.ts**: notices, notice_reads 테이블 정의
- **handlers.ts**: 비즈니스 로직 직접 작성 (Controller/Service 분리 X)
- **services.ts**: 복잡한 DB 쿼리만 분리 (YAGNI)
- **validators.ts**: 요청 데이터 Zod 검증
- **notice.probe.ts**: 운영 로그 전담 (INFO, WARN, ERROR)
- **index.ts**: Express Router 설정

## Drizzle DB 스키마

### notices 테이블

```typescript
// apps/server/src/modules/notice/schema.ts
import { pgTable, serial, varchar, text, boolean, integer, timestamp, index } from 'drizzle-orm/pg-core';

/**
 * 공지사항 테이블 (앱별 공지사항 관리)
 */
export const notices = pgTable('notices', {
  /** 고유 ID */
  id: serial('id').primaryKey(),
  /** 앱 코드 (외래키, FK 제약조건 없음) */
  appCode: varchar('app_code', { length: 50 }).notNull(),
  /** 공지사항 제목 (1~200자) */
  title: varchar('title', { length: 200 }).notNull(),
  /** 공지사항 본문 (마크다운 형식) */
  content: text('content').notNull(),
  /** 카테고리 (선택, 최대 50자) */
  category: varchar('category', { length: 50 }),
  /** 상단 고정 여부 */
  isPinned: boolean('is_pinned').notNull().default(false),
  /** 조회수 */
  viewCount: integer('view_count').notNull().default(0),
  /** 작성자 ID (외래키, FK 제약조건 없음) */
  authorId: integer('author_id'),
  /** 생성 시간 */
  createdAt: timestamp('created_at').defaultNow().notNull(),
  /** 수정 시간 */
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
  /** 삭제 시간 (soft delete) */
  deletedAt: timestamp('deleted_at'),
}, (table) => ({
  /** 앱별 조회 성능 향상 */
  appCodeIdx: index('idx_notices_app_code').on(table.appCode),
  /** 고정 공지 필터링 */
  isPinnedIdx: index('idx_notices_is_pinned').on(table.isPinned),
  /** 삭제되지 않은 공지 조회 */
  deletedAtIdx: index('idx_notices_deleted_at').on(table.deletedAt),
  /** 최신순 정렬 */
  createdAtIdx: index('idx_notices_created_at').on(table.createdAt),
  /** 카테고리별 조회 */
  categoryIdx: index('idx_notices_category').on(table.category),
}));
```

**설계 근거**:
- `appCode`: 멀티테넌트 분리 (앱별 독립 데이터)
- `isPinned`: 고정 공지 상단 표시
- `viewCount`: 조회수 카운트 (정확도 낮아도 무방)
- `deletedAt`: Soft delete (복구 가능)
- FK 제약조건 없음: 앱 레벨에서 관계 관리 (기존 패턴)

### notice_reads 테이블

```typescript
/**
 * 공지사항 읽음 상태 테이블 (사용자별 읽음 추적)
 */
export const noticeReads = pgTable('notice_reads', {
  /** 고유 ID */
  id: serial('id').primaryKey(),
  /** 공지사항 ID (외래키, FK 제약조건 없음) */
  noticeId: integer('notice_id').notNull(),
  /** 사용자 ID (외래키, FK 제약조건 없음) */
  userId: integer('user_id').notNull(),
  /** 읽은 시간 */
  readAt: timestamp('read_at').defaultNow().notNull(),
}, (table) => ({
  /** 중복 읽음 방지 (동일 공지사항을 같은 사용자가 여러 번 읽음 처리 안 함) */
  uniqueUserNotice: unique().on(table.noticeId, table.userId),
  /** 사용자별 읽음 목록 조회 */
  userIdIdx: index('idx_notice_reads_user_id').on(table.userId),
  /** 공지사항별 읽음 통계 */
  noticeIdIdx: index('idx_notice_reads_notice_id').on(table.noticeId),
}));
```

**설계 근거**:
- UNIQUE(noticeId, userId): 중복 읽음 방지
- 사용자별, 공지사항별 독립 읽음 상태 관리

## API 엔드포인트 명세

### 1. 공지사항 목록 조회 (사용자)

```
GET /notices
```

**Query Parameters**:
```typescript
{
  page?: number;        // 페이지 번호 (기본: 1)
  limit?: number;       // 페이지 크기 (기본: 20)
  category?: string;    // 카테고리 필터
  pinnedOnly?: boolean; // 고정 공지만 조회
}
```

**Request Headers**:
```
Authorization: Bearer <JWT>
```

**Response (200)**:
```typescript
{
  items: [
    {
      id: number;
      title: string;
      category: string | null;
      isPinned: boolean;
      isRead: boolean;        // 현재 사용자의 읽음 상태
      viewCount: number;
      createdAt: string;      // ISO-8601
    }
  ];
  totalCount: number;
  page: number;
  limit: number;
  hasNext: boolean;
}
```

**비즈니스 로직**:
1. JWT에서 userId, appCode 추출
2. deletedAt IS NULL 조건 (삭제된 공지 제외)
3. appCode 필터링 (멀티테넌트 분리)
4. category, pinnedOnly 쿼리 파라미터 적용
5. 정렬: isPinned DESC, createdAt DESC (고정 공지 상단)
6. notice_reads LEFT JOIN으로 isRead 계산
7. 페이지네이션 적용

### 2. 공지사항 상세 조회 (사용자)

```
GET /notices/:id
```

**Request Headers**:
```
Authorization: Bearer <JWT>
```

**Response (200)**:
```typescript
{
  id: number;
  title: string;
  content: string;          // 마크다운 본문
  category: string | null;
  isPinned: boolean;
  viewCount: number;
  createdAt: string;
  updatedAt: string;
}
```

**Response (404)**:
```typescript
{
  error: {
    code: "NOT_FOUND";
    message: "ID {id}에 해당하는 공지사항을 찾을 수 없습니다";
  }
}
```

**비즈니스 로직**:
1. JWT에서 userId, appCode 추출
2. notice 조회 (appCode 일치 확인)
3. deletedAt 확인 (삭제된 공지는 404)
4. 다른 앱의 공지는 404 반환
5. viewCount +1 업데이트 (별도 트랜잭션 불필요)
6. notice_reads INSERT (중복 무시: ON CONFLICT DO NOTHING)
7. 응답 반환

### 3. 읽지 않은 공지 개수 조회 (사용자)

```
GET /notices/unread-count
```

**Request Headers**:
```
Authorization: Bearer <JWT>
```

**Response (200)**:
```typescript
{
  unreadCount: number;
}
```

**비즈니스 로직**:
1. JWT에서 userId, appCode 추출
2. notices와 notice_reads LEFT JOIN
3. notice_reads.id IS NULL (읽지 않음)
4. appCode 필터링
5. deletedAt IS NULL
6. COUNT(*) 반환

### 4. 공지사항 작성 (관리자)

```
POST /notices
```

**Request Headers**:
```
Authorization: Bearer <JWT>
X-Admin-Secret: <ADMIN_SECRET>  // 관리자 인증 (간단한 방식)
```

**Request Body**:
```typescript
{
  title: string;          // 1~200자
  content: string;        // 필수
  category?: string;      // 최대 50자
  isPinned?: boolean;     // 기본: false
}
```

**Response (201)**:
```typescript
{
  id: number;
  title: string;
  content: string;
  category: string | null;
  isPinned: boolean;
  viewCount: number;
  createdAt: string;
  updatedAt: string;
}
```

**Response (400)**:
```typescript
{
  error: {
    code: "VALIDATION_ERROR";
    message: "제목은 1~200자 사이여야 합니다";
  }
}
```

**Response (403)**:
```typescript
{
  error: {
    code: "FORBIDDEN";
    message: "관리자 권한이 필요합니다";
  }
}
```

**비즈니스 로직**:
1. 관리자 권한 확인 (X-Admin-Secret 검증)
2. JWT에서 userId (authorId), appCode 추출
3. 요청 body Zod 검증
4. notices INSERT
5. 운영 로그: noticeProbe.created()
6. 201 응답

### 5. 공지사항 수정 (관리자)

```
PUT /notices/:id
```

**Request Headers**:
```
Authorization: Bearer <JWT>
X-Admin-Secret: <ADMIN_SECRET>
```

**Request Body**:
```typescript
{
  title?: string;
  content?: string;
  category?: string;
  isPinned?: boolean;
}
```

**Response (200)**:
```typescript
{
  id: number;
  title: string;
  content: string;
  category: string | null;
  isPinned: boolean;
  viewCount: number;
  createdAt: string;
  updatedAt: string;
}
```

**Response (404)**:
```typescript
{
  error: {
    code: "NOT_FOUND";
    message: "ID {id}에 해당하는 공지사항을 찾을 수 없습니다";
  }
}
```

**비즈니스 로직**:
1. 관리자 권한 확인
2. JWT에서 appCode 추출
3. 기존 notice 조회 (appCode 일치 확인)
4. deletedAt 확인 (삭제된 공지는 수정 불가)
5. 요청 body Zod 검증
6. notices UPDATE (updatedAt 자동 갱신)
7. 운영 로그: noticeProbe.updated()
8. 200 응답

### 6. 공지사항 삭제 (관리자)

```
DELETE /notices/:id
```

**Request Headers**:
```
Authorization: Bearer <JWT>
X-Admin-Secret: <ADMIN_SECRET>
```

**Response (204)**:
No Content

**Response (404)**:
```typescript
{
  error: {
    code: "NOT_FOUND";
    message: "ID {id}에 해당하는 공지사항을 찾을 수 없습니다";
  }
}
```

**비즈니스 로직**:
1. 관리자 권한 확인
2. JWT에서 appCode 추출
3. 기존 notice 조회 (appCode 일치 확인)
4. Soft delete: deletedAt = NOW()
5. 운영 로그: noticeProbe.deleted()
6. 204 응답 (멱등성: 이미 삭제된 공지도 204)

### 7. 공지사항 고정/해제 (관리자)

```
PATCH /notices/:id/pin
```

**Request Headers**:
```
Authorization: Bearer <JWT>
X-Admin-Secret: <ADMIN_SECRET>
```

**Request Body**:
```typescript
{
  isPinned: boolean;
}
```

**Response (200)**:
```typescript
{
  id: number;
  title: string;
  isPinned: boolean;
  updatedAt: string;
}
```

**비즈니스 로직**:
1. 관리자 권한 확인
2. JWT에서 appCode 추출
3. 기존 notice 조회 (appCode 일치 확인)
4. isPinned UPDATE
5. 운영 로그: noticeProbe.pinToggled()
6. 200 응답

## Zod 유효성 검증 스키마

```typescript
// apps/server/src/modules/notice/validators.ts
import { z } from 'zod';

/**
 * 공지사항 목록 조회 쿼리 파라미터 검증
 */
export const listNoticesSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  category: z.string().max(50).optional(),
  pinnedOnly: z.coerce.boolean().optional(),
});

/**
 * 공지사항 작성 요청 검증
 */
export const createNoticeSchema = z.object({
  title: z.string().min(1).max(200, '제목은 1~200자 사이여야 합니다'),
  content: z.string().min(1, '본문은 필수입니다'),
  category: z.string().max(50).optional(),
  isPinned: z.boolean().default(false),
});

/**
 * 공지사항 수정 요청 검증
 */
export const updateNoticeSchema = z.object({
  title: z.string().min(1).max(200).optional(),
  content: z.string().min(1).optional(),
  category: z.string().max(50).optional(),
  isPinned: z.boolean().optional(),
}).refine((data) => Object.keys(data).length > 0, {
  message: '최소 하나의 필드가 필요합니다',
});

/**
 * 공지사항 고정/해제 요청 검증
 */
export const pinNoticeSchema = z.object({
  isPinned: z.boolean(),
});

/**
 * 공지사항 ID 파라미터 검증
 */
export const noticeIdSchema = z.object({
  id: z.coerce.number().int().positive(),
});
```

## TypeScript 타입 정의

```typescript
// apps/server/src/modules/notice/types.ts

/**
 * 공지사항 요약 (목록 응답)
 */
export interface NoticeSummary {
  id: number;
  title: string;
  category: string | null;
  isPinned: boolean;
  isRead: boolean;
  viewCount: number;
  createdAt: string;
}

/**
 * 공지사항 상세 (상세 응답)
 */
export interface NoticeDetail {
  id: number;
  title: string;
  content: string;
  category: string | null;
  isPinned: boolean;
  viewCount: number;
  createdAt: string;
  updatedAt: string;
}

/**
 * 공지사항 목록 응답
 */
export interface NoticeListResponse {
  items: NoticeSummary[];
  totalCount: number;
  page: number;
  limit: number;
  hasNext: boolean;
}

/**
 * 읽지 않은 공지 개수 응답
 */
export interface UnreadCountResponse {
  unreadCount: number;
}

/**
 * JWT 페이로드 (userId, appCode 추출용)
 */
export interface JwtPayload {
  sub: number;      // userId
  appCode: string;
}
```

## 비즈니스 로직 흐름

### 공지사항 목록 조회

```typescript
// apps/server/src/modules/notice/handlers.ts
import { Request, Response } from 'express';
import { db } from '../../config/database';
import { notices, noticeReads } from './schema';
import { listNoticesSchema } from './validators';
import { eq, isNull, desc, and, sql } from 'drizzle-orm';
import { logger } from '../../utils/logger';
import * as noticeProbe from './notice.probe';
import { NoticeListResponse } from './types';

/**
 * 공지사항 목록 조회 (사용자)
 */
export const listNotices = async (req: Request, res: Response) => {
  // 1. 쿼리 파라미터 검증
  const { page, limit, category, pinnedOnly } = listNoticesSchema.parse(req.query);

  logger.debug('Listing notices', { page, limit, category, pinnedOnly });

  // 2. JWT에서 userId, appCode 추출 (인증 미들웨어에서 req.user에 주입)
  const { sub: userId, appCode } = req.user as JwtPayload;

  // 3. 조건 구성
  const conditions = [
    eq(notices.appCode, appCode),
    isNull(notices.deletedAt),
  ];

  if (category) {
    conditions.push(eq(notices.category, category));
  }

  if (pinnedOnly) {
    conditions.push(eq(notices.isPinned, true));
  }

  // 4. 전체 개수 조회
  const [{ count: totalCount }] = await db
    .select({ count: sql<number>`count(*)` })
    .from(notices)
    .where(and(...conditions));

  // 5. 목록 조회 (LEFT JOIN notice_reads)
  const offset = (page - 1) * limit;
  const items = await db
    .select({
      id: notices.id,
      title: notices.title,
      category: notices.category,
      isPinned: notices.isPinned,
      viewCount: notices.viewCount,
      createdAt: notices.createdAt,
      isRead: sql<boolean>`${noticeReads.id} IS NOT NULL`,
    })
    .from(notices)
    .leftJoin(
      noticeReads,
      and(
        eq(notices.id, noticeReads.noticeId),
        eq(noticeReads.userId, userId)
      )
    )
    .where(and(...conditions))
    .orderBy(desc(notices.isPinned), desc(notices.createdAt))
    .limit(limit)
    .offset(offset);

  // 6. 응답 구성
  const response: NoticeListResponse = {
    items: items.map(item => ({
      id: item.id,
      title: item.title,
      category: item.category,
      isPinned: item.isPinned,
      isRead: item.isRead,
      viewCount: item.viewCount,
      createdAt: item.createdAt.toISOString(),
    })),
    totalCount,
    page,
    limit,
    hasNext: offset + items.length < totalCount,
  };

  res.json(response);
};
```

### 공지사항 상세 조회

```typescript
/**
 * 공지사항 상세 조회 (사용자)
 */
export const getNotice = async (req: Request, res: Response) => {
  // 1. ID 파라미터 검증
  const { id } = noticeIdSchema.parse(req.params);

  logger.debug('Getting notice detail', { noticeId: id });

  // 2. JWT에서 userId, appCode 추출
  const { sub: userId, appCode } = req.user as JwtPayload;

  // 3. 공지사항 조회
  const [notice] = await db
    .select()
    .from(notices)
    .where(
      and(
        eq(notices.id, id),
        eq(notices.appCode, appCode),
        isNull(notices.deletedAt)
      )
    );

  if (!notice) {
    throw new NotFoundException(`ID ${id}에 해당하는 공지사항을 찾을 수 없습니다`);
  }

  // 4. 조회수 증가 (별도 트랜잭션 불필요)
  await db
    .update(notices)
    .set({ viewCount: sql`${notices.viewCount} + 1` })
    .where(eq(notices.id, id));

  // 5. 읽음 처리 (중복 무시)
  await db
    .insert(noticeReads)
    .values({
      noticeId: id,
      userId,
    })
    .onConflictDoNothing();

  // 6. 운영 로그
  noticeProbe.viewed({ noticeId: id, userId });

  // 7. 응답
  const response: NoticeDetail = {
    id: notice.id,
    title: notice.title,
    content: notice.content,
    category: notice.category,
    isPinned: notice.isPinned,
    viewCount: notice.viewCount + 1, // 증가된 값 반영
    createdAt: notice.createdAt.toISOString(),
    updatedAt: notice.updatedAt.toISOString(),
  };

  res.json(response);
};
```

### 공지사항 작성 (관리자)

```typescript
/**
 * 공지사항 작성 (관리자)
 */
export const createNotice = async (req: Request, res: Response) => {
  // 1. 관리자 권한 확인
  const adminSecret = req.get('X-Admin-Secret');
  if (!adminSecret || adminSecret !== process.env.ADMIN_SECRET) {
    throw new ForbiddenException('관리자 권한이 필요합니다');
  }

  // 2. 요청 body 검증
  const data = createNoticeSchema.parse(req.body);

  logger.debug('Creating notice', { title: data.title });

  // 3. JWT에서 userId (authorId), appCode 추출
  const { sub: authorId, appCode } = req.user as JwtPayload;

  // 4. 공지사항 생성
  const [notice] = await db
    .insert(notices)
    .values({
      appCode,
      title: data.title,
      content: data.content,
      category: data.category || null,
      isPinned: data.isPinned,
      authorId,
    })
    .returning();

  // 5. 운영 로그
  noticeProbe.created({ noticeId: notice.id, authorId, appCode, title: notice.title });

  // 6. 201 응답
  const response: NoticeDetail = {
    id: notice.id,
    title: notice.title,
    content: notice.content,
    category: notice.category,
    isPinned: notice.isPinned,
    viewCount: notice.viewCount,
    createdAt: notice.createdAt.toISOString(),
    updatedAt: notice.updatedAt.toISOString(),
  };

  res.status(201).json(response);
};
```

## 에러 처리 전략

### 커스텀 예외 클래스

```typescript
// apps/server/src/utils/errors.ts (기존 파일 확장)

/**
 * 금지된 접근 (403)
 */
export class ForbiddenException extends AppException {
  constructor(message: string) {
    super(message, 403, 'FORBIDDEN');
  }
}
```

### Global Error Handler

```typescript
// apps/server/src/middleware/error-handler.ts (기존 파일 사용)

// AppException 계층 구조로 자동 처리됨
// - NotFoundException → 404
// - ValidationException → 400
// - ForbiddenException → 403
```

### 에러 시나리오

| 상황 | 예외 | HTTP 상태 | 메시지 |
|------|------|-----------|--------|
| 공지사항 미존재 | NotFoundException | 404 | "ID {id}에 해당하는 공지사항을 찾을 수 없습니다" |
| 다른 앱의 공지 접근 | NotFoundException | 404 | (동일) |
| 입력 검증 실패 | ValidationException | 400 | "제목은 1~200자 사이여야 합니다" |
| 관리자 권한 없음 | ForbiddenException | 403 | "관리자 권한이 필요합니다" |
| JWT 누락/만료 | UnauthorizedException | 401 | "인증이 필요합니다" |

## Domain Probe 로깅 포인트

```typescript
// apps/server/src/modules/notice/notice.probe.ts
import { logger } from '../../utils/logger';

/**
 * 공지사항 생성 성공 (관리자)
 */
export const created = (data: {
  noticeId: number;
  authorId: number;
  appCode: string;
  title: string;
}) => {
  logger.info('Notice created', {
    noticeId: data.noticeId,
    authorId: data.authorId,
    appCode: data.appCode,
    title: data.title,
  });
};

/**
 * 공지사항 수정 (관리자)
 */
export const updated = (data: {
  noticeId: number;
  authorId: number;
  appCode: string;
}) => {
  logger.info('Notice updated', {
    noticeId: data.noticeId,
    authorId: data.authorId,
    appCode: data.appCode,
  });
};

/**
 * 공지사항 삭제 (관리자)
 */
export const deleted = (data: {
  noticeId: number;
  authorId: number;
  appCode: string;
}) => {
  logger.info('Notice deleted (soft)', {
    noticeId: data.noticeId,
    authorId: data.authorId,
    appCode: data.appCode,
  });
};

/**
 * 공지사항 고정/해제 (관리자)
 */
export const pinToggled = (data: {
  noticeId: number;
  isPinned: boolean;
  authorId: number;
}) => {
  logger.info('Notice pin toggled', {
    noticeId: data.noticeId,
    isPinned: data.isPinned,
    authorId: data.authorId,
  });
};

/**
 * 공지사항 상세 조회 (사용자)
 */
export const viewed = (data: { noticeId: number; userId: number }) => {
  logger.info('Notice viewed', {
    noticeId: data.noticeId,
    userId: data.userId,
  });
};

/**
 * 공지사항 찾기 실패
 */
export const notFound = (data: { noticeId: number; appCode: string }) => {
  logger.warn('Notice not found or deleted', {
    noticeId: data.noticeId,
    appCode: data.appCode,
  });
};
```

**로그 레벨 기준**:
- **INFO**: 성공적인 비즈니스 이벤트 (생성, 수정, 삭제, 조회)
- **WARN**: 찾을 수 없는 리소스 (복구 가능)
- **ERROR**: 사용 안 함 (예상 밖의 오류는 Global Error Handler에서 처리)

## 인증 및 권한 관리

### JWT 인증 미들웨어

```typescript
// apps/server/src/middleware/auth.ts (기존 파일 사용)
// req.user에 { sub: userId, appCode } 주입
```

### 관리자 권한 검증

```typescript
// apps/server/src/modules/notice/handlers.ts

// 각 관리자 핸들러에서 X-Admin-Secret 헤더 검증
const adminSecret = req.get('X-Admin-Secret');
if (!adminSecret || adminSecret !== process.env.ADMIN_SECRET) {
  throw new ForbiddenException('관리자 권한이 필요합니다');
}
```

**환경변수**:
```
ADMIN_SECRET=<강력한 비밀키>
```

**향후 개선**:
- users 테이블에 role 컬럼 추가 ('user' | 'admin')
- JWT에 role 포함
- isAdmin 미들웨어로 분리

## Router 설정

```typescript
// apps/server/src/modules/notice/index.ts
import { Router } from 'express';
import { authMiddleware } from '../../middleware/auth';
import * as handlers from './handlers';

const router = Router();

// 인증 필수
router.use(authMiddleware);

// 사용자 API
router.get('/', handlers.listNotices);
router.get('/unread-count', handlers.getUnreadCount);
router.get('/:id', handlers.getNotice);

// 관리자 API (X-Admin-Secret 헤더 필요)
router.post('/', handlers.createNotice);
router.put('/:id', handlers.updateNotice);
router.delete('/:id', handlers.deleteNotice);
router.patch('/:id/pin', handlers.pinNotice);

export default router;
```

```typescript
// apps/server/src/app.ts (기존 파일 수정)
import noticeRouter from './modules/notice';

// ...
app.use('/notices', noticeRouter);
```

## 성능 최적화

### 인덱스 전략

- `idx_notices_app_code`: 앱별 필터링 (필수)
- `idx_notices_is_pinned`: 고정 공지 조회 최적화
- `idx_notices_created_at`: 최신순 정렬 최적화
- `idx_notices_deleted_at`: 삭제되지 않은 공지 조회 최적화
- `idx_notices_category`: 카테고리별 필터링

### 쿼리 최적화

- LEFT JOIN으로 isRead 한 번에 조회 (N+1 방지)
- COUNT(*) 분리 쿼리 (페이지네이션 성능)
- sql\`count(*)\` 사용 (Drizzle 최적화)

### 조회수 카운팅

- 별도 트랜잭션 없이 UPDATE (성능 우선)
- 정확도 낮아도 무방 (비즈니스 크리티컬 아님)

## 마이그레이션

```bash
# 1. 스키마 변경 사항을 마이그레이션 파일로 생성
cd apps/server
pnpm drizzle-kit generate

# 2. 마이그레이션 적용
pnpm drizzle-kit migrate

# 또는 개발 환경에서만
pnpm drizzle-kit push
```

## 테스트 전략

### 단위 테스트 (Vitest)

```typescript
// apps/server/tests/unit/notice/handlers.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { Request, Response } from 'express';
import * as handlers from '../../../src/modules/notice/handlers';
import * as noticeProbe from '../../../src/modules/notice/notice.probe';

vi.mock('../../../src/modules/notice/notice.probe');

describe('Notice Handlers', () => {
  let mockReq: Partial<Request>;
  let mockRes: Partial<Response>;

  beforeEach(() => {
    mockReq = {
      user: { sub: 1, appCode: 'wowa' },
      query: {},
      params: {},
      body: {},
    };
    mockRes = {
      json: vi.fn(),
      status: vi.fn().mockReturnThis(),
    };
    vi.clearAllMocks();
  });

  it('should list notices with pagination', async () => {
    mockReq.query = { page: '1', limit: '10' };

    await handlers.listNotices(mockReq as Request, mockRes as Response);

    expect(mockRes.json).toHaveBeenCalled();
    const response = (mockRes.json as any).mock.calls[0][0];
    expect(response).toHaveProperty('items');
    expect(response).toHaveProperty('totalCount');
    expect(response).toHaveProperty('hasNext');
  });

  it('should log notice creation', async () => {
    mockReq.headers = { 'x-admin-secret': process.env.ADMIN_SECRET };
    mockReq.body = {
      title: 'Test Notice',
      content: 'Test Content',
    };

    await handlers.createNotice(mockReq as Request, mockRes as Response);

    expect(noticeProbe.created).toHaveBeenCalled();
    expect(mockRes.status).toHaveBeenCalledWith(201);
  });
});
```

## 환경변수

```bash
# apps/server/.env

# 관리자 인증 (향후 개선 필요)
ADMIN_SECRET=your-strong-secret-key
```

## 패키지 의존성

```json
{
  "dependencies": {
    "drizzle-orm": "^0.x.x",
    "zod": "^3.x.x",
    "express": "^4.x.x",
    "jsonwebtoken": "^9.x.x"
  }
}
```

**기존 패키지 사용** (추가 설치 불필요)

## API 테스트 예시

### 공지사항 목록 조회

```bash
curl -X GET "http://localhost:3001/notices?page=1&limit=10" \
  -H "Authorization: Bearer <JWT>"
```

### 공지사항 작성

```bash
curl -X POST "http://localhost:3001/notices" \
  -H "Authorization: Bearer <JWT>" \
  -H "X-Admin-Secret: <ADMIN_SECRET>" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "서비스 점검 안내",
    "content": "# 서비스 점검\n\n2026년 2월 5일 점검 예정입니다.",
    "category": "점검",
    "isPinned": true
  }'
```

### 읽지 않은 공지 개수

```bash
curl -X GET "http://localhost:3001/notices/unread-count" \
  -H "Authorization: Bearer <JWT>"
```

## 보안 고려사항

### 멀티테넌트 분리

- 모든 쿼리에 `appCode` 조건 포함 (JWT에서 추출)
- 다른 앱의 공지사항 접근 불가 (404 반환)

### 관리자 권한

- X-Admin-Secret 헤더 검증
- 환경변수로 관리 (코드에 하드코딩 금지)

### Soft Delete

- 물리적 삭제 안 함
- deletedAt 타임스탬프로 표시
- 복구 가능

### 민감 정보 로깅 금지

- 사용자 PII 로그에 포함 안 함
- 운영 로그는 비즈니스 이벤트만

## 확장 가능성

### 향후 추가 기능

1. **예약 발행**: publishedAt 컬럼 추가, 스케줄러 작업
2. **푸시 연동**: push-alert 모듈과 통합
3. **카테고리 관리**: categories 테이블 분리
4. **대상 지정**: target_user_ids JSONB 컬럼
5. **첨부파일**: 이미지/파일 URL 배열
6. **댓글**: notice_comments 테이블

### 확장 시 고려사항

- 스키마 변경은 Migration으로 관리
- 기존 API는 Breaking Change 없이 확장
- 새 필드는 optional로 추가

## 검증 기준

- [ ] Drizzle 스키마 정의 완료 (notices, notice_reads)
- [ ] 모든 테이블/컬럼에 comment 추가
- [ ] FK 제약조건 사용 안 함
- [ ] API 엔드포인트 7개 정의
- [ ] Zod 유효성 검증 스키마 작성
- [ ] Domain Probe 패턴 적용 (운영 로그 분리)
- [ ] camelCase 응답 필드, ISO-8601 날짜
- [ ] 빈 배열은 [], Boolean은 true/false만
- [ ] appCode 기반 멀티테넌트 분리
- [ ] 관리자 권한 검증 (X-Admin-Secret)
- [ ] Soft delete (deletedAt)
- [ ] 페이지네이션 지원
- [ ] 인덱스 최적화

## 참고 자료

- **기존 모듈 패턴**: apps/server/src/modules/auth/, push-alert/
- **API Response 가이드**: .claude/guide/server/api-response-design.md
- **예외 처리 가이드**: .claude/guide/server/exception-handling.md
- **로깅 가이드**: .claude/guide/server/logging-best-practices.md
- **Drizzle ORM**: https://orm.drizzle.team/
- **Zod**: https://zod.dev/

## 다음 단계

1. CTO가 설계 검증
2. Senior Developer가 구현 (schema.ts, handlers.ts, validators.ts, notice.probe.ts)
3. Junior Developer가 테스트 코드 작성
4. Migration 생성 및 적용
5. API 테스트 (Postman/Insomnia)
