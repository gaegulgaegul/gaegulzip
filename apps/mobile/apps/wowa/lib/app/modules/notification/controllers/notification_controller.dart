import 'package:push/push.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

/// 알림 목록 컨트롤러
///
/// 알림 조회, 읽음 처리, 무한 스크롤, 딥링크를 관리합니다.
class NotificationController extends GetxController {
  final PushApiClient _apiClient = Get.find<PushApiClient>();

  /// 알림 목록
  final notifications = <NotificationModel>[].obs;

  /// 읽지 않은 알림 개수
  final unreadCount = 0.obs;

  /// 로딩 상태
  final isLoading = false.obs;

  /// 에러 메시지
  final errorMessage = ''.obs;

  /// 추가 로딩 상태 (무한 스크롤)
  final isLoadingMore = false.obs;

  /// 더 불러올 데이터 존재 여부
  final hasMore = true.obs;

  /// 읽음 처리 진행 중인 알림 ID (더블탭 방어)
  final _pendingReads = <int>{};

  /// 페이지 당 로딩 개수
  static const _pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    fetchUnreadCount();
  }

  /// 알림 목록 조회
  ///
  /// [refresh] true이면 목록을 초기화하고 처음부터 조회
  Future<void> fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      notifications.clear();
      hasMore.value = true;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _apiClient.getMyNotifications(
        limit: _pageSize,
        offset: 0,
      );
      notifications.assignAll(response.notifications);
      hasMore.value = notifications.length < response.total;
    } on DioException catch (e) {
      errorMessage.value = e.message ?? '네트워크 오류가 발생했습니다';
    } catch (e) {
      errorMessage.value = '알림을 불러올 수 없습니다';
    } finally {
      isLoading.value = false;
    }
  }

  /// 무한 스크롤 - 다음 페이지 로드
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;

    isLoadingMore.value = true;

    try {
      final response = await _apiClient.getMyNotifications(
        limit: _pageSize,
        offset: notifications.length,
      );
      notifications.addAll(response.notifications);
      hasMore.value = notifications.length < response.total;
    } on DioException catch (e) {
      Logger.warn('추가 알림 로딩 실패: ${e.message}');
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// 읽지 않은 알림 개수 조회
  Future<void> fetchUnreadCount() async {
    try {
      final response = await _apiClient.getUnreadCount();
      unreadCount.value = response.unreadCount;
    } on DioException catch (e) {
      Logger.warn('읽지 않은 알림 개수 조회 실패: ${e.message}');
    }
  }

  /// 알림 탭 처리 (읽음 처리 + 딥링크)
  ///
  /// 낙관적 업데이트로 UI를 즉시 반영하고, API 호출이 실패하면 롤백합니다.
  /// 알림의 data 필드에서 딥링크 정보를 파싱하여 해당 화면으로 이동합니다.
  ///
  /// [notification] 탭한 알림 모델
  Future<void> handleNotificationTap(NotificationModel notification) async {
    // 이미 읽은 알림 또는 읽음 처리 진행 중이면 딥링크만 처리
    if (notification.isRead || _pendingReads.contains(notification.id)) {
      _handleDeepLink(notification.data);
      return;
    }

    _pendingReads.add(notification.id);

    // 낙관적 업데이트: 원본 보존 후 UI 즉시 변경
    final index = notifications.indexWhere((n) => n.id == notification.id);
    if (index != -1) {
      notifications[index] = notification.copyWith(
        isRead: true,
        readAt: DateTime.now().toIso8601String(),
      );
      unreadCount.value = (unreadCount.value - 1).clamp(0, 9999);
    }

    // API 호출, 실패 시 롤백
    try {
      await _apiClient.markAsRead(notification.id);
    } on DioException {
      if (index != -1) {
        notifications[index] = notification;
        unreadCount.value++;
      }
    } finally {
      _pendingReads.remove(notification.id);
    }

    // 딥링크 처리
    _handleDeepLink(notification.data);
  }

  /// 딥링크 데이터에서 화면 이동
  ///
  /// [data] 알림의 data 필드에서 'screen' 키로 이동할 화면을 결정합니다.
  /// 허용된 화면 목록에 포함된 경우에만 이동합니다.
  void _handleDeepLink(Map<String, dynamic> data) {
    final screen = data['screen'] as String?;
    if (screen != null && Routes.deepLinkAllowedScreens.contains(screen)) {
      Get.toNamed('/$screen', arguments: data);
    }
  }

  /// Pull-to-refresh
  Future<void> refreshNotifications() async {
    await Future.wait([
      fetchNotifications(refresh: true),
      fetchUnreadCount(),
    ]);
  }

  /// 재시도
  Future<void> retryLoadNotifications() async {
    await fetchNotifications();
  }
}
