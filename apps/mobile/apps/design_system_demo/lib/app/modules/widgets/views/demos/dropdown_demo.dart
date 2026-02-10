import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// SketchDropdown 데모
///
/// items, hint 속성을 실시간으로 조절할 수 있습니다.
class DropdownDemo extends StatefulWidget {
  const DropdownDemo({super.key});

  @override
  State<DropdownDemo> createState() => _DropdownDemoState();
}

class _DropdownDemoState extends State<DropdownDemo> {
  // 조절 가능한 속성들
  String? _selectedValue;

  final List<String> _items = [
    '옵션 1',
    '옵션 2',
    '옵션 3',
    '옵션 4',
    '옵션 5',
  ];

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
        SketchDropdown<String>(
          value: _selectedValue,
          items: _items,
          hint: '옵션을 선택하세요',
          onChanged: (value) => setState(() => _selectedValue = value),
        ),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Center(
          child: Text(
            'Selected: ${_selectedValue ?? "None"}',
            style: const TextStyle(fontSize: SketchDesignTokens.fontSizeSm, color: Colors.grey),
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

        SketchButton(
          text: 'Reset Selection',
          style: SketchButtonStyle.outline,
          size: SketchButtonSize.small,
          onPressed: () => setState(() => _selectedValue = null),
        ),
      ],
    );
  }

  /// 변형 갤러리 섹션
  Widget _buildGallerySection() {
    String? value1;
    String? value2 = 'B';

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

        // 기본 (힌트 표시)
        const Text('기본 (힌트 표시)', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        SketchDropdown<String>(
          value: value1,
          items: const ['A', 'B', 'C', 'D'],
          hint: '선택하세요',
          onChanged: (value) => setState(() => value1 = value),
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 값이 선택된 상태
        const Text('값이 선택된 상태', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        SketchDropdown<String>(
          value: value2,
          items: const ['A', 'B', 'C', 'D'],
          onChanged: (value) => setState(() => value2 = value),
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 비활성화
        const Text('비활성화', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        SketchDropdown<String>(
          value: 'C',
          items: const ['A', 'B', 'C', 'D'],
          onChanged: null,
        ),
      ],
    );
  }
}
