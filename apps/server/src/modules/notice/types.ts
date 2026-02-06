import { Request } from 'express';
import { AuthenticatedRequest } from '../auth/types';

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

// AuthenticatedRequest는 ../auth/types에서 import하여 사용
export type { AuthenticatedRequest };
