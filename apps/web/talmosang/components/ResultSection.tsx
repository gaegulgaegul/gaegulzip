'use client';

import { useState, useEffect } from 'react';
import { Share2, Check } from 'lucide-react';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Progress } from '@/components/ui/progress';
import { cn } from '@/lib/utils';
import type { AnalysisResult } from '@/types/analysis';

interface ResultSectionProps {
  result: AnalysisResult;
  onReset: () => void;
}

/**
 * 카운트업 애니메이션 훅
 *
 * 0에서 target까지 duration 동안 증가하는 애니메이션
 */
function useCountUp(target: number, duration: number = 1500) {
  const [count, setCount] = useState(0);

  useEffect(() => {
    const startTime = Date.now();
    const timer = setInterval(() => {
      const elapsed = Date.now() - startTime;
      if (elapsed >= duration) {
        setCount(target);
        clearInterval(timer);
        return;
      }
      setCount(Math.floor((elapsed / duration) * target));
    }, 16);

    return () => clearInterval(timer);
  }, [target, duration]);

  return count;
}

/**
 * 결과 표시 섹션
 *
 * 두피 분석 결과를 손그림 감성의 카드로 표시하고
 * Web Share API 또는 폴백 공유 기능을 제공합니다.
 */
export default function ResultSection({ result, onReset }: ResultSectionProps) {
  const [copied, setCopied] = useState(false);
  const animatedAge = useCountUp(result.hairAge, 1500);
  const animatedProbability = useCountUp(result.baldProbability5yr, 1500);

  // 확률에 따른 색상 결정
  const getProbabilityColor = (probability: number) => {
    if (probability <= 30) return 'text-forest-green';
    if (probability <= 60) return 'text-mustard';
    return 'text-coral';
  };

  // 등급별 배경색 결정 (Al Murphy 스타일)
  const gradeColor = {
    'A': 'var(--color-accent-green)',
    'B': 'var(--color-bg-yellow)',
    'C': 'var(--color-accent-orange)',
    'D': 'var(--color-accent-red)',
  }[result.grade[0]] || 'var(--color-accent-green)';

  // Web Share API 공유 핸들러
  const handleShare = async () => {
    const shareData = {
      title: '탈모상 - 내 관상 결과',
      text: `${result.gradeEmoji} ${result.gradeVerdict}\n내가 탈모가 될 상인가?`,
      url: window.location.href,
    };

    try {
      if (navigator.share && navigator.canShare?.(shareData)) {
        await navigator.share(shareData);
      } else {
        // 폴백: 링크 복사
        await handleCopyLink();
      }
    } catch (err) {
      if ((err as Error).name !== 'AbortError') {
        console.error('공유 실패:', err);
      }
    }
  };

  // 링크 복사 핸들러
  const handleCopyLink = async () => {
    try {
      await navigator.clipboard.writeText(window.location.href);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch (err) {
      console.error('링크 복사 실패:', err);
    }
  };

  return (
    <section className="result-section">
      {/* 결과 제목 */}
      <h2
        className="text-5xl md:text-7xl text-black text-center mb-8 animate-bounce-in inline-block bg-white border-[8px] border-black rounded-[48px] px-16 py-8 shadow-[12px_12px_0_#000] rotate-[-2deg]"
        style={{ fontFamily: 'var(--font-jua)' }}
      >
        <span className="scribble-star inline-block mr-4" />
        관상 결과가 나왔사옵니다!
        <span className="scribble-star inline-block ml-4" />
      </h2>

      {/* 분석 결과 카드 */}
      <Card className="paper-texture pencil-border p-6 md:p-8 mb-8 rotate-[-0.5deg]">
        {/* 모발 등급 판결문 */}
        <div className="grade-section text-center mb-8">
          <div
            className="w-[300px] h-[300px] mx-auto border-[10px] border-black rounded-full shadow-[12px_12px_0_#000] rotate-[-8deg] flex flex-col items-center justify-center"
            style={{ backgroundColor: gradeColor }}
          >
            <span className="text-7xl md:text-9xl font-extrabold text-white">
              {result.grade}
            </span>
            <span className="text-5xl mt-4">{result.gradeEmoji}</span>
          </div>
          <p className="text-2xl md:text-3xl font-bold mt-4 text-center">
            {result.gradeVerdict}
          </p>

        </div>

        {/* 모발 나이 */}
        <div className="hair-age mb-8 p-6 bg-white border-[6px] border-black rounded-[32px] shadow-[8px_8px_0_#000]">
          <div className="flex flex-col md:flex-row items-center justify-center gap-3 md:gap-4">
            <span className="text-base md:text-lg text-charcoal/70">모발 나이</span>
            <span className="text-5xl md:text-6xl font-bold text-deep-blue">
              {animatedAge}
              <span className="text-2xl md:text-3xl ml-1">세</span>
            </span>
          </div>
        </div>

        {/* 5년 내 탈모 확률 */}
        <div className="probability mb-8">
          <div className="flex items-center justify-between mb-3">
            <span className="text-base md:text-lg text-charcoal/70">5년 내 탈모 확률</span>
            <span
              className={cn(
                'text-3xl md:text-4xl font-bold',
                getProbabilityColor(animatedProbability)
              )}
            >
              {animatedProbability}%
            </span>
          </div>
          <Progress value={animatedProbability} className="hand-drawn-progress h-5" />
        </div>

        {/* 탈모 유형 */}
        <div className="hair-type mb-8">
          <span className="text-base md:text-lg text-charcoal/70 block mb-2">탈모 유형</span>
          <Badge variant="type" className="text-base">
            {result.baldType}
          </Badge>
        </div>

        {/* 닮은 대머리 유명인 */}
        <div className="celebrity mb-8">
          <p
            className="text-lg md:text-xl text-charcoal/70 mb-3"
            style={{ fontFamily: 'var(--font-jua)' }}
          >
            미래의 당신은...
          </p>
          <div className="speech-bubble bg-white border-[8px] border-black rounded-[48px] p-5 shadow-[12px_12px_0_#000]">
            <p className="text-xl md:text-2xl font-bold mb-2">{result.celebrity.name}</p>
            <p className="text-base md:text-lg text-charcoal/80">{result.celebrity.comment}</p>
          </div>
        </div>

        {/* 관리 팁 */}
        <div className="tips">
          <span className="text-base md:text-lg text-charcoal/70 block mb-3">관리 팁</span>
          <ul className="space-y-3">
            {result.tips.map((tip, index) => (
              <li key={index} className="flex items-start gap-3 bg-white border-[4px] border-black rounded-[24px] p-4 shadow-[6px_6px_0_#000]">
                <Check className="w-5 h-5 text-forest-green flex-shrink-0 mt-0.5" />
                <span className="text-sm md:text-base">{tip}</span>
              </li>
            ))}
          </ul>
        </div>
      </Card>

      {/* 종합 코멘트 */}
      <div className="comment mb-8 bg-white border-[8px] border-black rounded-[32px] p-6 md:p-8 shadow-[16px_16px_0_#000]">
        <p className="text-lg md:text-xl italic text-charcoal leading-relaxed">
          &ldquo;{result.comment}&rdquo;
        </p>
      </div>

      {/* 10년 뒤 시뮬레이션 이미지 카드 (이미지 생성 활성화 시에만 표시) */}
      {result.simulationImage && (
        <Card className="simulation-card paper-texture pencil-border p-6 md:p-8 mb-8 rotate-[1deg]">
          <h3
            className="text-3xl md:text-4xl text-center mb-6"
            style={{ fontFamily: 'var(--font-jua)' }}
          >
            🔮 10년 뒤 그대의 상
          </h3>
          <div className="polaroid-frame rotate-[1.5deg] relative">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src={result.simulationImage}
              alt="10년 뒤 헤어라인 시뮬레이션"
              className="w-full rounded"
            />
            <div className="scribble-arrow absolute bottom-4 right-4" />
          </div>
        </Card>
      )}

      {/* 액션 버튼 */}
      <div className="action-buttons flex flex-col md:flex-row gap-4 justify-center mb-8">
        <Button
          variant="outline"
          onClick={onReset}
          className="bg-white text-black border-[6px] border-black rounded-[48px] px-16 py-6 text-2xl font-extrabold shadow-[8px_8px_0_#000] hover:bg-[var(--color-bg-yellow)] hover:rotate-[-2deg] hover:scale-105"
        >
          다시 관상 보기
        </Button>
        <Button
          variant="primary"
          onClick={handleShare}
          className="btn-primary"
        >
          <Share2 className="w-6 h-6 mr-3" />
          {copied ? '복사 완료!' : '관상 결과 공유하기'}
        </Button>
      </div>
    </section>
  );
}
