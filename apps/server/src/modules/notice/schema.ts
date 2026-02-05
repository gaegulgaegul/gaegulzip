import { pgTable, serial, varchar, text, boolean, integer, timestamp, index, unique } from 'drizzle-orm/pg-core';

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
