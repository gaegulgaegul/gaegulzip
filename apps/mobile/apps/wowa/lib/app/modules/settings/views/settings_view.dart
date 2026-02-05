import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:design_system/design_system.dart';
import '../controllers/settings_controller.dart';

/// 설정 화면
///
/// 프로필, 박스 변경, 알림, 로그아웃을 관리합니다.
class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 현재 박스 정보
                _buildCurrentBoxCard(),
                const SizedBox(height: 24),

                // 메뉴 항목들
                _buildMenuSection(),
                const SizedBox(height: 32),

                // 로그아웃 버튼
                _buildLogoutButton(),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// 현재 박스 정보 카드
  Widget _buildCurrentBoxCard() {
    return Obx(() {
      final box = controller.currentBox.value;

      return SketchCard(
        header: const Text('내 박스',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        body: box != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.fitness_center, size: 20),
                      const SizedBox(width: 8),
                      Text(box.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(box.region,
                      style: TextStyle(color: Colors.grey[600])),
                ],
              )
            : const Text('가입된 박스가 없습니다'),
      );
    });
  }

  /// 메뉴 항목 섹션
  Widget _buildMenuSection() {
    return Column(
      children: [
        // 공지사항
        Obx(() {
          final count = controller.unreadCount.value;
          return _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: '공지사항',
            subtitle: '앱 업데이트 및 중요 안내사항',
            onTap: controller.goToNoticeList,
            badge: count > 0
                ? Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: count < 10 ? 6 : 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF44336),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        count > 99 ? '99+' : count.toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ),
                  )
                : null,
          );
        }),
        const SizedBox(height: 12),

        // 박스 변경
        _buildMenuItem(
          icon: Icons.swap_horiz,
          title: '박스 변경',
          subtitle: '다른 박스를 검색하고 가입할 수 있습니다',
          onTap: controller.goToBoxChange,
        ),
      ],
    );
  }

  /// 메뉴 항목
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SketchCard(
        body: Row(
          children: [
            // 아이콘 + 뱃지
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 24, color: Colors.grey[700]),
                if (badge != null)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: badge,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  /// 로그아웃 버튼
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: SketchButton(
        text: '로그아웃',
        style: SketchButtonStyle.outline,
        size: SketchButtonSize.large,
        onPressed: controller.logout,
      ),
    );
  }
}
