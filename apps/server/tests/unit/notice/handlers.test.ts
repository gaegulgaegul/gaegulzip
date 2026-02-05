import { describe, it, expect, vi, beforeEach, beforeAll } from 'vitest';
import { Request, Response } from 'express';
import {
  listNotices,
  getNotice,
  getUnreadCount,
  createNotice,
  updateNotice,
  deleteNotice,
  pinNotice,
} from '../../../src/modules/notice/handlers';
import {
  listNoticesSchema,
  createNoticeSchema,
  updateNoticeSchema,
  pinNoticeSchema,
  noticeIdSchema,
} from '../../../src/modules/notice/validators';
import { db } from '../../../src/config/database';
import { findAppById } from '../../../src/modules/auth/services';
import * as noticeProbe from '../../../src/modules/notice/notice.probe';
import { NotFoundException, ForbiddenException } from '../../../src/utils/errors';

// ─── Mocks ──────────────────────────────────────────────────────

vi.mock('../../../src/config/database', () => ({
  db: {
    select: vi.fn(),
    insert: vi.fn(),
    update: vi.fn(),
  },
}));

vi.mock('../../../src/modules/notice/validators', () => ({
  listNoticesSchema: { parse: vi.fn() },
  createNoticeSchema: { parse: vi.fn() },
  updateNoticeSchema: { parse: vi.fn() },
  pinNoticeSchema: { parse: vi.fn() },
  noticeIdSchema: { parse: vi.fn() },
}));

vi.mock('../../../src/modules/notice/notice.probe', () => ({
  created: vi.fn(),
  updated: vi.fn(),
  deleted: vi.fn(),
  pinToggled: vi.fn(),
  viewed: vi.fn(),
  notFound: vi.fn(),
}));

vi.mock('../../../src/modules/auth/services', () => ({
  findAppById: vi.fn(),
}));

vi.mock('../../../src/utils/logger', () => ({
  logger: { debug: vi.fn(), info: vi.fn(), warn: vi.fn(), error: vi.fn() },
}));

// ─── Helpers ────────────────────────────────────────────────────

/**
 * Drizzle DB 체인 모킹 헬퍼
 * 모든 체이닝 메서드가 자기 자신을 반환하고, await 시 resolvedValue를 반환
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
const MOCK_APP = { id: 1, code: 'wowa', name: 'Test App' };
const MOCK_NOTICE = {
  id: 1,
  appCode: 'wowa',
  title: '서비스 업데이트 안내',
  content: '## 변경사항\n- 신규 기능 추가',
  category: 'update',
  isPinned: false,
  viewCount: 10,
  authorId: 1,
  createdAt: NOW,
  updatedAt: NOW,
  deletedAt: null,
};

// ─── Environment ────────────────────────────────────────────────

beforeAll(() => {
  process.env.ADMIN_SECRET = 'test-admin-secret';
});

// ─── listNotices ────────────────────────────────────────────────

describe('listNotices handler', () => {
  let req: Partial<Request>;
  let res: Partial<Response>;

  beforeEach(() => {
    req = { query: {}, user: { userId: 1, appId: 1 } } as any;
    res = { json: vi.fn() };
    vi.clearAllMocks();
  });

  it('should return paginated notice list with read status', async () => {
    vi.mocked(listNoticesSchema.parse).mockReturnValue({
      page: 1, limit: 20, category: undefined, pinnedOnly: undefined,
    });
    vi.mocked(findAppById).mockResolvedValue(MOCK_APP);
    vi.mocked(db.select)
      .mockReturnValueOnce(dbChain([{ count: 2 }]) as any)
      .mockReturnValueOnce(dbChain([
        { id: 1, title: '고정 공지', category: null, isPinned: true, viewCount: 5, createdAt: NOW, isRead: true },
        { id: 2, title: '일반 공지', category: 'update', isPinned: false, viewCount: 3, createdAt: NOW, isRead: false },
      ]) as any);

    await listNotices(req as Request, res as Response);

    expect(findAppById).toHaveBeenCalledWith(1);
    expect(res.json).toHaveBeenCalledWith({
      items: [
        { id: 1, title: '고정 공지', category: null, isPinned: true, isRead: true, viewCount: 5, createdAt: NOW.toISOString() },
        { id: 2, title: '일반 공지', category: 'update', isPinned: false, isRead: false, viewCount: 3, createdAt: NOW.toISOString() },
      ],
      totalCount: 2,
      page: 1,
      limit: 20,
      hasNext: false,
    });
  });

  it('should throw NotFoundException when app not found', async () => {
    vi.mocked(listNoticesSchema.parse).mockReturnValue({
      page: 1, limit: 20, category: undefined, pinnedOnly: undefined,
    });
    vi.mocked(findAppById).mockResolvedValue(null);

    await expect(listNotices(req as Request, res as Response)).rejects.toThrow(NotFoundException);
  });
});

// ─── getNotice ──────────────────────────────────────────────────

describe('getNotice handler', () => {
  let req: Partial<Request>;
  let res: Partial<Response>;

  beforeEach(() => {
    req = { params: { id: '1' }, user: { userId: 1, appId: 1 } } as any;
    res = { json: vi.fn() };
    vi.clearAllMocks();
  });

  it('should return notice detail with incremented viewCount', async () => {
    vi.mocked(noticeIdSchema.parse).mockReturnValue({ id: 1 });
    vi.mocked(findAppById).mockResolvedValue(MOCK_APP);
    vi.mocked(db.select).mockReturnValueOnce(dbChain([MOCK_NOTICE]) as any);
    vi.mocked(db.update).mockReturnValueOnce(dbChain() as any);
    vi.mocked(db.insert).mockReturnValueOnce(dbChain() as any);

    await getNotice(req as Request, res as Response);

    expect(noticeProbe.viewed).toHaveBeenCalledWith({ noticeId: 1, userId: 1 });
    expect(res.json).toHaveBeenCalledWith({
      id: 1,
      title: MOCK_NOTICE.title,
      content: MOCK_NOTICE.content,
      category: MOCK_NOTICE.category,
      isPinned: false,
      viewCount: 11,
      createdAt: NOW.toISOString(),
      updatedAt: NOW.toISOString(),
    });
  });

  it('should throw NotFoundException when notice not found', async () => {
    vi.mocked(noticeIdSchema.parse).mockReturnValue({ id: 999 });
    vi.mocked(findAppById).mockResolvedValue(MOCK_APP);
    vi.mocked(db.select).mockReturnValueOnce(dbChain([]) as any);

    await expect(getNotice(req as Request, res as Response)).rejects.toThrow(NotFoundException);
    expect(noticeProbe.notFound).toHaveBeenCalledWith({ noticeId: 999, appCode: 'wowa' });
  });
});

// ─── getUnreadCount ─────────────────────────────────────────────

describe('getUnreadCount handler', () => {
  let req: Partial<Request>;
  let res: Partial<Response>;

  beforeEach(() => {
    req = { user: { userId: 1, appId: 1 } } as any;
    res = { json: vi.fn() };
    vi.clearAllMocks();
  });

  it('should return count of unread notices', async () => {
    vi.mocked(findAppById).mockResolvedValue(MOCK_APP);
    vi.mocked(db.select).mockReturnValueOnce(dbChain([{ unreadCount: 5 }]) as any);

    await getUnreadCount(req as Request, res as Response);

    expect(res.json).toHaveBeenCalledWith({ unreadCount: 5 });
  });
});

// ─── createNotice ───────────────────────────────────────────────

describe('createNotice handler', () => {
  let req: Partial<Request>;
  let res: Partial<Response>;

  beforeEach(() => {
    req = {
      body: { title: '새 공지', content: '내용입니다', category: 'update' },
      get: vi.fn().mockReturnValue('test-admin-secret'),
      user: { userId: 1, appId: 1 },
    } as any;
    res = {
      status: vi.fn().mockReturnThis(),
      json: vi.fn(),
    };
    vi.clearAllMocks();
  });

  it('should create notice and return 201', async () => {
    vi.mocked(createNoticeSchema.parse).mockReturnValue({
      title: '새 공지', content: '내용입니다', category: 'update', isPinned: false,
    });
    vi.mocked(findAppById).mockResolvedValue(MOCK_APP);
    const createdNotice = { ...MOCK_NOTICE, id: 10, title: '새 공지', content: '내용입니다' };
    vi.mocked(db.insert).mockReturnValueOnce(dbChain([createdNotice]) as any);

    await createNotice(req as Request, res as Response);

    expect(noticeProbe.created).toHaveBeenCalledWith({
      noticeId: 10, authorId: 1, appCode: 'wowa', title: '새 공지',
    });
    expect(res.status).toHaveBeenCalledWith(201);
    expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
      id: 10,
      title: '새 공지',
      content: '내용입니다',
    }));
  });

  it('should throw ForbiddenException without admin secret', async () => {
    (req as any).get = vi.fn().mockReturnValue(undefined);

    await expect(createNotice(req as Request, res as Response)).rejects.toThrow(ForbiddenException);
  });
});

// ─── updateNotice ───────────────────────────────────────────────

describe('updateNotice handler', () => {
  let req: Partial<Request>;
  let res: Partial<Response>;

  beforeEach(() => {
    req = {
      params: { id: '1' },
      body: { title: '수정된 제목' },
      get: vi.fn().mockReturnValue('test-admin-secret'),
      user: { userId: 1, appId: 1 },
    } as any;
    res = { json: vi.fn() };
    vi.clearAllMocks();
  });

  it('should update notice and return 200', async () => {
    vi.mocked(noticeIdSchema.parse).mockReturnValue({ id: 1 });
    vi.mocked(updateNoticeSchema.parse).mockReturnValue({ title: '수정된 제목' });
    vi.mocked(findAppById).mockResolvedValue(MOCK_APP);
    vi.mocked(db.select).mockReturnValueOnce(dbChain([MOCK_NOTICE]) as any);
    const updatedNotice = { ...MOCK_NOTICE, title: '수정된 제목', updatedAt: NOW };
    vi.mocked(db.update).mockReturnValueOnce(dbChain([updatedNotice]) as any);

    await updateNotice(req as Request, res as Response);

    expect(noticeProbe.updated).toHaveBeenCalledWith({ noticeId: 1, authorId: 1, appCode: 'wowa' });
    expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
      id: 1,
      title: '수정된 제목',
    }));
  });

  it('should throw NotFoundException when notice not found', async () => {
    vi.mocked(noticeIdSchema.parse).mockReturnValue({ id: 999 });
    vi.mocked(updateNoticeSchema.parse).mockReturnValue({ title: '수정' });
    vi.mocked(findAppById).mockResolvedValue(MOCK_APP);
    vi.mocked(db.select).mockReturnValueOnce(dbChain([]) as any);

    await expect(updateNotice(req as Request, res as Response)).rejects.toThrow(NotFoundException);
  });
});

// ─── deleteNotice ───────────────────────────────────────────────

describe('deleteNotice handler', () => {
  let req: Partial<Request>;
  let res: Partial<Response>;

  beforeEach(() => {
    req = {
      params: { id: '1' },
      get: vi.fn().mockReturnValue('test-admin-secret'),
      user: { userId: 1, appId: 1 },
    } as any;
    res = {
      status: vi.fn().mockReturnThis(),
      send: vi.fn(),
    };
    vi.clearAllMocks();
  });

  it('should soft delete notice and return 204', async () => {
    vi.mocked(noticeIdSchema.parse).mockReturnValue({ id: 1 });
    vi.mocked(findAppById).mockResolvedValue(MOCK_APP);
    vi.mocked(db.select).mockReturnValueOnce(dbChain([MOCK_NOTICE]) as any);
    vi.mocked(db.update).mockReturnValueOnce(dbChain() as any);

    await deleteNotice(req as Request, res as Response);

    expect(noticeProbe.deleted).toHaveBeenCalledWith({ noticeId: 1, authorId: 1, appCode: 'wowa' });
    expect(res.status).toHaveBeenCalledWith(204);
    expect(res.send).toHaveBeenCalled();
  });

  it('should throw ForbiddenException without admin secret', async () => {
    (req as any).get = vi.fn().mockReturnValue(undefined);

    await expect(deleteNotice(req as Request, res as Response)).rejects.toThrow(ForbiddenException);
  });

  it('should throw NotFoundException when notice not found', async () => {
    vi.mocked(noticeIdSchema.parse).mockReturnValue({ id: 999 });
    vi.mocked(findAppById).mockResolvedValue(MOCK_APP);
    vi.mocked(db.select).mockReturnValueOnce(dbChain([]) as any);

    await expect(deleteNotice(req as Request, res as Response)).rejects.toThrow(NotFoundException);
  });
});

// ─── pinNotice ──────────────────────────────────────────────────

describe('pinNotice handler', () => {
  let req: Partial<Request>;
  let res: Partial<Response>;

  beforeEach(() => {
    req = {
      params: { id: '1' },
      body: { isPinned: true },
      get: vi.fn().mockReturnValue('test-admin-secret'),
      user: { userId: 1, appId: 1 },
    } as any;
    res = { json: vi.fn() };
    vi.clearAllMocks();
  });

  it('should toggle pin status and return 200', async () => {
    vi.mocked(noticeIdSchema.parse).mockReturnValue({ id: 1 });
    vi.mocked(pinNoticeSchema.parse).mockReturnValue({ isPinned: true });
    vi.mocked(findAppById).mockResolvedValue(MOCK_APP);
    vi.mocked(db.select).mockReturnValueOnce(dbChain([MOCK_NOTICE]) as any);
    const pinnedNotice = { ...MOCK_NOTICE, isPinned: true, updatedAt: NOW };
    vi.mocked(db.update).mockReturnValueOnce(dbChain([pinnedNotice]) as any);

    await pinNotice(req as Request, res as Response);

    expect(noticeProbe.pinToggled).toHaveBeenCalledWith({ noticeId: 1, isPinned: true, authorId: 1 });
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
    vi.mocked(findAppById).mockResolvedValue(MOCK_APP);
    vi.mocked(db.select).mockReturnValueOnce(dbChain([]) as any);

    await expect(pinNotice(req as Request, res as Response)).rejects.toThrow(NotFoundException);
  });
});
