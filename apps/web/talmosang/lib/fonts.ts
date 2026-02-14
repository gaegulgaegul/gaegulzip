import { Nanum_Pen_Script, Noto_Sans_KR } from 'next/font/google';

/**
 * 나눔 펜 스크립트 폰트 (손글씨)
 *
 * 용도: 앱 타이틀, 결과 제목, 로딩 메시지
 */
export const nanumPen = Nanum_Pen_Script({
  weight: '400',
  subsets: ['latin'],
  variable: '--font-nanum-pen',
  display: 'swap',
  preload: true,
});

/**
 * Noto Sans KR 폰트 (본문)
 *
 * 용도: 일반 텍스트, 버튼, 라벨
 * 참고: Pretendard 대신 Google Fonts의 Noto Sans KR 사용
 */
export const pretendard = Noto_Sans_KR({
  weight: ['400', '500', '700'],
  subsets: ['latin'],
  variable: '--font-pretendard',
  display: 'swap',
});
