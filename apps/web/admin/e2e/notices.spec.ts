import { test, expect } from '@playwright/test';

/**
 * 로그인 후 인증 상태를 설정하는 헬퍼
 * admin-session 쿠키를 직접 설정하여 인증을 우회
 */
async function loginAsAdmin(page: import('@playwright/test').Page) {
  await page.context().addCookies([{
    name: 'admin-session',
    value: 'test-session-token',
    domain: 'localhost',
    path: '/',
  }]);
}

// ─── 7. 공지사항 사이드바 메뉴 ──────────────────────────────────

test.describe('공지사항 사이드바 메뉴', () => {
  test('사이드바에 "공지사항" 메뉴가 표시된다', async ({ page }) => {
    await loginAsAdmin(page);
    await page.goto('/dashboard');
    await expect(page.getByRole('link', { name: '공지사항' })).toBeVisible();
  });

  test('클릭하면 /notices로 이동한다', async ({ page }) => {
    await loginAsAdmin(page);
    await page.goto('/dashboard');
    await page.getByRole('link', { name: '공지사항' }).click();
    await expect(page).toHaveURL(/\/notices/);
  });
});

// ─── 8. 공지사항 목록 페이지 ────────────────────────────────────

test.describe('공지사항 목록 페이지', () => {
  test('/notices에 접속하면 공지사항 관리 페이지가 표시된다', async ({ page }) => {
    await loginAsAdmin(page);
    await page.goto('/notices');
    await expect(page.getByRole('heading', { name: '공지사항 관리' })).toBeVisible();
  });

  test('"새 공지 작성" 버튼이 있다', async ({ page }) => {
    await loginAsAdmin(page);
    await page.goto('/notices');
    await expect(page.getByRole('button', { name: '새 공지 작성' })).toBeVisible();
  });
});

// ─── 9. 공지사항 작성 ──────────────────────────────────────────

test.describe('공지사항 작성', () => {
  test('새 공지 작성 폼에서 제목/본문 입력 후 저장하면 목록에 나타난다', async ({ page }) => {
    await loginAsAdmin(page);

    // API 모킹: create 성공
    await page.route('**/admin/notices', async (route) => {
      const method = route.request().method();
      if (method === 'POST') {
        await route.fulfill({
          status: 201,
          contentType: 'application/json',
          body: JSON.stringify({
            id: 1,
            title: '테스트 공지',
            content: '테스트 내용',
            category: null,
            isPinned: false,
            viewCount: 0,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
          }),
        });
      } else {
        // GET — list
        await route.fulfill({
          status: 200,
          contentType: 'application/json',
          body: JSON.stringify({
            items: [{
              id: 1,
              title: '테스트 공지',
              category: null,
              isPinned: false,
              viewCount: 0,
              createdAt: new Date().toISOString(),
            }],
            totalCount: 1,
            page: 1,
            limit: 20,
            hasNext: false,
          }),
        });
      }
    });

    await page.goto('/notices/new');
    await page.getByLabel('제목').fill('테스트 공지');
    await page.getByLabel('본문').fill('테스트 내용');
    await page.getByRole('button', { name: '저장' }).click();

    // 목록 페이지로 리디렉트되어 새 공지가 보여야 함
    await expect(page).toHaveURL(/\/notices$/);
    await expect(page.getByText('테스트 공지')).toBeVisible();
  });
});

// ─── 10. 공지사항 수정 ─────────────────────────────────────────

test.describe('공지사항 수정', () => {
  test('목록에서 공지를 클릭하면 수정 페이지로 이동한다', async ({ page }) => {
    await loginAsAdmin(page);

    await page.route('**/admin/notices?*', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          items: [{
            id: 1,
            title: '기존 공지',
            category: 'update',
            isPinned: false,
            viewCount: 5,
            createdAt: new Date().toISOString(),
          }],
          totalCount: 1,
          page: 1,
          limit: 20,
          hasNext: false,
        }),
      });
    });

    await page.goto('/notices');
    await page.getByText('기존 공지').click();
    await expect(page).toHaveURL(/\/notices\/1\/edit/);
  });

  test('수정 후 저장하면 변경사항이 반영된다', async ({ page }) => {
    await loginAsAdmin(page);

    // GET /admin/notices/1 — 기존 데이터
    await page.route('**/admin/notices/1', async (route) => {
      const method = route.request().method();
      if (method === 'GET') {
        await route.fulfill({
          status: 200,
          contentType: 'application/json',
          body: JSON.stringify({
            id: 1,
            title: '기존 공지',
            content: '기존 내용',
            category: 'update',
            isPinned: false,
            viewCount: 5,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
          }),
        });
      } else if (method === 'PUT') {
        await route.fulfill({
          status: 200,
          contentType: 'application/json',
          body: JSON.stringify({
            id: 1,
            title: '수정된 공지',
            content: '수정된 내용',
            category: 'update',
            isPinned: false,
            viewCount: 5,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
          }),
        });
      }
    });

    // 목록 API 모킹 (리디렉트 후)
    await page.route('**/admin/notices?*', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          items: [{
            id: 1,
            title: '수정된 공지',
            category: 'update',
            isPinned: false,
            viewCount: 5,
            createdAt: new Date().toISOString(),
          }],
          totalCount: 1,
          page: 1,
          limit: 20,
          hasNext: false,
        }),
      });
    });

    await page.goto('/notices/1/edit');
    await page.getByLabel('제목').fill('수정된 공지');
    await page.getByRole('button', { name: '저장' }).click();

    await expect(page).toHaveURL(/\/notices$/);
    await expect(page.getByText('수정된 공지')).toBeVisible();
  });
});

// ─── 11. 공지사항 삭제 ─────────────────────────────────────────

test.describe('공지사항 삭제', () => {
  test('삭제 버튼 클릭 시 확인 다이얼로그가 표시된다', async ({ page }) => {
    await loginAsAdmin(page);

    await page.route('**/admin/notices?*', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          items: [{
            id: 1,
            title: '삭제할 공지',
            category: null,
            isPinned: false,
            viewCount: 0,
            createdAt: new Date().toISOString(),
          }],
          totalCount: 1,
          page: 1,
          limit: 20,
          hasNext: false,
        }),
      });
    });

    await page.goto('/notices');
    await page.getByRole('button', { name: '삭제' }).click();
    await expect(page.getByText('공지사항 삭제')).toBeVisible();
  });

  test('확인하면 목록에서 사라진다', async ({ page }) => {
    await loginAsAdmin(page);
    let deleted = false;

    await page.route('**/admin/notices/1', async (route) => {
      if (route.request().method() === 'DELETE') {
        deleted = true;
        await route.fulfill({ status: 204 });
      }
    });

    await page.route('**/admin/notices?*', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          items: deleted ? [] : [{
            id: 1,
            title: '삭제할 공지',
            category: null,
            isPinned: false,
            viewCount: 0,
            createdAt: new Date().toISOString(),
          }],
          totalCount: deleted ? 0 : 1,
          page: 1,
          limit: 20,
          hasNext: false,
        }),
      });
    });

    await page.goto('/notices');
    await page.getByRole('button', { name: '삭제' }).click();
    await page.getByRole('alertdialog').getByRole('button', { name: '삭제' }).click();

    await expect(page.getByText('공지사항이 없습니다.')).toBeVisible();
  });
});

// ─── 12. 공지사항 고정 ─────────────────────────────────────────

test.describe('공지사항 고정', () => {
  test('고정 토글 시 상태가 변경된다', async ({ page }) => {
    await loginAsAdmin(page);
    let pinned = false;

    await page.route('**/admin/notices/1/pin', async (route) => {
      pinned = true;
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          id: 1, title: '고정 공지', isPinned: true,
          updatedAt: new Date().toISOString(),
        }),
      });
    });

    await page.route('**/admin/notices?*', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          items: [{
            id: 1,
            title: '고정 공지',
            category: null,
            isPinned: pinned,
            viewCount: 0,
            createdAt: new Date().toISOString(),
          }],
          totalCount: 1,
          page: 1,
          limit: 20,
          hasNext: false,
        }),
      });
    });

    await page.goto('/notices');
    const switchEl = page.getByRole('switch');
    await expect(switchEl).not.toBeChecked();
    await switchEl.click();
    await expect(switchEl).toBeChecked();
  });
});
