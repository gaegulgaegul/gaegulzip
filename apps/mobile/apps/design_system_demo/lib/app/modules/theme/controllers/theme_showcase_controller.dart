import 'package:get/get.dart';
import 'package:design_system/design_system.dart';

/// 테마 쇼케이스 컨트롤러
///
/// 6개 테마 프리셋 선택 및 미리보기를 관리합니다.
class ThemeShowcaseController extends GetxController {
  /// 선택된 프리셋 이름 (반응형)
  final selectedPreset = 'light'.obs;

  /// 사용 가능한 프리셋 목록
  final List<String> presets = [
    'light',
    'dark',
    'rough',
    'smooth',
    'ultraSmooth',
    'veryRough',
  ];

  /// 프리셋 이름-한글 라벨 맵
  final Map<String, String> presetLabels = {
    'light': '라이트',
    'dark': '다크',
    'rough': '거칠게',
    'smooth': '부드럽게',
    'ultraSmooth': '매우 부드럽게',
    'veryRough': '매우 거칠게',
  };

  /// 현재 선택된 프리셋의 SketchThemeExtension 인스턴스
  SketchThemeExtension get currentThemeExtension {
    switch (selectedPreset.value) {
      case 'light':
        return SketchThemeExtension.light();
      case 'dark':
        return SketchThemeExtension.dark();
      case 'rough':
        return SketchThemeExtension.rough();
      case 'smooth':
        return SketchThemeExtension.smooth();
      case 'ultraSmooth':
        return SketchThemeExtension.ultraSmooth();
      case 'veryRough':
        return SketchThemeExtension.veryRough();
      default:
        return SketchThemeExtension.light();
    }
  }

  /// 프리셋 선택
  ///
  /// [preset] 선택할 프리셋 이름
  void selectPreset(String preset) {
    selectedPreset.value = preset;
  }
}
