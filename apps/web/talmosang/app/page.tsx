'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import dynamic from 'next/dynamic';
import UploadSection from '@/components/UploadSection';
import AdBanner from '@/components/AdBanner';
import DisclaimerText from '@/components/DisclaimerText';
import { resizeImage, getMimeType } from '@/lib/image-utils';
import { ERROR_MESSAGES } from '@/lib/errors';
import type { AnalysisResult, GenerateImageResponse } from '@/types/analysis';

// Dynamic import로 초기 번들 크기 감소
const LoadingSection = dynamic(() => import('@/components/LoadingSection'), {
  ssr: false,
});
const ResultSection = dynamic(() => import('@/components/ResultSection'), {
  ssr: false,
});

type AppStep = 'upload' | 'loading' | 'result';

/**
 * 탈모상 메인 페이지
 *
 * 3단계 상태 전환을 관리합니다:
 * 1. upload: 사진 업로드
 * 2. loading: AI 분석 중
 * 3. result: 분석 결과 표시
 */
export default function HomePage() {
  const [step, setStep] = useState<AppStep>('upload');
  const [photo, setPhoto] = useState<File | null>(null);
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [result, setResult] = useState<AnalysisResult | null>(null);

  /**
   * previewUrl cleanup (메모리 누수 방지)
   */
  useEffect(() => {
    return () => {
      if (previewUrl) {
        URL.revokeObjectURL(previewUrl);
      }
    };
  }, [previewUrl]);

  /**
   * 사진 업로드 핸들러
   *
   * File 객체를 받아서 미리보기 URL을 생성하고 상태를 업데이트합니다.
   */
  const handlePhotoUpload = (file: File) => {
    // 기존 미리보기 URL 정리
    if (previewUrl) {
      URL.revokeObjectURL(previewUrl);
    }

    setPhoto(file);
    setPreviewUrl(URL.createObjectURL(file));
    setError(null);
  };

  /**
   * 분석 시작 핸들러
   *
   * 1. 이미지를 리사이즈하고 Base64로 변환
   * 2. POST /api/analyze 호출하여 두피 분석
   * 3. 분석 결과로 POST /api/generate-image 호출하여 시뮬레이션 이미지 생성
   * 4. 결과 화면으로 전환
   */
  const handleAnalyze = async () => {
    if (!photo) {
      setError('사진을 먼저 선택해주시옵소서.');
      return;
    }

    setStep('loading');
    setError(null);

    try {
      // 1. 이미지 리사이즈 및 Base64 변환
      const base64Image = await resizeImage(photo, 800);
      const mimeType = getMimeType(photo);

      // 2. 두피 분석 API 호출
      const analysisResponse = await fetch('/api/analyze', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          image: base64Image,
          mimeType,
        }),
      });

      if (!analysisResponse.ok) {
        const errorData = await analysisResponse.json().catch(() => ({}));

        // Rate Limit 에러 처리
        if (analysisResponse.status === 429) {
          throw new Error(ERROR_MESSAGES.RATE_LIMIT);
        }

        // 일반 API 에러
        throw new Error(errorData.error || ERROR_MESSAGES.API_ERROR);
      }

      const analysisData: AnalysisResult = await analysisResponse.json();

      // 3. 이미지 생성 API 호출 (순차)
      try {
        const imageResponse = await fetch('/api/generate-image', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            prompt: analysisData.imagePrompt,
          }),
        });

        if (imageResponse.ok) {
          const imageData: GenerateImageResponse = await imageResponse.json();
          analysisData.simulationImage = imageData.image;
        } else {
          // 이미지 생성 실패해도 분석 결과는 표시
          console.warn('이미지 생성 실패, 분석 결과만 표시합니다.');
          analysisData.simulationImage = null;
        }
      } catch (imageError) {
        // 이미지 생성 실패해도 분석 결과는 표시
        console.error('이미지 생성 오류:', imageError);
        analysisData.simulationImage = null;
      }

      // 4. 결과 화면으로 전환
      setResult(analysisData);
      setStep('result');
    } catch (err) {
      console.error('분석 오류:', err);

      // 네트워크 오류
      if (err instanceof TypeError && err.message.includes('fetch')) {
        setError(ERROR_MESSAGES.NETWORK_ERROR);
      } else if (err instanceof Error) {
        setError(err.message);
      } else {
        setError(ERROR_MESSAGES.API_ERROR);
      }

      // 에러 시 업로드 화면으로 복귀
      setStep('upload');
    }
  };

  /**
   * 리셋 핸들러
   *
   * 모든 상태를 초기화하고 업로드 화면으로 돌아갑니다.
   */
  const handleReset = () => {
    // 미리보기 URL 정리
    if (previewUrl) {
      URL.revokeObjectURL(previewUrl);
    }

    setStep('upload');
    setPhoto(null);
    setPreviewUrl(null);
    setError(null);
    setResult(null);
  };

  return (
    <main className="min-h-screen px-4 py-8 max-w-lg mx-auto">
      {/* 앱 타이틀 (항상 표시) */}
      <header className="text-center mb-8">
        <h1
          className="text-4xl md:text-5xl text-charcoal rotate-[-2deg]"
          style={{ fontFamily: 'var(--font-nanum-pen)' }}
        >
          탈모상
        </h1>
        <div className="scribble-underline mx-auto max-w-[120px]" />
      </header>

      {/* 상단 광고 */}
      <AdBanner className="mb-6" />

      {/* 면책 문구 */}
      <DisclaimerText />

      {/* 메인 콘텐츠 (상태에 따라 전환) */}
      <div className="mt-8">
        {step === 'upload' && (
          <UploadSection
            photo={photo}
            previewUrl={previewUrl}
            error={error}
            onPhotoUpload={handlePhotoUpload}
            onAnalyze={handleAnalyze}
            onReset={handleReset}
          />
        )}

        {step === 'loading' && <LoadingSection />}

        {step === 'result' && result && (
          <ResultSection result={result} onReset={handleReset} />
        )}
      </div>

      {/* 하단 광고 */}
      <AdBanner className="mt-8" />

      {/* 푸터 */}
      <footer className="text-center mt-12 pb-8">
        <p className="text-sm text-charcoal/50">
          © 2026 탈모상 |{' '}
          <Link href="/privacy" className="underline hover:text-charcoal">
            개인정보처리방침
          </Link>
        </p>
      </footer>
    </main>
  );
}
