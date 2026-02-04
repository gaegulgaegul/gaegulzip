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
const createOctokitInstance = (): Octokit => {
  return new MyOctokit({
    authStrategy: createAppAuth,
    auth: {
      appId: env.QNA_GITHUB_APP_ID,
      privateKey: env.QNA_GITHUB_PRIVATE_KEY,
      installationId: parseInt(env.QNA_GITHUB_INSTALLATION_ID, 10),
    },
    throttle: {
      onRateLimit: (retryAfter, options, octokit, retryCount) => {
        octokit.log.warn(`Rate limit hit: ${options.method} ${options.url}`);
        if (retryCount < 2) {
          octokit.log.info(`Retrying after ${retryAfter}s`);
          return true; // 재시도
        }
        return false; // 포기
      },
      onSecondaryRateLimit: (retryAfter, options, octokit) => {
        octokit.log.warn(`Secondary rate limit: ${options.method} ${options.url}`);
        return true; // 콘텐츠 생성은 secondary rate limit에 민감하므로 재시도
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
