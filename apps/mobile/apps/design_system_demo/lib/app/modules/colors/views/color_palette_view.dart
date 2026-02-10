import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:design_system/design_system.dart';
import 'package:core/core.dart';
import '../controllers/color_palette_controller.dart';

/// 컬러 팔레트 화면 View
///
/// 6개 컬러 팔레트 선택 및 색상 스와치 미리보기를 담당합니다.
class ColorPaletteView extends GetView<ColorPaletteController> {
  const ColorPaletteView({super.key});

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
      title: const Text('컬러 팔레트'),
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
          _buildPaletteSelector(),
          const SizedBox(height: SketchDesignTokens.spacingXl),
          _buildColorSwatches(),
          const SizedBox(height: SketchDesignTokens.spacingXl),
          _buildComponentPreviews(),
        ],
      ),
    );
  }

  /// 팔레트 선택 섹션 빌드
  Widget _buildPaletteSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '팔레트 선택',
          style: TextStyle(
            fontSize: SketchDesignTokens.fontSizeLg,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SketchDesignTokens.spacingMd),
        Obx(() => Wrap(
              spacing: SketchDesignTokens.spacingSm,
              runSpacing: SketchDesignTokens.spacingSm,
              children: controller.availablePalettes
                  .map((palette) => _buildPaletteChip(palette))
                  .toList(),
            )),
      ],
    );
  }

  /// 팔레트 칩 빌드
  Widget _buildPaletteChip(String palette) {
    final isSelected = controller.selectedPalette.value == palette;
    final label = controller.paletteLabels[palette] ?? palette;

    return GestureDetector(
      onTap: () => controller.selectPalette(palette),
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

  /// 색상 스와치 섹션 빌드
  Widget _buildColorSwatches() {
    return Obx(() {
      final colors = controller.currentPaletteColors;
      if (colors.isEmpty) {
        return const Center(
          child: Text('팔레트를 찾을 수 없습니다.'),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '색상 스와치',
            style: TextStyle(
              fontSize: SketchDesignTokens.fontSizeLg,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: SketchDesignTokens.spacingMd),
          ...colors.entries.map((entry) => _buildColorSwatch(
                entry.key,
                entry.value,
              )),
        ],
      );
    });
  }

  /// 개별 색상 스와치 빌드
  Widget _buildColorSwatch(String name, Color color) {
    final hexCode = controller.colorToHex(color);

    return Container(
      margin: const EdgeInsets.only(bottom: SketchDesignTokens.spacingSm),
      child: Row(
        children: [
          // 색상 박스
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(SketchDesignTokens.radiusMd),
              border: Border.all(
                color: SketchDesignTokens.base300,
                width: SketchDesignTokens.strokeThin,
              ),
            ),
          ),
          const SizedBox(width: SketchDesignTokens.spacingMd),
          // 색상 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: SketchDesignTokens.fontSizeBase,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: SketchDesignTokens.spacingXs),
                Text(
                  hexCode,
                  style: const TextStyle(
                    fontSize: SketchDesignTokens.fontSizeSm,
                    color: SketchDesignTokens.base600,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 컴포넌트 미리보기 섹션 빌드
  Widget _buildComponentPreviews() {
    return Obx(() {
      final colors = controller.currentPaletteColors;
      if (colors.isEmpty) return const SizedBox.shrink();

      final primaryColor = colors['primary'] ?? SketchDesignTokens.accentPrimary;
      final secondaryColor =
          colors['secondary'] ?? SketchDesignTokens.base300;
      final backgroundColor =
          colors['background'] ?? SketchDesignTokens.white;

      return Column(
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
          _buildButtonPreview(primaryColor, secondaryColor),
          const SizedBox(height: SketchDesignTokens.spacingLg),
          _buildCardPreview(backgroundColor, primaryColor),
        ],
      );
    });
  }

  /// 버튼 미리보기 빌드
  Widget _buildButtonPreview(Color primaryColor, Color secondaryColor) {
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
              onPressed: () {},
            ),
            SketchButton(
              text: 'Secondary',
              style: SketchButtonStyle.secondary,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  /// 카드 미리보기 빌드
  Widget _buildCardPreview(Color backgroundColor, Color borderColor) {
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
          fillColor: backgroundColor,
          borderColor: borderColor,
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
                '선택된 팔레트 색상이 적용된 카드입니다.',
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
}
