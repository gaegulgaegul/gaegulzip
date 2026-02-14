import { defineConfig, devices } from '@playwright/test';

/**
 * Playwright 설정
 *
 * 탈모상 E2E 테스트 설정
 */
export default defineConfig({
  testDir: './tests',

  // 최대 실패 횟수
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,

  // 리포터 설정
  reporter: 'html',

  use: {
    // Base URL (로컬 개발 서버)
    baseURL: 'http://localhost:3000',

    // 스크린샷, 비디오 설정
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },

  // 프로젝트별 설정 (브라우저)
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'mobile-chrome',
      use: { ...devices['Pixel 5'] },
    },
  ],

  // 개발 서버 자동 시작
  webServer: {
    command: 'pnpm dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
