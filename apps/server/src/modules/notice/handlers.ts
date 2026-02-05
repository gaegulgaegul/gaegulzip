import { Request, Response, RequestHandler } from 'express';
import { db } from '../../config/database';
import { notices, noticeReads } from './schema';
import { listNoticesSchema, createNoticeSchema, updateNoticeSchema, pinNoticeSchema, noticeIdSchema } from './validators';
import { NoticeListResponse, NoticeDetail, NoticeSummary, UnreadCountResponse, AuthUser } from './types';
import { eq, isNull, desc, and, sql, count } from 'drizzle-orm';
import { logger } from '../../utils/logger';
import * as noticeProbe from './notice.probe';
import { NotFoundException, ForbiddenException } from '../../utils/errors';
import { findAppById } from '../auth/services';

/**
 * 인증된 사용자의 appCode를 조회합니다.
 * auth 미들웨어가 설정한 req.user.appId로 apps 테이블에서 code를 가져옵니다.
 */
async function getAppCode(appId: number): Promise<string> {
  const app = await findAppById(appId);
  if (!app) {
    throw new NotFoundException('App', appId);
  }
  return app.code;
}

/**
 * 공지사항 목록 조회 (사용자)
 * @param req - Express 요청 객체 (query: { page?, limit?, category?, pinnedOnly? })
 * @param res - Express 응답 객체
 * @returns 200: 공지사항 목록 (페이지네이션 포함)
 * @throws ValidationException 쿼리 파라미터 검증 실패 시
 */
export const listNotices: RequestHandler = async (req, res) => {
  // 1. 쿼리 파라미터 검증
  const { page, limit, category, pinnedOnly } = listNoticesSchema.parse(req.query);

  logger.debug({ page, limit, category, pinnedOnly }, 'Listing notices');

  // 2. JWT에서 userId, appId 추출 (인증 미들웨어에서 req.user에 주입)
  const { userId, appId } = (req as any).user as AuthUser;
  const appCode = await getAppCode(appId);

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
    .select({ count: count() })
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
      isRead: item.isRead ?? false,
      viewCount: item.viewCount,
      createdAt: item.createdAt.toISOString(),
    })),
    totalCount: Number(totalCount),
    page,
    limit,
    hasNext: offset + items.length < Number(totalCount),
  };

  res.json(response);
};

/**
 * 공지사항 상세 조회 (사용자)
 * @param req - Express 요청 객체 (params: { id })
 * @param res - Express 응답 객체
 * @returns 200: 공지사항 상세
 * @throws NotFoundException 공지사항을 찾을 수 없는 경우
 * @throws ValidationException ID 파라미터 검증 실패 시
 */
export const getNotice: RequestHandler = async (req, res) => {
  // 1. ID 파라미터 검증
  const { id } = noticeIdSchema.parse(req.params);

  logger.debug({ noticeId: id }, 'Getting notice detail');

  // 2. JWT에서 userId, appId 추출
  const { userId, appId } = (req as any).user as AuthUser;
  const appCode = await getAppCode(appId);

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
    noticeProbe.notFound({ noticeId: id, appCode });
    throw new NotFoundException('Notice', id);
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

/**
 * 읽지 않은 공지 개수 조회 (사용자)
 * @param req - Express 요청 객체
 * @param res - Express 응답 객체
 * @returns 200: { unreadCount: number }
 */
export const getUnreadCount: RequestHandler = async (req, res) => {
  logger.debug('Getting unread count');

  // 1. JWT에서 userId, appId 추출
  const { userId, appId } = (req as any).user as AuthUser;
  const appCode = await getAppCode(appId);

  // 2. 읽지 않은 공지 개수 조회
  const [{ unreadCount }] = await db
    .select({ unreadCount: count() })
    .from(notices)
    .leftJoin(
      noticeReads,
      and(
        eq(notices.id, noticeReads.noticeId),
        eq(noticeReads.userId, userId)
      )
    )
    .where(
      and(
        eq(notices.appCode, appCode),
        isNull(notices.deletedAt),
        isNull(noticeReads.id) // 읽지 않음
      )
    );

  const response: UnreadCountResponse = {
    unreadCount: Number(unreadCount),
  };

  res.json(response);
};

/**
 * 공지사항 작성 (관리자)
 * @param req - Express 요청 객체 (body: { title, content, category?, isPinned? })
 * @param res - Express 응답 객체
 * @returns 201: 생성된 공지사항
 * @throws ForbiddenException 관리자 권한이 없는 경우
 * @throws ValidationException 요청 body 검증 실패 시
 */
export const createNotice: RequestHandler = async (req, res) => {
  // 1. 관리자 권한 확인
  const adminSecret = req.get('X-Admin-Secret');
  if (!adminSecret || adminSecret !== process.env.ADMIN_SECRET) {
    throw new ForbiddenException('관리자 권한이 필요합니다');
  }

  // 2. 요청 body 검증
  const data = createNoticeSchema.parse(req.body);

  logger.debug({ title: data.title }, 'Creating notice');

  // 3. JWT에서 userId (authorId), appId 추출
  const { userId: authorId, appId } = (req as any).user as AuthUser;
  const appCode = await getAppCode(appId);

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

/**
 * 공지사항 수정 (관리자)
 * @param req - Express 요청 객체 (params: { id }, body: { title?, content?, category?, isPinned? })
 * @param res - Express 응답 객체
 * @returns 200: 수정된 공지사항
 * @throws ForbiddenException 관리자 권한이 없는 경우
 * @throws NotFoundException 공지사항을 찾을 수 없는 경우
 * @throws ValidationException 요청 검증 실패 시
 */
export const updateNotice: RequestHandler = async (req, res) => {
  // 1. 관리자 권한 확인
  const adminSecret = req.get('X-Admin-Secret');
  if (!adminSecret || adminSecret !== process.env.ADMIN_SECRET) {
    throw new ForbiddenException('관리자 권한이 필요합니다');
  }

  // 2. ID 파라미터 검증
  const { id } = noticeIdSchema.parse(req.params);

  // 3. 요청 body 검증
  const data = updateNoticeSchema.parse(req.body);

  logger.debug({ noticeId: id, data }, 'Updating notice');

  // 4. JWT에서 appId 추출
  const { userId: authorId, appId } = (req as any).user as AuthUser;
  const appCode = await getAppCode(appId);

  // 5. 기존 notice 조회 (appCode 일치 확인)
  const [existingNotice] = await db
    .select()
    .from(notices)
    .where(
      and(
        eq(notices.id, id),
        eq(notices.appCode, appCode),
        isNull(notices.deletedAt)
      )
    );

  if (!existingNotice) {
    noticeProbe.notFound({ noticeId: id, appCode });
    throw new NotFoundException('Notice', id);
  }

  // 6. notices UPDATE (updatedAt 자동 갱신)
  const [updatedNotice] = await db
    .update(notices)
    .set({
      ...data,
      updatedAt: new Date(),
    })
    .where(eq(notices.id, id))
    .returning();

  // 7. 운영 로그
  noticeProbe.updated({ noticeId: id, authorId, appCode });

  // 8. 200 응답
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
 * 공지사항 삭제 (관리자)
 * @param req - Express 요청 객체 (params: { id })
 * @param res - Express 응답 객체
 * @returns 204: No Content
 * @throws ForbiddenException 관리자 권한이 없는 경우
 * @throws NotFoundException 공지사항을 찾을 수 없는 경우
 * @throws ValidationException ID 파라미터 검증 실패 시
 */
export const deleteNotice: RequestHandler = async (req, res) => {
  // 1. 관리자 권한 확인
  const adminSecret = req.get('X-Admin-Secret');
  if (!adminSecret || adminSecret !== process.env.ADMIN_SECRET) {
    throw new ForbiddenException('관리자 권한이 필요합니다');
  }

  // 2. ID 파라미터 검증
  const { id } = noticeIdSchema.parse(req.params);

  logger.debug({ noticeId: id }, 'Deleting notice');

  // 3. JWT에서 appId 추출
  const { userId: authorId, appId } = (req as any).user as AuthUser;
  const appCode = await getAppCode(appId);

  // 4. 기존 notice 조회 (appCode 일치 확인)
  const [existingNotice] = await db
    .select()
    .from(notices)
    .where(
      and(
        eq(notices.id, id),
        eq(notices.appCode, appCode)
      )
    );

  if (!existingNotice) {
    noticeProbe.notFound({ noticeId: id, appCode });
    throw new NotFoundException('Notice', id);
  }

  // 5. Soft delete: deletedAt = NOW()
  await db
    .update(notices)
    .set({ deletedAt: new Date() })
    .where(eq(notices.id, id));

  // 6. 운영 로그
  noticeProbe.deleted({ noticeId: id, authorId, appCode });

  // 7. 204 응답 (멱등성: 이미 삭제된 공지도 204)
  res.status(204).send();
};

/**
 * 공지사항 고정/해제 (관리자)
 * @param req - Express 요청 객체 (params: { id }, body: { isPinned })
 * @param res - Express 응답 객체
 * @returns 200: { id, title, isPinned, updatedAt }
 * @throws ForbiddenException 관리자 권한이 없는 경우
 * @throws NotFoundException 공지사항을 찾을 수 없는 경우
 * @throws ValidationException 요청 검증 실패 시
 */
export const pinNotice: RequestHandler = async (req, res) => {
  // 1. 관리자 권한 확인
  const adminSecret = req.get('X-Admin-Secret');
  if (!adminSecret || adminSecret !== process.env.ADMIN_SECRET) {
    throw new ForbiddenException('관리자 권한이 필요합니다');
  }

  // 2. ID 파라미터 검증
  const { id } = noticeIdSchema.parse(req.params);

  // 3. 요청 body 검증
  const { isPinned } = pinNoticeSchema.parse(req.body);

  logger.debug({ noticeId: id, isPinned }, 'Toggling notice pin');

  // 4. JWT에서 appId 추출
  const { userId: authorId, appId } = (req as any).user as AuthUser;
  const appCode = await getAppCode(appId);

  // 5. 기존 notice 조회 (appCode 일치 확인)
  const [existingNotice] = await db
    .select()
    .from(notices)
    .where(
      and(
        eq(notices.id, id),
        eq(notices.appCode, appCode),
        isNull(notices.deletedAt)
      )
    );

  if (!existingNotice) {
    noticeProbe.notFound({ noticeId: id, appCode });
    throw new NotFoundException('Notice', id);
  }

  // 6. isPinned UPDATE
  const [updatedNotice] = await db
    .update(notices)
    .set({
      isPinned,
      updatedAt: new Date(),
    })
    .where(eq(notices.id, id))
    .returning();

  // 7. 운영 로그
  noticeProbe.pinToggled({ noticeId: id, isPinned, authorId });

  // 8. 200 응답
  const response = {
    id: updatedNotice.id,
    title: updatedNotice.title,
    isPinned: updatedNotice.isPinned,
    updatedAt: updatedNotice.updatedAt.toISOString(),
  };

  res.json(response);
};
