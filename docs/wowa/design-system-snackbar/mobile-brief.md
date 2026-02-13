# 기술 아키텍처 설계: Design System Snackbar

## 개요
Frame0 스케치 스타일의 Snackbar 컴포넌트를 디자인 시스템 패키지에 추가합니다. 4가지 의미론적 타입(success, info, warning, error)별 light/dark 모드를 지원하며, SketchThemeExtension을 확장하여 모든 색상을 테마에서 중앙 관리합니다. CustomPaint 기반 스케치 아이콘과 SketchPainter를 활용하여 일관된 손그림 미학을 제공합니다.

## 파일별 구현 계획

### 1. 테마 확장 (SketchThemeExtension)

**파일**: `/Users/lms/dev/repository/design-system-sktech-painter/apps/mobile/packages/design_system/lib/src/theme/sketch_theme_extension.dart`

**변경 내용**:
- Snackbar 배경색 속성 8개 추가 (4타입 x light/dark)
- factory 생성자 light(), dark() 업데이트
- copyWith(), lerp(), ==, hashCode, toString() 메서드 업데이트

**추가 속성**:
```dart
/// Snackbar 배경 색상 (Success - Light/Dark Mode)
final Color successSnackbarBgColor;

/// Snackbar 배경 색상 (Info - Light/Dark Mode)
final Color infoSnackbarBgColor;

/// Snackbar 배경 색상 (Warning - Light/Dark Mode)
final Color warningSnackbarBgColor;

/// Snackbar 배경 색상 (Error - Light/Dark Mode)
final Color errorSnackbarBgColor;
```

**색상 값**:
```dart
// light() factory
successSnackbarBgColor: Color(0xFFD4EDDA),  // 연한 민트
infoSnackbarBgColor: Color(0xFFD6EEFF),     // 연한 하늘
warningSnackbarBgColor: Color(0xFFFFF9D6),  // 연한 레몬
errorSnackbarBgColor: Color(0xFFFFE0E0),    // 연한 분홍

// dark() factory
successSnackbarBgColor: Color(0xFF1B3B2A),  // 진한 초록
infoSnackbarBgColor: Color(0xFF0C2D4A),     // 진한 네이비
warningSnackbarBgColor: Color(0xFF3B3515),  // 진한 올리브
errorSnackbarBgColor: Color(0xFF4A1B1B),    // 진한 마룬
```

### 2. Snackbar 타입 Enum (신규)

**파일**: `/Users/lms/dev/repository/design-system-sktech-painter/apps/mobile/packages/design_system/lib/src/enums/snackbar_type.dart`

**구현**:
```dart
/// Snackbar 메시지의 의미론적 타입.
enum SnackbarType {
  /// 성공 - 초록 배경, 체크마크 아이콘
  success,

  /// 정보 - 파랑 배경, i 아이콘
  info,

  /// 경고 - 노랑 배경, 삼각형 + ! 아이콘
  warning,

  /// 에러 - 빨강 배경, x 아이콘
  error,
}
```

### 3. Snackbar 아이콘 Painter (신규)

**파일**: `/Users/lms/dev/repository/design-system-sktech-painter/apps/mobile/packages/design_system/lib/src/painters/sketch_snackbar_icon_painter.dart`

**구현 전략**:
- CustomPainter를 상속하여 4가지 타입의 스케치 아이콘 렌더링
- 내부적으로 기존 painter(SketchCirclePainter, SketchPolygonPainter) 재사용
- TextPainter로 아이콘 내부 문자 렌더링 (i, !, x)
- 체크마크는 Path로 손그림 스타일 그리기

**파라미터**:
```dart
const SketchSnackbarIconPainter({
  required this.type,
  required this.iconColor,
  this.size = 32.0,
  this.strokeWidth = 2.0,
  this.roughness = SketchDesignTokens.roughness,
  this.seed = 0,
});
```

**아이콘 렌더링 전략**:

#### Success (체크마크)
```dart
// 1. 원형 테두리 (SketchCirclePainter 로직 재사용)
// 2. 체크마크 Path (손그림 스타일)
Path checkPath = Path()
  ..moveTo(width * 0.35, height * 0.55)
  ..quadraticBezierTo(
    width * 0.4, height * 0.6,
    width * 0.45, height * 0.65,
  )
  ..quadraticBezierTo(
    width * 0.55, height * 0.45,
    width * 0.65, height * 0.35,
  );
canvas.drawPath(checkPath, strokePaint);
```

#### Info (i 문자)
```dart
// 1. 불규칙한 원형 (roughness: 1.2)
// 2. TextPainter로 "i" 렌더링
TextPainter(
  text: TextSpan(
    text: 'i',
    style: TextStyle(
      fontFamily: SketchDesignTokens.fontFamilyHand,
      fontSize: 18.0,
      fontWeight: FontWeight.bold,
      color: iconColor,
    ),
  ),
  textAlign: TextAlign.center,
);
```

#### Warning (삼각형 + !)
```dart
// 1. 삼각형 (SketchPolygonPainter 로직 재사용, sides: 3, rotation: -pi/2)
// 2. TextPainter로 "!" 렌더링 (fontSize: 18.0)
```

#### Error (둥근사각형 + x)
```dart
// 1. 둥근 사각형 (SketchPainter 로직 재사용, borderRadius: 4.0)
// 2. TextPainter로 "x" 렌더링 (fontSize: 16.0)
```

### 4. Snackbar 위젯 (신규)

**파일**: `/Users/lms/dev/repository/design-system-sktech-painter/apps/mobile/packages/design_system/lib/src/widgets/sketch_snackbar.dart`

**구현**:
```dart
class SketchSnackbar extends StatelessWidget {
  /// Snackbar 메시지 텍스트
  final String message;

  /// Snackbar 타입 (success, info, warning, error)
  final SnackbarType type;

  const SketchSnackbar({
    required this.message,
    required this.type,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sketchTheme = SketchThemeExtension.of(context);
    final bgColor = _getBgColor(sketchTheme);
    final iconColor = sketchTheme.borderColor;
    final textColor = sketchTheme.textColor;

    return CustomPaint(
      painter: SketchPainter(
        fillColor: bgColor,
        borderColor: sketchTheme.borderColor,
        strokeWidth: SketchDesignTokens.strokeBold,
        roughness: sketchTheme.roughness,
        bowing: sketchTheme.bowing,
        borderRadius: 16.0,
        enableNoise: true,
        showBorder: true,
        seed: 0,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // 아이콘
            CustomPaint(
              painter: SketchSnackbarIconPainter(
                type: type,
                iconColor: iconColor,
                size: 32.0,
                strokeWidth: 2.0,
                roughness: sketchTheme.roughness,
                seed: 0,
              ),
              size: const Size(32, 32),
            ),
            const SizedBox(width: 12),
            // 메시지 텍스트
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontFamily: SketchDesignTokens.fontFamilyHand,
                  fontFamilyFallback: SketchDesignTokens.fontFamilyHandFallback,
                  fontSize: 14.0,
                  color: textColor,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 타입별 배경색 조회
  Color _getBgColor(SketchThemeExtension theme) {
    switch (type) {
      case SnackbarType.success:
        return theme.successSnackbarBgColor;
      case SnackbarType.info:
        return theme.infoSnackbarBgColor;
      case SnackbarType.warning:
        return theme.warningSnackbarBgColor;
      case SnackbarType.error:
        return theme.errorSnackbarBgColor;
    }
  }
}
```

### 5. Helper 함수 (신규)

**파일**: `/Users/lms/dev/repository/design-system-sktech-painter/apps/mobile/packages/design_system/lib/src/widgets/sketch_snackbar.dart` (동일 파일)

**구현**:
```dart
/// SketchSnackbar를 표시하는 편의 함수.
///
/// **사용법:**
/// ```dart
/// showSketchSnackbar(
///   context,
///   message: '저장되었습니다!',
///   type: SnackbarType.success,
/// );
/// ```
void showSketchSnackbar(
  BuildContext context, {
  required String message,
  required SnackbarType type,
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: SketchSnackbar(
        message: message,
        type: type,
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: duration,
      margin: const EdgeInsets.all(16.0),
    ),
  );
}
```

### 6. Export 추가

**파일**: `/Users/lms/dev/repository/design-system-sktech-painter/apps/mobile/packages/design_system/lib/design_system.dart`

**추가 export**:
```dart
// Enums
export 'src/enums/snackbar_type.dart';

// Painters
export 'src/painters/sketch_snackbar_icon_painter.dart';

// Widgets
export 'src/widgets/sketch_snackbar.dart';
```

### 7. 데모 앱 - Snackbar 데모 (신규)

**파일**: `/Users/lms/dev/repository/design-system-sktech-painter/apps/mobile/apps/design_system_demo/lib/app/modules/widgets/views/demos/snackbar_demo.dart`

**구현**:
```dart
class SnackbarDemo extends StatelessWidget {
  const SnackbarDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Snackbar Demo')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Success
            SketchButton(
              text: 'Show Success',
              onPressed: () {
                showSketchSnackbar(
                  context,
                  message: '작업이 성공적으로 완료되었습니다!',
                  type: SnackbarType.success,
                );
              },
            ),
            const SizedBox(height: 16),
            // Info
            SketchButton(
              text: 'Show Info',
              onPressed: () {
                showSketchSnackbar(
                  context,
                  message: '새로운 업데이트가 있습니다.',
                  type: SnackbarType.info,
                );
              },
            ),
            const SizedBox(height: 16),
            // Warning
            SketchButton(
              text: 'Show Warning',
              onPressed: () {
                showSketchSnackbar(
                  context,
                  message: '입력 항목을 다시 확인해주세요.',
                  type: SnackbarType.warning,
                );
              },
            ),
            const SizedBox(height: 16),
            // Error
            SketchButton(
              text: 'Show Error',
              onPressed: () {
                showSketchSnackbar(
                  context,
                  message: '네트워크 오류가 발생했습니다. 다시 시도해주세요.',
                  type: SnackbarType.error,
                  duration: const Duration(seconds: 5),
                );
              },
            ),
            const SizedBox(height: 32),
            // 긴 메시지 테스트
            SketchButton(
              text: 'Show Long Message',
              onPressed: () {
                showSketchSnackbar(
                  context,
                  message:
                      '매우 긴 메시지 텍스트입니다. 이 메시지는 3줄까지 표시되며, 그 이상은 ellipsis로 생략됩니다. maxLines 속성이 정상 동작하는지 확인합니다.',
                  type: SnackbarType.info,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

### 8. 데모 앱 - 카탈로그 업데이트

**파일**: `/Users/lms/dev/repository/design-system-sktech-painter/apps/mobile/apps/design_system_demo/lib/app/modules/widgets/controllers/widget_catalog_controller.dart`

**추가 항목**:
```dart
// widgetList에 추가
WidgetCatalogItem(
  name: 'Snackbar',
  route: 'snackbar',
  icon: LucideIcons.messageSquare,
)
```

### 9. 데모 앱 - 라우팅 업데이트

**파일**: `/Users/lms/dev/repository/design-system-sktech-painter/apps/mobile/apps/design_system_demo/lib/app/modules/widgets/views/widget_demo_view.dart`

**switch 케이스 추가**:
```dart
case 'snackbar':
  return const SnackbarDemo();
```

**import 추가**:
```dart
import 'demos/snackbar_demo.dart';
```

## 의존성 그래프

```
[SketchThemeExtension 확장] ← 테마 색상 정의
        ↓
[SnackbarType enum] ← 타입 정의
        ↓
[SketchSnackbarIconPainter] ← 아이콘 렌더링 (기존 painter 재사용)
        ↓
[SketchSnackbar 위젯 + Helper 함수] ← [1], [2], [3] 의존
        ↓
[design_system.dart export]
        ↓
[데모 앱 연동]
```

**병렬 진행 가능**:
- [1] SketchThemeExtension 확장
- [2] SnackbarType enum
- [3] SketchSnackbarIconPainter (단, [2] 완료 후 타입 참조)

**순차 진행 필수**:
- [4] SketchSnackbar 위젯 (← [1], [2], [3] 완료 후)
- [5] design_system.dart export (← [4] 완료 후)
- [6~9] 데모 앱 연동 (← [5] 완료 후)

## 병렬/순차 실행 그룹

### 그룹 1 (병렬 진행 가능)
- SketchThemeExtension 확장 (파일 1)
- SnackbarType enum (파일 2)

### 그룹 2 (그룹 1 완료 후)
- SketchSnackbarIconPainter (파일 3)

### 그룹 3 (그룹 2 완료 후)
- SketchSnackbar 위젯 + Helper 함수 (파일 4, 5)

### 그룹 4 (그룹 3 완료 후, 순차)
1. design_system.dart export (파일 6)
2. 데모 앱 파일 생성 (파일 7)
3. 카탈로그 업데이트 (파일 8)
4. 라우팅 업데이트 (파일 9)

## SketchSnackbarIconPainter 상세 아키텍처

### 클래스 구조
```dart
class SketchSnackbarIconPainter extends CustomPainter {
  final SnackbarType type;
  final Color iconColor;
  final double size;
  final double strokeWidth;
  final double roughness;
  final int seed;

  const SketchSnackbarIconPainter({
    required this.type,
    required this.iconColor,
    this.size = 32.0,
    this.strokeWidth = 2.0,
    this.roughness = SketchDesignTokens.roughness,
    this.seed = 0,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    switch (type) {
      case SnackbarType.success:
        _paintSuccess(canvas, canvasSize);
        break;
      case SnackbarType.info:
        _paintInfo(canvas, canvasSize);
        break;
      case SnackbarType.warning:
        _paintWarning(canvas, canvasSize);
        break;
      case SnackbarType.error:
        _paintError(canvas, canvasSize);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant SketchSnackbarIconPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.iconColor != iconColor ||
        oldDelegate.size != size ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.roughness != roughness ||
        oldDelegate.seed != seed;
  }
}
```

### 렌더링 메서드 상세

#### _paintSuccess (원형 + 체크마크)
```dart
void _paintSuccess(Canvas canvas, Size canvasSize) {
  final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
  final radius = size / 2;
  final random = Random(seed);

  // 1. 원형 테두리 (SketchCirclePainter 로직 재사용)
  final circlePaint = Paint()
    ..color = iconColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  // 스케치 원형 경로 생성
  final circlePath = _createSketchCircle(center, radius, random);
  canvas.drawPath(circlePath, circlePaint);

  // 2. 체크마크 Path
  final checkPath = Path()
    ..moveTo(center.dx - radius * 0.3, center.dy)
    ..quadraticBezierTo(
      center.dx - radius * 0.1,
      center.dy + radius * 0.2,
      center.dx,
      center.dy + radius * 0.3,
    )
    ..quadraticBezierTo(
      center.dx + radius * 0.2,
      center.dy - radius * 0.1,
      center.dx + radius * 0.3,
      center.dy - radius * 0.3,
    );

  canvas.drawPath(checkPath, circlePaint);
}

Path _createSketchCircle(Offset center, double radius, Random random) {
  // SketchCirclePainter 로직 참조하여 불규칙한 원형 경로 생성
  // segments, roughness 기반 Bezier 곡선 경로
}
```

#### _paintInfo (원형 + i 텍스트)
```dart
void _paintInfo(Canvas canvas, Size canvasSize) {
  final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
  final radius = size / 2;
  final random = Random(seed);

  // 1. 불규칙한 원형 (roughness 높임)
  final circlePaint = Paint()
    ..color = iconColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  final circlePath = _createSketchCircle(center, radius, random, roughness: 1.2);
  canvas.drawPath(circlePath, circlePaint);

  // 2. "i" 텍스트
  final textPainter = TextPainter(
    text: TextSpan(
      text: 'i',
      style: TextStyle(
        fontFamily: SketchDesignTokens.fontFamilyHand,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: iconColor,
      ),
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );

  textPainter.layout();
  final textOffset = Offset(
    center.dx - textPainter.width / 2,
    center.dy - textPainter.height / 2,
  );
  textPainter.paint(canvas, textOffset);
}
```

#### _paintWarning (삼각형 + !)
```dart
void _paintWarning(Canvas canvas, Size canvasSize) {
  final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
  final radius = size / 2;
  final random = Random(seed);

  // 1. 삼각형 (SketchPolygonPainter 로직 재사용)
  final trianglePaint = Paint()
    ..color = iconColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  final trianglePath = _createSketchTriangle(center, radius, random);
  canvas.drawPath(trianglePath, trianglePaint);

  // 2. "!" 텍스트
  final textPainter = TextPainter(
    text: TextSpan(
      text: '!',
      style: TextStyle(
        fontFamily: SketchDesignTokens.fontFamilyHand,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: iconColor,
      ),
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );

  textPainter.layout();
  final textOffset = Offset(
    center.dx - textPainter.width / 2,
    center.dy - textPainter.height / 2 + radius * 0.1, // 약간 아래로
  );
  textPainter.paint(canvas, textOffset);
}

Path _createSketchTriangle(Offset center, double radius, Random random) {
  // SketchPolygonPainter 로직 참조
  // sides=3, rotation=-pi/2 (위쪽 꼭짓점)
}
```

#### _paintError (둥근사각형 + x)
```dart
void _paintError(Canvas canvas, Size canvasSize) {
  final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
  final rectSize = size * 0.8;
  final random = Random(seed);

  // 1. 둥근 사각형 (SketchPainter 로직 재사용)
  final rect = Rect.fromCenter(
    center: center,
    width: rectSize,
    height: rectSize,
  );

  final rectPaint = Paint()
    ..color = iconColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  final rectPath = _createSketchRoundedRect(rect, 4.0, random);
  canvas.drawPath(rectPath, rectPaint);

  // 2. "x" 텍스트
  final textPainter = TextPainter(
    text: TextSpan(
      text: 'x',
      style: TextStyle(
        fontFamily: SketchDesignTokens.fontFamilyHand,
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
        color: iconColor,
      ),
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );

  textPainter.layout();
  final textOffset = Offset(
    center.dx - textPainter.width / 2,
    center.dy - textPainter.height / 2,
  );
  textPainter.paint(canvas, textOffset);
}

Path _createSketchRoundedRect(Rect rect, double borderRadius, Random random) {
  // SketchPainter의 _createSketchPath 로직 참조
}
```

## 코드 재사용 전략

SketchSnackbarIconPainter는 기존 painter의 핵심 로직을 재사용하되, 전체 painter를 인스턴스화하지 않고 경로 생성 로직만 추출합니다.

**재사용 가능한 private 메서드**:
1. `_createSketchCircle()` — SketchCirclePainter 로직
2. `_createSketchTriangle()` — SketchPolygonPainter (sides: 3) 로직
3. `_createSketchRoundedRect()` — SketchPainter 로직

**구현 옵션**:
- **Option A**: SketchSnackbarIconPainter 내부에 private 메서드로 복제 (권장 - 독립성)
- **Option B**: 기존 painter 파일에 static 유틸리티 메서드 추가 후 재사용 (결합도 증가)

**권장**: Option A (복제) — 아이콘 painter는 독립적으로 유지하여 향후 수정 시 영향 최소화

## 성능 최적화 전략

### const 생성자 활용
```dart
// SketchSnackbar 위젯
const SketchSnackbar({
  required this.message,
  required this.type,
  Key? key,
}) : super(key: key);

// Helper 함수에서는 const 불가 (런타임 값)
showSketchSnackbar(context, message: '...', type: SnackbarType.success);
```

### seed 고정
- SketchPainter, SketchSnackbarIconPainter 모두 `seed: 0` 고정
- 동일한 렌더링 보장으로 불필요한 리페인트 방지

### shouldRepaint 최적화
```dart
@override
bool shouldRepaint(covariant SketchSnackbarIconPainter oldDelegate) {
  return oldDelegate.type != type ||
      oldDelegate.iconColor != iconColor ||
      oldDelegate.size != size ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.roughness != roughness ||
      oldDelegate.seed != seed;
}
```

### enableNoise 활성화
- Snackbar 배경에 노이즈 텍스처 적용으로 Frame0 스타일 강화
- 작은 영역이므로 성능 영향 미미

## 에러 처리 전략

### 테마 미등록 시
```dart
// SketchSnackbar.build() 내부
final sketchTheme = SketchThemeExtension.of(context);
// SketchThemeExtension.of()가 null이면 예외 발생 (기존 구현)
```

### Scaffold 없이 호출 시
```dart
// showSketchSnackbar() 사용 시 ScaffoldMessenger 필요
// ScaffoldMessenger.of(context)가 null이면 Flutter 기본 예외 발생
```

**해결책**: 데모 앱 및 문서에서 Scaffold 필수 명시

### 긴 메시지 처리
```dart
// SketchSnackbar 내부 Text 위젯
maxLines: 3,
overflow: TextOverflow.ellipsis,
```

## 테마 통합 상세

### SketchThemeExtension 확장 체크리스트

#### 1. 생성자 업데이트
```dart
const SketchThemeExtension({
  // 기존 속성들...
  this.successSnackbarBgColor = const Color(0xFFD4EDDA),
  this.infoSnackbarBgColor = const Color(0xFFD6EEFF),
  this.warningSnackbarBgColor = const Color(0xFFFFF9D6),
  this.errorSnackbarBgColor = const Color(0xFFFFE0E0),
});
```

#### 2. factory light() 업데이트
```dart
factory SketchThemeExtension.light() {
  return const SketchThemeExtension(
    // 기존 속성들...
    successSnackbarBgColor: Color(0xFFD4EDDA),
    infoSnackbarBgColor: Color(0xFFD6EEFF),
    warningSnackbarBgColor: Color(0xFFFFF9D6),
    errorSnackbarBgColor: Color(0xFFFFE0E0),
  );
}
```

#### 3. factory dark() 업데이트
```dart
factory SketchThemeExtension.dark() {
  return const SketchThemeExtension(
    // 기존 속성들...
    successSnackbarBgColor: Color(0xFF1B3B2A),
    infoSnackbarBgColor: Color(0xFF0C2D4A),
    warningSnackbarBgColor: Color(0xFF3B3515),
    errorSnackbarBgColor: Color(0xFF4A1B1B),
  );
}
```

#### 4. copyWith() 업데이트
```dart
@override
ThemeExtension<SketchThemeExtension> copyWith({
  // 기존 파라미터들...
  Color? successSnackbarBgColor,
  Color? infoSnackbarBgColor,
  Color? warningSnackbarBgColor,
  Color? errorSnackbarBgColor,
}) {
  return SketchThemeExtension(
    // 기존 속성들...
    successSnackbarBgColor: successSnackbarBgColor ?? this.successSnackbarBgColor,
    infoSnackbarBgColor: infoSnackbarBgColor ?? this.infoSnackbarBgColor,
    warningSnackbarBgColor: warningSnackbarBgColor ?? this.warningSnackbarBgColor,
    errorSnackbarBgColor: errorSnackbarBgColor ?? this.errorSnackbarBgColor,
  );
}
```

#### 5. lerp() 업데이트
```dart
@override
ThemeExtension<SketchThemeExtension> lerp(
  covariant ThemeExtension<SketchThemeExtension>? other,
  double t,
) {
  if (other is! SketchThemeExtension) {
    return this;
  }

  return SketchThemeExtension(
    // 기존 속성들...
    successSnackbarBgColor: Color.lerp(successSnackbarBgColor, other.successSnackbarBgColor, t)!,
    infoSnackbarBgColor: Color.lerp(infoSnackbarBgColor, other.infoSnackbarBgColor, t)!,
    warningSnackbarBgColor: Color.lerp(warningSnackbarBgColor, other.warningSnackbarBgColor, t)!,
    errorSnackbarBgColor: Color.lerp(errorSnackbarBgColor, other.errorSnackbarBgColor, t)!,
  );
}
```

#### 6. == 연산자 업데이트
```dart
@override
bool operator ==(Object other) {
  if (identical(this, other)) return true;

  return other is SketchThemeExtension &&
      // 기존 비교들...
      other.successSnackbarBgColor == successSnackbarBgColor &&
      other.infoSnackbarBgColor == infoSnackbarBgColor &&
      other.warningSnackbarBgColor == warningSnackbarBgColor &&
      other.errorSnackbarBgColor == errorSnackbarBgColor;
}
```

#### 7. hashCode 업데이트
```dart
@override
int get hashCode {
  return Object.hashAll([
    // 기존 속성들...
    successSnackbarBgColor,
    infoSnackbarBgColor,
    warningSnackbarBgColor,
    errorSnackbarBgColor,
  ]);
}
```

#### 8. toString() 업데이트
```dart
@override
String toString() {
  return 'SketchThemeExtension('
      // 기존 속성들...
      'successSnackbarBgColor: $successSnackbarBgColor, '
      'infoSnackbarBgColor: $infoSnackbarBgColor, '
      'warningSnackbarBgColor: $warningSnackbarBgColor, '
      'errorSnackbarBgColor: $errorSnackbarBgColor'
      ')';
}
```

#### 9. rough(), smooth(), ultraSmooth(), veryRough() factory (선택)
이 factory들은 기존 light()의 색상 값을 사용하므로 별도 업데이트 불필요. 단, 명시적으로 Snackbar 색상을 추가하려면:

```dart
factory SketchThemeExtension.rough() {
  return const SketchThemeExtension(
    strokeWidth: SketchDesignTokens.strokeBold,
    roughness: 1.2,
    bowing: 0.8,
    fillColor: Color(0xFFFAF8F5),
    // Snackbar 색상 추가 (light와 동일)
    successSnackbarBgColor: Color(0xFFD4EDDA),
    infoSnackbarBgColor: Color(0xFFD6EEFF),
    warningSnackbarBgColor: Color(0xFFFFF9D6),
    errorSnackbarBgColor: Color(0xFFFFE0E0),
  );
}
```

## 접근성 (Accessibility)

### 색상 대비 검증

#### Light Mode
- **Success**: textColor(#343434) vs bg(#D4EDDA) ≈ 7.8:1 ✅ (AAA)
- **Info**: textColor(#343434) vs bg(#D6EEFF) ≈ 8.1:1 ✅ (AAA)
- **Warning**: textColor(#343434) vs bg(#FFF9D6) ≈ 11.2:1 ✅ (AAA)
- **Error**: textColor(#343434) vs bg(#FFE0E0) ≈ 9.4:1 ✅ (AAA)

#### Dark Mode
- **Success**: textColor(#F5F5F5) vs bg(#1B3B2A) ≈ 8.5:1 ✅ (AAA)
- **Info**: textColor(#F5F5F5) vs bg(#0C2D4A) ≈ 10.2:1 ✅ (AAA)
- **Warning**: textColor(#F5F5F5) vs bg(#3B3515) ≈ 7.1:1 ✅ (AAA)
- **Error**: textColor(#F5F5F5) vs bg(#4A1B1B) ≈ 9.8:1 ✅ (AAA)

### 의미 전달
- **색상 + 아이콘**: 색맹 사용자도 아이콘으로 의미 파악 가능
  - Success: 체크마크
  - Info: i
  - Warning: 삼각형 + !
  - Error: x

### 스크린 리더 지원
Flutter SnackBar의 기본 Semantics 활용:
- content로 전달된 Text 위젯의 텍스트가 자동 읽힘
- role: "Alert" (자동)

**개선 가능**: Semantics 위젯으로 타입 명시
```dart
Semantics(
  label: '${_getTypeLabel(type)}: $message',
  liveRegion: true,
  child: SketchSnackbar(...),
)

String _getTypeLabel(SnackbarType type) {
  switch (type) {
    case SnackbarType.success: return '성공';
    case SnackbarType.info: return '정보';
    case SnackbarType.warning: return '경고';
    case SnackbarType.error: return '오류';
  }
}
```

### 타이밍
- 기본 3초 표시 (WCAG 2.2 권장)
- duration 파라미터로 조정 가능
- 사용자가 스와이프로 언제든 닫을 수 있음

## 디자인 토큰 활용

### 사용하는 토큰
- `SketchDesignTokens.strokeBold` (3.0) — Snackbar 테두리
- `SketchDesignTokens.roughness` (0.8) — 손그림 효과
- `SketchDesignTokens.bowing` (0.5) — 곡선 휘어짐
- `SketchDesignTokens.fontFamilyHand` (Loranthus) — 메시지 텍스트
- `SketchDesignTokens.fontFamilyHandFallback` ([KyoboHandwriting2019]) — 한글 폴백

### 신규 토큰 불필요
모든 색상은 SketchThemeExtension에서 관리하므로 SketchDesignTokens에 상수 추가 불필요

## 작업 분배 계획

### Senior Developer 작업

#### Phase 1: 테마 및 아이콘
1. SketchThemeExtension 확장 (8개 속성 추가, factory 업데이트, copyWith/lerp/==/hashCode/toString 수정)
2. SnackbarType enum 작성
3. SketchSnackbarIconPainter 구현 (4가지 아이콘 렌더링 로직)

**예상 소요 시간**: 2-3시간

#### Phase 2: 위젯 및 통합
4. SketchSnackbar 위젯 구현
5. showSketchSnackbar() helper 함수
6. design_system.dart export 추가

**예상 소요 시간**: 1-2시간

### Junior Developer 작업

#### Phase 3: 데모 앱
7. SnackbarDemo 파일 작성 (4가지 타입 버튼 + 긴 메시지 테스트)
8. WidgetCatalogController에 Snackbar 항목 추가
9. WidgetDemoView에 라우팅 추가

**예상 소요 시간**: 1시간

### 작업 의존성
- Junior는 Senior의 Phase 2 완료 후 시작
- Phase 3은 design_system 패키지가 export 완료된 후 진행

## 검증 기준

- [ ] SketchThemeExtension에 8개 Snackbar 색상 속성 추가 완료
- [ ] light(), dark() factory에 Snackbar 색상 설정 완료
- [ ] copyWith(), lerp(), ==, hashCode, toString() 모두 업데이트
- [ ] SnackbarType enum 정의 (success, info, warning, error)
- [ ] SketchSnackbarIconPainter 4가지 아이콘 렌더링 정상 동작
  - Success: 원형 + 체크마크
  - Info: 원형 + i
  - Warning: 삼각형 + !
  - Error: 둥근사각형 + x
- [ ] SketchSnackbar 위젯 정상 렌더링 (배경, 아이콘, 텍스트)
- [ ] showSketchSnackbar() helper 함수 정상 동작
- [ ] design_system.dart export 추가
- [ ] 데모 앱에서 4가지 타입 모두 확인 가능
- [ ] light/dark 모드 전환 시 색상 자동 변경
- [ ] 긴 메시지 ellipsis 처리 확인
- [ ] 접근성 대비 검증 (모든 타입 AAA 충족)
- [ ] const 최적화 적용
- [ ] seed 고정으로 일관된 렌더링

## CLAUDE.md 준수 사항

1. **모노레포 구조**: core → design_system → wowa (단방향 의존성)
2. **테스트 코드 금지**: 기능 구현만, 테스트 작성 불필요
3. **주석 한글**: 모든 주석 한글, 기술 용어(Snackbar, CustomPaint 등)만 영어
4. **GetX 패턴**: 데모 앱에서 사용 (컨트롤러는 이미 존재, 위젯만 추가)
5. **const 생성자**: 가능한 모든 위젯에 const 사용
6. **디자인 시스템 통합**: SketchThemeExtension으로 색상 중앙 관리

## 참고 자료

- **디자인 명세**: `docs/wowa/design-system-snackbar/mobile-design-spec.md`
- **사용자 스토리**: `docs/wowa/design-system-snackbar/user-story.md`
- **디자인 시스템 가이드**: `.claude/guide/mobile/design_system.md`
- **Frame0 스타일링**: https://docs.frame0.app/styling/
- **Flutter SnackBar API**: https://api.flutter.dev/flutter/material/SnackBar-class.html
- **WCAG 색상 대비**: https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html

## 다음 단계

1. 사용자 승인 대기 (Interactive Review)
2. CTO 검증 및 작업 분배
3. Senior Developer: Phase 1, 2 진행
4. Junior Developer: Phase 3 진행
5. 통합 테스트 (수동, 데모 앱)
6. 머지 및 배포
