import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/painter_catalog_controller.dart';

/// 페인터 카탈로그 View
///
/// 페인터 목록을 표시하고 각 페인터 데모 화면으로 이동.
/// Frame0 스타일: 스케치 테두리 없는 깔끔한 리스트.
class PainterCatalogView extends GetView<PainterCatalogController> {
  const PainterCatalogView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// AppBar 빌드
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Painter Catalog'),
      centerTitle: true,
    );
  }

  /// Body 빌드
  Widget _buildBody() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: SketchDesignTokens.spacingLg,
        vertical: SketchDesignTokens.spacingSm,
      ),
      itemCount: controller.painters.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: SketchDesignTokens.base200,
      ),
      itemBuilder: (context, index) {
        final painter = controller.painters[index];
        return _buildPainterItem(painter);
      },
    );
  }

  /// 페인터 리스트 항목 빌드
  ///
  /// SketchCard 대신 간결한 리스트 스타일 사용.
  Widget _buildPainterItem(PainterInfo painter) {
    return InkWell(
      onTap: () => controller.navigateToPainterDemo(painter.name),
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
                    painter.name,
                    style: const TextStyle(
                      fontSize: SketchDesignTokens.fontSizeLg,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: SketchDesignTokens.spacingXs),
                  Text(
                    painter.description,
                    style: TextStyle(
                      fontSize: SketchDesignTokens.fontSizeSm,
                      color: SketchDesignTokens.base500,
                      height: 1.5,
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
