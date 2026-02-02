import 'dart:ui';

/// Frame0 스타일 스케치 디자인 토큰
///
/// design-tokens.json에서 추출한 손그림 와이어프레임 스타일 디자인 상수.
/// 스케치 디자인 시스템의 모든 기초 디자인 값을 포함.
///
/// **아키텍처 노트**: 이 파일은 UI 의존성이 없음 (Color 타입을 위한 dart:ui만 사용).
/// 순수 데이터/상수이므로 core 패키지에 속함.
class SketchDesignTokens {
  SketchDesignTokens._(); // private 생성자 - 상수 전용 클래스

  // ============================================================================
  // 선 두께
  // ============================================================================

  /// 얇은 선 두께 (1.0px) - 텍스트 밑줄, 세밀한 디테일, 아이콘용
  static const double strokeThin = 1.0;

  /// 표준 선 두께 (2.0px) - 도형 테두리, 구분선, 대부분의 UI 요소용
  static const double strokeStandard = 2.0;

  /// 굵은 선 두께 (3.0px) - 강조, 선택 상태, 헤더용
  static const double strokeBold = 3.0;

  /// 매우 굵은 선 두께 (4.0px) - 타이틀, 주요 시각 요소, 포커스 표시용
  static const double strokeThick = 4.0;

  // ============================================================================
  // 테두리 반경
  // ============================================================================

  /// 불규칙한 테두리 반경 (12.0px) - 스케치 스타일 둥근 모서리용
  static const double irregularBorderRadius = 12.0;

  // ============================================================================
  // 손그림 효과 파라미터
  // ============================================================================

  /// 거칠기 계수 (0.0-1.0) - 경로에 추가되는 무작위성 정도 제어
  ///
  /// - 0.0: 완벽하게 매끄러움 (스케치 효과 없음)
  /// - 0.8: 권장 기본값 (은은한 손그림 느낌)
  /// - 1.0: 더 두드러진 흔들림
  /// - 1.5+: 매우 스케치스럽고 혼란스러움
  static const double roughness = 0.8;

  /// 휘어짐 계수 - 곡선이 바깥쪽으로 휘는 정도 제어
  ///
  /// 높은 값은 직선에서 더 두드러진 곡선을 만들어,
  /// 손으로 그린 선의 자연스러운 불완전함을 시뮬레이션함.
  static const double bowing = 0.5;

  // ============================================================================
  // 스케치 컬러 (80% 투명도 변형)
  // ============================================================================

  /// 그레이 스케치 100 - 가장 밝은 회색, 80% 불투명도 (#F7F7F7CC)
  static const Color graySketch100 = Color(0xCCF7F7F7);

  /// 그레이 스케치 200 - 밝은 회색, 80% 불투명도 (#EBEBEBCC)
  static const Color graySketch200 = Color(0xCCEBEBEB);

  /// 그레이 스케치 300 - 부드러운 회색, 80% 불투명도 (#DCDCDCCC)
  static const Color graySketch300 = Color(0xCCDCDCDC);

  /// 그레이 스케치 500 - 중간 회색, 80% 불투명도 (#8E8E8ECC)
  static const Color graySketch500 = Color(0xCC8E8E8E);

  /// 그레이 스케치 700 - 어두운 회색, 80% 불투명도 (#5E5E5ECC)
  static const Color graySketch700 = Color(0xCC5E5E5E);

  /// 그레이 스케치 900 - 매우 어두운 회색, 80% 불투명도 (#343434CC)
  static const Color graySketch900 = Color(0xCC343434);

  // ============================================================================
  // 단색
  // ============================================================================

  /// 순수 흰색 (#FFFFFF)
  static const Color white = Color(0xFFFFFFFF);

  /// 베이스 100 - 거의 흰색 (#F7F7F7)
  static const Color base100 = Color(0xFFF7F7F7);

  /// 베이스 200 - 밝은 회색 (#EBEBEB)
  static const Color base200 = Color(0xFFEBEBEB);

  /// 베이스 300 - 부드러운 회색 (#DCDCDC)
  static const Color base300 = Color(0xFFDCDCDC);

  /// 베이스 400 - 중간-밝은 회색 (#B5B5B5)
  static const Color base400 = Color(0xFFB5B5B5);

  /// 베이스 500 - 중간 회색 (#8E8E8E)
  static const Color base500 = Color(0xFF8E8E8E);

  /// 베이스 600 - 중간-어두운 회색 (#767676)
  static const Color base600 = Color(0xFF767676);

  /// 베이스 700 - 어두운 회색 (#5E5E5E)
  static const Color base700 = Color(0xFF5E5E5E);

  /// 베이스 900 - 거의 검은색 (#343434)
  static const Color base900 = Color(0xFF343434);

  /// 순수 검은색 (#000000)
  static const Color black = Color(0xFF000000);

  // ============================================================================
  // 강조 색상
  // ============================================================================

  /// 강조 메인 - 코랄/오렌지 (#DF7D5F)
  static const Color accentPrimary = Color(0xFFDF7D5F);

  /// 강조 메인, 80% 불투명도 (#DF7D5FCC)
  static const Color accentPrimaryAlpha = Color(0xCCDF7D5F);

  /// 강조 밝은 - 밝은 코랄/피치 (#F19E7E)
  static const Color accentLight = Color(0xFFF19E7E);

  /// 강조 밝은, 80% 불투명도 (#F19E7ECC)
  static const Color accentLightAlpha = Color(0xCCF19E7E);

  /// 강조 어두운 - 어두운 코랄 (#C86947)
  static const Color accentDark = Color(0xFFC86947);

  // ============================================================================
  // 의미론적 색상
  // ============================================================================

  /// 성공 색상 (#4CAF50)
  static const Color success = Color(0xFF4CAF50);

  /// 경고 색상 (#FFC107)
  static const Color warning = Color(0xFFFFC107);

  /// 에러 색상 (#F44336)
  static const Color error = Color(0xFFF44336);

  /// 정보 색상 (#2196F3)
  static const Color info = Color(0xFF2196F3);

  // ============================================================================
  // 간격 (8px 그리드)
  // ============================================================================

  /// 매우 작은 간격 (4px)
  static const double spacingXs = 4.0;

  /// 작은 간격 (8px)
  static const double spacingSm = 8.0;

  /// 중간 간격 (12px)
  static const double spacingMd = 12.0;

  /// 큰 간격 (16px)
  static const double spacingLg = 16.0;

  /// 매우 큰 간격 (24px)
  static const double spacingXl = 24.0;

  /// 2배 큰 간격 (32px)
  static const double spacing2Xl = 32.0;

  /// 3배 큰 간격 (48px)
  static const double spacing3Xl = 48.0;

  /// 4배 큰 간격 (64px)
  static const double spacing4Xl = 64.0;

  // ============================================================================
  // 테두리 반경 스케일
  // ============================================================================

  /// 테두리 반경 없음 (0px)
  static const double radiusNone = 0.0;

  /// 작은 테두리 반경 (2px)
  static const double radiusSm = 2.0;

  /// 중간 테두리 반경 (4px)
  static const double radiusMd = 4.0;

  /// 큰 테두리 반경 (8px)
  static const double radiusLg = 8.0;

  /// 매우 큰 테두리 반경 (12px)
  static const double radiusXl = 12.0;

  /// 2배 큰 테두리 반경 (16px)
  static const double radius2Xl = 16.0;

  /// 알약형 테두리 반경 (9999px) - 완전히 둥근
  static const double radiusPill = 9999.0;

  // ============================================================================
  // 그림자
  // ============================================================================

  /// 중간 높이 그림자 오프셋 (0, 2)
  static const Offset shadowOffsetMd = Offset(0, 2);

  /// 중간 높이 그림자 블러 반경 (4.0)
  static const double shadowBlurMd = 4.0;

  /// 그림자 색상 (rgba(0, 0, 0, 0.15))
  static const Color shadowColor = Color(0x26000000);

  // ============================================================================
  // 노이즈 텍스처 파라미터
  // ============================================================================

  /// 노이즈 강도 (0.035) - 노이즈 점의 불투명도
  ///
  /// 권장 범위: 0.02 - 0.05
  /// - 낮을수록: 더 은은한 텍스처
  /// - 높을수록: 더 눈에 띄는 입자감
  static const double noiseIntensity = 0.035;

  /// 노이즈 입자 크기 (1.5px) - 개별 노이즈 점의 크기
  static const double noiseGrainSize = 1.5;

  // ============================================================================
  // 타이포그래피 스케일
  // ============================================================================

  /// 매우 작은 폰트 크기 (12px)
  static const double fontSizeXs = 12.0;

  /// 작은 폰트 크기 (14px)
  static const double fontSizeSm = 14.0;

  /// 기본 폰트 크기 (16px)
  static const double fontSizeBase = 16.0;

  /// 큰 폰트 크기 (18px)
  static const double fontSizeLg = 18.0;

  /// 매우 큰 폰트 크기 (20px)
  static const double fontSizeXl = 20.0;

  /// 2배 큰 폰트 크기 (24px)
  static const double fontSize2Xl = 24.0;

  /// 3배 큰 폰트 크기 (30px)
  static const double fontSize3Xl = 30.0;

  /// 4배 큰 폰트 크기 (36px)
  static const double fontSize4Xl = 36.0;

  /// 5배 큰 폰트 크기 (48px)
  static const double fontSize5Xl = 48.0;

  /// 6배 큰 폰트 크기 (60px)
  static const double fontSize6Xl = 60.0;

  // ============================================================================
  // 불투명도
  // ============================================================================

  /// 비활성화 불투명도 (0.4)
  static const double opacityDisabled = 0.4;

  /// 은은한 불투명도 (0.6)
  static const double opacitySubtle = 0.6;

  /// 스케치 오버레이 불투명도 (0.8)
  static const double opacitySketch = 0.8;

  /// 완전 불투명 (1.0)
  static const double opacityFull = 1.0;

  // ============================================================================
  // 추가 의미론적 색상 (에러 변형)
  // ============================================================================

  /// 밝은 에러 색상 - 에러 배경용
  static const Color errorLight = Color(0xFFFFEBEE);
}
