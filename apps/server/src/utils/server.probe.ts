import { logger } from './logger';

/**
 * 서버 수명주기 운영 로그 (Domain Probe 패턴)
 *
 * 서버 시작/종료와 관련된 운영 로그를 담당합니다.
 * 디버깅 로그는 각 핸들러에서 직접 작성하세요.
 */

/**
 * 서버 시작 완료 로그
 */
export const started = (port: number | string) => {
  logger.info({ port }, 'Server started successfully');
};

/**
 * Shutdown 신호 수신 로그 (SIGTERM, SIGINT)
 */
export const shutdownSignalReceived = (signal: string) => {
  logger.info({ signal }, 'Shutdown signal received');
};

/**
 * 새 연결 수락 중단 로그
 */
export const stoppingNewConnections = () => {
  logger.info('Stopping new connections');
};

/**
 * 데이터베이스 연결 종료 시작 로그
 */
export const closingDatabase = () => {
  logger.info('Closing database connections');
};

/**
 * 데이터베이스 연결 종료 완료 로그
 */
export const databaseClosed = () => {
  logger.info('Database connections closed');
};

/**
 * Shutdown 완료 로그
 */
export const shutdownComplete = (durationMs: number) => {
  logger.info({ durationMs }, 'Server shutdown complete');
};

/**
 * 타임아웃으로 인한 강제 종료 로그
 */
export const forceShutdown = (timeoutMs: number) => {
  logger.error({ timeoutMs }, 'Forced shutdown due to timeout');
};

/**
 * Shutdown 중 에러 발생 로그
 */
export const shutdownError = (error: Error) => {
  logger.error(
    { error: error.message, stack: error.stack },
    'Error during shutdown'
  );
};
