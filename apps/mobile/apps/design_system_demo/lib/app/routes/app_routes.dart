/// 앱 라우트 이름 정의
///
/// 모든 네비게이션에서 사용할 라우트 상수들
abstract class Routes {
  /// 홈 화면
  static const HOME = '/';

  /// 위젯 카탈로그 목록
  static const WIDGET_CATALOG = '/widgets';

  /// 위젯 데모 상세 (arguments: widget name)
  static const WIDGET_DEMO = '/widgets/demo';

  /// 페인터 카탈로그 목록
  static const PAINTER_CATALOG = '/painters';

  /// 페인터 데모 상세 (arguments: painter name)
  static const PAINTER_DEMO = '/painters/demo';

  /// 테마 쇼케이스
  static const THEME_SHOWCASE = '/theme';

  /// 컬러 팔레트
  static const COLOR_PALETTES = '/colors';

  /// 디자인 토큰
  static const TOKENS = '/tokens';
}
