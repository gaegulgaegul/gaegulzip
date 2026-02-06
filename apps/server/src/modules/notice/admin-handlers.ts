import { RequestHandler } from 'express';
import { db } from '../../config/database';
import { notices } from './schema';
import { adminListNoticesSchema, adminCreateNoticeSchema, adminUpdateNoticeSchema } from './admin-validators';
import { noticeIdSchema, pinNoticeSchema } from './validators';
import { NoticeDetail } from './types';
import { eq, isNull, desc, and, count } from 'drizzle-orm';
import { logger } from '../../utils/logger';
import * as noticeProbe from './notice.probe';
import { NotFoundException } from '../../utils/errors';

/**
 * 어드민 공지사항 목록 조회
 * JWT 불필요, appCode를 쿼리 파라미터로 직접 받음
 * isRead 필드 없음 (사용자 추적 불필요)
 */
export const adminListNotices: RequestHandler = async (req, res) => {
  const { page, limit, category, appCode } = adminListNoticesSchema.parse(req.query);

  logger.debug({ page, limit, category, appCode }, 'Admin listing notices');

  const conditions = [
    eq(notices.appCode, appCode),
    isNull(notices.deletedAt),
  ];

  if (category) {
    conditions.push(eq(notices.category, category));
  }

  const [{ count: totalCount }] = await db
    .select({ count: count() })
    .from(notices)
    .where(and(...conditions));

  const offset = (page - 1) * limit;
  const items = await db
    .select({
      id: notices.id,
      title: notices.title,
      category: notices.category,
      isPinned: notices.isPinned,
      viewCount: notices.viewCount,
      createdAt: notices.createdAt,
    })
    .from(notices)
    .where(and(...conditions))
    .orderBy(desc(notices.isPinned), desc(notices.createdAt))
    .limit(limit)
    .offset(offset);

  res.json({
    items: items.map(item => ({
      id: item.id,
      title: item.title,
      category: item.category,
      isPinned: item.isPinned,
      viewCount: item.viewCount,
      createdAt: item.createdAt.toISOString(),
    })),
    totalCount: Number(totalCount),
    page,
    limit,
    hasNext: offset + items.length < Number(totalCount),
  });
};

/**
 * 어드민 공지사항 상세 조회
 * 조회수 증가 없음, 읽음 처리 없음
 */
export const adminGetNotice: RequestHandler = async (req, res) => {
  const { id } = noticeIdSchema.parse(req.params);

  logger.debug({ noticeId: id }, 'Admin getting notice detail');

  const [notice] = await db
    .select()
    .from(notices)
    .where(
      and(
        eq(notices.id, id),
        isNull(notices.deletedAt)
      )
    );

  if (!notice) {
    noticeProbe.notFound({ noticeId: id, appCode: 'unknown' });
    throw new NotFoundException('Notice', id);
  }

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

  res.json(response);
};

/**
 * 어드민 공지사항 작성
 * appCode를 body에서 받음, authorId=null
 */
export const adminCreateNotice: RequestHandler = async (req, res) => {
  const data = adminCreateNoticeSchema.parse(req.body);

  logger.debug({ title: data.title, appCode: data.appCode }, 'Admin creating notice');

  const [notice] = await db
    .insert(notices)
    .values({
      appCode: data.appCode,
      title: data.title,
      content: data.content,
      category: data.category || null,
      isPinned: data.isPinned,
      authorId: null,
    })
    .returning();

  noticeProbe.created({ noticeId: notice.id, authorId: null, appCode: data.appCode, title: notice.title });

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

/**
 * 어드민 공지사항 수정
 * id로만 조회 (appCode 검증 불필요)
 */
export const adminUpdateNotice: RequestHandler = async (req, res) => {
  const { id } = noticeIdSchema.parse(req.params);
  const data = adminUpdateNoticeSchema.parse(req.body);

  logger.debug({ noticeId: id, data }, 'Admin updating notice');

  const [existingNotice] = await db
    .select()
    .from(notices)
    .where(
      and(
        eq(notices.id, id),
        isNull(notices.deletedAt)
      )
    );

  if (!existingNotice) {
    noticeProbe.notFound({ noticeId: id, appCode: 'unknown' });
    throw new NotFoundException('Notice', id);
  }

  const [updatedNotice] = await db
    .update(notices)
    .set({
      ...data,
      updatedAt: new Date(),
    })
    .where(eq(notices.id, id))
    .returning();

  noticeProbe.updated({ noticeId: id, authorId: null, appCode: existingNotice.appCode });

  const response: NoticeDetail = {
    id: updatedNotice.id,
    title: updatedNotice.title,
    content: updatedNotice.content,
    category: updatedNotice.category,
    isPinned: updatedNotice.isPinned,
    viewCount: updatedNotice.viewCount,
    createdAt: updatedNotice.createdAt.toISOString(),
    updatedAt: updatedNotice.updatedAt.toISOString(),
  };

  res.json(response);
};

/**
 * 어드민 공지사항 삭제 (Soft delete)
 */
export const adminDeleteNotice: RequestHandler = async (req, res) => {
  const { id } = noticeIdSchema.parse(req.params);

  logger.debug({ noticeId: id }, 'Admin deleting notice');

  const [existingNotice] = await db
    .select()
    .from(notices)
    .where(
      and(
        eq(notices.id, id),
        isNull(notices.deletedAt)
      )
    );

  if (!existingNotice) {
    noticeProbe.notFound({ noticeId: id, appCode: 'unknown' });
    throw new NotFoundException('Notice', id);
  }

  await db
    .update(notices)
    .set({ deletedAt: new Date() })
    .where(eq(notices.id, id));

  noticeProbe.deleted({ noticeId: id, authorId: null, appCode: existingNotice.appCode });

  res.status(204).send();
};

/**
 * 어드민 공지사항 고정/해제
 */
export const adminPinNotice: RequestHandler = async (req, res) => {
  const { id } = noticeIdSchema.parse(req.params);
  const { isPinned } = pinNoticeSchema.parse(req.body);

  logger.debug({ noticeId: id, isPinned }, 'Admin toggling notice pin');

  const [existingNotice] = await db
    .select()
    .from(notices)
    .where(
      and(
        eq(notices.id, id),
        isNull(notices.deletedAt)
      )
    );

  if (!existingNotice) {
    noticeProbe.notFound({ noticeId: id, appCode: 'unknown' });
    throw new NotFoundException('Notice', id);
  }

  const [updatedNotice] = await db
    .update(notices)
    .set({
      isPinned,
      updatedAt: new Date(),
    })
    .where(eq(notices.id, id))
    .returning();

  noticeProbe.pinToggled({ noticeId: id, isPinned, authorId: null });

  res.json({
    id: updatedNotice.id,
    title: updatedNotice.title,
    isPinned: updatedNotice.isPinned,
    updatedAt: updatedNotice.updatedAt.toISOString(),
  });
};
