/**
 * Admin 인증 유틸리티
 *
 * 비밀번호 검증, 세션 토큰 생성 및 관리를 제공합니다.
 */

/**
 * Admin 비밀번호 해시 (SHA-256)
 *
 * 해시: 691b255bbb5e34e38311967742cbff2ee2dbec87db5b78a64f5db99ff3acd7b1
 */
export const ADMIN_PASSWORD_HASH =
  '691b255bbb5e34e38311967742cbff2ee2dbec87db5b78a64f5db99ff3acd7b1';

/**
 * 세션 쿠키 이름
 */
export const SESSION_COOKIE_NAME = 'admin-session';

/**
 * 입력된 비밀번호를 검증합니다
 *
 * @param input - 사용자가 입력한 비밀번호
 * @returns 비밀번호가 올바르면 true, 아니면 false
 */
export async function verifyPassword(input: string): Promise<boolean> {
  // SHA-256 해시 생성
  const encoder = new TextEncoder();
  const data = encoder.encode(input);
  const hashBuffer = await crypto.subtle.digest('SHA-256', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  const hashHex = hashArray.map((b) => b.toString(16).padStart(2, '0')).join('');

  return hashHex === ADMIN_PASSWORD_HASH;
}

/**
 * 세션 토큰을 생성합니다
 *
 * @returns 랜덤 세션 토큰 문자열
 */
export function createSessionToken(): string {
  // 간단한 랜덤 문자열 생성 (32바이트 hex)
  const array = new Uint8Array(32);
  crypto.getRandomValues(array);
  return Array.from(array)
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}
