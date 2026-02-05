import { describe, it, expect, beforeEach, vi } from 'vitest';

vi.mock('../../../src/config/env', () => ({
  env: {
    QNA_GITHUB_APP_ID: '123456',
    QNA_GITHUB_PRIVATE_KEY: '-----BEGIN RSA PRIVATE KEY-----\nfake-key\n-----END RSA PRIVATE KEY-----',
    QNA_GITHUB_INSTALLATION_ID: '789012',
    QNA_GITHUB_REPO_OWNER: 'gaegulzip-org',
    QNA_GITHUB_REPO_NAME: 'gaegulzip-issues',
  },
}));

import { getOctokitInstance, clearOctokitCache } from '../../../src/modules/qna/octokit';

describe('QnA Octokit', () => {
  beforeEach(() => {
    clearOctokitCache();
  });

  describe('getOctokitInstance', () => {
    it('should return an Octokit instance using env config', () => {
      const instance = getOctokitInstance();

      expect(instance).toBeDefined();
      expect(instance.rest).toBeDefined();
      expect(instance.rest.issues).toBeDefined();
    });

    it('should return cached instance on subsequent calls', () => {
      const instance1 = getOctokitInstance();
      const instance2 = getOctokitInstance();

      expect(instance1).toBe(instance2);
    });
  });
});
