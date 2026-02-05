import { timingSafeEqual } from 'crypto';
import { RequestHandler } from 'express';
import { ForbiddenException } from '../utils/errors';

/**
 * 관리자 권한 검증 미들웨어
 *
 * X-Admin-Secret 헤더의 값을 환경변수 ADMIN_SECRET과 비교합니다.
 * 타이밍 공격 방지를 위해 crypto.timingSafeEqual을 사용합니다.
 *
 * @throws ForbiddenException 관리자 권한이 없는 경우
 */
export const requireAdmin: RequestHandler = (req, _res, next) => {
  const adminSecret = req.get('X-Admin-Secret');
  const expectedSecret = process.env.ADMIN_SECRET;

  if (!adminSecret || !expectedSecret) {
    throw new ForbiddenException('관리자 권한이 필요합니다');
  }

  const isValid =
    adminSecret.length === expectedSecret.length &&
    timingSafeEqual(Buffer.from(adminSecret), Buffer.from(expectedSecret));

  if (!isValid) {
    throw new ForbiddenException('관리자 권한이 필요합니다');
  }

  next();
};
