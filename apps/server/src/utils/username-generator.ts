/**
 * 한글 닉네임 자동 생성 유틸리티
 *
 * "형용사 + 명사 + 숫자" 패턴으로 랜덤 닉네임을 생성합니다.
 * 예: 신비로운호랑이123, 빠른구름42
 */

/**
 * 긍정적이고 친근한 형용사 목록
 */
const ADJECTIVES = [
  '신비로운',
  '빠른',
  '용감한',
  '밝은',
  '조용한',
  '멋진',
  '귀여운',
  '강한',
  '똑똑한',
  '행복한',
  '따뜻한',
  '시원한',
  '부지런한',
  '재빠른',
  '상냥한',
] as const;

/**
 * 동물, 자연, 일상 관련 명사 목록
 */
const NOUNS = [
  '호랑이',
  '독수리',
  '여우',
  '사자',
  '고양이',
  '강아지',
  '별',
  '달',
  '구름',
  '바다',
  '산',
  '강',
  '나무',
  '꽃',
  '바람',
] as const;

/**
 * 랜덤 닉네임 생성
 *
 * @returns 형용사+명사+숫자 패턴의 닉네임 (예: "신비로운호랑이123")
 *
 * @example
 * ```typescript
 * const username = generateRandomUsername();
 * // "빠른구름42"
 * ```
 */
export function generateRandomUsername(): string {
  const adjective = ADJECTIVES[Math.floor(Math.random() * ADJECTIVES.length)];
  const noun = NOUNS[Math.floor(Math.random() * NOUNS.length)];
  const number = Math.floor(Math.random() * 10000); // 0-9999

  return `${adjective}${noun}${number}`;
}
