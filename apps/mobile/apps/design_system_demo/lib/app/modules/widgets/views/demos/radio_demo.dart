import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// SketchRadio 데모
///
/// 라디오 그룹 선택, 라벨, 비활성화 상태를 확인할 수 있습니다.
class RadioDemo extends StatefulWidget {
  const RadioDemo({super.key});

  @override
  State<RadioDemo> createState() => _RadioDemoState();
}

class _RadioDemoState extends State<RadioDemo> {
  // 프리뷰용 선택값
  String _previewValue = 'option1';
  bool _isDisabled = false;
  bool _enableHatching = false;

  // 갤러리용 선택값
  String _notificationFrequency = 'instant';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SketchDesignTokens.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPreviewSection(),
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
        SketchRadio<String>(
          value: 'option1',
          groupValue: _previewValue,
          label: 'Option 1',
          enableDisabledHatching: _enableHatching,
          onChanged: _isDisabled ? null : (value) => setState(() => _previewValue = value),
        ),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        SketchRadio<String>(
          value: 'option2',
          groupValue: _previewValue,
          label: 'Option 2',
          enableDisabledHatching: _enableHatching,
          onChanged: _isDisabled ? null : (value) => setState(() => _previewValue = value),
        ),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        SketchRadio<String>(
          value: 'option3',
          groupValue: _previewValue,
          label: 'Option 3',
          enableDisabledHatching: _enableHatching,
          onChanged: _isDisabled ? null : (value) => setState(() => _previewValue = value),
        ),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Text(
          'Selected: $_previewValue',
          style: const TextStyle(
            fontSize: SketchDesignTokens.fontSizeSm,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 속성 조절
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
            const Text('Disabled', style: TextStyle(fontSize: SketchDesignTokens.fontSizeBase)),
            SketchSwitch(
              value: _isDisabled,
              onChanged: (value) => setState(() => _isDisabled = value),
            ),
          ],
        ),
        const SizedBox(height: SketchDesignTokens.spacingMd),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Hatching', style: TextStyle(fontSize: SketchDesignTokens.fontSizeBase)),
            SketchSwitch(
              value: _enableHatching,
              onChanged: (value) => setState(() => _enableHatching = value),
            ),
          ],
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

        // 라디오 그룹 예시
        const Text('알림 빈도', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        SketchRadio<String>(
          value: 'instant',
          groupValue: _notificationFrequency,
          label: '즉시',
          onChanged: (value) => setState(() => _notificationFrequency = value),
        ),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        SketchRadio<String>(
          value: 'hourly',
          groupValue: _notificationFrequency,
          label: '1시간마다',
          onChanged: (value) => setState(() => _notificationFrequency = value),
        ),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        SketchRadio<String>(
          value: 'daily',
          groupValue: _notificationFrequency,
          label: '하루 1번',
          onChanged: (value) => setState(() => _notificationFrequency = value),
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 라벨 없는 라디오
        const Text('라벨 없음', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Row(
          children: [
            SketchRadio<String>(
              value: 'option1',
              groupValue: _previewValue,
              onChanged: (value) => setState(() => _previewValue = value),
            ),
            const SizedBox(width: SketchDesignTokens.spacingLg),
            SketchRadio<String>(
              value: 'option2',
              groupValue: _previewValue,
              onChanged: (value) => setState(() => _previewValue = value),
            ),
            const SizedBox(width: SketchDesignTokens.spacingLg),
            SketchRadio<String>(
              value: 'option3',
              groupValue: _previewValue,
              onChanged: (value) => setState(() => _previewValue = value),
            ),
          ],
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 비활성화
        const Text('비활성화', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        const SketchRadio<String>(
          value: 'disabled_off',
          groupValue: 'other',
          label: 'Disabled Unselected',
          enableDisabledHatching: true,
          onChanged: null,
        ),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        const SketchRadio<String>(
          value: 'disabled_on',
          groupValue: 'disabled_on',
          label: 'Disabled Selected',
          enableDisabledHatching: true,
          onChanged: null,
        ),
      ],
    );
  }
}
