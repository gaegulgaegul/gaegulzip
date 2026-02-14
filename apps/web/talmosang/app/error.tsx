'use client';

import { useEffect } from 'react';
import Link from 'next/link';

/**
 * 전역 에러 경계 (Error Boundary)
 *
 * React 렌더링 에러를 catch하여 사용자 친화적인 에러 화면을 표시합니다.
 * 사극 말투로 에러 메시지를 제공합니다.
 */
export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    // 에러 로깅 (프로덕션에서는 로깅 서비스로 전송)
    console.error('전역 에러 발생:', error);
  }, [error]);

  return (
    <main className="min-h-screen px-4 py-8 max-w-lg mx-auto flex items-center justify-center">
      <div className="text-center">
        {/* 에러 타이틀 */}
        <h1
          className="text-4xl md:text-5xl text-charcoal mb-4 rotate-[-2deg]"
          style={{ fontFamily: 'var(--font-nanum-pen)' }}
        >
          아이고, 큰일났구려!
        </h1>

        {/* 에러 메시지 카드 */}
        <div className="bg-cream border-3 border-coral rounded-2xl p-8 mb-6 rotate-[0.5deg] shadow-lg">
          <div className="mb-4">
            <span className="text-6xl">😱</span>
          </div>

          <p className="text-lg text-charcoal mb-4">
            관상가 양반이 잠시 정신을 잃었사옵니다.
          </p>

          <p className="text-sm text-charcoal/70 mb-6">
            예기치 못한 오류가 발생했습니다. 잠시 후 다시 시도해주시게.
          </p>

          {/* 에러 상세 (개발 환경에서만 표시) */}
          {process.env.NODE_ENV === 'development' && (
            <details className="text-left mt-4 p-4 bg-cream-dark rounded-lg">
              <summary className="text-sm font-medium cursor-pointer">
                기술 상세 정보 (개발 모드)
              </summary>
              <pre className="text-xs mt-2 overflow-auto">
                {error.message}
                {error.digest && `\nDigest: ${error.digest}`}
              </pre>
            </details>
          )}
        </div>

        {/* 액션 버튼 */}
        <div className="flex flex-col sm:flex-row gap-4 justify-center">
          <button
            onClick={reset}
            className="px-6 py-3 bg-coral text-white rounded-full font-bold hover:bg-coral/90 hover:scale-105 transition-all shadow-md"
          >
            다시 시도하기
          </button>

          <Link
            href="/"
            className="px-6 py-3 bg-deep-blue text-white rounded-full font-bold hover:bg-deep-blue/90 hover:scale-105 transition-all shadow-md"
          >
            처음으로 돌아가기
          </Link>
        </div>

        {/* 하단 안내 */}
        <p className="text-sm text-charcoal/50 mt-8">
          문제가 계속되면 페이지를 새로고침해주시게.
        </p>
      </div>
    </main>
  );
}
