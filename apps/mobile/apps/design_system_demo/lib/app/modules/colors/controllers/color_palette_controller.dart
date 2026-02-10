import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:core/core.dart';

/// 컬러 팔레트 컨트롤러
///
/// 6개 컬러 팔레트 선택 및 색상 정보를 관리합니다.
class ColorPaletteController extends GetxController {
  /// 선택된 팔레트 이름 (반응형)
  final selectedPalette = 'pastel'.obs;

  /// 사용 가능한 팔레트 목록
  List<String> get availablePalettes => SketchColorPalettes.availablePalettes;

  /// 팔레트 이름-한글 라벨 맵
  final Map<String, String> paletteLabels = {
    'pastel': '파스텔',
    'vibrant': '생동감',
    'monochrome': '모노크롬',
    'earthy': '자연',
    'ocean': '바다',
    'sunset': '석양',
  };

  /// 현재 선택된 팔레트의 색상 맵
  Map<String, Color> get currentPaletteColors {
    return SketchColorPalettes.getPalette(selectedPalette.value);
  }

  /// 팔레트 선택
  ///
  /// [palette] 선택할 팔레트 이름
  void selectPalette(String palette) {
    if (!availablePalettes.contains(palette)) return;
    selectedPalette.value = palette;
  }

  /// Color를 HEX 코드 문자열로 변환
  ///
  /// [color] 변환할 Color 객체
  /// Returns: '#RRGGBB' 형식의 HEX 코드
  String colorToHex(Color color) {
    final r = ((color.r * 255.0).round().clamp(0, 255))
        .toRadixString(16)
        .padLeft(2, '0');
    final g = ((color.g * 255.0).round().clamp(0, 255))
        .toRadixString(16)
        .padLeft(2, '0');
    final b = ((color.b * 255.0).round().clamp(0, 255))
        .toRadixString(16)
        .padLeft(2, '0');
    return '#${r.toUpperCase()}${g.toUpperCase()}${b.toUpperCase()}';
  }
}
