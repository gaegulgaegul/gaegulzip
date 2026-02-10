import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:design_system/design_system.dart';
import 'package:core/core.dart';
import '../controllers/theme_showcase_controller.dart';

/// 테마 쇼케이스 화면 View
///
/// 6개 테마 프리셋 선택 및 샘플 컴포넌트 미리보기를 담당합니다.
class ThemeShowcaseView extends GetView<ThemeShowcaseController> {
  const ThemeShowcaseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// AppBar 빌드
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('테마 쇼케이스'),
      centerTitle: true,
    );
  }

  /// Body 빌드
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SketchDesignTokens.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPresetSelector(),
          const SizedBox(height: SketchDesignTokens.spacingXl),
          _buildThemeInfo(),
          const SizedBox(height: SketchDesignTokens.spacingXl),
          _buildComponentSamples(),
        ],
      ),
    );
  }

  /// 프리셋 선택 섹션 빌드
  Widget _buildPresetSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '테마 프리셋',
          style: TextStyle(
            fontSize: SketchDesignTokens.fontSizeLg,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SketchDesignTokens.spacingMd),
        Obx(() => Wrap(
              spacing: SketchDesignTokens.spacingSm,
              runSpacing: SketchDesignTokens.spacingSm,
              children: controller.presets
                  .map((preset) => _buildPresetChip(preset))
                  .toList(),
            )),
      ],
    );
  }

  /// 프리셋 칩 빌드
  Widget _buildPresetChip(String preset) {
    final isSelected = controller.selectedPreset.value == preset;
    final label = controller.presetLabels[preset] ?? preset;

    return GestureDetector(
      onTap: () => controller.selectPreset(preset),
      child: SketchContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: SketchDesignTokens.spacingMd,
          vertical: SketchDesignTokens.spacingSm,
        ),
        fillColor: isSelected
            ? SketchDesignTokens.accentPrimary
            : SketchDesignTokens.white,
        borderColor: isSelected
            ? SketchDesignTokens.accentPrimary
            : SketchDesignTokens.base300,
        strokeWidth: isSelected
            ? SketchDesignTokens.strokeBold
            : SketchDesignTokens.strokeStandard,
        child: Text(
          label,
          style: TextStyle(
            fontSize: SketchDesignTokens.fontSizeSm,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color:
                isSelected ? SketchDesignTokens.white : SketchDesignTokens.base900,
          ),
        ),
      ),
    );
  }

  /// 테마 정보 섹션 빌드
  Widget _buildThemeInfo() {
    return Obx(() {
      final theme = controller.currentThemeExtension;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '현재 테마 속성',
            style: TextStyle(
              fontSize: SketchDesignTokens.fontSizeBase,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: SketchDesignTokens.spacingMd),
          _buildThemeProperty('스트로크 너비', '${theme.strokeWidth}px'),
          const SizedBox(height: SketchDesignTokens.spacingSm),
          _buildThemeProperty('거칠기', theme.roughness.toStringAsFixed(1)),
          const SizedBox(height: SketchDesignTokens.spacingSm),
          _buildThemeProperty('휘어짐', theme.bowing.toStringAsFixed(1)),
        ],
      );
    });
  }

  /// 테마 속성 행 빌드
  Widget _buildThemeProperty(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: SketchDesignTokens.fontSizeSm,
            color: SketchDesignTokens.base600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: SketchDesignTokens.fontSizeSm,
            fontWeight: FontWeight.bold,
            color: SketchDesignTokens.base900,
          ),
        ),
      ],
    );
  }

  /// 컴포넌트 샘플 섹션 빌드
  Widget _buildComponentSamples() {
    return Obx(() {
      final themeExtension = controller.currentThemeExtension;

      return Builder(builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          extensions: [themeExtension],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '컴포넌트 미리보기',
              style: TextStyle(
                fontSize: SketchDesignTokens.fontSizeLg,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: SketchDesignTokens.spacingMd),
            _buildButtonSamples(),
            const SizedBox(height: SketchDesignTokens.spacingLg),
            _buildCardSample(),
            const SizedBox(height: SketchDesignTokens.spacingLg),
            _buildInputSample(),
            const SizedBox(height: SketchDesignTokens.spacingLg),
            _buildContainerSamples(),
          ],
        ),
      ));
    });
  }

  /// 버튼 샘플 빌드
  Widget _buildButtonSamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SketchButton',
          style: TextStyle(
            fontSize: SketchDesignTokens.fontSizeBase,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Wrap(
          spacing: SketchDesignTokens.spacingSm,
          runSpacing: SketchDesignTokens.spacingSm,
          children: [
            SketchButton(
              text: 'Primary',
              style: SketchButtonStyle.primary,
              onPressed: () {},
            ),
            SketchButton(
              text: 'Secondary',
              style: SketchButtonStyle.secondary,
              onPressed: () {},
            ),
            SketchButton(
              text: 'Outline',
              style: SketchButtonStyle.outline,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  /// 카드 샘플 빌드
  Widget _buildCardSample() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SketchCard',
          style: TextStyle(
            fontSize: SketchDesignTokens.fontSizeBase,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        SketchCard(
          elevation: 2,
          body: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '샘플 카드',
                style: TextStyle(
                  fontSize: SketchDesignTokens.fontSizeBase,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: SketchDesignTokens.spacingSm),
              Text(
                '선택된 테마가 적용된 카드 컴포넌트입니다.',
                style: TextStyle(
                  fontSize: SketchDesignTokens.fontSizeSm,
                  color: SketchDesignTokens.base700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 입력 필드 샘플 빌드
  Widget _buildInputSample() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SketchInput',
          style: TextStyle(
            fontSize: SketchDesignTokens.fontSizeBase,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        const SketchInput(
          hint: '텍스트를 입력하세요',
          prefixIcon: Icon(Icons.edit),
        ),
      ],
    );
  }

  /// 컨테이너 샘플 빌드
  Widget _buildContainerSamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SketchContainer',
          style: TextStyle(
            fontSize: SketchDesignTokens.fontSizeBase,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Wrap(
          spacing: SketchDesignTokens.spacingSm,
          runSpacing: SketchDesignTokens.spacingSm,
          children: [
            SketchContainer(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(SketchDesignTokens.spacingSm),
              child: const Center(
                child: Text(
                  '박스 1',
                  style: TextStyle(fontSize: SketchDesignTokens.fontSizeSm),
                ),
              ),
            ),
            SketchContainer(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(SketchDesignTokens.spacingSm),
              child: const Center(
                child: Text(
                  '박스 2',
                  style: TextStyle(fontSize: SketchDesignTokens.fontSizeSm),
                ),
              ),
            ),
            SketchContainer(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(SketchDesignTokens.spacingSm),
              child: const Center(
                child: Text(
                  '박스 3',
                  style: TextStyle(fontSize: SketchDesignTokens.fontSizeSm),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
