import type { Metadata } from 'next';
import { blackHanSans, jua, notoSansKr } from '@/lib/fonts';
import './globals.css';

export const metadata: Metadata = {
  metadataBase: new URL('https://gaegulzip-talmosang.vercel.app'),
  title: '탈모상 - 내가 탈모가 될 상인가?',
  description:
    'AI 관상가가 그대의 모발 운명을 점지하리라. 사진 하나로 탈모 확률, 모발 나이, 닮은 유명인을 알아보세요.',
  keywords: [
    '탈모',
    '탈모 테스트',
    'AI 두피 분석',
    '탈모 확률',
    'AI 관상',
    '두피 분석',
    '헤어라인',
    '탈모 진단',
    '바이럴 게임',
    '탈모상',
    '탈모 상',
  ],
  alternates: {
    canonical: 'https://gaegulzip-talmosang.vercel.app',
  },
  openGraph: {
    title: '탈모상 - 내가 탈모가 될 상인가?',
    description:
      'AI 관상가가 그대의 모발 운명을 점지하리라. 사진 하나로 탈모 확률, 모발 나이, 닮은 유명인을 알아보세요.',
    type: 'website',
    url: 'https://gaegulzip-talmosang.vercel.app',
    locale: 'ko_KR',
    siteName: '탈모상',
    images: [
      {
        url: '/og-image.png',
        width: 1200,
        height: 630,
        alt: '탈모상 - AI 두피 분석 서비스',
      },
    ],
  },
  twitter: {
    card: 'summary_large_image',
    title: '탈모상 - 내가 탈모가 될 상인가?',
    description:
      'AI 관상가가 그대의 모발 운명을 점지하리라. 사진 하나로 탈모 확률, 모발 나이, 닮은 유명인을 알아보세요.',
    images: ['/og-image.png'],
  },
};

/**
 * WebApplication 타입 JSON-LD 구조화 데이터
 *
 * 검색엔진이 탈모상의 서비스 유형을 의미론적으로 이해하도록 지원합니다.
 */
const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'WebApplication',
  name: '탈모상',
  alternateName: '탈모상 - 내가 탈모가 될 상인가?',
  url: 'https://gaegulzip-talmosang.vercel.app',
  description:
    'AI 관상가가 사진 하나로 탈모 확률, 모발 나이, 닮은 유명인을 분석해드립니다. 재미로 즐기는 AI 두피 분석 서비스.',
  applicationCategory: 'EntertainmentApplication',
  operatingSystem: 'Web',
  inLanguage: 'ko-KR',
  offers: {
    '@type': 'Offer',
    price: '0',
    priceCurrency: 'KRW',
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html
      lang="ko"
      className={`${blackHanSans.variable} ${jua.variable} ${notoSansKr.variable}`}
    >
      <head>
        {/* JSON-LD 구조화 데이터 */}
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
        />
        {/* Google AdSense */}
        {process.env.NEXT_PUBLIC_ADSENSE_ID && (
          <script
            async
            src={`https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=${process.env.NEXT_PUBLIC_ADSENSE_ID}`}
            crossOrigin="anonymous"
          />
        )}
      </head>
      <body className="antialiased">
        {/* 노이즈 텍스처 오버레이 */}
        <div className="noise-overlay" aria-hidden="true" />
        {children}
      </body>
    </html>
  );
}
