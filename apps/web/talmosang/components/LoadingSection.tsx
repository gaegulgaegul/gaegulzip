"use client";

import { useState, useEffect } from 'react';
import { Search } from 'lucide-react';
import { Progress } from '@/components/ui/progress';

const messages = [
  "두피의 기운을 살피는 중... 🔍",
  "모낭 하나하나의 관상을 보는 중... 🧬",
  "그대의 모발 운명을 점지하는 중... 🔮",
  "10년 뒤의 상을 그리는 중... 🎨",
];

/**
 * 로딩 섹션 컴포넌트
 *
 * 두피 분석 중에 표시되는 로딩 화면입니다.
 * 머리카락 떨어지는 애니메이션, 사극 말투 메시지 전환, 프로그레스 바를 포함합니다.
 */
export default function LoadingSection() {
  const [messageIndex, setMessageIndex] = useState(0);
  const [progress, setProgress] = useState(0);

  useEffect(() => {
    // 메시지 전환 (2초마다)
    const messageTimer = setInterval(() => {
      setMessageIndex((prev) => (prev + 1) % messages.length);
    }, 2000);

    return () => clearInterval(messageTimer);
  }, []);

  useEffect(() => {
    // 프로그레스 바 증가 (30초 동안 90%까지)
    // 100ms마다 0.3% 증가 (100ms * 300회 = 30초)
    const progressTimer = setInterval(() => {
      setProgress((prev) => {
        if (prev >= 90) return 90;
        return prev + 0.3;
      });
    }, 100);

    return () => clearInterval(progressTimer);
  }, []);

  return (
    <section className="loading-section text-center py-12">
      {/* 로딩 애니메이션 */}
      <div className="loading-animation relative mb-8">
        {/* 머리카락 떨어지는 애니메이션 */}
        <div className="hair-falling-container mx-auto mb-6">
          <div className="hair-strand"></div>
          <div className="hair-strand"></div>
          <div className="hair-strand"></div>
          <div className="hair-strand"></div>
          <div className="hair-strand"></div>
        </div>

        {/* 중앙 돋보기 아이콘 */}
        <div className="flex justify-center">
          <Search className="w-20 h-20 text-mustard animate-spin-slow" />
        </div>
      </div>

      {/* 로딩 메시지 (페이드 애니메이션) */}
      <p className="font-nanum-pen text-xl md:text-2xl text-charcoal mb-8 animate-fade-in" key={messageIndex}>
        {messages[messageIndex]}
      </p>

      {/* 프로그레스 바 */}
      <div className="max-w-md mx-auto">
        <div className="hand-drawn-progress mb-4">
          <Progress value={progress} className="h-4" />
        </div>
        <p className="font-nanum-pen text-lg text-charcoal">
          {Math.round(progress)}%
        </p>
      </div>
    </section>
  );
}
