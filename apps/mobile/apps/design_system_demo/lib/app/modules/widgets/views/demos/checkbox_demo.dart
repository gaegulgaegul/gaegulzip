import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// SketchCheckbox 데모
///
/// value, tristate 속성을 실시간으로 조절할 수 있습니다.
class CheckboxDemo extends StatefulWidget {
  const CheckboxDemo({super.key});

  @override
  State<CheckboxDemo> createState() => _CheckboxDemoState();
}

class _CheckboxDemoState extends State<CheckboxDemo> {
  // 조절 가능한 속성들
  bool? _value = false;
  bool _tristate = false;

  // 갤러리 상태
  bool _galleryValue1 = false;
  bool _galleryValue2 = true;
  bool? _galleryValue3;

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
          child: SketchCheckbox(
            value: _value,
            tristate: _tristate,
            onChanged: (value) => setState(() => _value = value),
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
            const Text('Tristate (3가지 상태)', style: TextStyle(fontSize: SketchDesignTokens.fontSizeBase)),
            SketchSwitch(
              value: _tristate,
              onChanged: (value) {
                setState(() {
                  _tristate = value;
                  if (!value && _value == null) {
                    _value = false;
                  }
                });
              },
            ),
          ],
        ),

        const SizedBox(height: SketchDesignTokens.spacingSm),
        Text(
          'Current value: ${_value == null ? "null (indeterminate)" : _value.toString()}',
          style: const TextStyle(fontSize: SketchDesignTokens.fontSizeSm, color: Colors.grey),
        ),
      ],
    );
  }

  /// 변형 갤러리 섹션
  Widget _buildGallerySection() {
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

        // 체크/체크 안됨
        const Text('체크/체크 안됨', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Row(
          children: [
            SketchCheckbox(
              value: _galleryValue1,
              onChanged: (value) => setState(() => _galleryValue1 = value ?? false),
            ),
            const SizedBox(width: SketchDesignTokens.spacingSm),
            const Text('Unchecked'),
          ],
        ),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Row(
          children: [
            SketchCheckbox(
              value: _galleryValue2,
              onChanged: (value) => setState(() => _galleryValue2 = value ?? false),
            ),
            const SizedBox(width: SketchDesignTokens.spacingSm),
            const Text('Checked'),
          ],
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // Tristate (3가지 상태)
        const Text('Tristate', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Row(
          children: [
            SketchCheckbox(
              value: _galleryValue3,
              tristate: true,
              onChanged: (value) => setState(() => _galleryValue3 = value),
            ),
            const SizedBox(width: SketchDesignTokens.spacingSm),
            const Text('Indeterminate (탭하여 순환)'),
          ],
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 비활성화
        const Text('비활성화', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Row(
          children: [
            const SketchCheckbox(
              value: false,
              onChanged: null,
            ),
            const SizedBox(width: SketchDesignTokens.spacingSm),
            const Text('Disabled Unchecked'),
          ],
        ),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Row(
          children: [
            const SketchCheckbox(
              value: true,
              onChanged: null,
            ),
            const SizedBox(width: SketchDesignTokens.spacingSm),
            const Text('Disabled Checked'),
          ],
        ),
      ],
    );
  }
}
