import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../controllers/widget_catalog_controller.dart';

/// 위젯 카탈로그 화면
///
/// 13개 위젯 목록을 표시하고 각 위젯 데모로 이동할 수 있습니다.
/// Frame0 스타일: 스케치 테두리 없는 깔끔한 리스트.
class WidgetCatalogView extends GetView<WidgetCatalogController> {
  const WidgetCatalogView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(context),
    );
  }

  /// AppBar 빌드
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Widget Catalog'),
      centerTitle: true,
    );
  }

  /// Body 빌드
  Widget _buildBody(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: SketchDesignTokens.spacingLg,
        vertical: SketchDesignTokens.spacingSm,
      ),
      itemCount: WidgetCatalogController.widgets.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: SketchDesignTokens.base200,
      ),
      itemBuilder: (context, index) {
        final item = WidgetCatalogController.widgets[index];
        return _buildWidgetItem(item);
      },
    );
  }

  /// 위젯 리스트 항목 빌드
  ///
  /// SketchCard 대신 간결한 ListTile 스타일 사용.
  Widget _buildWidgetItem(WidgetCatalogItem item) {
    return InkWell(
      onTap: () {
        controller.selectWidget(item.name);
        Get.toNamed(
          Routes.WIDGET_DEMO,
          arguments: item.name,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: SketchDesignTokens.spacingMd,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: SketchDesignTokens.fontSizeLg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: SketchDesignTokens.spacingXs),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: SketchDesignTokens.fontSizeSm,
                      color: SketchDesignTokens.base500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: SketchDesignTokens.base400,
            ),
          ],
        ),
      ),
    );
  }
}
