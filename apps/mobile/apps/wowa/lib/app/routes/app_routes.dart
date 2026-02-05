/// 앱 라우트 상수
///
/// 모든 네임드 라우트를 상수로 정의합니다.
abstract class Routes {
  /// 로그인 화면
  static const LOGIN = '/login';

  /// 홈 화면 (WOD 홈)
  static const HOME = '/home';

  /// 설정 화면
  static const SETTINGS = '/settings';

  /// 박스 검색 화면
  static const BOX_SEARCH = '/box/search';

  /// 박스 생성 화면
  static const BOX_CREATE = '/box/create';

  /// WOD 등록 화면
  static const WOD_REGISTER = '/wod/register';

  /// WOD 상세/비교 화면
  static const WOD_DETAIL = '/wod/detail';

  /// WOD 선택 화면
  static const WOD_SELECT = '/wod/select';

  /// 제안 검토 화면
  static const PROPOSAL_REVIEW = '/wod/proposal/review';
}
