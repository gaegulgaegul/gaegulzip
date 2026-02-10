import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'sketch_input.dart';

/// 손으로 그린 스케치 스타일의 검색 입력 필드.
///
/// 검색 아이콘(prefixIcon)과 선택적 지우기 버튼(suffixIcon)이 포함된 입력 필드.
/// 텍스트가 입력되면 지우기 버튼이 자동으로 표시됨.
///
/// **기본 사용법:**
/// ```dart
/// SketchSearchInput(
///   hint: '박스 이름 검색',
///   onSubmitted: (query) {
///     searchBoxes(query);
///   },
/// )
/// ```
///
/// **실시간 검색:**
/// ```dart
/// SketchSearchInput(
///   hint: '운동 검색',
///   onChanged: (query) {
///     setState(() {
///       _searchResults = _filterWorkouts(query);
///     });
///   },
/// )
/// ```
///
/// **Controller 사용:**
/// ```dart
/// final _searchController = TextEditingController();
///
/// SketchSearchInput(
///   controller: _searchController,
///   hint: '검색어 입력',
///   onSubmitted: (query) {
///     print('검색: $query');
///   },
/// )
/// ```
///
/// **상태:**
/// - Normal: base300 테두리, base500 아이콘
/// - Focused: accentPrimary 테두리, accentPrimary 아이콘
/// - Filled: base700 테두리/아이콘
/// - Disabled: base300 테두리, textDisabled 아이콘
class SketchSearchInput extends StatefulWidget {
  /// 힌트 텍스트
  final String? hint;

  /// 텍스트 컨트롤러
  final TextEditingController? controller;

  /// 입력 변경 시 콜백
  final ValueChanged<String>? onChanged;

  /// 검색 실행 시 콜백 (엔터 또는 검색 아이콘 탭)
  final ValueChanged<String>? onSubmitted;

  /// 검색 아이콘 (기본값: Icons.search)
  final IconData searchIcon;

  /// 지우기 버튼 표시 여부
  final bool showClearButton;

  /// 자동 포커스 여부
  final bool autofocus;

  const SketchSearchInput({
    super.key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.searchIcon = Icons.search,
    this.showClearButton = true,
    this.autofocus = false,
  });

  @override
  State<SketchSearchInput> createState() => _SketchSearchInputState();
}

class _SketchSearchInputState extends State<SketchSearchInput> {
  late final TextEditingController _effectiveController;
  bool _isControllerInternallyCreated = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _effectiveController = TextEditingController();
      _isControllerInternallyCreated = true;
    } else {
      _effectiveController = widget.controller!;
    }
    _effectiveController.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant SketchSearchInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _effectiveController.removeListener(_onTextChanged);
      if (_isControllerInternallyCreated) {
        _effectiveController.dispose();
      }

      if (widget.controller == null) {
        _effectiveController = TextEditingController();
        _isControllerInternallyCreated = true;
      } else {
        _effectiveController = widget.controller!;
        _isControllerInternallyCreated = false;
      }
      _effectiveController.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_onTextChanged);
    if (_isControllerInternallyCreated) {
      _effectiveController.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      // 텍스트 변경 시 UI 업데이트 (지우기 버튼 표시/숨김)
    });
  }

  /// 텍스트가 있는지 확인
  bool get _hasText {
    return _effectiveController.text.isNotEmpty;
  }

  /// 아이콘 색상 결정
  Color _getIconColor() {
    if (_hasText) {
      return SketchDesignTokens.base700;
    }
    return SketchDesignTokens.base500;
  }

  @override
  Widget build(BuildContext context) {
    return SketchInput(
      controller: _effectiveController,
      hint: widget.hint ?? '검색...',
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      autofocus: widget.autofocus,
      prefixIcon: Icon(
        widget.searchIcon,
        color: _getIconColor(),
      ),
      suffixIcon: widget.showClearButton && _hasText
          ? IconButton(
              icon: Icon(Icons.clear, color: SketchDesignTokens.base500),
              onPressed: () {
                _effectiveController.clear();
                widget.onChanged?.call('');
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
          : null,
    );
  }
}
