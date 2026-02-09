import { describe, it, expect } from 'vitest';
import { generateRandomUsername } from './username-generator';

describe('generateRandomUsername', () => {
  it('should generate username with adjective, noun, and number', () => {
    const username = generateRandomUsername();

    // 형용사+명사+숫자 패턴 검증
    expect(username).toBeTruthy();
    expect(typeof username).toBe('string');
    expect(username.length).toBeGreaterThan(0);
  });

  it('should generate unique usernames on multiple calls', () => {
    const username1 = generateRandomUsername();
    const username2 = generateRandomUsername();
    const username3 = generateRandomUsername();

    // 세 번 호출했을 때 최소 2개는 달라야 함 (숫자가 랜덤이므로)
    const uniqueUsernames = new Set([username1, username2, username3]);
    expect(uniqueUsernames.size).toBeGreaterThanOrEqual(2);
  });

  it('should contain only Korean characters and numbers', () => {
    const username = generateRandomUsername();

    // 한글 + 숫자만 포함 (형용사+명사+숫자)
    const koreanAndNumberPattern = /^[가-힣0-9]+$/;
    expect(username).toMatch(koreanAndNumberPattern);
  });

  it('should have reasonable length (not too short or too long)', () => {
    const username = generateRandomUsername();

    // 형용사(2-4자) + 명사(2-3자) + 숫자(1-4자) = 대략 5-11자
    expect(username.length).toBeGreaterThanOrEqual(5);
    expect(username.length).toBeLessThanOrEqual(15);
  });
});
