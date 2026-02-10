import 'package:flutter_test/flutter_test.dart';

import 'package:design_system/design_system.dart';

void main() {
  test('design system exports are available', () {
    // barrel export가 정상적으로 동작하는지 확인
    expect(SketchAvatarSize.md.size, 40);
  });
}
