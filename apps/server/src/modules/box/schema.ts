import { pgTable, serial, varchar, text, timestamp, integer, index, unique } from 'drizzle-orm/pg-core';

/**
 * 박스(CrossFit gym) 테이블
 */
export const boxes = pgTable('boxes', {
  /** 박스 고유 ID */
  id: serial('id').primaryKey(),
  /** 박스 이름 (예: 'CrossFit Seoul') */
  name: varchar('name', { length: 255 }).notNull(),
  /** 박스 지역 (예: '서울 강남구') */
  region: varchar('region', { length: 255 }).notNull(),
  /** 박스 설명/소개 */
  description: text('description'),
  /** 박스 생성자 사용자 ID (FK 제약조건 없음, users.id 참조) */
  createdBy: integer('created_by').notNull(),
  /** 생성 시간 */
  createdAt: timestamp('created_at').defaultNow(),
  /** 수정 시간 */
  updatedAt: timestamp('updated_at').defaultNow(),
}, (table) => ({
  createdByIdx: index('idx_boxes_created_by').on(table.createdBy),
  nameIdx: index('idx_boxes_name').on(table.name),
  regionIdx: index('idx_boxes_region').on(table.region),
}));

/**
 * 박스 멤버 테이블 (박스-사용자 다대다 관계)
 */
export const boxMembers = pgTable('box_members', {
  /** 멤버 고유 ID */
  id: serial('id').primaryKey(),
  /** 박스 ID (FK 제약조건 없음, boxes.id 참조) */
  boxId: integer('box_id').notNull(),
  /** 사용자 ID (FK 제약조건 없음, users.id 참조) */
  userId: integer('user_id').notNull(),
  /** 멤버 역할 (MVP: 'member'만, 향후 확장 가능) */
  role: varchar('role', { length: 20 }).notNull().default('member'),
  /** 가입 시간 */
  joinedAt: timestamp('joined_at').defaultNow(),
}, (table) => ({
  uniqueBoxUser: unique().on(table.boxId, table.userId),
  boxIdIdx: index('idx_box_members_box_id').on(table.boxId),
  userIdIdx: index('idx_box_members_user_id').on(table.userId),
}));
