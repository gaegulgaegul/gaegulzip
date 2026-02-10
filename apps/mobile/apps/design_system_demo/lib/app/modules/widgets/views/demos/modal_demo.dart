import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// SketchModal 데모
///
/// title, showCloseButton, barrierDismissible 속성을 실시간으로 조절할 수 있습니다.
class ModalDemo extends StatefulWidget {
  const ModalDemo({super.key});

  @override
  State<ModalDemo> createState() => _ModalDemoState();
}

class _ModalDemoState extends State<ModalDemo> {
  // 조절 가능한 속성들
  bool _showTitle = true;
  bool _showCloseButton = true;
  bool _barrierDismissible = true;

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
          child: SketchButton(
            text: '모달 열기',
            onPressed: () => _showModal(),
          ),
        ),
      ],
    );
  }

  /// 모달 표시
  void _showModal() {
    SketchModal.show(
      context: context,
      title: _showTitle ? 'Modal Title' : null,
      child: const Text(
        'This is the modal content. You can put any widget here.',
      ),
      showCloseButton: _showCloseButton,
      barrierDismissible: _barrierDismissible,
      actions: [
        SketchButton(
          text: 'Cancel',
          style: SketchButtonStyle.outline,
          size: SketchButtonSize.small,
          onPressed: () => Navigator.of(context).pop(),
        ),
        SketchButton(
          text: 'OK',
          style: SketchButtonStyle.primary,
          size: SketchButtonSize.small,
          onPressed: () => Navigator.of(context).pop(),
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
            const Text('Show Title', style: TextStyle(fontSize: SketchDesignTokens.fontSizeBase)),
            SketchSwitch(
              value: _showTitle,
              onChanged: (value) => setState(() => _showTitle = value),
            ),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Show Close Button', style: TextStyle(fontSize: SketchDesignTokens.fontSizeBase)),
            SketchSwitch(
              value: _showCloseButton,
              onChanged: (value) => setState(() => _showCloseButton = value),
            ),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Barrier Dismissible', style: TextStyle(fontSize: SketchDesignTokens.fontSizeBase)),
            SketchSwitch(
              value: _barrierDismissible,
              onChanged: (value) => setState(() => _barrierDismissible = value),
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

        // 기본 모달
        const Text('기본 모달', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        SketchButton(
          text: '기본 모달',
          style: SketchButtonStyle.secondary,
          size: SketchButtonSize.small,
          onPressed: () {
            SketchModal.show(
              context: context,
              title: 'Basic Modal',
              child: const Text('Simple modal with title and close button.'),
            );
          },
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 액션 버튼
        const Text('액션 버튼', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        SketchButton(
          text: '액션 버튼 모달',
          style: SketchButtonStyle.secondary,
          size: SketchButtonSize.small,
          onPressed: () {
            SketchModal.show(
              context: context,
              title: 'Confirm',
              child: const Text('Are you sure?'),
              actions: [
                SketchButton(
                  text: 'Cancel',
                  style: SketchButtonStyle.outline,
                  size: SketchButtonSize.small,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                SketchButton(
                  text: 'OK',
                  style: SketchButtonStyle.primary,
                  size: SketchButtonSize.small,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 닫기 버튼 없음
        const Text('닫기 버튼 없음', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        SketchButton(
          text: '닫기 버튼 없음',
          style: SketchButtonStyle.secondary,
          size: SketchButtonSize.small,
          onPressed: () {
            SketchModal.show(
              context: context,
              child: const Text('No close button. Use actions to close.'),
              showCloseButton: false,
              actions: [
                SketchButton(
                  text: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
