import { z } from 'zod';

const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  JWT_SECRET_FALLBACK: z.string().min(32),
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.string().default('3001'),
  QNA_GITHUB_APP_ID: z.string().optional(),
  QNA_GITHUB_PRIVATE_KEY: z.string().optional(),
  QNA_GITHUB_INSTALLATION_ID: z.string().optional(),
  QNA_GITHUB_REPO_OWNER: z.string().optional(),
  QNA_GITHUB_REPO_NAME: z.string().optional(),
});

/**
 * 환경 변수 검증 및 타입 안전한 객체
 */
export const env = envSchema.parse(process.env);
