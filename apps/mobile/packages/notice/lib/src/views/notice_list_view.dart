import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'package:get/get.dart';
import 'package:design_system/design_system.dart';
import '../controllers/notice_list_controller.dart';
import '../widgets/notice_list_card.dart';

/// 공지사항 목록 화면
class NoticeListView extends GetView<NoticeListController> {
  const NoticeListView({super.key});

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        controller.loadMoreNotices();
      }
    });

    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(() {
        // 로딩 상태
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        // 에러 상태
        if (controller.errorMessage.value.isNotEmpty &&
            controller.notices.isEmpty) {
          return _buildErrorState();
        }

        // 빈 상태
        if (controller.notices.isEmpty && controller.pinnedNotices.isEmpty) {
          return _buildEmptyState();
        }

        // 데이터 있음
        return _buildNoticeList(scrollController);
      }),
    );
  }

  /// AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('공지사항'),
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: controller.refreshNotices,
          tooltip: '새로고침',
        ),
      ],
    );
  }

  /// 공지사항 목록
  Widget _buildNoticeList(ScrollController scrollController) {
    return RefreshIndicator(
      onRefresh: controller.refreshNotices,
      color: SketchDesignTokens.accentPrimary,
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          // 상단 패딩
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // 고정 공지 섹션
          if (controller.pinnedNotices.isNotEmpty) ...[
            _buildPinnedSection(),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            _buildDivider(),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],

          // 일반 공지 헤더
          _buildSectionHeader('최신 공지'),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // 일반 공지 목록
          _buildNoticeItems(),

          // 무한 스크롤 로딩 인디케이터
          if (controller.isLoadingMore.value)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),

          // 하단 패딩
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  /// 고정 공지 섹션
  Widget _buildPinnedSection() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '📌 고정 공지',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...controller.pinnedNotices.map(
            (notice) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: NoticeListCard(
                notice: notice,
                onTap: () => _navigateToDetail(notice.id),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 구분선
  Widget _buildDivider() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Divider(thickness: 1),
      ),
    );
  }

  /// 섹션 헤더
  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 일반 공지 아이템들
  Widget _buildNoticeItems() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final notice = controller.notices[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: NoticeListCard(
              notice: notice,
              onTap: () => _navigateToDetail(notice.id),
            ),
          );
        },
        childCount: controller.notices.length,
      ),
    );
  }

  /// 상세 화면으로 이동
  void _navigateToDetail(int noticeId) {
    Get.toNamed('/notice/detail', arguments: noticeId);
  }

  /// 로딩 상태
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('공지사항을 불러오는 중...'),
        ],
      ),
    );
  }

  /// 에러 상태
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              '인터넷 연결을 확인해주세요',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SketchButton(
              text: '다시 시도',
              style: SketchButtonStyle.primary,
              onPressed: controller.refreshNotices,
            ),
          ],
        ),
      ),
    );
  }

  /// 빈 상태
  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '아직 등록된 공지사항이 없습니다',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              '새로운 공지사항이 등록되면 알려드릴게요',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
