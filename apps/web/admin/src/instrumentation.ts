const MIN_INTERVAL = 3 * 60 * 1000;
const MAX_INTERVAL = 5 * 60 * 1000;
const FETCH_TIMEOUT = 10 * 1000;

function scheduleHealthCheck(serverUrl: string) {
  const delay = MIN_INTERVAL + Math.random() * (MAX_INTERVAL - MIN_INTERVAL);
  setTimeout(async () => {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), FETCH_TIMEOUT);
    try {
      await fetch(`${serverUrl}/health`, { signal: controller.signal });
    } catch {
      // 서버 응답 실패는 무시 (슬립 방지 목적)
    } finally {
      clearTimeout(timeoutId);
    }
    scheduleHealthCheck(serverUrl);
  }, delay);
}

export function register() {
  if (process.env.NEXT_RUNTIME === 'nodejs') {
    const serverUrl = process.env.NEXT_PUBLIC_SERVER_URL;
    if (!serverUrl) return;

    scheduleHealthCheck(serverUrl);
  }
}
