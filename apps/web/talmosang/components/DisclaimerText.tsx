/**
 * 면책 고지 컴포넌트
 *
 * 안심 문구 + 면책 문구를 통합하여 작은 크기로 표시합니다.
 */
export default function DisclaimerText() {
  return (
    <p className="text-[10px] md:text-xs text-charcoal/60 text-center leading-relaxed">
      그대의 초상화는 관상을 본 즉시 소각되오니 안심하시옵소서 · 본 관상은 재미 목적이며 의원의 진단을 대신하지 않사옵니다
    </p>
  );
}
