/**
 * Express Request 타입 확장
 * 인증 미들웨어에서 설정하는 user 속성을 타입 안전하게 사용
 */
export interface AuthenticatedUser {
  userId: number;
  appId: number;
}

declare global {
  namespace Express {
    interface Request {
      user?: AuthenticatedUser;
    }
  }
}
