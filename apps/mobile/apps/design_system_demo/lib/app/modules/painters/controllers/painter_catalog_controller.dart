import 'package:get/get.dart';

/// 페인터 카탈로그 컨트롤러
///
/// 페인터 목록 관리 및 데모 화면 네비게이션 담당
class PainterCatalogController extends GetxController {
  /// 페인터 목록
  final painters = <PainterInfo>[
    const PainterInfo(
      name: 'SketchPainter',
      description: '손으로 그린 스케치 스타일 UI 요소\n불규칙한 테두리와 노이즈 텍스처',
    ),
    const PainterInfo(
      name: 'SketchCirclePainter',
      description: '스케치 스타일 원과 타원\n흔들리는 가장자리를 가진 원형 도형',
    ),
    const PainterInfo(
      name: 'SketchLinePainter',
      description: '스케치 스타일 선과 화살표\n불규칙한 경로와 화살표 지원',
    ),
    const PainterInfo(
      name: 'SketchPolygonPainter',
      description: '손그림 스타일 다각형\n삼각형부터 다각형까지 다양한 도형',
    ),
    const PainterInfo(
      name: 'AnimatedSketchPainter',
      description: '애니메이션 스케치\n손으로 그리는 듯한 애니메이션 효과',
    ),
  ].obs;

  /// 페인터 데모 화면으로 이동
  ///
  /// [painterName] 페인터 이름
  void navigateToPainterDemo(String painterName) {
    Get.toNamed(
      '/painters/demo',
      arguments: painterName,
    );
  }
}

/// 페인터 정보 모델
class PainterInfo {
  /// 페인터 이름
  final String name;

  /// 페인터 설명
  final String description;

  const PainterInfo({
    required this.name,
    required this.description,
  });
}
