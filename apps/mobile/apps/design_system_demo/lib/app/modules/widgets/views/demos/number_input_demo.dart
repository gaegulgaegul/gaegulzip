import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// SketchNumberInput 데모
///
/// 기본 입력, 라벨 포함, 범위 설정, 소수점, 비활성 상태를 확인할 수 있습니다.
class NumberInputDemo extends StatefulWidget {
  const NumberInputDemo({super.key});

  @override
  State<NumberInputDemo> createState() => _NumberInputDemoState();
}

class _NumberInputDemoState extends State<NumberInputDemo> {
  double _basicValue = 0;
  double _labeledValue = 75;
  double _rangedValue = 5;
  double _decimalValue = 3.5;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SketchDesignTokens.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '변형 갤러리',
            style: TextStyle(
              fontSize: SketchDesignTokens.fontSizeLg,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: SketchDesignTokens.spacingLg),

          // 기본 입력
          const Text('기본 입력', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: SketchDesignTokens.spacingSm),
          SketchNumberInput(
            value: _basicValue,
            onChanged: (v) => setState(() => _basicValue = v),
          ),
          const SizedBox(height: SketchDesignTokens.spacingXl),

          // 라벨 + 접미사
          const Text('라벨 + 접미사', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: SketchDesignTokens.spacingSm),
          SketchNumberInput(
            label: '무게',
            value: _labeledValue,
            min: 0,
            max: 300,
            suffix: 'kg',
            onChanged: (v) => setState(() => _labeledValue = v),
          ),
          const SizedBox(height: SketchDesignTokens.spacingXl),

          // 범위 제한
          const Text('범위 제한 (1~10)', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: SketchDesignTokens.spacingSm),
          SketchNumberInput(
            label: '수량',
            value: _rangedValue,
            min: 1,
            max: 10,
            suffix: '개',
            onChanged: (v) => setState(() => _rangedValue = v),
          ),
          const SizedBox(height: SketchDesignTokens.spacingXl),

          // 소수점
          const Text('소수점 (step: 0.5)', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: SketchDesignTokens.spacingSm),
          SketchNumberInput(
            label: '거리',
            value: _decimalValue,
            step: 0.5,
            decimalPlaces: 1,
            suffix: 'km',
            onChanged: (v) => setState(() => _decimalValue = v),
          ),
          const SizedBox(height: SketchDesignTokens.spacingXl),

          // 버튼 없이
          const Text('버튼 없이', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: SketchDesignTokens.spacingSm),
          SketchNumberInput(
            label: '나이',
            value: 25,
            showButtons: false,
            onChanged: (_) {},
          ),
        ],
      ),
    );
  }
}
