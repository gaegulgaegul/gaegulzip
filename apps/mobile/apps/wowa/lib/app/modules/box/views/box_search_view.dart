import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:api/api.dart';
import 'package:design_system/design_system.dart';
import '../controllers/box_search_controller.dart';
import '../../../routes/app_routes.dart';

/// 박스 검색 화면
///
/// 이름/지역으로 박스를 검색하고 가입할 수 있는 화면입니다.
class BoxSearchView extends GetView<BoxSearchController> {
  const BoxSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('박스 찾기')),
      body: SafeArea(
        child: Column(
          children: [
            // 검색 입력 영역
            _buildSearchInputs(),
            const SizedBox(height: 16),
            // 검색 결과 목록
            Expanded(child: _buildSearchResults()),
          ],
        ),
      ),
      // 신규 박스 생성 버튼
      floatingActionButton: SketchButton(
        text: '새 박스 만들기',
        style: SketchButtonStyle.primary,
        onPressed: () => Get.toNamed(Routes.BOX_CREATE),
      ),
    );
  }

  /// 검색 입력 영역
  Widget _buildSearchInputs() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SketchInput(
            label: '박스 이름',
            hint: '검색할 박스 이름을 입력하세요',
            prefixIcon: const Icon(Icons.search),
            onChanged: (value) => controller.nameQuery.value = value,
          ),
          const SizedBox(height: 12),
          SketchInput(
            label: '지역',
            hint: '지역을 입력하세요',
            prefixIcon: const Icon(Icons.location_on),
            onChanged: (value) => controller.regionQuery.value = value,
          ),
        ],
      ),
    );
  }

  /// 검색 결과 목록
  Widget _buildSearchResults() {
    return Obx(() {
      // 로딩 상태
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // 검색어 없음
      if (controller.nameQuery.value.isEmpty &&
          controller.regionQuery.value.isEmpty) {
        return const Center(
          child: Text('박스 이름이나 지역을 검색해보세요'),
        );
      }

      // 결과 없음
      if (controller.searchResults.isEmpty) {
        return const Center(
          child: Text('검색 결과가 없습니다'),
        );
      }

      // 결과 목록
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.searchResults.length,
        itemBuilder: (context, index) {
          final box = controller.searchResults[index];
          return _buildBoxCard(box);
        },
      );
    });
  }

  /// 박스 카드
  Widget _buildBoxCard(BoxModel box) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SketchCard(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              box.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              box.region,
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (box.description != null) ...[
              const SizedBox(height: 4),
              Text(
                box.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (box.memberCount != null) ...[
              const SizedBox(height: 8),
              Text(
                '멤버 ${box.memberCount}명',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ],
        ),
        footer: Align(
          alignment: Alignment.centerRight,
          child: SketchButton(
            text: '가입',
            style: SketchButtonStyle.outline,
            size: SketchButtonSize.small,
            onPressed: () => controller.joinBox(box.id),
          ),
        ),
      ),
    );
  }
}
