/// Auth SDK - 재사용 가능한 소셜 로그인 패키지
///
/// 카카오, 네이버, 구글, 애플 소셜 로그인을 지원하며,
/// 인증 상태 관리, 토큰 자동 갱신, API 통신을 제공합니다.
library auth_sdk;

// Providers
export 'src/providers/social_login_provider.dart';
export 'src/providers/kakao_login_provider.dart';
export 'src/providers/naver_login_provider.dart';
export 'src/providers/google_login_provider.dart';
export 'src/providers/apple_login_provider.dart';

// Services
export 'src/services/auth_state_service.dart';
export 'src/services/auth_api_service.dart';

// Interceptors
export 'src/interceptors/auth_interceptor.dart';

// Repositories
export 'src/repositories/auth_repository.dart';

// Models
export 'src/models/login_request.dart';
export 'src/models/login_response.dart';
export 'src/models/refresh_request.dart';
export 'src/models/refresh_response.dart';
export 'src/models/user_model.dart';

// Widgets (re-exported from design_system)
export 'package:design_system/src/widgets/social_login_button.dart';
export 'package:design_system/src/enums/social_login_platform.dart';
export 'package:design_system/src/enums/apple_sign_in_style.dart';

// Main SDK class
export 'src/auth_sdk.dart';
