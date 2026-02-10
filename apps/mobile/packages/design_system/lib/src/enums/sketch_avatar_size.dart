/// 아바타 크기 프리셋
enum SketchAvatarSize {
  /// 24x24 - 인라인 아이콘 크기
  xs(24),

  /// 32x32 - 소형 목록
  sm(32),

  /// 40x40 - 기본 크기
  md(40),

  /// 56x56 - 프로필 헤더
  lg(56),

  /// 80x80 - 대형 프로필
  xl(80),

  /// 120x120 - 초대형 프로필
  xxl(120);

  const SketchAvatarSize(this.size);

  /// 크기 (픽셀)
  final double size;
}
