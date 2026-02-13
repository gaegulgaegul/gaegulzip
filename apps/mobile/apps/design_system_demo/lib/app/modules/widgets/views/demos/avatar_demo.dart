import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// SketchAvatar 데모
///
/// 이미지, 이니셜, 플레이스홀더, 다양한 크기/모양을 확인할 수 있습니다.
class AvatarDemo extends StatelessWidget {
  const AvatarDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SketchDesignTokens.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSizeSection(),
          const SizedBox(height: SketchDesignTokens.spacing2Xl),
          _buildShapeSection(),
          const SizedBox(height: SketchDesignTokens.spacing2Xl),
          _buildContentSection(),
        ],
      ),
    );
  }

  /// 크기별 아바타
  Widget _buildSizeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '크기',
          style: TextStyle(
            fontSize: SketchDesignTokens.fontSizeLg,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),
        Wrap(
          spacing: SketchDesignTokens.spacingMd,
          runSpacing: SketchDesignTokens.spacingMd,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            SketchAvatar(
              initials: 'XS',
              size: SketchAvatarSize.xs,
            ),
            SketchAvatar(
              initials: 'SM',
              size: SketchAvatarSize.sm,
            ),
            SketchAvatar(
              initials: 'MD',
              size: SketchAvatarSize.md,
            ),
            SketchAvatar(
              initials: 'LG',
              size: SketchAvatarSize.lg,
            ),
            SketchAvatar(
              initials: 'XL',
              size: SketchAvatarSize.xl,
            ),
            SketchAvatar(
              initials: '2X',
              size: SketchAvatarSize.xxl,
            ),
          ],
        ),
      ],
    );
  }

  /// 모양별 아바타
  Widget _buildShapeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '모양',
          style: TextStyle(
            fontSize: SketchDesignTokens.fontSizeLg,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),
        Wrap(
          spacing: SketchDesignTokens.spacingMd,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            SketchAvatar(
              initials: '원',
              shape: SketchAvatarShape.circle,
              size: SketchAvatarSize.lg,
            ),
            SketchAvatar(
              initials: '각',
              shape: SketchAvatarShape.roundedSquare,
              size: SketchAvatarSize.lg,
            ),
          ],
        ),
      ],
    );
  }

  /// 컨텐츠 타입별
  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '컨텐츠 타입',
          style: TextStyle(
            fontSize: SketchDesignTokens.fontSizeLg,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 이니셜
        const Text('이니셜', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Wrap(
          spacing: SketchDesignTokens.spacingMd,
          children: const [
            SketchAvatar(
              initials: 'AB',
              size: SketchAvatarSize.lg,
              backgroundColor: Color(0xFF6366F1),
            ),
            SketchAvatar(
              initials: 'CD',
              size: SketchAvatarSize.lg,
              backgroundColor: Color(0xFFF59E0B),
            ),
            SketchAvatar(
              initials: 'EF',
              size: SketchAvatarSize.lg,
              backgroundColor: Color(0xFF10B981),
            ),
          ],
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 플레이스홀더
        const Text('플레이스홀더', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Wrap(
          spacing: SketchDesignTokens.spacingMd,
          children: const [
            SketchAvatar(
              size: SketchAvatarSize.lg,
            ),
            SketchAvatar(
              placeholderIcon: Icons.group,
              size: SketchAvatarSize.lg,
            ),
            SketchAvatar(
              size: SketchAvatarSize.lg,
              iconColor: Color(0xFFEC4899), // 핑크 아이콘
            ),
          ],
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 테두리 없음
        const Text('테두리 없음', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        const SketchAvatar(
          initials: 'NB',
          size: SketchAvatarSize.lg,
          showBorder: false,
          backgroundColor: Color(0xFF6366F1),
        ),
      ],
    );
  }
}
