# User Story: design-system-nav-bar

## SketchBottomNavigationBar 스케치 스타일 테두리 적용

### 배경

현재 `SketchBottomNavigationBar`는 `BoxDecoration`의 단순 직선 `BorderSide`를 사용하여 테두리를 그리고 있음. 이는 디자인 시스템의 "Frame0 스케치 스타일" 컨셉과 맞지 않음. `SketchInput` 등 다른 위젯은 이미 `SketchPainter`를 사용하여 손그림 느낌의 테두리를 구현하고 있으므로, BottomNavigationBar도 동일한 스케치 스타일로 통일해야 함.

### 사용자 스토리

**AS A** 앱 사용자
**I WANT** 하단 네비게이션 바가 손으로 그린 스케치 스타일의 테두리와 질감을 가지길
**SO THAT** 앱 전체에서 일관된 Frame0 스케치 미학을 경험할 수 있다

### 수용 기준

1. **스케치 테두리 적용**: `SketchBottomNavigationBar`가 `SketchPainter` 기반의 손그림 스타일 둥근 사각형 테두리를 사용함
2. **노이즈 텍스처**: 종이 같은 질감의 노이즈 텍스처가 배경에 적용됨
3. **라이트/다크 모드 지원**: 테마에 따라 테두리 색상과 배경색이 적절히 변경됨 (img_28: 라이트, img_29: 다크)
4. **기존 기능 유지**: 항목 선택, 배지, 라벨 표시 모드 등 기존 기능이 동일하게 동작함
5. **오버플로 해결**: 현재 발생하는 "BOTTOM OVERFLOWED BY 2.0 PIXELS" 에러가 해결됨
6. **데모 앱 확인**: `design_system_demo` 앱에서 변경된 디자인을 확인할 수 있음

### 참조 디자인

- **현재 디자인**: `prompt/archives/img_30.png` - 평평한 직선 테두리, 오버플로 에러
- **목표 스타일**: `prompt/archives/img_28.png` (라이트), `prompt/archives/img_29.png` (다크) - 손그림 둥근 사각형 테두리 + 노이즈 텍스처

### 대상 파일

- 위젯: `apps/mobile/packages/design_system/lib/src/widgets/sketch_bottom_navigation_bar.dart`
- 데모: `apps/mobile/apps/design_system_demo/lib/app/modules/widgets/views/demos/bottom_nav_bar_demo.dart`

### 플랫폼

Mobile (Flutter design_system 패키지)
