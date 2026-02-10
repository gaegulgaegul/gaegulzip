import 'package:get/get.dart';

/// 디자인 토큰 섹션 타입
enum TokenSection {
  colors,
  typography,
  spacing,
  stroke,
  borderRadius,
  opacity,
  shadows,
  sketchEffects,
}

/// 디자인 토큰 컨트롤러
///
/// 디자인 토큰 섹션 선택 및 상태를 관리합니다.
class TokensController extends GetxController {
  /// 선택된 섹션 (반응형)
  final selectedSection = TokenSection.colors.obs;

  /// 스케치 효과 데모용 roughness 값 (반응형)
  final demoRoughness = 0.8.obs;

  /// 스케치 효과 데모용 bowing 값 (반응형)
  final demoBowing = 0.5.obs;

  /// 섹션 선택
  ///
  /// [section] 선택할 섹션
  void selectSection(TokenSection section) {
    selectedSection.value = section;
  }

  /// roughness 값 업데이트
  ///
  /// [value] 새로운 roughness 값 (0.0 - 2.0)
  void updateRoughness(double value) {
    demoRoughness.value = value;
  }

  /// bowing 값 업데이트
  ///
  /// [value] 새로운 bowing 값 (0.0 - 2.0)
  void updateBowing(double value) {
    demoBowing.value = value;
  }
}
