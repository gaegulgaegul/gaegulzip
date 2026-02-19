'use client';

import { useRef, useEffect } from 'react';
import { cn } from '@/lib/utils';

type Grade = 'A' | 'B' | 'C' | 'D';

interface ParticlesProps {
  grade: Grade;
  active: boolean;
  className?: string;
}

interface Particle {
  x: number;
  y: number;
  vx: number;
  vy: number;
  size: number;
  color: string;
  rotation: number;
  rotationSpeed: number;
  opacity: number;
  shape: 'star' | 'circle' | 'hair' | 'leaf';
}

const GRADE_CONFIG: Record<Grade, { colors: string[]; count: number; shape: Particle['shape'] }> = {
  A: { colors: ['#FFD700', '#FFA500', '#ffe847'], count: 30, shape: 'star' },
  B: { colors: ['#C0C0C0', '#E8E8E8', '#A0A0A0'], count: 15, shape: 'circle' },
  C: { colors: ['#ffe847', '#ffcc00', '#FFDEAD'], count: 10, shape: 'leaf' },
  D: { colors: ['#1a1a1a', '#333333', '#4a4a4a'], count: 20, shape: 'hair' },
};

export default function Particles({ grade, active, className }: ParticlesProps) {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const particlesRef = useRef<Particle[]>([]);
  const animFrameRef = useRef<number>(0);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas || !active) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    const rect = canvas.getBoundingClientRect();
    canvas.width = rect.width * window.devicePixelRatio;
    canvas.height = rect.height * window.devicePixelRatio;
    ctx.scale(window.devicePixelRatio, window.devicePixelRatio);

    const config = GRADE_CONFIG[grade] ?? GRADE_CONFIG.A;

    // 파티클 초기화
    particlesRef.current = Array.from({ length: config.count }, () => ({
      x: rect.width / 2 + (Math.random() - 0.5) * 100,
      y: rect.height / 2,
      vx: (Math.random() - 0.5) * 8,
      vy: -Math.random() * 10 - 2,
      size: Math.random() * 8 + 4,
      color: config.colors[Math.floor(Math.random() * config.colors.length)],
      rotation: Math.random() * Math.PI * 2,
      rotationSpeed: (Math.random() - 0.5) * 0.2,
      opacity: 1,
      shape: config.shape,
    }));

    const drawParticle = (p: Particle) => {
      ctx.save();
      ctx.translate(p.x, p.y);
      ctx.rotate(p.rotation);
      ctx.globalAlpha = p.opacity;
      ctx.fillStyle = p.color;

      if (p.shape === 'star') {
        const spikes = 5;
        const outerRadius = p.size;
        const innerRadius = p.size / 2;
        ctx.beginPath();
        for (let i = 0; i < spikes * 2; i++) {
          const radius = i % 2 === 0 ? outerRadius : innerRadius;
          const angle = (Math.PI * i) / spikes - Math.PI / 2;
          ctx.lineTo(Math.cos(angle) * radius, Math.sin(angle) * radius);
        }
        ctx.closePath();
        ctx.fill();
      } else if (p.shape === 'circle') {
        ctx.beginPath();
        ctx.arc(0, 0, p.size / 2, 0, Math.PI * 2);
        ctx.fill();
      } else if (p.shape === 'hair') {
        ctx.strokeStyle = p.color;
        ctx.lineWidth = 2;
        ctx.beginPath();
        ctx.moveTo(0, -p.size);
        ctx.quadraticCurveTo(p.size / 2, 0, 0, p.size);
        ctx.stroke();
      } else if (p.shape === 'leaf') {
        ctx.beginPath();
        ctx.ellipse(0, 0, p.size / 2, p.size, 0, 0, Math.PI * 2);
        ctx.fill();
      }

      ctx.restore();
    };

    const animate = () => {
      ctx.clearRect(0, 0, rect.width, rect.height);

      let alive = false;
      for (const p of particlesRef.current) {
        p.x += p.vx;
        p.y += p.vy;
        p.vy += 0.15; // 중력
        p.rotation += p.rotationSpeed;
        p.opacity -= 0.008;

        if (p.opacity > 0) {
          alive = true;
          drawParticle(p);
        }
      }

      if (alive) {
        animFrameRef.current = requestAnimationFrame(animate);
      }
    };

    animFrameRef.current = requestAnimationFrame(animate);

    return () => {
      cancelAnimationFrame(animFrameRef.current);
    };
  }, [grade, active]);

  if (!active) return null;

  return (
    <canvas
      ref={canvasRef}
      className={cn('absolute inset-0 pointer-events-none z-50', className)}
      aria-hidden="true"
      style={{ width: '100%', height: '100%' }}
    />
  );
}
