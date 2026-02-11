import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:design_system/design_system.dart';

import '../controllers/sdk_list_controller.dart';
import '../models/sdk_item.dart';

/// SDK 목록 화면
///
/// 데모 가능한 SDK 패키지 목록을 표시합니다.
class SdkListView extends GetView<SdkListController> {
  const SdkListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SDK Demos'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: ListView(
          children: [
            const SizedBox(height: 8),
            // 안내 문구
            Text(
              '각 SDK 패키지의 UI/UX를 테스트할 수 있습니다.',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall?.color ??
                    const Color(0xFF5E5E5E),
              ),
            ),
            const SizedBox(height: 16),
            // SDK 항목 카드들
            ...controller.sdkItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildSdkItemCard(item),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// SDK 항목 카드
  Widget _buildSdkItemCard(SdkItem item) {
    // TODO(human): SDK 아이템 카드의 레이아웃을 구현하세요
    return SketchCard(
      onTap: () => controller.navigateToSdk(item.route),
      elevation: 1,
      body: Row(
        children: [
          Icon(item.icon, size: 40, color: const Color(0xFF2196F3)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5E5E5E),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF8E8E8E)),
        ],
      ),
    );
  }
}
