import { pgTable, serial, integer, date, jsonb, text, boolean, timestamp, index, unique, varchar } from 'drizzle-orm/pg-core';

/**
 * WOD 테이블 (Workout of the Day)
 */
export const wods = pgTable('wods', {
  /** WOD 고유 ID */
  id: serial('id').primaryKey(),
  /** 박스 ID (FK 제약조건 없음, boxes.id 참조) */
  boxId: integer('box_id').notNull(),
  /** WOD 날짜 (YYYY-MM-DD) */
  date: date('date').notNull(),
  /** 구조화된 WOD 데이터 (JSONB 형식) */
  programData: jsonb('program_data').notNull(),
  /** 원본 텍스트 (사용자 입력) */
  rawText: text('raw_text').notNull(),
  /** Base WOD 여부 (true: 기준, false: Personal) */
  isBase: boolean('is_base').notNull().default(false),
  /** 등록자 사용자 ID (FK 제약조건 없음, users.id 참조) */
  createdBy: integer('created_by').notNull(),
  /** 생성 시간 */
  createdAt: timestamp('created_at').defaultNow().notNull(),
  /** 수정 시간 */
  updatedAt: timestamp('updated_at').defaultNow().notNull().$onUpdate(() => new Date()),
}, (table) => ({
  // Partial unique index: Base WOD는 box + date 조합당 최대 1개
  // Drizzle ORM은 partial unique index를 지원하지 않으므로 SQL 마이그레이션에서 수동 생성:
  // CREATE UNIQUE INDEX unique_box_date_base ON wods (box_id, date) WHERE is_base = true;
  boxIdDateIdx: index('idx_wods_box_id_date').on(table.boxId, table.date),
  createdByIdx: index('idx_wods_created_by').on(table.createdBy),
}));

/**
 * WOD 변경 제안 테이블 (Phase 2)
 */
export const proposedChanges = pgTable('proposed_changes', {
  /** 제안 고유 ID */
  id: serial('id').primaryKey(),
  /** 대상 Base WOD ID (FK 제약조건 없음, wods.id 참조) */
  baseWodId: integer('base_wod_id').notNull(),
  /** 제안된 Personal WOD ID (FK 제약조건 없음, wods.id 참조) */
  proposedWodId: integer('proposed_wod_id').notNull(),
  /** 제안 상태 ('pending' | 'approved' | 'rejected') */
  status: varchar('status', { length: 20 }).notNull().default('pending'),
  /** 제안 일시 */
  proposedAt: timestamp('proposed_at').defaultNow(),
  /** 승인/거부 일시 */
  resolvedAt: timestamp('resolved_at'),
  /** 승인/거부자 사용자 ID (FK 제약조건 없음, users.id 참조) */
  resolvedBy: integer('resolved_by'),
}, (table) => ({
  baseWodIdIdx: index('idx_proposed_changes_base_wod_id').on(table.baseWodId),
  proposedWodIdIdx: index('idx_proposed_changes_proposed_wod_id').on(table.proposedWodId),
  statusIdx: index('idx_proposed_changes_status').on(table.status),
}));

/**
 * WOD 선택 테이블 (Phase 3) - 기록 불변성 보장
 */
export const wodSelections = pgTable('wod_selections', {
  /** 선택 고유 ID */
  id: serial('id').primaryKey(),
  /** 사용자 ID (FK 제약조건 없음, users.id 참조) */
  userId: integer('user_id').notNull(),
  /** 선택한 WOD ID (FK 제약조건 없음, wods.id 참조) */
  wodId: integer('wod_id').notNull(),
  /** 박스 ID (FK 제약조건 없음, boxes.id 참조) */
  boxId: integer('box_id').notNull(),
  /** WOD 날짜 (YYYY-MM-DD, 조회 성능 최적화) */
  date: date('date').notNull(),
  /** 선택 시점의 WOD 스냅샷 (JSONB, 불변성 보장) */
  snapshotData: jsonb('snapshot_data').notNull(),
  /** 생성 시간 */
  createdAt: timestamp('created_at').defaultNow(),
}, (table) => ({
  uniqueUserDate: unique().on(table.userId, table.boxId, table.date),
  userIdIdx: index('idx_wod_selections_user_id').on(table.userId),
  boxIdDateIdx: index('idx_wod_selections_box_id_date').on(table.boxId, table.date),
}));
