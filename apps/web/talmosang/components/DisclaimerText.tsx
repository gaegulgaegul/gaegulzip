import { ShieldCheck } from 'lucide-react';

/**
 * 면책 고지 컴포넌트
 *
 * 정적 면책 문구를 표시합니다 (Server Component).
 * 본 서비스는 재미 목적이며 의료 진단이 아님을 명시합니다.
 */
export default function DisclaimerText() {
  return (
    <div className="reassurance-text">
      <ShieldCheck className="w-5 h-5 text-forest-green flex-shrink-0" />
      <p className="text-sm text-charcoal/70">
        본 관상은 재미 목적이며 의원의 진단을 대신하지 않사옵니다. 업로드한
        사진은 분석 후 즉시 삭제되옵니다.
      </p>
    </div>
  );
}
