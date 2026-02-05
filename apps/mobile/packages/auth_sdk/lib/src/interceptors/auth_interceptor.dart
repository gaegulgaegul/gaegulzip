import 'dart:async';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../services/auth_state_service.dart';

/// 인증 인터셉터
///
/// 모든 API 요청에 Authorization 헤더를 자동 추가하고,
/// 401 응답 시 토큰 갱신을 시도합니다.
///
/// 동시 401 처리: 큐 방식으로 갱신 1회만 실행하고 나머지 요청은 대기합니다.
///
/// 사용법:
/// ```dart
/// final dio = Get.find<Dio>();
/// dio.interceptors.add(AuthInterceptor());
/// ```
class AuthInterceptor extends Interceptor {
  SecureStorageService get _storageService => Get.find<SecureStorageService>();
  AuthStateService get _authStateService => Get.find<AuthStateService>();

  /// 토큰 갱신 진행 중 플래그
  bool _isRefreshing = false;

  /// 갱신 대기 중인 요청들의 Completer 큐
  final List<Completer<bool>> _refreshQueue = [];

  /// 인증 불필요한 경로 목록
  static const _publicPaths = [
    '/auth/oauth',
    '/auth/refresh',
  ];

  /// 요청 전: Authorization 헤더 자동 추가
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 인증 불필요한 경로는 건너뜀
    if (_isPublicPath(options.path)) {
      return handler.next(options);
    }

    try {
      final accessToken = await _storageService.getAccessToken();
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    } catch (e) {
      // 토큰 조회 실패 시에도 요청은 계속 진행
      // (서버가 401로 응답하면 onError에서 처리)
    }

    handler.next(options);
  }

  /// 에러 응답: 401이면 토큰 갱신 후 재시도
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // 인증 불필요한 경로의 401은 갱신 시도하지 않음
    if (_isPublicPath(err.requestOptions.path)) {
      return handler.next(err);
    }

    // 갱신 시도
    final refreshed = await _tryRefresh();

    if (!refreshed) {
      return handler.next(err);
    }

    // 갱신 성공 — 새 토큰으로 원래 요청 재시도
    try {
      final accessToken = await _storageService.getAccessToken();
      if (accessToken == null) {
        return handler.next(err);
      }
      err.requestOptions.headers['Authorization'] = 'Bearer $accessToken';
      final response = await Get.find<Dio>().fetch(err.requestOptions);
      handler.resolve(response);
    } catch (retryErr) {
      handler.next(retryErr is DioException ? retryErr : err);
    }
  }

  /// 토큰 갱신 시도 (큐 방식)
  ///
  /// 이미 갱신 중이면 대기 큐에 추가되어 결과를 기다립니다.
  /// 갱신 중이 아니면 직접 갱신을 수행합니다.
  Future<bool> _tryRefresh() async {
    if (_isRefreshing) {
      // 이미 갱신 중 — 큐에 추가하고 결과 대기
      final completer = Completer<bool>();
      _refreshQueue.add(completer);
      return completer.future;
    }

    _isRefreshing = true;

    try {
      final success = await _authStateService.refreshToken();
      // 대기 중인 모든 요청에 결과 전달
      _resolveQueue(success);
      return success;
    } catch (_) {
      _resolveQueue(false);
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// 대기 큐의 모든 Completer에 결과 전달
  void _resolveQueue(bool result) {
    for (final completer in _refreshQueue) {
      completer.complete(result);
    }
    _refreshQueue.clear();
  }

  /// 인증 불필요한 경로인지 확인
  bool _isPublicPath(String path) {
    return _publicPaths.any((p) => path == p || path.startsWith('$p/') || path.startsWith('$p?'));
  }
}
