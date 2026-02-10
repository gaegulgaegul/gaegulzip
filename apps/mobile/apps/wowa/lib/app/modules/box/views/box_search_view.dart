import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/box/box_model.dart';
import 'package:design_system/design_system.dart';
import '../controllers/box_search_controller.dart';
import '../../../routes/app_routes.dart';

/// 박스 검색 화면
///
/// 통합 키워드로 박스를 검색하고 가입할 수 있는 화면
/// 5가지 UI 상태: 초기/로딩/에러/결과 없음/결과 표시
class BoxSearchView extends GetView<BoxSearchController> {
  const BoxSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchSection(),
            const SizedBox(height: 16),
            Expanded(child: _buildSearchResults()),
          ],
        ),
      ),
      floatingActionButton: _buildCreateButton(),
    );
  }

  /// AppBar
  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Get.back(),
      ),
      title: const Text('박스 찾기'),
      centerTitle: true,
    );
  }

  /// 검색 영역 (단일 통합 검색)
  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(
        () => SketchInput(
          controller: controller.searchController,
          hint: '박스 이름이나 지역을 검색하세요',
          prefixIcon: Icon(
            Icons.search,
            color: SketchDesignTokens.base500,
          ),
          suffixIcon: controller.keyword.value.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: SketchDesignTokens.base500,
                  ),
                  onPressed: controller.clearSearch,
                  tooltip: '검색어 지우기',
                )
              : null,
        ),
      ),
    );
  }

  /// 검색 결과 영역 (5가지 상태)
  Widget _buildSearchResults() {
    return Obx(() {
      // 1. 로딩 상태
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      // 2. 검색어 없음 (초기 상태)
      if (controller.keyword.value.isEmpty) {
        return _buildEmptySearch();
      }

      // 3. 에러 상태
      if (controller.errorMessage.value.isNotEmpty) {
        return _buildErrorState();
      }

      // 4. 검색 결과 없음
      if (controller.searchResults.isEmpty) {
        return _buildNoResults();
      }

      // 5. 검색 결과 표시
      return _buildResultsList();
    });
  }

  /// Empty State: 검색어 없음
  Widget _buildEmptySearch() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: SketchDesignTokens.base300,
          ),
          const SizedBox(height: 16),
          Text(
            '박스 이름이나 지역을 검색해보세요',
            style: TextStyle(
              fontSize: SketchDesignTokens.fontSizeBase,
              color: SketchDesignTokens.base500,
            ),
          ),
        ],
      ),
    );
  }

  /// Empty State: 검색 결과 없음
  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 64,
            color: SketchDesignTokens.base300,
          ),
          const SizedBox(height: 16),
          Text(
            '검색 결과가 없습니다',
            style: TextStyle(
              fontSize: SketchDesignTokens.fontSizeLg,
              fontWeight: FontWeight.w500,
              color: SketchDesignTokens.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '다른 검색어를 시도해보세요',
            style: TextStyle(
              fontSize: SketchDesignTokens.fontSizeSm,
              color: SketchDesignTokens.base700,
            ),
          ),
        ],
      ),
    );
  }

  /// Error State: 에러 발생
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: SketchDesignTokens.error,
          ),
          const SizedBox(height: 16),
          Text(
            controller.errorMessage.value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: SketchDesignTokens.fontSizeBase,
              color: SketchDesignTokens.error,
            ),
          ),
          const SizedBox(height: 16),
          SketchButton(
            text: '재시도',
            onPressed: controller.searchBoxes,
            style: SketchButtonStyle.outline,
          ),
        ],
      ),
    );
  }

  /// 검색 결과 목록
  Widget _buildResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      itemCount: controller.searchResults.length,
      itemBuilder: (context, index) {
        final box = controller.searchResults[index];
        return _buildBoxCard(box);
      },
    );
  }

  /// 박스 카드
  Widget _buildBoxCard(BoxModel box) {
    return SketchCard(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Row(
            children: [
              Expanded(
                child: Text(
                  box.name,
                  style: TextStyle(
                    fontSize: SketchDesignTokens.fontSizeLg,
                    fontWeight: FontWeight.bold,
                    color: SketchDesignTokens.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // 지역
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: SketchDesignTokens.base500,
              ),
              const SizedBox(width: 4),
              Text(
                box.region,
                style: TextStyle(
                  fontSize: SketchDesignTokens.fontSizeSm,
                  color: SketchDesignTokens.base700,
                ),
              ),
            ],
          ),

          // 설명 (선택)
          if (box.description != null && box.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              box.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: SketchDesignTokens.fontSizeSm,
                color: SketchDesignTokens.base900,
              ),
            ),
          ],

          const SizedBox(height: 8),

          // 멤버 수
          if (box.memberCount != null)
            Row(
              children: [
                Icon(
                  Icons.people,
                  size: 14,
                  color: SketchDesignTokens.base500,
                ),
                const SizedBox(width: 4),
                Text(
                  '${box.memberCount}명',
                  style: TextStyle(
                    fontSize: SketchDesignTokens.fontSizeXs,
                    color: SketchDesignTokens.base500,
                  ),
                ),
              ],
            ),
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
    );
  }

  /// 새 박스 만들기 버튼
  Widget _buildCreateButton() {
    return SketchButton(
      text: '새 박스 만들기',
      icon: const Icon(Icons.add, size: 20),
      style: SketchButtonStyle.primary,
      size: SketchButtonSize.medium,
      onPressed: () => Get.toNamed(Routes.BOX_CREATE),
    );
  }
}
