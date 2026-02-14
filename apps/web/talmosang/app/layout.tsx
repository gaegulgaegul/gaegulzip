import type { Metadata } from 'next';
import { blackHanSans, jua, notoSansKr } from '@/lib/fonts';
import './globals.css';

export const metadata: Metadata = {
  metadataBase: new URL('https://talmosang.vercel.app'),
  title: '탈모상 - 내가 탈모가 될 상인가?',
  description: 'AI 관상가가 그대의 모발 운명을 점지하리라',
  keywords: ['탈모', 'AI 관상', '두피 분석', '헤어라인', '바이럴 게임'],
  openGraph: {
    title: '탈모상 - 내가 탈모가 될 상인가?',
    description: 'AI 관상가가 그대의 모발 운명을 점지하리라',
    type: 'website',
    images: ['/og-image.png'],
  },
  twitter: {
    card: 'summary_large_image',
    title: '탈모상 - 내가 탈모가 될 상인가?',
    description: 'AI 관상가가 그대의 모발 운명을 점지하리라',
    images: ['/og-image.png'],
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
