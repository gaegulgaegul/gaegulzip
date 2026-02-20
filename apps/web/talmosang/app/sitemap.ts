import type { MetadataRoute } from 'next';

const BASE_URL = 'https://gaegulzip-talmosang.vercel.app';

/**
 * sitemap.xml 생성
 *
 * 검색엔진에 페이지 목록과 우선순위를 전달합니다.
 * - 메인 페이지(/): priority 1.0, 월간 변경
 * - 개인정보처리방침(/privacy): priority 0.3, 연간 변경
 * - 동적 분석 결과 페이지는 서버에 저장되지 않으므로 제외
 */
export default function sitemap(): MetadataRoute.Sitemap {
  return [
    {
      url: BASE_URL,
      lastModified: new Date('2026-02-20'),
      changeFrequency: 'monthly',
      priority: 1.0,
    },
    {
      url: `${BASE_URL}/privacy`,
      lastModified: new Date('2026-02-20'),
      changeFrequency: 'yearly',
      priority: 0.3,
    },
  ];
}
