import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'demos/sketch_painter_demo.dart';
import 'demos/circle_painter_demo.dart';
import 'demos/line_painter_demo.dart';
import 'demos/polygon_painter_demo.dart';
import 'demos/animated_painter_demo.dart';

/// 페인터 데모 View
///
/// arguments로 받은 painterName에 따라 해당 데모 위젯 표시
class PainterDemoView extends StatelessWidget {
  const PainterDemoView({super.key});

  @override
  Widget build(BuildContext context) {
    final String painterName = Get.arguments as String? ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(painterName),
        centerTitle: true,
      ),
      body: _buildDemoWidget(painterName),
    );
  }

  /// painterName에 따라 적절한 데모 위젯 반환
  Widget _buildDemoWidget(String painterName) {
    switch (painterName) {
      case 'SketchPainter':
        return const SketchPainterDemo();
      case 'SketchCirclePainter':
        return const CirclePainterDemo();
      case 'SketchLinePainter':
        return const LinePainterDemo();
      case 'SketchPolygonPainter':
        return const PolygonPainterDemo();
      case 'AnimatedSketchPainter':
        return const AnimatedPainterDemo();
      default:
        return Center(
          child: Text('Unknown painter: $painterName'),
        );
    }
  }
}
