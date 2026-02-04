import 'package:get/get.dart';
import 'package:core/core.dart';
import '../data/repositories/auth_repository.dart';

/// 인증 상태 열거형
enum AuthStatus {
  /// 인증 상태 확인 중 (앱 시작 시)
  unknown,

  /// 인증됨 (유효한 토큰 보유)
  authenticated,

  /// 미인증 (로그인 필요)
  unauthenticated,
}

/// 앱 전역 인증 상태 관리 서비스
///
/// GetxService로 앱 수명 주기 동안 유지됩니다.
/// 인증 상태 변화를 반응형으로 관리하고, 다른 컨트롤러에서 참조합니다.
///
/// 사용법:
/// ```dart
/// // main.dart에서 초기화
/// await Get.putAsync(() => AuthStateService().init());
///
/// // 다른 곳에서 참조
/// final authService = Get.find<AuthStateService>();
/// if (authService.isAuthenticated) { ... }
/// ```
class AuthStateService extends GetxService {
  late final SecureStorageService _storageService;
  late final AuthRepository _authRepository;

  /// 현재 인증 상태 (반응형)
  final status = AuthStatus.unknown.obs;

  /// 인증 여부 편의 getter
  bool get isAuthenticated => status.value == AuthStatus.authenticated;

  /// 미인증 여부 편의 getter
  bool get isUnauthenticated => status.value == AuthStatus.unauthenticated;

  /// 서비스 초기화
  ///
  /// main.dart에서 Get.putAsync로 호출합니다.
  Future<AuthStateService> init() async {
    _storageService = Get.find<SecureStorageService>();
    _authRepository = Get.find<AuthRepository>();
    await _initializeAuthState();
    return this;
  }

  /// 앱 시작 시 인증 상태 결정 (B 방식: 보수적 — 만료 시 갱신 시도)
  ///
  /// 흐름:
  ///   토큰 없음 → unauthenticated
  ///   토큰 있고 유효 → authenticated
  ///   토큰 있고 만료 → refreshToken 시도
  ///     ├─ 갱신 성공 → authenticated
  ///     └─ 갱신 실패 → unauthenticated
  Future<void> _initializeAuthState() async {
    final accessToken = await _storageService.getAccessToken();
    if (accessToken == null) {
      status.value = AuthStatus.unauthenticated;
      return;
    }

    final expired = await _storageService.isTokenExpired();
    if (!expired) {
      status.value = AuthStatus.authenticated;
      return;
    }

    // 토큰 만료 — 갱신 시도
    final refreshed = await refreshToken();
    if (!refreshed) {
      status.value = AuthStatus.unauthenticated;
    }
  }

  /// 로그인 성공 시 호출
  ///
  /// LoginController에서 로그인 성공 후 이 메서드를 호출하여
  /// 전역 상태를 업데이트합니다.
  void onLoginSuccess() {
    status.value = AuthStatus.authenticated;
  }

  /// 로그아웃 처리
  ///
  /// 서버 토큰 무효화 + 로컬 데이터 삭제 + 상태 업데이트
  Future<void> logout({bool revokeAll = false}) async {
    await _authRepository.logout(revokeAll: revokeAll);
    status.value = AuthStatus.unauthenticated;
  }

  /// 토큰 갱신
  ///
  /// AuthInterceptor에서 401 응답 시 호출합니다.
  /// 갱신 실패 시 unauthenticated 상태로 전환합니다.
  Future<bool> refreshToken() async {
    try {
      await _authRepository.refreshAccessToken();
      return true;
    } on AuthException {
      status.value = AuthStatus.unauthenticated;
      return false;
    }
  }
}
