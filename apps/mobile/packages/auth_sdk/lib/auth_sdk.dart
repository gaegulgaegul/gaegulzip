/// Auth SDK - 재사용 가능한 소셜 로그인 패키지
///
/// 카카오, 네이버, 구글, 애플 소셜 로그인을 지원하며,
/// 인증 상태 관리, 토큰 자동 갱신, API 통신을 제공합니다.
library auth_sdk;

// 프로바이더
export 'src/providers/social_login_provider.dart';
export 'src/providers/kakao_login_provider.dart';
export 'src/providers/naver_login_provider.dart';
export 'src/providers/google_login_provider.dart';
export 'src/providers/apple_login_provider.dart';

// 서비스
export 'src/services/auth_state_service.dart';
export 'src/services/auth_api_service.dart';

// 인터셉터
export 'src/interceptors/auth_interceptor.dart';

// 리포지토리
export 'src/repositories/auth_repository.dart';

// 모델
export 'src/models/login_request.dart';
export 'src/models/login_response.dart';
export 'src/models/refresh_request.dart';
export 'src/models/refresh_response.dart';
export 'src/models/user_model.dart';

// 위젯 (design_system에서 재export)
export 'package:design_system/design_system.dart'
    show SocialLoginButton, SocialLoginPlatform, AppleSignInStyle;

// SDK 메인 클래스
export 'src/auth_sdk.dart';
