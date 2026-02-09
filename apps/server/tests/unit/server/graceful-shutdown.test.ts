import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';

// ─── Mocks ──────────────────────────────────────────────────────

/** Mock HTTP server */
const mockServerClose = vi.fn();
const mockHttpServer = {
  listen: vi.fn((port, callback) => {
    callback();
    return mockHttpServer;
  }),
  close: mockServerClose,
};

/** Mock Express app */
const mockApp = {
  listen: vi.fn((port, callback) => {
    callback();
    return mockHttpServer;
  }),
};

/** Mock PostgreSQL client */
const mockClientEnd = vi.fn();
const mockClient = {
  end: mockClientEnd,
};

/** Mock logger */
const mockLogger = {
  info: vi.fn(),
  error: vi.fn(),
  debug: vi.fn(),
  warn: vi.fn(),
};

// Mock modules
vi.mock('../../../src/app', () => ({
  app: mockApp,
}));

vi.mock('../../../src/config/database', () => ({
  client: mockClient,
}));

vi.mock('../../../src/utils/logger', () => ({
  logger: mockLogger,
}));

vi.mock('../../../src/utils/server.probe', () => ({
  started: vi.fn(),
  shutdownSignalReceived: vi.fn(),
  stoppingNewConnections: vi.fn(),
  closingDatabase: vi.fn(),
  databaseClosed: vi.fn(),
  shutdownComplete: vi.fn(),
  forceShutdown: vi.fn(),
  shutdownError: vi.fn(),
}));

// ─── Tests ──────────────────────────────────────────────────────

describe('Graceful Shutdown', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    vi.useFakeTimers();

    // Reset process.exit mock
    vi.spyOn(process, 'exit').mockImplementation((() => {}) as any);

    // Default: server.close() succeeds immediately
    mockServerClose.mockImplementation((callback) => {
      callback();
    });

    // Default: client.end() succeeds immediately
    mockClientEnd.mockResolvedValue(undefined);
  });

  afterEach(() => {
    vi.useRealTimers();
    vi.restoreAllMocks();
  });

  it('should close server when SIGTERM received', async () => {
    // Import server to trigger listener registration
    await import('../../../src/server');

    // Emit SIGTERM
    process.emit('SIGTERM' as any);

    // Wait for async operations
    await vi.runAllTimersAsync();

    // Verify server.close() was called
    expect(mockServerClose).toHaveBeenCalled();
  });

  it('should close database connections', async () => {
    await import('../../../src/server');

    process.emit('SIGTERM' as any);
    await vi.runAllTimersAsync();

    // Verify client.end() was called
    expect(mockClientEnd).toHaveBeenCalled();
  });

  it('should exit with code 0 after successful shutdown', async () => {
    await import('../../../src/server');

    process.emit('SIGTERM' as any);
    await vi.runAllTimersAsync();

    expect(process.exit).toHaveBeenCalledWith(0);
  });

  it('should force exit after timeout', async () => {
    // Make server.close() take longer than timeout (25s)
    mockServerClose.mockImplementation((callback) => {
      setTimeout(callback, 30000);
    });

    await import('../../../src/server');

    process.emit('SIGTERM' as any);

    // Advance time to just before timeout
    await vi.advanceTimersByTime(24999);
    expect(process.exit).not.toHaveBeenCalled();

    // Advance past timeout
    await vi.advanceTimersByTime(1);
    expect(process.exit).toHaveBeenCalledWith(1);
  });

  it('should handle SIGINT as well as SIGTERM', async () => {
    await import('../../../src/server');

    process.emit('SIGINT' as any);
    await vi.runAllTimersAsync();

    expect(mockServerClose).toHaveBeenCalled();
    expect(mockClientEnd).toHaveBeenCalled();
    expect(process.exit).toHaveBeenCalledWith(0);
  });

  it('should exit with code 1 if database close fails', async () => {
    // Make client.end() fail
    mockClientEnd.mockRejectedValue(new Error('DB connection error'));

    await import('../../../src/server');

    process.emit('SIGTERM' as any);
    await vi.runAllTimersAsync();

    expect(process.exit).toHaveBeenCalledWith(1);
  });
});
