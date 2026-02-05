import { Octokit } from '@octokit/rest';
import { createAppAuth } from '@octokit/auth-app';
import { throttling } from '@octokit/plugin-throttling';
import { retry } from '@octokit/plugin-retry';
import { env } from '../../config/env';

/**
 * Octokit 플러그인 적용
 */
const MyOctokit = Octokit.plugin(throttling, retry);

/**
 * Octokit 인스턴스 캐시 (단일 인스턴스)
 */
let cachedInstance: Octokit | null = null;

/**
 * env 기반으로 Octokit 인스턴스를 생성합니다
 * @returns Octokit 인스턴스
 */
/**
 * 환경 변수에서 installation ID를 파싱합니다
 * @param value - 문자열 형태의 installation ID
 * @returns 파싱된 숫자
 * @throws Error - 유효하지 않은 숫자인 경우
 */
const parseInstallationId = (value: string): number => {
  const parsed = parseInt(value, 10);
  if (Number.isNaN(parsed)) {
    throw new Error(`QNA_GITHUB_INSTALLATION_ID must be a valid number, got: "${value}"`);
  }
  return parsed;
};

const createOctokitInstance = (): Octokit => {
  if (!env.QNA_GITHUB_APP_ID || !env.QNA_GITHUB_PRIVATE_KEY || !env.QNA_GITHUB_INSTALLATION_ID) {
    throw new Error('QnA GitHub App credentials are not configured. Check QNA_GITHUB_APP_ID, QNA_GITHUB_PRIVATE_KEY, QNA_GITHUB_INSTALLATION_ID.');
  }

  return new MyOctokit({
    authStrategy: createAppAuth,
    auth: {
      appId: env.QNA_GITHUB_APP_ID,
      privateKey: env.QNA_GITHUB_PRIVATE_KEY,
      installationId: parseInstallationId(env.QNA_GITHUB_INSTALLATION_ID),
    },
    throttle: {
      onRateLimit: (retryAfter, options, octokit, retryCount) => {
        octokit.log.warn(`Rate limit hit: ${options.method} ${options.url}`);
        if (retryCount < 2) {
          octokit.log.info(`Retrying after ${retryAfter}s`);
          return true;
        }
        return false;
      },
      onSecondaryRateLimit: (retryAfter, options, octokit, retryCount) => {
        octokit.log.warn(`Secondary rate limit: ${options.method} ${options.url}`);
        if (retryCount < 2) {
          return true;
        }
        return false;
      },
    },
    retry: {
      doNotRetry: ['429'], // throttling 플러그인이 429를 처리
    },
  });
};

/**
 * Octokit 인스턴스를 가져옵니다 (캐싱)
 * @returns Octokit 인스턴스 (캐시된 인스턴스 또는 새 인스턴스)
 */
export const getOctokitInstance = (): Octokit => {
  if (!cachedInstance) {
    cachedInstance = createOctokitInstance();
  }
  return cachedInstance;
};

/**
 * Octokit 캐시를 삭제합니다 (테스트용)
 */
export const clearOctokitCache = (): void => {
  cachedInstance = null;
};
