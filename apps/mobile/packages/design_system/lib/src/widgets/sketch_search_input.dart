import 'package:flutter/material.dart';

import 'sketch_input.dart';

/// 손으로 그린 스케치 스타일의 검색 입력 필드.
///
/// @deprecated [SketchInput]에 `mode: SketchInputMode.search`를 사용하세요.
/// ```dart
/// // 이전:
/// SketchSearchInput(hint: '검색', onChanged: (q) => search(q))
///
/// // 이후:
/// SketchInput(mode: SketchInputMode.search, hint: '검색', onChanged: (q) => search(q))
/// ```
@Deprecated('SketchInput(mode: SketchInputMode.search)를 사용하세요')
class SketchSearchInput extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SketchInput(
      mode: SketchInputMode.search,
      hint: hint,
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      prefixIcon: Icon(searchIcon),
      showClearButton: showClearButton,
      autofocus: autofocus,
    );
  }
}
