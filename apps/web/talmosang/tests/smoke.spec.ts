import { test, expect } from '@playwright/test';

/**
 * 스모크 테스트 (Smoke Test)
 *
 * 기본적인 UI 로딩 및 핵심 요소 표시 확인
 * API 호출은 모킹 없이 UI만 테스트
 */

test.describe('탈모상 기본 UI 테스트', () => {
  test('홈페이지 로딩 및 타이틀 확인', async ({ page }) => {
    // 홈페이지 접속
    await page.goto('/');

    // 타이틀 확인
    await expect(page).toHaveTitle(/탈모상/);

    // 메인 타이틀 표시 확인
    const title = page.getByRole('heading', { name: /탈모상/ });
    await expect(title).toBeVisible();
  });

  test('업로드 영역 표시 확인', async ({ page }) => {
    await page.goto('/');

    // 업로드 영역 텍스트 확인
    const uploadText = page.getByText(/사진을 드래그하거나 클릭하여 업로드/);
    await expect(uploadText).toBeVisible();

    // 파일 input 존재 확인
    const fileInput = page.locator('input[type="file"]');
    await expect(fileInput).toBeAttached();
  });

  test('면책 고지 표시 확인', async ({ page }) => {
    await page.goto('/');

    // 면책 문구 확인
    const disclaimer = page.getByText(/업로드한 사진은 분석 후 즉시 삭제됩니다/);
    await expect(disclaimer).toBeVisible();
  });

  test('개인정보처리방침 링크 확인', async ({ page }) => {
    await page.goto('/');

    // 개인정보처리방침 링크 확인
    const privacyLink = page.getByRole('link', { name: /개인정보처리방침/ });
    await expect(privacyLink).toBeVisible();

    // 링크 클릭 시 이동 확인
    await privacyLink.click();
    await expect(page).toHaveURL(/\/privacy/);
  });

  test('모바일 반응형 확인', async ({ page }) => {
    // 모바일 뷰포트 설정
    await page.setViewportSize({ width: 375, height: 667 });
    await page.goto('/');

    // 모바일에서도 타이틀 표시 확인
    const title = page.getByRole('heading', { name: /탈모상/ });
    await expect(title).toBeVisible();

    // 업로드 영역 표시 확인
    const uploadText = page.getByText(/사진을 드래그하거나 클릭하여 업로드/);
    await expect(uploadText).toBeVisible();
  });
});
