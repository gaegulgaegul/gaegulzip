import { Request } from 'express';

/**
 * OAuth 제공자별 사용자 정보 (정규화된 형태)
 */
export interface OAuthUserInfo {
  providerId: string;
  email: string | null;
  nickname: string | null;
  profileImage: string | null;
}

/**
 * JWT 페이로드 인터페이스 (최소화)
 */
export interface JWTPayload {
  sub: number;              // users.id (JWT 표준)
  appId: number;
  email: string | null;
  nickname: string | null;
  iat?: number;
  exp?: number;
}

/**
 * 인증된 요청 타입 (req.user가 있는 경우)
 */
export interface AuthenticatedRequest extends Request {
  user: {
    userId: number;
    appId: number;
  };
}

/**
 * 카카오 API 응답 타입
 */
export interface KakaoTokenInfo {
  id: number;
  expires_in: number;
  app_id: number;
}

/**
 * 카카오 사용자 정보 응답 타입
 */
export interface KakaoUserInfo {
  id: number;
  kakao_account?: {
    email?: string;
  };
  properties?: {
    nickname?: string;
    profile_image?: string;
  };
}

/**
 * 네이버 사용자 정보 응답 타입
 */
export interface NaverUserInfo {
  resultcode: string;
  message: string;
  response: {
    id: string;
    email?: string;
    nickname?: string;
    profile_image?: string;
  };
}

/**
 * 구글 ID Token 검증 응답 타입 (tokeninfo endpoint)
 */
export interface GoogleIdTokenPayload {
  iss: string;
  sub: string;
  aud: string;
  exp: string;
  email?: string;
  email_verified?: string;
  name?: string;
  picture?: string;
}

/**
 * 애플 ID Token 페이로드 타입
 */
export interface AppleIdToken {
  iss: string;
  aud: string;
  exp: number;
  iat: number;
  sub: string;
  email?: string;
  email_verified?: boolean;
}
