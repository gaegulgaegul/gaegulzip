import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// SketchInput 데모
///
/// 모드 전환, label, hint, errorText, prefix/suffix 속성을 실시간으로 조절할 수 있습니다.
class InputDemo extends StatefulWidget {
  const InputDemo({super.key});

  @override
  State<InputDemo> createState() => _InputDemoState();
}

class _InputDemoState extends State<InputDemo> {
  // 조절 가능한 속성들
  SketchInputMode _mode = SketchInputMode.defaultMode;
  bool _showLabel = true;
  bool _showHint = true;
  bool _showError = false;
  bool _obscureText = false;
  bool _showPrefix = false;
  bool _showSuffix = false;

  final _controller = TextEditingController();
  final _dateController = TextEditingController(text: '2024/09/02');
  final _timeController = TextEditingController(text: '09:24 AM');

  @override
  void dispose() {
    _controller.dispose();
    _dateController.dispose();
    _timeController.dispose();
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
          _buildModeGallerySection(),
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
        SketchInput(
          mode: _mode,
          controller: _mode == SketchInputMode.date
              ? _dateController
              : _mode == SketchInputMode.time
                  ? _timeController
                  : _controller,
          label: _showLabel ? 'Label' : null,
          hint: _showHint ? null : '', // null이면 모드 기본 힌트 사용
          errorText: _showError ? 'This field is required' : null,
          obscureText: _obscureText,
          prefixIcon: _showPrefix ? const Icon(LucideIcons.user) : null,
          suffixIcon: _showSuffix ? const Icon(LucideIcons.eye) : null,
          onTap: _mode == SketchInputMode.date ||
                  _mode == SketchInputMode.time ||
                  _mode == SketchInputMode.datetime
              ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Picker would open here')),
                  );
                }
              : null,
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

        // 모드 선택
        const Text('Mode',
            style: TextStyle(
                fontSize: SketchDesignTokens.fontSizeBase,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SketchInputMode.values.map((mode) {
            final isSelected = _mode == mode;
            return SketchButton(
              text: mode.name,
              style: isSelected
                  ? SketchButtonStyle.primary
                  : SketchButtonStyle.outline,
              size: SketchButtonSize.small,
              onPressed: () => setState(() => _mode = mode),
            );
          }).toList(),
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        _buildToggleRow(
            'Show Label', _showLabel, (v) => setState(() => _showLabel = v)),
        _buildToggleRow(
            'Show Hint', _showHint, (v) => setState(() => _showHint = v)),
        _buildToggleRow(
            'Show Error', _showError, (v) => setState(() => _showError = v)),
        _buildToggleRow('Obscure Text', _obscureText,
            (v) => setState(() => _obscureText = v)),
        _buildToggleRow('Show Prefix Icon', _showPrefix,
            (v) => setState(() => _showPrefix = v)),
        _buildToggleRow('Show Suffix Icon', _showSuffix,
            (v) => setState(() => _showSuffix = v)),
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

  /// 모드별 갤러리 섹션
  Widget _buildModeGallerySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '모드별 갤러리',
          style: TextStyle(
            fontSize: SketchDesignTokens.fontSizeLg,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // Search 모드
        const Text('Search 모드',
            style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        const SketchInput(
          mode: SketchInputMode.search,
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // Date 모드
        const Text('Date 모드',
            style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        SketchInput(
          mode: SketchInputMode.date,
          controller: TextEditingController(text: '2024/09/02'),
          onTap: () {},
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // Time 모드
        const Text('Time 모드',
            style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        SketchInput(
          mode: SketchInputMode.time,
          controller: TextEditingController(text: '09:24 AM'),
          onTap: () {},
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // DateTime 모드
        const Text('DateTime 모드',
            style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        SketchInput(
          mode: SketchInputMode.datetime,
          controller:
              TextEditingController(text: '2024/09/02 09:24 AM'),
          onTap: () {},
        ),
      ],
    );
  }

  /// 기존 변형 갤러리 섹션
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
        const SketchInput(
          hint: 'Basic input',
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 라벨과 힌트
        const Text('라벨과 힌트',
            style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        const SketchInput(
          label: 'Email',
          hint: 'you@example.com',
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 에러 상태
        const Text('에러 상태',
            style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        const SketchInput(
          label: 'Username',
          hint: 'Enter username',
          errorText: 'Username is required',
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 비밀번호
        const Text('비밀번호',
            style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        const SketchInput(
          label: 'Password',
          hint: 'Enter password',
          obscureText: true,
          prefixIcon: Icon(LucideIcons.lock),
        ),
      ],
    );
  }
}
