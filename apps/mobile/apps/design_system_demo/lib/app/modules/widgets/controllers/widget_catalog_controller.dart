import 'package:get/get.dart';

/// 위젯 카탈로그 아이템
class WidgetCatalogItem {
  /// 위젯 이름
  final String name;

  /// 위젯 설명
  final String description;

  const WidgetCatalogItem({
    required this.name,
    required this.description,
  });
}

/// 위젯 카탈로그 컨트롤러
///
/// 13개의 위젯 목록과 선택 상태를 관리합니다.
class WidgetCatalogController extends GetxController {
  /// 위젯 목록
  static const List<WidgetCatalogItem> widgets = [
    WidgetCatalogItem(
      name: 'SketchButton',
      description: 'Primary, Secondary, Outline 스타일 버튼',
    ),
    WidgetCatalogItem(
      name: 'SketchCard',
      description: 'Header, Body, Footer 섹션을 가진 카드',
    ),
    WidgetCatalogItem(
      name: 'SketchInput',
      description: '텍스트 입력 필드 with 라벨, 에러, 아이콘',
    ),
    WidgetCatalogItem(
      name: 'SketchModal',
      description: '다이얼로그 모달',
    ),
    WidgetCatalogItem(
      name: 'SketchIconButton',
      description: '아이콘 전용 버튼 with 뱃지, 툴팁',
    ),
    WidgetCatalogItem(
      name: 'SketchChip',
      description: '선택 가능한 칩/태그',
    ),
    WidgetCatalogItem(
      name: 'SketchProgressBar',
      description: 'Linear/Circular 프로그레스 바',
    ),
    WidgetCatalogItem(
      name: 'SketchSwitch',
      description: 'ON/OFF 토글 스위치',
    ),
    WidgetCatalogItem(
      name: 'SketchCheckbox',
      description: '체크박스 with tristate 지원',
    ),
    WidgetCatalogItem(
      name: 'SketchRadio',
      description: '라디오 버튼 (단일 선택)',
    ),
    WidgetCatalogItem(
      name: 'SketchSlider',
      description: '드래그 슬라이더',
    ),
    WidgetCatalogItem(
      name: 'SketchDropdown',
      description: '드롭다운 선택 위젯',
    ),
    WidgetCatalogItem(
      name: 'SketchContainer',
      description: '스케치 스타일 컨테이너',
    ),
    WidgetCatalogItem(
      name: 'SocialLoginButton',
      description: '소셜 로그인 버튼 (4종)',
    ),
    WidgetCatalogItem(
      name: 'SketchSnackbar',
      description: 'Snackbar 알림 (4가지 타입)',
    ),
    WidgetCatalogItem(
      name: 'SketchTextArea',
      description: '여러 줄 텍스트 입력 (스케치 스타일)',
    ),
  ];

  /// 선택된 위젯 이름 (nullable)
  final selectedWidget = Rxn<String>();

  /// 위젯 선택
  ///
  /// [name] 위젯 이름
  void selectWidget(String name) {
    selectedWidget.value = name;
  }

  /// 선택 해제
  void clearSelection() {
    selectedWidget.value = null;
  }
}
