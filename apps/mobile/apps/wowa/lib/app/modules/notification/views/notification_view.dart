import 'package:push/push.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notification_controller.dart';

/// 알림 목록 화면
///
/// 수신한 푸시 알림 목록을 표시합니다.
/// 상태별 렌더링(로딩/에러/빈/성공), 무한 스크롤, Pull-to-refresh를 지원합니다.
class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SketchDesignTokens.white,
      appBar: SketchAppBar(
        backgroundColor: SketchDesignTokens.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
        title: '알림',
      ),
      body: RefreshIndicator(
        color: SketchDesignTokens.accentPrimary,
        onRefresh: controller.refreshNotifications,
        displacement: 40,
        child: Obx(() {
          if (controller.isLoading.value && controller.notifications.isEmpty) {
            return _buildLoading();
          }
          if (controller.errorMessage.isNotEmpty &&
              controller.notifications.isEmpty) {
            return _buildError();
          }
          if (controller.notifications.isEmpty) {
            return _buildEmpty();
          }
          return _buildList();
        }),
      ),
    );
  }

  /// 로딩 상태
  Widget _buildLoading() {
    return const Center(
      child: SketchProgressBar(
        style: SketchProgressBarStyle.circular,
        value: null,
        size: 48,
      ),
    );
  }

  /// 에러 상태
  Widget _buildError() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: SketchDesignTokens.base500,
            ),
            const SizedBox(height: SketchDesignTokens.spacingLg),
            const Text(
              '알림을 불러올 수 없습니다',
              style: TextStyle(
                fontSize: SketchDesignTokens.fontSizeLg,
                fontWeight: FontWeight.w500,
                color: SketchDesignTokens.base900,
              ),
            ),
            const SizedBox(height: SketchDesignTokens.spacingSm),
            Obx(() => Text(
                  controller.errorMessage.value,
                  style: const TextStyle(
                    fontSize: SketchDesignTokens.fontSizeSm,
                    color: SketchDesignTokens.base500,
                  ),
                  textAlign: TextAlign.center,
                )),
            const SizedBox(height: SketchDesignTokens.spacingXl),
            SketchButton(
              text: '다시 시도',
              style: SketchButtonStyle.primary,
              onPressed: controller.retryLoadNotifications,
            ),
          ],
        ),
      ),
    );
  }

  /// 빈 목록 상태
  Widget _buildEmpty() {
    return const Center(
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: SketchDesignTokens.base300,
            ),
            SizedBox(height: SketchDesignTokens.spacingLg),
            Text(
              '알림이 없습니다',
              style: TextStyle(
                fontSize: SketchDesignTokens.fontSizeXl,
                fontWeight: FontWeight.w500,
                color: SketchDesignTokens.base700,
              ),
            ),
            SizedBox(height: SketchDesignTokens.spacingSm),
            Text(
              '새로운 알림이 도착하면 여기에 표시됩니다',
              style: TextStyle(
                fontSize: SketchDesignTokens.fontSizeSm,
                color: SketchDesignTokens.base500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 알림 목록
  Widget _buildList() {
    return Obx(() {
      final items = controller.notifications;
      // 페이징 로더를 위해 +1
      final itemCount =
          items.length + (controller.hasMore.value ? 1 : 0);

      return ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: SketchDesignTokens.spacingLg,
          vertical: SketchDesignTokens.spacingSm,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          // 무한 스크롤 트리거 (끝에서 3개 전, 로딩 중이 아닐 때만)
          if (index >= items.length - 3 &&
              controller.hasMore.value &&
              !controller.isLoadingMore.value) {
            controller.loadMore();
          }

          // 마지막 아이템 = 페이징 로더
          if (index >= items.length) {
            return _buildPagingLoader();
          }

          return _NotificationCard(
            notification: items[index],
            onTap: () => controller.handleNotificationTap(items[index]),
          );
        },
      );
    });
  }

  /// 페이징 로더
  Widget _buildPagingLoader() {
    return Obx(() {
      if (!controller.isLoadingMore.value) {
        return const SizedBox.shrink();
      }
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: SketchDesignTokens.spacingLg),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: SketchDesignTokens.accentPrimary,
            ),
          ),
        ),
      );
    });
  }
}

/// 개별 알림 카드
class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return Padding(
      padding: const EdgeInsets.only(bottom: SketchDesignTokens.spacingMd),
      child: SketchCard(
        onTap: onTap,
        elevation: 1,
        borderColor: isUnread
            ? SketchDesignTokens.accentPrimary
            : SketchDesignTokens.base300,
        strokeWidth: isUnread
            ? SketchDesignTokens.strokeBold
            : SketchDesignTokens.strokeStandard,
        padding: const EdgeInsets.all(SketchDesignTokens.spacingMd),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 + NEW 배지
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: SketchDesignTokens.fontSizeBase,
                            fontWeight:
                                isUnread ? FontWeight.bold : FontWeight.normal,
                            color: isUnread
                                ? SketchDesignTokens.base900
                                : SketchDesignTokens.base700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUnread) ...[
                        const SizedBox(width: SketchDesignTokens.spacingSm),
                        const SketchChip(
                          label: 'NEW',
                          selected: true,
                          fillColor: SketchDesignTokens.accentPrimary,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: SketchDesignTokens.spacingSm),
                  // 본문
                  Text(
                    notification.body,
                    style: const TextStyle(
                      fontSize: SketchDesignTokens.fontSizeSm,
                      color: SketchDesignTokens.base700,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: SketchDesignTokens.spacingSm),
                  // 시간
                  Text(
                    _formatRelativeTime(notification.receivedAt),
                    style: const TextStyle(
                      fontSize: SketchDesignTokens.fontSizeXs,
                      color: SketchDesignTokens.base500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: SketchDesignTokens.spacingSm),
            const Icon(
              Icons.chevron_right,
              color: SketchDesignTokens.base400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// 상대 시간 표시
  String _formatRelativeTime(String isoString) {
    final dateTime = DateTime.tryParse(isoString)?.toLocal();
    if (dateTime == null) return isoString;

    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inHours < 1) return '${diff.inMinutes}분 전';
    if (diff.inDays < 1) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${dateTime.month}월 ${dateTime.day}일';
  }
}
