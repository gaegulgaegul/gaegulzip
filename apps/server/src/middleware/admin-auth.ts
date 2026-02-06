import crypto from 'crypto';
import { Request, Response, NextFunction, RequestHandler } from 'express';
import { signToken, verifyToken } from '../utils/jwt';
import { UnauthorizedException, ValidationException } from '../utils/errors';
import { env } from '../config/env';
import { logger } from '../utils/logger';

/** 어드민 JWT 만료 시간 (쿠키와 동일: 7일) */
const ADMIN_TOKEN_EXPIRES_IN = '7d';

/**
 * 어드민 비밀번호 해시 (SHA-256)
 * 웹 어드민과 동일한 값 사용
 */
const ADMIN_PASSWORD_HASH = '691b255bbb5e34e38311967742cbff2ee2dbec87db5b78a64f5db99ff3acd7b1';

/**
 * 어드민 JWT 인증 미들웨어
 * Authorization: Bearer <token> 헤더에서 ADMIN_SECRET으로 서명된 JWT를 검증합니다.
 * @throws UnauthorizedException 토큰이 없거나 유효하지 않은 경우
 */
export const requireAdmin = async (
  req: Request,
  _res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedException('No admin token provided', 'INVALID_TOKEN');
    }

    const token = authHeader.substring(7);

    try {
      verifyToken(token, env.ADMIN_SECRET);
    } catch (error) {
      if (error instanceof Error && error.name === 'TokenExpiredError') {
        throw new UnauthorizedException('Admin token expired', 'EXPIRED_TOKEN');
      }
      throw new UnauthorizedException('Invalid admin token', 'INVALID_TOKEN');
    }

    logger.debug('Admin authentication successful');
    next();
  } catch (error) {
    next(error);
  }
};

/**
 * 어드민 로그인 핸들러
 * 비밀번호를 검증하고 JWT 토큰을 발급합니다 (만료: 7일, 쿠키와 동일).
 * @param req - 요청 객체 (body: { password: string })
 * @param res - 응답 객체
 * @returns { token: string }
 * @throws ValidationException 비밀번호 누락
 * @throws UnauthorizedException 비밀번호 불일치
 */
export const adminLogin: RequestHandler = async (req: Request, res: Response) => {
  const { password } = req.body;
  if (!password || typeof password !== 'string') {
    throw new ValidationException('비밀번호를 입력해주세요.', 'password');
  }

  const inputHash = crypto.createHash('sha256').update(password).digest('hex');
  const expectedHash = ADMIN_PASSWORD_HASH;

  if (inputHash.length !== expectedHash.length ||
    !crypto.timingSafeEqual(Buffer.from(inputHash), Buffer.from(expectedHash))) {
    throw new UnauthorizedException('비밀번호가 올바르지 않습니다.', 'INVALID_TOKEN');
  }

  logger.info('Admin login successful');

  const token = signToken({ role: 'admin' }, env.ADMIN_SECRET, ADMIN_TOKEN_EXPIRES_IN);
  res.json({ token });
};
