import type { Metadata } from 'next';
import { blackHanSans, jua, notoSansKr } from '@/lib/fonts';
import './globals.css';

export const metadata: Metadata = {
  metadataBase: new URL('https://gaegulzip-talmosang.vercel.app'),
  title: '탈모상 - 내가 탈모가 될 상인가?',
  description:
    'AI 관상가가 그대의 모발 운명을 점지하리라. 사진 하나로 탈모 확률, 모발 나이, 닮은 유명인을 알아보세요.',
  keywords: [
    // 핵심 브랜드
    '탈모상',
    '탈모 상',
    // 서비스 핵심
    '탈모 테스트',
    'AI 두피 분석',
    'AI 관상',
    '탈모 확률',
    '두피 분석',
    '탈모 진단',
    // 자가진단 관련
    '탈모 자가진단',
    '탈모 자가 테스트',
    '탈모 셀프 체크',
    '탈모 체크리스트',
    '탈모 초기 증상',
    '탈모 초기',
    '탈모 확인법',
    '탈모인가',
    '나도 탈모',
    '탈모 시작',
    // 탈모 유형
    '탈모',
    'M자 탈모',
    'O형 탈모',
    '원형 탈모',
    '정수리 탈모',
    '앞머리 탈모',
    '이마 탈모',
    '여성 탈모',
    '남성 탈모',
    '스트레스 탈모',
    '산후 탈모',
    '20대 탈모',
    '30대 탈모',
    // 두피 건강
    '두피 건강',
    '두피 상태',
    '두피 타입',
    '지성 두피',
    '건성 두피',
    '민감성 두피',
    '두피 각질',
    '두피 피지',
    '두피 냄새',
    '두피 가려움',
    '두피 트러블',
    // 모발 관련
    '헤어라인',
    '헤어라인 후퇴',
    '이마 넓어짐',
    '머리숱',
    '머리숱 적은',
    '머리카락 빠짐',
    '머리카락 얇아짐',
    '모발 굵기',
    '모발 밀도',
    '모발 나이',
    '머리결',
    // AI 기술
    'AI 탈모 검사',
    'AI 두피 진단',
    'AI 모발 분석',
    'AI 헤어 분석',
    '사진 탈모 진단',
    '사진 두피 분석',
    '두피 카메라',
    '두피 스캐너',
    // 재미/바이럴
    '바이럴 게임',
    '관상 테스트',
    '관상 보기',
    '재미로 보는 탈모',
    '탈모 운세',
    '탈모 관상',
    '모발 운명',
    '닮은 유명인',
    '닮은꼴 테스트',
    '심리 테스트',
    // 케어/예방
    '탈모 예방',
    '탈모 관리',
    '두피 관리',
    '두피 케어',
    '탈모 샴푸',
    '두피 샴푸',
    '탈모 영양제',
    '비오틴',
    '헤드스파',
    '두피 스파',
    // 병원/치료
    '탈모 병원',
    '탈모 치료',
    '모발이식',
    '탈모약',
    '미녹시딜',
    '피나스테리드',
    // 검색 롱테일
    '탈모 원인',
    '탈모 유전',
    '탈모에 좋은 음식',
    '탈모 스트레스',
    '하루 머리카락 빠지는 양',
    '머리카락 몇개 빠지면 탈모',
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
