import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// SketchTextArea 데모
///
/// label, hint, errorText, counter, enabled 속성을 실시간으로 조절할 수 있습니다.
class TextAreaDemo extends StatefulWidget {
  const TextAreaDemo({super.key});

  @override
  State<TextAreaDemo> createState() => _TextAreaDemoState();
}

class _TextAreaDemoState extends State<TextAreaDemo> {
  bool _showLabel = true;
  bool _showHint = true;
  bool _showError = false;
  bool _showCounter = false;
  bool _enabled = true;

  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
        SketchTextArea(
          controller: _controller,
          label: _showLabel ? 'Label' : null,
          hint: _showHint ? 'Text area' : null,
          errorText: _showError ? 'This field is required' : null,
          showCounter: _showCounter,
          maxLength: _showCounter ? 500 : null,
          enabled: _enabled,
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
        _buildToggleRow(
            'Show Label', _showLabel, (v) => setState(() => _showLabel = v)),
        _buildToggleRow(
            'Show Hint', _showHint, (v) => setState(() => _showHint = v)),
        _buildToggleRow(
            'Show Error', _showError, (v) => setState(() => _showError = v)),
        _buildToggleRow('Show Counter', _showCounter,
            (v) => setState(() => _showCounter = v)),
        _buildToggleRow(
            'Enabled', _enabled, (v) => setState(() => _enabled = v)),
      ],
    );
  }

  Widget _buildToggleRow(
      String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: SketchDesignTokens.fontSizeBase)),
        SketchSwitch(value: value, onChanged: onChanged),
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

        // 기본
        const Text('기본', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        const SketchTextArea(
          hint: 'Text area',
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 라벨과 힌트
        const Text('라벨과 힌트',
            style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        const SketchTextArea(
          label: '의견',
          hint: '의견을 자유롭게 작성하세요',
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 에러 상태
        const Text('에러 상태',
            style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        const SketchTextArea(
          label: '질문',
          hint: '질문 내용',
          errorText: '최소 20자 이상 입력하세요',
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 카운터
        const Text('글자 수 카운터',
            style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        const SketchTextArea(
          label: '댓글',
          hint: '댓글 입력',
          maxLength: 500,
          showCounter: true,
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 비활성화
        const Text('비활성화',
            style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        const SketchTextArea(
          hint: 'Disabled text area',
          enabled: false,
        ),
      ],
    );
  }
}
