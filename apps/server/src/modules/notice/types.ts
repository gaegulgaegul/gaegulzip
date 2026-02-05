import { Request } from 'express';

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
 * 인증 미들웨어가 설정하는 req.user 형태
 * @see apps/server/src/middleware/auth.ts
 */
export interface AuthUser {
  userId: number;
  appId: number;
}

/**
 * 인증 미들웨어 통과 후의 Request 타입
 * (req as any).user 대신 타입 안전하게 접근할 수 있습니다.
 */
export interface AuthenticatedRequest extends Request {
  user: AuthUser;
}
