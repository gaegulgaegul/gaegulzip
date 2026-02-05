import { pgTable, serial, integer, varchar, text, timestamp, index } from 'drizzle-orm/pg-core';

/**
 * QnA 질문 이력 테이블
 * 제출된 질문과 GitHub Issue 연동 정보를 저장합니다
 */
export const qnaQuestions = pgTable('qna_questions', {
  /** 고유 ID */
  id: serial('id').primaryKey(),

  /** 앱 ID (apps 테이블 참조, FK 제약조건 없음) */
  appId: integer('app_id').notNull(),

  /** 사용자 ID (users 테이블 참조, FK 제약조건 없음, null = 익명 사용자) */
  userId: integer('user_id'),

  /** 질문 제목 */
  title: varchar('title', { length: 256 }).notNull(),

  /** 질문 내용 */
  body: text('body').notNull(),

  /** GitHub Issue 번호 */
  issueNumber: integer('issue_number').notNull(),

  /** GitHub Issue URL */
  issueUrl: varchar('issue_url', { length: 500 }).notNull(),

  /** 생성 시간 */
  createdAt: timestamp('created_at').defaultNow().notNull(),
}, (table) => ({
  /** 앱 ID 인덱스 */
  appIdIdx: index('idx_qna_questions_app_id').on(table.appId),
  /** 사용자 ID 인덱스 */
  userIdIdx: index('idx_qna_questions_user_id').on(table.userId),
  /** Issue 번호 인덱스 */
  issueNumberIdx: index('idx_qna_questions_issue_number').on(table.issueNumber),
  /** 생성 시간 인덱스 */
  createdAtIdx: index('idx_qna_questions_created_at').on(table.createdAt),
  /** 앱별 최신 질문 조회용 복합 인덱스 */
  appIdCreatedAtIdx: index('idx_qna_questions_app_id_created_at').on(table.appId, table.createdAt),
}));
