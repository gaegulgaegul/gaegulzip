import { Black_Han_Sans, Jua, Noto_Sans_KR } from 'next/font/google';

/**
 * Black Han Sans (굵은 타이틀 폰트)
 *
 * 용도: 앱 타이틀, 섹션 제목
 * Al Murphy 스타일: 굵고 대담한 손글씨
 */
export const blackHanSans = Black_Han_Sans({
  weight: '400',
  subsets: ['latin'],
  variable: '--font-black-han',
  display: 'swap',
  preload: true,
});

/**
 * Jua (둥근 손글씨 폰트)
 *
 * 용도: 로딩 메시지, 결과 제목
 * Al Murphy 스타일: 귀여운 손글씨
 */
export const jua = Jua({
  weight: '400',
  subsets: ['latin'],
  variable: '--font-jua',
  display: 'swap',
  preload: true,
});

/**
 * Noto Sans KR (본문 폰트)
 *
 * 용도: 일반 텍스트, 버튼, 라벨
 */
export const notoSansKr = Noto_Sans_KR({
  weight: ['400', '500', '700', '900'], // ExtraBold 추가
  subsets: ['latin'],
  variable: '--font-pretendard',
  display: 'swap',
});
