import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'demos/button_demo.dart';
import 'demos/card_demo.dart';
import 'demos/input_demo.dart';
import 'demos/modal_demo.dart';
import 'demos/icon_button_demo.dart';
import 'demos/chip_demo.dart';
import 'demos/progress_bar_demo.dart';
import 'demos/switch_demo.dart';
import 'demos/checkbox_demo.dart';
import 'demos/slider_demo.dart';
import 'demos/dropdown_demo.dart';
import 'demos/container_demo.dart';
import 'demos/radio_demo.dart';
import 'demos/social_login_button_demo.dart';
import 'demos/snackbar_demo.dart';
import 'demos/text_area_demo.dart';

/// 위젯 데모 화면
///
/// arguments로 받은 widgetName에 따라 해당 데모를 표시합니다.
class WidgetDemoView extends StatelessWidget {
  const WidgetDemoView({super.key});

  @override
  Widget build(BuildContext context) {
    final widgetName = Get.arguments as String? ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: Text(widgetName),
        centerTitle: true,
      ),
      body: _buildDemo(widgetName),
    );
  }

  /// 위젯 이름에 따라 해당 데모 빌드
  Widget _buildDemo(String name) {
    switch (name) {
      case 'SketchButton':
        return const ButtonDemo();
      case 'SketchCard':
        return const CardDemo();
      case 'SketchInput':
        return const InputDemo();
      case 'SketchModal':
        return const ModalDemo();
      case 'SketchIconButton':
        return const IconButtonDemo();
      case 'SketchChip':
        return const ChipDemo();
      case 'SketchProgressBar':
        return const ProgressBarDemo();
      case 'SketchSwitch':
        return const SwitchDemo();
      case 'SketchCheckbox':
        return const CheckboxDemo();
      case 'SketchSlider':
        return const SliderDemo();
      case 'SketchDropdown':
        return const DropdownDemo();
      case 'SketchRadio':
        return const RadioDemo();
      case 'SketchContainer':
        return const ContainerDemo();
      case 'SocialLoginButton':
        return const SocialLoginButtonDemo();
      case 'SketchSnackbar':
        return const SnackbarDemo();
      case 'SketchTextArea':
        return const TextAreaDemo();
      default:
        return Center(
          child: Text('Unknown widget: $name'),
        );
    }
  }
}
