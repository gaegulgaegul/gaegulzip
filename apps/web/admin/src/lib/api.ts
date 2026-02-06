const SERVER_URL = process.env.NEXT_PUBLIC_SERVER_URL || 'http://localhost:3001';
const APP_CODE = 'wowa';

export interface Notice {
  id: number;
  title: string;
  content: string;
  category: string | null;
  isPinned: boolean;
  viewCount: number;
  createdAt: string;
  updatedAt: string;
}

export interface NoticeSummary {
  id: number;
  title: string;
  category: string | null;
  isPinned: boolean;
  viewCount: number;
  createdAt: string;
}

export interface NoticeListResponse {
  items: NoticeSummary[];
  totalCount: number;
  page: number;
  limit: number;
  hasNext: boolean;
}

export interface CreateNoticeData {
  title: string;
  content: string;
  category?: string;
  isPinned?: boolean;
}

export interface UpdateNoticeData {
  title?: string;
  content?: string;
  category?: string;
  isPinned?: boolean;
}

/**
 * 인증 헤더를 포함한 fetch 래퍼
 * localStorage에서 admin-token을 읽어 Authorization 헤더에 추가합니다.
 */
function authFetch(url: string, init?: RequestInit): Promise<Response> {
  const token = typeof window !== 'undefined' ? localStorage.getItem('admin-token') : null;
  const headers: Record<string, string> = {
    ...(init?.headers as Record<string, string>),
  };
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }
  return fetch(url, { ...init, headers });
}

/**
 * 어드민 공지사항 API 클라이언트
 * NEXT_PUBLIC_SERVER_URL로 Express 서버에 직접 호출 (JWT 인증 포함)
 */
export const noticeApi = {
  async list(page = 1, limit = 20): Promise<NoticeListResponse> {
    const params = new URLSearchParams({
      appCode: APP_CODE,
      page: String(page),
      limit: String(limit),
    });
    const res = await authFetch(`${SERVER_URL}/admin/notices?${params}`);
    if (!res.ok) throw new Error('Failed to fetch notices');
    return res.json();
  },

  async getById(id: number): Promise<Notice> {
    const res = await authFetch(`${SERVER_URL}/admin/notices/${id}`);
    if (!res.ok) throw new Error('Failed to fetch notice');
    return res.json();
  },

  async create(data: CreateNoticeData): Promise<Notice> {
    const res = await authFetch(`${SERVER_URL}/admin/notices`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ ...data, appCode: APP_CODE }),
    });
    if (!res.ok) throw new Error('Failed to create notice');
    return res.json();
  },

  async update(id: number, data: UpdateNoticeData): Promise<Notice> {
    const res = await authFetch(`${SERVER_URL}/admin/notices/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });
    if (!res.ok) throw new Error('Failed to update notice');
    return res.json();
  },

  async remove(id: number): Promise<void> {
    const res = await authFetch(`${SERVER_URL}/admin/notices/${id}`, {
      method: 'DELETE',
    });
    if (!res.ok) throw new Error('Failed to delete notice');
  },

  async togglePin(id: number, isPinned: boolean): Promise<void> {
    const res = await authFetch(`${SERVER_URL}/admin/notices/${id}/pin`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ isPinned }),
    });
    if (!res.ok) throw new Error('Failed to toggle pin');
  },
};
