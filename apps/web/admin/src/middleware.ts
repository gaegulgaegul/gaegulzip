import { NextRequest, NextResponse } from 'next/server';
import { SESSION_COOKIE_NAME } from '@/lib/auth';

/**
 * Next.js 미들웨어
 *
 * 보호된 경로(/dashboard, /users, /push 등)에 대한 인증을 체크합니다.
 * /login 페이지는 이미 인증된 사용자를 /dashboard로 리디렉트합니다.
 */
export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  const sessionToken = request.cookies.get(SESSION_COOKIE_NAME)?.value;

  // 보호된 경로 목록
  const protectedPaths = ['/dashboard', '/users', '/push', '/notices'];
  const isProtectedPath = protectedPaths.some((path) =>
    pathname.startsWith(path)
  );

  // 보호된 경로: 세션이 없으면 로그인 페이지로 리디렉트
  if (isProtectedPath && !sessionToken) {
    const loginUrl = new URL('/login', request.url);
    loginUrl.searchParams.set('redirect', pathname);
    return NextResponse.redirect(loginUrl);
  }

  // 로그인 페이지: 이미 세션이 있으면 대시보드로 리디렉트
  if ((pathname === '/login' || pathname === '/login/') && sessionToken) {
    return NextResponse.redirect(new URL('/dashboard', request.url));
  }

  return NextResponse.next();
}

/**
 * 미들웨어가 적용될 경로 설정
 *
 * API, Next.js 내부 경로, 정적 파일은 제외합니다.
 */
export const config = {
  matcher: [
    /*
     * 다음 경로를 제외한 모든 경로에 적용:
     * - api (API routes)
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     */
    '/((?!api|_next/static|_next/image|favicon.ico).*)',
  ],
};
