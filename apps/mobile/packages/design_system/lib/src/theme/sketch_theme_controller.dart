import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'sketch_theme_extension.dart';

/// 스케치 테마 상태를 관리하는 GetX controller.
///
/// 밝기 모드(light/dark)를 관리하고 반응형 테마 업데이트를 제공함.
/// 시스템 테마를 자동으로 감지하거나 수동으로 전환 가능함.
///
/// **main.dart에서 설정:**
/// ```dart
/// void main() {
///   // 테마 컨트롤러 초기화
///   Get.put(SketchThemeController());
///
///   runApp(MyApp());
/// }
/// ```
///
/// **MaterialApp에서 사용:**
/// ```dart
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     final themeController = Get.find<SketchThemeController>();
///
///     return Obx(() => MaterialApp(
///       theme: ThemeData(
///         brightness: Brightness.light,
///         extensions: [themeController.currentTheme],
///       ),
///       darkTheme: ThemeData(
///         brightness: Brightness.dark,
///         extensions: [SketchThemeExtension.dark()],
///       ),
///       themeMode: themeController.themeMode.value,
///       home: HomeScreen(),
///     ));
///   }
/// }
/// ```
///
/// **수동으로 테마 전환:**
/// ```dart
/// final controller = Get.find<SketchThemeController>();
/// controller.toggleBrightness();
/// ```
///
/// **특정 밝기 설정:**
/// ```dart
/// controller.setBrightness(Brightness.dark);
/// ```
///
/// **시스템 테마 따르기:**
/// ```dart
/// controller.setThemeMode(ThemeMode.system);
/// ```
class SketchThemeController extends GetxController {
  /// 현재 테마 모드 (system, light, dark).
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  /// 현재 밝기 (light 또는 dark).
  ///
  /// themeMode와 시스템 밝기로부터 파생됨.
  final Rx<Brightness> _brightness = Brightness.light.obs;

  /// 밝기에 따른 현재 스케치 테마를 가져옴.
  SketchThemeExtension get currentTheme {
    return _brightness.value == Brightness.light
        ? SketchThemeExtension.light()
        : SketchThemeExtension.dark();
  }

  /// 현재 밝기 값을 가져옴.
  Brightness get brightness => _brightness.value;

  /// 다크 모드가 현재 활성화되었는지 여부.
  bool get isDarkMode => _brightness.value == Brightness.dark;

  /// 라이트 모드가 현재 활성화되었는지 여부.
  bool get isLightMode => _brightness.value == Brightness.light;

  @override
  void onInit() {
    super.onInit();

    // 테마 모드 변경 감지
    ever(themeMode, (_) => _updateBrightness());

    // 밝기 초기화
    _updateBrightness();
  }

  /// 라이트 모드와 다크 모드 사이를 전환함.
  ///
  /// themeMode를 light 또는 dark로 설정함 (system 아님).
  void toggleBrightness() {
    if (_brightness.value == Brightness.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }

  /// 특정 밝기를 설정함.
  ///
  /// themeMode를 light 또는 dark로 설정함 (system 아님).
  void setBrightness(Brightness brightness) {
    if (brightness == Brightness.light) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }

  /// 테마 모드를 설정함 (system, light, dark).
  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
  }

  /// 테마 모드와 시스템 밝기를 기반으로 밝기를 업데이트함.
  void _updateBrightness() {
    if (themeMode.value == ThemeMode.light) {
      _brightness.value = Brightness.light;
    } else if (themeMode.value == ThemeMode.dark) {
      _brightness.value = Brightness.dark;
    } else {
      // ThemeMode.system - 플랫폼에서 가져옴
      _brightness.value = _getSystemBrightness();
    }
  }

  /// 시스템 밝기가 변경될 때 밝기를 업데이트함 (ThemeMode.system용).
  ///
  /// WidgetsBindingObserver.didChangePlatformBrightness()에서 호출함.
  void updateSystemBrightness() {
    if (themeMode.value == ThemeMode.system) {
      _updateBrightness();
    }
  }

  /// 플랫폼에서 시스템 밝기를 가져옴.
  Brightness _getSystemBrightness() {
    try {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness;
    } catch (e) {
      return Brightness.light; // 폴백
    }
  }
}

/// 시스템 밝기 변경을 관찰해야 하는 widget용 mixin.
///
/// **사용법:**
/// ```dart
/// class MyApp extends StatefulWidget with WidgetsBindingObserver {
///   @override
///   State<MyApp> createState() => _MyAppState();
/// }
///
/// class _MyAppState extends State<MyApp> with SketchThemeObserver {
///   @override
///   void initState() {
///     super.initState();
///     initThemeObserver();
///   }
///
///   @override
///   void dispose() {
///     disposeThemeObserver();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     // Widget 트리
///   }
/// }
/// ```
mixin SketchThemeObserver on State<StatefulWidget> implements WidgetsBindingObserver {
  /// 테마 옵저버를 초기화함.
  ///
  /// initState()에서 호출함.
  void initThemeObserver() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// 테마 옵저버를 해제함.
  ///
  /// dispose()에서 호출함.
  void disposeThemeObserver() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangePlatformBrightness() {
    // 테마 컨트롤러에 밝기 업데이트 알림
    try {
      Get.find<SketchThemeController>().updateSystemBrightness();
    } catch (e) {
      // 컨트롤러를 찾을 수 없으면 무시
    }
  }
}
