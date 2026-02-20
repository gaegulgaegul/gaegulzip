'use client';

import { useEffect } from 'react';

// AdSense 타입 선언
declare global {
  interface Window {
    adsbygoogle: unknown[];
  }
}

interface AdBannerProps {
  /** 광고 슬롯 ID (옵셔널) */
  slot?: string;
  /** 광고 포맷 */
  format?: 'auto' | 'rectangle' | 'horizontal';
  /** 반응형 광고 여부 */
  responsive?: boolean;
  /** 추가 클래스 */
  className?: string;
}

/**
 * Google AdSense 광고 배너 컴포넌트
 *
 * AdSense 스크립트를 로드하고 광고를 표시합니다.
 * 광고 로드 실패 시 빈 공간 없이 collapse됩니다.
 */
export default function AdBanner({
  slot,
  format = 'auto',
  responsive = true,
  className = '',
}: AdBannerProps) {
  useEffect(() => {
    // AdSense 광고 로드
    try {
      if (typeof window !== 'undefined') {
        (window.adsbygoogle = window.adsbygoogle || []).push({});
      }
    } catch (err) {
      console.error('AdSense 로드 실패:', err);
    }
  }, []);

  // AdSense ID가 없으면 렌더링하지 않음
  const adsenseId = process.env.NEXT_PUBLIC_ADSENSE_ID;
  if (!adsenseId) {
    return null;
  }

  return (
    <div className={`ad-container ${className}`}>
      <p className="ad-label">광고</p>
      <ins
        className="adsbygoogle"
        style={{ display: 'block' }}
        data-ad-client={adsenseId}
        data-ad-slot={slot}
        data-ad-format={format}
        data-full-width-responsive={responsive.toString()}
      />
    </div>
  );
}
