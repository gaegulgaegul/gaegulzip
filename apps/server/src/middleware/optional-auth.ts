import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { db } from '../config/database';
import { apps } from '../modules/auth/schema';
import { eq } from 'drizzle-orm';
import { logger } from '../utils/logger';

/**
 * 선택적 인증 미들웨어
 * Authorization 헤더가 있으면 JWT를 검증하고 req.user를 설정합니다.
 * Authorization 헤더가 없으면 그냥 통과합니다 (익명 사용자 허용).
 * @param req - Express 요청 객체
 * @param res - Express 응답 객체
 * @param next - 다음 미들웨어 함수
 */
export const optionalAuthenticate = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;

    // Authorization 헤더가 없으면 익명 사용자로 통과
    if (!authHeader) {
      logger.debug('No Authorization header, proceeding as anonymous user');
      next();
      return;
    }

    // Bearer 토큰 추출
    const token = authHeader.startsWith('Bearer ')
      ? authHeader.substring(7)
      : authHeader;

    if (!token) {
      logger.debug('Empty token, proceeding as anonymous user');
      next();
      return;
    }

    // JWT 디코딩 (검증 전에 appId 추출을 위해)
    const decoded = jwt.decode(token) as any;

    if (!decoded || !decoded.appId) {
      logger.debug('Invalid token format, proceeding as anonymous user');
      next();
      return;
    }

    // 앱 조회 (JWT 시크릿 가져오기)
    const [app] = await db
      .select()
      .from(apps)
      .where(eq(apps.id, decoded.appId));

    if (!app) {
      logger.debug({ appId: decoded.appId }, 'App not found, proceeding as anonymous user');
      next();
      return;
    }

    // JWT 검증
    const verified = jwt.verify(token, app.jwtSecret) as any;

    // req.user 설정
    (req as any).user = {
      userId: verified.userId,
      appId: verified.appId,
    };

    logger.debug({ userId: verified.userId, appId: verified.appId }, 'User authenticated');
    next();
  } catch (error) {
    // JWT 검증 실패 시에도 익명 사용자로 통과
    logger.debug({ error: (error as Error).message }, 'Token verification failed, proceeding as anonymous user');
    next();
  }
};
