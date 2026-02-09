import { app } from './app';
import { client } from './config/database';
import * as serverProbe from './utils/server.probe';

const PORT = process.env.PORT || 3001;
const SHUTDOWN_TIMEOUT = 25000; // 25초 (Render 30초보다 5초 여유)

/**
 * HTTP 서버 시작
 */
const server = app.listen(PORT, () => {
  serverProbe.started(PORT);
});

/**
 * Graceful shutdown 핸들러
 *
 * SIGTERM/SIGINT 수신 시:
 * 1. 새 연결 거부 (server.close)
 * 2. 진행 중인 요청 완료 대기
 * 3. 데이터베이스 연결 종료
 * 4. 프로세스 종료 (코드 0: 성공, 1: 실패)
 *
 * 타임아웃(25초) 초과 시 강제 종료
 */
const gracefulShutdown = async (signal: string) => {
  const startTime = Date.now();
  serverProbe.shutdownSignalReceived(signal);

  const forceShutdownTimer = setTimeout(() => {
    serverProbe.forceShutdown(SHUTDOWN_TIMEOUT);
    process.exit(1);
  }, SHUTDOWN_TIMEOUT);

  try {
    // 1. 새 연결 거부
    serverProbe.stoppingNewConnections();
    await new Promise<void>((resolve, reject) => {
      server.close((err) => (err ? reject(err) : resolve()));
    });

    // 2. Database 연결 종료
    serverProbe.closingDatabase();
    await client.end();
    serverProbe.databaseClosed();

    // 3. 종료 완료
    const duration = Date.now() - startTime;
    serverProbe.shutdownComplete(duration);

    clearTimeout(forceShutdownTimer);
    process.exit(0);
  } catch (error) {
    serverProbe.shutdownError(error as Error);
    clearTimeout(forceShutdownTimer);
    process.exit(1);
  }
};

/**
 * SIGTERM: Render.com 배포 시 종료 신호
 * SIGINT: Ctrl+C (로컬 개발 환경)
 */
process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));
