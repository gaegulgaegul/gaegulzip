import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:design_system/design_system.dart';
import 'package:core/core.dart';
import '../controllers/tokens_controller.dart';

/// 디자인 토큰 화면 View
///
/// 디자인 토큰 섹션별 값을 시각화하여 보여줍니다.
class TokensView extends GetView<TokensController> {
  const TokensView({super.key});

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
      title: const Text('디자인 토큰'),
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
          _buildSectionSelector(),
          const SizedBox(height: SketchDesignTokens.spacingXl),
          _buildSectionContent(),
        ],
      ),
    );
  }

  /// 섹션 선택기 빌드
  Widget _buildSectionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '토큰 섹션',
          style: TextStyle(
            fontSize: SketchDesignTokens.fontSizeLg,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SketchDesignTokens.spacingMd),
        Obx(() => Wrap(
              spacing: SketchDesignTokens.spacingXs,
              runSpacing: SketchDesignTokens.spacingXs,
              children: TokenSection.values
                  .map((section) => _buildSectionChip(section))
                  .toList(),
            )),
      ],
    );
  }

  /// 섹션 칩 빌드
  Widget _buildSectionChip(TokenSection section) {
    final isSelected = controller.selectedSection.value == section;
    final label = _getSectionLabel(section);

    return GestureDetector(
      onTap: () => controller.selectSection(section),
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
            fontSize: SketchDesignTokens.fontSizeXs,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color:
                isSelected ? SketchDesignTokens.white : SketchDesignTokens.base900,
          ),
        ),
      ),
    );
  }

  /// 섹션 라벨 가져오기
  String _getSectionLabel(TokenSection section) {
    switch (section) {
      case TokenSection.colors:
        return '색상';
      case TokenSection.typography:
        return '타이포그래피';
      case TokenSection.spacing:
        return '간격';
      case TokenSection.stroke:
        return '선 두께';
      case TokenSection.borderRadius:
        return '테두리 반경';
      case TokenSection.opacity:
        return '불투명도';
      case TokenSection.shadows:
        return '그림자';
      case TokenSection.sketchEffects:
        return '스케치 효과';
    }
  }

  /// 섹션 콘텐츠 빌드
  Widget _buildSectionContent() {
    return Obx(() {
      switch (controller.selectedSection.value) {
        case TokenSection.colors:
          return _buildColorsSection();
        case TokenSection.typography:
          return _buildTypographySection();
        case TokenSection.spacing:
          return _buildSpacingSection();
        case TokenSection.stroke:
          return _buildStrokeSection();
        case TokenSection.borderRadius:
          return _buildBorderRadiusSection();
        case TokenSection.opacity:
          return _buildOpacitySection();
        case TokenSection.shadows:
          return _buildShadowsSection();
        case TokenSection.sketchEffects:
          return _buildSketchEffectsSection();
      }
    });
  }

  /// 색상 섹션 빌드
  Widget _buildColorsSection() {
    final colors = [
      ('base100', SketchDesignTokens.base100),
      ('base200', SketchDesignTokens.base200),
      ('base300', SketchDesignTokens.base300),
      ('base400', SketchDesignTokens.base400),
      ('base500', SketchDesignTokens.base500),
      ('base600', SketchDesignTokens.base600),
      ('base700', SketchDesignTokens.base700),
      ('base900', SketchDesignTokens.base900),
      ('accentPrimary', SketchDesignTokens.accentPrimary),
      ('accentLight', SketchDesignTokens.accentLight),
      ('accentDark', SketchDesignTokens.accentDark),
      ('success', SketchDesignTokens.success),
      ('warning', SketchDesignTokens.warning),
      ('error', SketchDesignTokens.error),
      ('info', SketchDesignTokens.info),
    ];

    return Column(
      children: colors.map((colorInfo) {
        final name = colorInfo.$1;
        final color = colorInfo.$2;
        final hexCode = _colorToHex(color);

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
                  borderRadius:
                      BorderRadius.circular(SketchDesignTokens.radiusMd),
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
      }).toList(),
    );
  }

  /// 타이포그래피 섹션 빌드
  Widget _buildTypographySection() {
    final fontSizes = [
      ('xs', SketchDesignTokens.fontSizeXs),
      ('sm', SketchDesignTokens.fontSizeSm),
      ('base', SketchDesignTokens.fontSizeBase),
      ('lg', SketchDesignTokens.fontSizeLg),
      ('xl', SketchDesignTokens.fontSizeXl),
      ('2xl', SketchDesignTokens.fontSize2Xl),
      ('3xl', SketchDesignTokens.fontSize3Xl),
      ('4xl', SketchDesignTokens.fontSize4Xl),
      ('5xl', SketchDesignTokens.fontSize5Xl),
      ('6xl', SketchDesignTokens.fontSize6Xl),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '폰트 크기',
          style: TextStyle(
            fontSize: SketchDesignTokens.fontSizeLg,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SketchDesignTokens.spacingMd),
        ...fontSizes.map((sizeInfo) {
          final name = sizeInfo.$1;
          final size = sizeInfo.$2;

          return Container(
            margin: const EdgeInsets.only(bottom: SketchDesignTokens.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name (${size}px)',
                  style: const TextStyle(
                    fontSize: SketchDesignTokens.fontSizeSm,
                    color: SketchDesignTokens.base600,
                  ),
                ),
                const SizedBox(height: SketchDesignTokens.spacingXs),
                Text(
                  'The quick brown fox',
                  style: TextStyle(fontSize: size),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: SketchDesignTokens.spacingXl),
        // Frame0 Default Fonts 비교
        const Text(
          'Default Fonts (Frame0)',
          style: TextStyle(
            fontSize: SketchDesignTokens.fontSizeLg,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SketchDesignTokens.spacingMd),
        _buildFontFamilyComparison(
          'Hand — Sketch 테마 기본',
          SketchDesignTokens.fontFamilyHand,
        ),
        const SizedBox(height: SketchDesignTokens.spacingMd),
        _buildFontFamilyComparison(
          'Sans — Solid 테마 기본',
          SketchDesignTokens.fontFamilySans,
        ),
        const SizedBox(height: SketchDesignTokens.spacingMd),
        _buildFontFamilyComparison(
          'Mono — 코드/숫자',
          SketchDesignTokens.fontFamilyMono,
        ),
        const SizedBox(height: SketchDesignTokens.spacingMd),
        _buildFontFamilyComparison(
          'Serif — 본문 텍스트',
          SketchDesignTokens.fontFamilySerif,
        ),
      ],
    );
  }

  /// 간격 섹션 빌드
  Widget _buildSpacingSection() {
    final spacings = [
      ('xs', SketchDesignTokens.spacingXs),
      ('sm', SketchDesignTokens.spacingSm),
      ('md', SketchDesignTokens.spacingMd),
      ('lg', SketchDesignTokens.spacingLg),
      ('xl', SketchDesignTokens.spacingXl),
      ('2xl', SketchDesignTokens.spacing2Xl),
      ('3xl', SketchDesignTokens.spacing3Xl),
      ('4xl', SketchDesignTokens.spacing4Xl),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: spacings.map((spacingInfo) {
        final name = spacingInfo.$1;
        final spacing = spacingInfo.$2;

        return Container(
          margin: const EdgeInsets.only(bottom: SketchDesignTokens.spacingMd),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  '$name (${spacing}px)',
                  style: const TextStyle(
                    fontSize: SketchDesignTokens.fontSizeSm,
                    color: SketchDesignTokens.base700,
                  ),
                ),
              ),
              Container(
                width: spacing,
                height: 24,
                color: SketchDesignTokens.accentPrimary,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 선 두께 섹션 빌드
  Widget _buildStrokeSection() {
    final strokes = [
      ('thin', SketchDesignTokens.strokeThin),
      ('standard', SketchDesignTokens.strokeStandard),
      ('bold', SketchDesignTokens.strokeBold),
      ('thick', SketchDesignTokens.strokeThick),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: strokes.map((strokeInfo) {
        final name = strokeInfo.$1;
        final strokeWidth = strokeInfo.$2;

        return Container(
          margin: const EdgeInsets.only(bottom: SketchDesignTokens.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$name (${strokeWidth}px)',
                style: const TextStyle(
                  fontSize: SketchDesignTokens.fontSizeSm,
                  color: SketchDesignTokens.base600,
                ),
              ),
              const SizedBox(height: SketchDesignTokens.spacingSm),
              Container(
                height: strokeWidth,
                color: SketchDesignTokens.base900,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 테두리 반경 섹션 빌드
  Widget _buildBorderRadiusSection() {
    final radii = [
      ('none', SketchDesignTokens.radiusNone),
      ('sm', SketchDesignTokens.radiusSm),
      ('md', SketchDesignTokens.radiusMd),
      ('lg', SketchDesignTokens.radiusLg),
      ('xl', SketchDesignTokens.radiusXl),
      ('2xl', SketchDesignTokens.radius2Xl),
      ('pill', SketchDesignTokens.radiusPill),
    ];

    return Wrap(
      spacing: SketchDesignTokens.spacingMd,
      runSpacing: SketchDesignTokens.spacingMd,
      children: radii.map((radiusInfo) {
        final name = radiusInfo.$1;
        final radius = radiusInfo.$2;

        return Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: SketchDesignTokens.accentPrimary,
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
            const SizedBox(height: SketchDesignTokens.spacingSm),
            Text(
              '$name (${radius}px)',
              style: const TextStyle(
                fontSize: SketchDesignTokens.fontSizeXs,
                color: SketchDesignTokens.base700,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  /// 불투명도 섹션 빌드
  Widget _buildOpacitySection() {
    final opacities = [
      ('disabled', SketchDesignTokens.opacityDisabled),
      ('subtle', SketchDesignTokens.opacitySubtle),
      ('sketch', SketchDesignTokens.opacitySketch),
      ('full', SketchDesignTokens.opacityFull),
    ];

    return Column(
      children: opacities.map((opacityInfo) {
        final name = opacityInfo.$1;
        final opacity = opacityInfo.$2;

        return Container(
          margin: const EdgeInsets.only(bottom: SketchDesignTokens.spacingMd),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$name ($opacity)',
                  style: const TextStyle(
                    fontSize: SketchDesignTokens.fontSizeBase,
                    color: SketchDesignTokens.base700,
                  ),
                ),
              ),
              Opacity(
                opacity: opacity,
                child: Container(
                  width: 100,
                  height: 60,
                  color: SketchDesignTokens.accentPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 그림자 섹션 빌드
  Widget _buildShadowsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShadowProperty(
          '오프셋',
          '${SketchDesignTokens.shadowOffsetMd.dx}, ${SketchDesignTokens.shadowOffsetMd.dy}',
        ),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        _buildShadowProperty(
          '블러 반경',
          '${SketchDesignTokens.shadowBlurMd}px',
        ),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        _buildShadowProperty(
          '색상',
          _colorToHex(SketchDesignTokens.shadowColor),
        ),
        const SizedBox(height: SketchDesignTokens.spacingXl),
        const Text(
          '미리보기',
          style: TextStyle(
            fontSize: SketchDesignTokens.fontSizeBase,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: SketchDesignTokens.spacingMd),
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: SketchDesignTokens.white,
              borderRadius:
                  BorderRadius.circular(SketchDesignTokens.radiusLg),
              boxShadow: [
                BoxShadow(
                  offset: SketchDesignTokens.shadowOffsetMd,
                  blurRadius: SketchDesignTokens.shadowBlurMd,
                  color: SketchDesignTokens.shadowColor,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '그림자',
                style: TextStyle(
                  fontSize: SketchDesignTokens.fontSizeBase,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 그림자 속성 행 빌드
  Widget _buildShadowProperty(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: SketchDesignTokens.fontSizeBase,
            color: SketchDesignTokens.base700,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: SketchDesignTokens.fontSizeBase,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  /// 스케치 효과 섹션 빌드
  Widget _buildSketchEffectsSection() {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'roughness (거칠기)',
              style: TextStyle(
                fontSize: SketchDesignTokens.fontSizeBase,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: SketchDesignTokens.spacingSm),
            Row(
              children: [
                Expanded(
                  child: SketchSlider(
                    value: controller.demoRoughness.value,
                    min: 0.0,
                    max: 2.0,
                    divisions: 20,
                    label: controller.demoRoughness.value.toStringAsFixed(1),
                    onChanged: controller.updateRoughness,
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    controller.demoRoughness.value.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: SketchDesignTokens.fontSizeBase,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SketchDesignTokens.spacingLg),
            const Text(
              'bowing (휘어짐)',
              style: TextStyle(
                fontSize: SketchDesignTokens.fontSizeBase,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: SketchDesignTokens.spacingSm),
            Row(
              children: [
                Expanded(
                  child: SketchSlider(
                    value: controller.demoBowing.value,
                    min: 0.0,
                    max: 2.0,
                    divisions: 20,
                    label: controller.demoBowing.value.toStringAsFixed(1),
                    onChanged: controller.updateBowing,
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    controller.demoBowing.value.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: SketchDesignTokens.fontSizeBase,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SketchDesignTokens.spacingXl),
            const Text(
              '미리보기',
              style: TextStyle(
                fontSize: SketchDesignTokens.fontSizeBase,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: SketchDesignTokens.spacingMd),
            Center(
              child: SketchContainer(
                width: 200,
                height: 120,
                roughness: controller.demoRoughness.value,
                bowing: controller.demoBowing.value,
                child: const Center(
                  child: Text(
                    '스케치 효과',
                    style: TextStyle(
                      fontSize: SketchDesignTokens.fontSizeLg,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  /// 폰트 패밀리 비교 행 빌드
  Widget _buildFontFamilyComparison(String label, String? fontFamily) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: SketchDesignTokens.fontSizeSm,
            color: SketchDesignTokens.base600,
          ),
        ),
        const SizedBox(height: SketchDesignTokens.spacingXs),
        Text(
          'The quick brown fox',
          style: TextStyle(
            fontSize: SketchDesignTokens.fontSizeLg,
            fontFamily: fontFamily,
          ),
        ),
      ],
    );
  }

  /// Color를 HEX 코드 문자열로 변환
  String _colorToHex(Color color) {
    final r = ((color.r * 255.0).round().clamp(0, 255))
        .toRadixString(16)
        .padLeft(2, '0');
    final g = ((color.g * 255.0).round().clamp(0, 255))
        .toRadixString(16)
        .padLeft(2, '0');
    final b = ((color.b * 255.0).round().clamp(0, 255))
        .toRadixString(16)
        .padLeft(2, '0');
    return '#${r.toUpperCase()}${g.toUpperCase()}${b.toUpperCase()}';
  }
}
