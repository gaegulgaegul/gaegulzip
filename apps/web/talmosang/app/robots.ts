import type { MetadataRoute } from 'next';

/**
 * robots.txt 생성
 *
 * 검색엔진 크롤러의 크롤링 범위를 제어합니다.
 * - 정적 페이지(/, /privacy)는 허용
 * - API 라우트(/api/*)는 차단
 */
export default function robots(): MetadataRoute.Robots {
  return {
    rules: [
      {
        userAgent: '*',
        allow: '/',
        disallow: '/api/',
      },
    ],
    sitemap: 'https://talmosang.vercel.app/sitemap.xml',
  };
}
