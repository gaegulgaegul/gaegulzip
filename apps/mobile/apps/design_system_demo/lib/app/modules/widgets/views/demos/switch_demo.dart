import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// SketchSwitch 데모
///
/// value, disabled 속성을 실시간으로 조절할 수 있습니다.
class SwitchDemo extends StatefulWidget {
  const SwitchDemo({super.key});

  @override
  State<SwitchDemo> createState() => _SwitchDemoState();
}

class _SwitchDemoState extends State<SwitchDemo> {
  // 조절 가능한 속성들
  bool _value = true;
  bool _disabled = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SketchDesignTokens.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPreviewSection(),
          const SizedBox(height: SketchDesignTokens.spacing2Xl),
          _buildControlsSection(),
          const SizedBox(height: SketchDesignTokens.spacing2Xl),
          _buildGallerySection(),
        ],
      ),
    );
  }

  /// 실시간 프리뷰 섹션
  Widget _buildPreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '실시간 프리뷰',
          style: TextStyle(
            fontSize: SketchDesignTokens.fontSizeLg,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),
        Center(
          child: SketchSwitch(
            value: _value,
            onChanged: _disabled ? null : (value) => setState(() => _value = value),
          ),
        ),
      ],
    );
  }

  /// 속성 조절 패널
  Widget _buildControlsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '속성 조절',
          style: TextStyle(
            fontSize: SketchDesignTokens.fontSizeLg,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Value', style: TextStyle(fontSize: SketchDesignTokens.fontSizeBase)),
            SketchSwitch(
              value: _value,
              onChanged: (value) => setState(() => _value = value),
            ),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Disabled', style: TextStyle(fontSize: SketchDesignTokens.fontSizeBase)),
            SketchSwitch(
              value: _disabled,
              onChanged: (value) => setState(() => _disabled = value),
            ),
          ],
        ),
      ],
    );
  }

  /// 변형 갤러리 섹션
  Widget _buildGallerySection() {
    bool value1 = false;
    bool value2 = true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '변형 갤러리',
          style: TextStyle(
            fontSize: SketchDesignTokens.fontSizeLg,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // ON/OFF
        const Text('ON/OFF', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Row(
          children: [
            SketchSwitch(
              value: value1,
              onChanged: (value) => setState(() => value1 = value),
            ),
            const SizedBox(width: SketchDesignTokens.spacingLg),
            const Text('OFF'),
          ],
        ),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Row(
          children: [
            SketchSwitch(
              value: value2,
              onChanged: (value) => setState(() => value2 = value),
            ),
            const SizedBox(width: SketchDesignTokens.spacingLg),
            const Text('ON'),
          ],
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 비활성화
        const Text('비활성화', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Row(
          children: [
            const SketchSwitch(
              value: false,
              onChanged: null,
            ),
            const SizedBox(width: SketchDesignTokens.spacingLg),
            const Text('Disabled OFF'),
          ],
        ),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Row(
          children: [
            const SketchSwitch(
              value: true,
              onChanged: null,
            ),
            const SizedBox(width: SketchDesignTokens.spacingLg),
            const Text('Disabled ON'),
          ],
        ),
      ],
    );
  }
}
