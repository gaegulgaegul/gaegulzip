import { describe, it, expect, vi, beforeEach } from 'vitest';
import { Request, Response } from 'express';
import { db } from '../../../src/config/database';
import * as noticeProbe from '../../../src/modules/notice/notice.probe';
import { NotFoundException } from '../../../src/utils/errors';

// ─── Mocks ──────────────────────────────────────────────────────

vi.mock('../../../src/config/database', () => ({
  db: {
    select: vi.fn(),
    insert: vi.fn(),
    update: vi.fn(),
  },
}));

vi.mock('../../../src/modules/notice/admin-validators', () => ({
  adminListNoticesSchema: { parse: vi.fn() },
  adminCreateNoticeSchema: { parse: vi.fn() },
  adminUpdateNoticeSchema: { parse: vi.fn() },
}));

vi.mock('../../../src/modules/notice/validators', () => ({
  noticeIdSchema: { parse: vi.fn() },
  pinNoticeSchema: { parse: vi.fn() },
}));

vi.mock('../../../src/modules/notice/notice.probe', () => ({
  created: vi.fn(),
  updated: vi.fn(),
  deleted: vi.fn(),
  pinToggled: vi.fn(),
  notFound: vi.fn(),
}));

vi.mock('../../../src/utils/logger', () => ({
  logger: { debug: vi.fn(), info: vi.fn(), warn: vi.fn(), error: vi.fn() },
}));

// ─── Lazy imports (after mocks) ─────────────────────────────────

import {
  adminListNotices,
  adminGetNotice,
  adminCreateNotice,
  adminUpdateNotice,
  adminDeleteNotice,
  adminPinNotice,
} from '../../../src/modules/notice/admin-handlers';
import {
  adminListNoticesSchema,
  adminCreateNoticeSchema,
  adminUpdateNoticeSchema,
} from '../../../src/modules/notice/admin-validators';
import { noticeIdSchema, pinNoticeSchema } from '../../../src/modules/notice/validators';

// ─── Helpers ────────────────────────────────────────────────────

/**
 * Drizzle DB 체인 모킹 헬퍼
 */
function dbChain(resolvedValue: any = []) {
  const chain: any = {};
  [
    'select', 'from', 'where', 'leftJoin', 'orderBy', 'limit', 'offset',
    'insert', 'values', 'onConflictDoNothing', 'update', 'set', 'returning',
  ].forEach(m => { chain[m] = vi.fn().mockReturnValue(chain); });
  chain.then = (resolve: any, reject?: any) =>
    Promise.resolve(resolvedValue).then(resolve, reject);
  return chain;
}

// ─── Fixtures ───────────────────────────────────────────────────

const NOW = new Date('2026-01-01T00:00:00.000Z');
const MOCK_NOTICE = {
  id: 1,
  appCode: 'wowa',
  title: '서비스 업데이트 안내',
  content: '## 변경사항\n- 신규 기능 추가',
  category: 'update',
  isPinned: false,
  viewCount: 10,
  authorId: null,
  createdAt: NOW,
  updatedAt: NOW,
  deletedAt: null,
};

// ─── adminListNotices ───────────────────────────────────────────

describe('adminListNotices handler', () => {
  let req: Partial<Request>;
  let res: Partial<Response>;

  beforeEach(() => {
    req = { query: { appCode: 'wowa' } } as any;
    res = { json: vi.fn() };
    vi.clearAllMocks();
  });

  it('should return paginated notice list without isRead', async () => {
    vi.mocked(adminListNoticesSchema.parse).mockReturnValue({
      page: 1, limit: 20, category: undefined, appCode: 'wowa',
    });
    vi.mocked(db.select)
      .mockReturnValueOnce(dbChain([{ count: 1 }]) as any)
      .mockReturnValueOnce(dbChain([
        { id: 1, title: '공지', category: 'update', isPinned: false, viewCount: 10, createdAt: NOW },
      ]) as any);

    await adminListNotices(req as Request, res as Response);

    expect(res.json).toHaveBeenCalledWith({
      items: [
        { id: 1, title: '공지', category: 'update', isPinned: false, viewCount: 10, createdAt: NOW.toISOString() },
      ],
      totalCount: 1,
      page: 1,
      limit: 20,
      hasNext: false,
    });
  });
});

// ─── adminGetNotice ─────────────────────────────────────────────

describe('adminGetNotice handler', () => {
  let req: Partial<Request>;
  let res: Partial<Response>;

  beforeEach(() => {
    req = { params: { id: '1' } } as any;
    res = { json: vi.fn() };
    vi.clearAllMocks();
  });

  it('should return notice detail without incrementing viewCount', async () => {
    vi.mocked(noticeIdSchema.parse).mockReturnValue({ id: 1 });
    vi.mocked(db.select).mockReturnValueOnce(dbChain([MOCK_NOTICE]) as any);

    await adminGetNotice(req as Request, res as Response);

    // viewCount should NOT be incremented (stays at 10)
    expect(res.json).toHaveBeenCalledWith({
      id: 1,
      title: MOCK_NOTICE.title,
      content: MOCK_NOTICE.content,
      category: MOCK_NOTICE.category,
      isPinned: false,
      viewCount: 10,
      createdAt: NOW.toISOString(),
      updatedAt: NOW.toISOString(),
    });
    // No db.update or db.insert should be called
    expect(db.update).not.toHaveBeenCalled();
    expect(db.insert).not.toHaveBeenCalled();
  });

  it('should throw NotFoundException when notice not found', async () => {
    vi.mocked(noticeIdSchema.parse).mockReturnValue({ id: 999 });
    vi.mocked(db.select).mockReturnValueOnce(dbChain([]) as any);

    await expect(adminGetNotice(req as Request, res as Response)).rejects.toThrow(NotFoundException);
    expect(noticeProbe.notFound).toHaveBeenCalled();
  });
});

// ─── adminCreateNotice ──────────────────────────────────────────

describe('adminCreateNotice handler', () => {
  let req: Partial<Request>;
  let res: Partial<Response>;

  beforeEach(() => {
    req = { body: { appCode: 'wowa', title: '새 공지', content: '내용' } } as any;
    res = {
      status: vi.fn().mockReturnThis(),
      json: vi.fn(),
    };
    vi.clearAllMocks();
  });

  it('should create notice with authorId=null and return 201', async () => {
    vi.mocked(adminCreateNoticeSchema.parse).mockReturnValue({
      appCode: 'wowa', title: '새 공지', content: '내용', category: undefined, isPinned: false,
    });
    const created = { ...MOCK_NOTICE, id: 10, title: '새 공지', content: '내용' };
    vi.mocked(db.insert).mockReturnValueOnce(dbChain([created]) as any);

    await adminCreateNotice(req as Request, res as Response);

    expect(noticeProbe.created).toHaveBeenCalledWith({
      noticeId: 10, authorId: null, appCode: 'wowa', title: '새 공지',
    });
    expect(res.status).toHaveBeenCalledWith(201);
    expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
      id: 10,
      title: '새 공지',
    }));
  });
});

// ─── adminUpdateNotice ──────────────────────────────────────────

describe('adminUpdateNotice handler', () => {
  let req: Partial<Request>;
  let res: Partial<Response>;

  beforeEach(() => {
    req = { params: { id: '1' }, body: { title: '수정 제목' } } as any;
    res = { json: vi.fn() };
    vi.clearAllMocks();
  });

  it('should update notice and return 200', async () => {
    vi.mocked(noticeIdSchema.parse).mockReturnValue({ id: 1 });
    vi.mocked(adminUpdateNoticeSchema.parse).mockReturnValue({ title: '수정 제목' });
    vi.mocked(db.select).mockReturnValueOnce(dbChain([MOCK_NOTICE]) as any);
    const updated = { ...MOCK_NOTICE, title: '수정 제목', updatedAt: NOW };
    vi.mocked(db.update).mockReturnValueOnce(dbChain([updated]) as any);

    await adminUpdateNotice(req as Request, res as Response);

    expect(noticeProbe.updated).toHaveBeenCalledWith({
      noticeId: 1, authorId: null, appCode: 'wowa',
    });
    expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
      id: 1, title: '수정 제목',
    }));
  });

  it('should throw NotFoundException when notice not found', async () => {
    vi.mocked(noticeIdSchema.parse).mockReturnValue({ id: 999 });
    vi.mocked(adminUpdateNoticeSchema.parse).mockReturnValue({ title: '수정' });
    vi.mocked(db.select).mockReturnValueOnce(dbChain([]) as any);

    await expect(adminUpdateNotice(req as Request, res as Response)).rejects.toThrow(NotFoundException);
  });
});

// ─── adminDeleteNotice ──────────────────────────────────────────

describe('adminDeleteNotice handler', () => {
  let req: Partial<Request>;
  let res: Partial<Response>;

  beforeEach(() => {
    req = { params: { id: '1' } } as any;
    res = {
      status: vi.fn().mockReturnThis(),
      send: vi.fn(),
    };
    vi.clearAllMocks();
  });

  it('should soft delete notice and return 204', async () => {
    vi.mocked(noticeIdSchema.parse).mockReturnValue({ id: 1 });
    vi.mocked(db.select).mockReturnValueOnce(dbChain([MOCK_NOTICE]) as any);
    vi.mocked(db.update).mockReturnValueOnce(dbChain() as any);

    await adminDeleteNotice(req as Request, res as Response);

    expect(noticeProbe.deleted).toHaveBeenCalledWith({
      noticeId: 1, authorId: null, appCode: 'wowa',
    });
    expect(res.status).toHaveBeenCalledWith(204);
    expect(res.send).toHaveBeenCalled();
  });

  it('should throw NotFoundException when notice not found', async () => {
    vi.mocked(noticeIdSchema.parse).mockReturnValue({ id: 999 });
    vi.mocked(db.select).mockReturnValueOnce(dbChain([]) as any);

    await expect(adminDeleteNotice(req as Request, res as Response)).rejects.toThrow(NotFoundException);
  });
});

// ─── adminPinNotice ─────────────────────────────────────────────

describe('adminPinNotice handler', () => {
  let req: Partial<Request>;
  let res: Partial<Response>;

  beforeEach(() => {
    req = { params: { id: '1' }, body: { isPinned: true } } as any;
    res = { json: vi.fn() };
    vi.clearAllMocks();
  });

  it('should toggle pin status and return 200', async () => {
    vi.mocked(noticeIdSchema.parse).mockReturnValue({ id: 1 });
    vi.mocked(pinNoticeSchema.parse).mockReturnValue({ isPinned: true });
    vi.mocked(db.select).mockReturnValueOnce(dbChain([MOCK_NOTICE]) as any);
    const pinned = { ...MOCK_NOTICE, isPinned: true, updatedAt: NOW };
    vi.mocked(db.update).mockReturnValueOnce(dbChain([pinned]) as any);

    await adminPinNotice(req as Request, res as Response);

    expect(noticeProbe.pinToggled).toHaveBeenCalledWith({
      noticeId: 1, isPinned: true, authorId: null,
    });
    expect(res.json).toHaveBeenCalledWith({
      id: 1,
      title: MOCK_NOTICE.title,
      isPinned: true,
      updatedAt: NOW.toISOString(),
    });
  });

  it('should throw NotFoundException when notice not found', async () => {
    vi.mocked(noticeIdSchema.parse).mockReturnValue({ id: 999 });
    vi.mocked(pinNoticeSchema.parse).mockReturnValue({ isPinned: true });
    vi.mocked(db.select).mockReturnValueOnce(dbChain([]) as any);

    await expect(adminPinNotice(req as Request, res as Response)).rejects.toThrow(NotFoundException);
  });
});
