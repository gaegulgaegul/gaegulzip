'use client';

import { useRef, useState, useEffect } from 'react';
import gsap from 'gsap';
import { useGSAP } from '@gsap/react';
import { cn } from '@/lib/utils';
import Particles from './Particles';

gsap.registerPlugin(useGSAP);

type Grade = 'A' | 'B' | 'C' | 'D';

interface ResultRevealProps {
  grade: Grade;
  gradeEmoji: string;
  gradeVerdict: string;
  onRevealComplete: () => void;
  children: React.ReactNode;
}

export default function ResultReveal({
  grade,
  gradeEmoji,
  gradeVerdict,
  onRevealComplete,
  children,
}: ResultRevealProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const overlayRef = useRef<HTMLDivElement>(null);
  const scrollRef = useRef<HTMLDivElement>(null);
  const titleRef = useRef<HTMLHeadingElement>(null);
  const badgeRef = useRef<HTMLDivElement>(null);
  const contentRef = useRef<HTMLDivElement>(null);
  const [showParticles, setShowParticles] = useState(false);
  const [revealed, setRevealed] = useState(false);

  // stale closure 방지: 최신 콜백을 ref에 보관
  const onRevealCompleteRef = useRef(onRevealComplete);
  useEffect(() => {
    onRevealCompleteRef.current = onRevealComplete;
  }, [onRevealComplete]);

  // 접근성: prefers-reduced-motion 확인
  const [prefersReduced, setPrefersReduced] = useState(() => {
    if (typeof window === 'undefined') return false;
    return window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  });
  useEffect(() => {
    const mq = window.matchMedia('(prefers-reduced-motion: reduce)');
    setPrefersReduced(mq.matches);
    const handler = (e: MediaQueryListEvent) => setPrefersReduced(e.matches);
    mq.addEventListener('change', handler);
    return () => mq.removeEventListener('change', handler);
  }, []);

  useGSAP(() => {
    if (revealed) return;

    // reduced motion이면 즉시 표시
    if (prefersReduced) {
      setRevealed(true);
      onRevealCompleteRef.current();
      return;
    }

    const tl = gsap.timeline({
      onComplete: () => {
        setRevealed(true);
        onRevealCompleteRef.current();
      },
    });

    // Phase 1: 오버레이
    tl.fromTo(overlayRef.current, { opacity: 0 }, { opacity: 0.85, duration: 0.3 });

    // Phase 2: 두루마리 펼침
    tl.fromTo(scrollRef.current,
      { scaleY: 0, opacity: 0 },
      { scaleY: 1, opacity: 1, duration: 0.5, ease: 'back.out(1.7)' }
    );

    // Phase 3: 제목 스탬프
    tl.from(titleRef.current, {
      scale: 3, rotation: -15, opacity: 0, duration: 0.4, ease: 'back.out(2)',
    });

    // Phase 4: 등급 뱃지
    tl.from(badgeRef.current, {
      scale: 0, rotation: -10, duration: 0.5, ease: 'elastic.out(1, 0.3)',
    });

    // Phase 5: 파티클 발사
    tl.call(() => setShowParticles(true));

    // Phase 6: 오버레이 해제 + 콘텐츠 등장
    tl.to(overlayRef.current, { opacity: 0, duration: 0.4 });
    tl.fromTo(contentRef.current,
      { opacity: 0, y: 30 },
      { opacity: 1, y: 0, duration: 0.5 },
      '-=0.2'
    );
  }, { scope: containerRef, dependencies: [prefersReduced, revealed] });

  // 등급별 색상
  const gradeColor = {
    A: 'var(--color-accent-green)',
    B: 'var(--color-bg-yellow)',
    C: 'var(--color-accent-orange)',
    D: 'var(--color-accent-red)',
  }[grade];

  if (prefersReduced || revealed) {
    return <div className="relative">{children}</div>;
  }

  return (
    <div ref={containerRef} className="relative">
      {/* 오버레이 */}
      <div
        ref={overlayRef}
        className="fixed inset-0 bg-black z-40 pointer-events-none"
        style={{ opacity: 0 }}
      />

      {/* 리빌 UI (오버레이 위) */}
      <div className="fixed inset-0 z-50 flex flex-col items-center justify-center pointer-events-none">
        {/* 두루마리 */}
        <div
          ref={scrollRef}
          className="bg-white border-[8px] border-black rounded-[32px] p-8 md:p-12 shadow-[12px_12px_0_#000] max-w-lg w-[90%] origin-top"
          style={{ transform: 'scaleY(0)' }}
        >
          {/* 제목 */}
          <h2
            ref={titleRef}
            className="text-3xl md:text-5xl text-black text-center mb-6"
            style={{ fontFamily: 'var(--font-jua)' }}
          >
            관상 결과가 나왔사옵니다!
          </h2>

          {/* 등급 뱃지 */}
          <div
            ref={badgeRef}
            className="w-[200px] h-[200px] mx-auto border-[8px] border-black rounded-full shadow-[8px_8px_0_#000] rotate-[-8deg] flex flex-col items-center justify-center"
            style={{ backgroundColor: gradeColor }}
          >
            <span className="text-6xl font-extrabold text-white">{grade}</span>
            <span className="text-4xl mt-2">{gradeEmoji}</span>
          </div>

          <p className="text-xl md:text-2xl font-bold text-center mt-4">{gradeVerdict}</p>

        </div>

        {/* 파티클 */}
        <Particles grade={grade} active={showParticles} />
      </div>

      {/* 실제 콘텐츠 (리빌 후 표시) */}
      <div ref={contentRef} style={{ opacity: 0 }}>
        {children}
      </div>
    </div>
  );
}
