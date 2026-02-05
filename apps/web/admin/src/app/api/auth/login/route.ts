import { NextRequest, NextResponse } from 'next/server';
import { verifyPassword, createSessionToken, SESSION_COOKIE_NAME } from '@/lib/auth';

/**
 * Admin 로그인 API
 *
 * POST: 비밀번호를 검증하고 HttpOnly 쿠키를 발급합니다.
 */
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { password } = body;

    if (!password) {
      return NextResponse.json(
        { error: '비밀번호를 입력해주세요.' },
        { status: 400 }
      );
    }

    // 비밀번호 검증
    const isValid = await verifyPassword(password);

    if (!isValid) {
      return NextResponse.json(
        { error: '비밀번호가 올바르지 않습니다.' },
        { status: 401 }
      );
    }

    // 세션 토큰 생성
    const sessionToken = createSessionToken();

    // HttpOnly 쿠키 설정
    const response = NextResponse.json({ success: true });
    response.cookies.set(SESSION_COOKIE_NAME, sessionToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      maxAge: 60 * 60 * 24 * 7, // 7일
      path: '/',
    });

    return response;
  } catch (error) {
    console.error('Login error:', error);
    return NextResponse.json(
      { error: '로그인 처리 중 오류가 발생했습니다.' },
      { status: 500 }
    );
  }
}
