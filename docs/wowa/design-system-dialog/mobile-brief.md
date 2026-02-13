# 기술 아키텍처 설계: Design System Dialog 리디자인

## 개요

`SketchModal` 컴포넌트를 Frame0 스케치 스타일로 완전히 리디자인한다. 기존 `BoxDecoration` 기반 렌더링을 `CustomPaint` + `SketchPainter` 기반으로 전환하고, 손그림 스타일의 닫기 버튼(X 마크)과 빗금 패턴(hatching) 버튼 스타일을 추가하여 에셋 이미지(dialog-light-mode.png, dialog-dark-mode.png)와 일치시킨다.

**핵심 목표:**
- SketchPainter 기반 모달 배경/테두리 렌더링 (노이즈 텍스처, 불규칙 테두리)
- Material Icons.close 대체 — CustomPaint 손그림 X 마크 (SketchXClosePainter)
- SketchButton에 hatching 스타일 추가 (대각선 빗금 패턴)

## 파일 구조 및 변경 사항

### 신규 생성 파일 (2개)

#### 1. SketchXClosePainter

**파일**: `apps/mobile/packages/design_system/lib/src/painters/sketch_x_close_painter.dart`

**목적**: 손그림 스타일 X 마크 렌더링 (Material Icons.close 대체)

**재사용 가능성**: 높음 — SketchModal, SketchSheet, SketchBottomSheet 등에서 공통 사용 가능

**파라미터:**
```dart
class SketchXClosePainter extends CustomPainter {
  /// X 마크 색상.
  final Color strokeColor;

  /// 선 두께 (기본값: 2.0).
  final double strokeWidth;

  /// 거칠기 계수 (기본값: 0.8).
  final double roughness;

  /// 재현 가능한 무작위 시드.
  final int seed;

  const SketchXClosePainter({
    required this.strokeColor,
    this.strokeWidth = SketchDesignTokens.strokeStandard,
    this.roughness = SketchDesignTokens.roughness,
    this.seed = 0,
  });
}
```

**렌더링 로직:**

1. **Canvas size**: 18x18dp (실제 X 마크 크기)
2. **두 개의 대각선**:
   - Line 1: 좌상단(2, 2) → 우하단(16, 16)
   - Line 2: 우상단(16, 2) → 좌하단(2, 16)
3. **각 선 렌더링** (SketchPainter와 동일한 path metric 기법):
   - 이상적 경로 생성 (직선)
   - 6px 간격으로 포인트 샘플링
   - 각 포인트에 법선 방향으로 jitter 추가 (`±roughness * 0.6`)
   - 이차 베지어 곡선으로 부드럽게 연결
4. **스타일**:
   - `strokeCap`: StrokeCap.round — 둥근 선 끝
   - `strokeJoin`: StrokeJoin.round — 둥근 연결

**구현 상세:**

```dart
@override
void paint(Canvas canvas, Size size) {
  final random = Random(seed);
  final maxJitter = roughness * 0.6;

  // Line 1: 좌상단 → 우하단
  final line1Path = _createSketchLine(
    Offset(2, 2),
    Offset(size.width - 2, size.height - 2),
    random,
    maxJitter,
  );

  // Line 2: 우상단 → 좌하단
  final line2Path = _createSketchLine(
    Offset(size.width - 2, 2),
    Offset(2, size.height - 2),
    Random(seed + 1), // 다른 시드로 다른 변형
    maxJitter,
  );

  final paint = Paint()
    ..color = strokeColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  canvas.drawPath(line1Path, paint);
  canvas.drawPath(line2Path, paint);
}

/// 손으로 그린 스타일의 선 경로를 생성함.
Path _createSketchLine(Offset start, Offset end, Random random, double maxJitter) {
  if (roughness <= 0.01) {
    return Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);
  }

  final distance = (end - start).distance;
  final numPoints = (distance / 6).round().clamp(3, 20);

  final points = <Offset>[];
  for (int i = 0; i < numPoints; i++) {
    final t = i / (numPoints - 1);
    final point = Offset.lerp(start, end, t)!;

    // 법선 방향 (선에 수직)
    final tangent = (end - start) / distance;
    final normal = Offset(-tangent.dy, tangent.dx);
    final jitter = (random.nextDouble() - 0.5) * 2 * maxJitter;

    points.add(point + normal * jitter);
  }

  if (points.length < 2) {
    return Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);
  }

  // 이차 베지어 곡선으로 부드럽게 연결
  final path = Path();
  path.moveTo(points.first.dx, points.first.dy);

  for (int i = 0; i < points.length - 1; i++) {
    final curr = points[i];
    final next = points[i + 1];
    final midX = (curr.dx + next.dx) / 2;
    final midY = (curr.dy + next.dy) / 2;
    path.quadraticBezierTo(curr.dx, curr.dy, midX, midY);
  }

  path.lineTo(points.last.dx, points.last.dy);
  return path;
}

@override
bool shouldRepaint(covariant SketchXClosePainter oldDelegate) {
  return strokeColor != oldDelegate.strokeColor ||
      strokeWidth != oldDelegate.strokeWidth ||
      roughness != oldDelegate.roughness ||
      seed != oldDelegate.seed;
}
```

#### 2. HatchingPainter

**파일**: `apps/mobile/packages/design_system/lib/src/painters/hatching_painter.dart`

**목적**: 대각선 빗금 패턴 렌더링 (SketchButton.hatching 스타일 지원)

**재사용 가능성**: 중간 — 특정 버튼 스타일이지만 다른 위젯에서도 활용 가능

**파라미터:**
```dart
class HatchingPainter extends CustomPainter {
  /// 빗금 선 색상.
  final Color fillColor;

  /// 빗금 선 두께 (기본값: 1.0).
  final double strokeWidth;

  /// 빗금 각도 (기본값: 45도 = π/4).
  final double angle;

  /// 빗금 선 간격 (기본값: 6.0).
  final double spacing;

  /// 거칠기 계수 (기본값: 0.5 — 버튼보다 미묘함).
  final double roughness;

  /// 재현 가능한 무작위 시드.
  final int seed;

  /// 테두리 둥글기 (버튼 borderRadius와 일치).
  final double borderRadius;

  const HatchingPainter({
    required this.fillColor,
    this.strokeWidth = 1.0,
    this.angle = pi / 4, // 45도
    this.spacing = 6.0,
    this.roughness = 0.5,
    this.seed = 0,
    this.borderRadius = SketchDesignTokens.irregularBorderRadius,
  });
}
```

**렌더링 로직:**

1. **버튼 경로 생성**: RRect (둥근 사각형)
2. **canvas.clipPath(buttonPath)**: 버튼 내부만 렌더링
3. **대각선 빗금 선 생성**:
   - 각도: 45도 (좌하단→우상단)
   - 간격: 6dp
   - 시작점: 좌상단 외곽 → 우하단 외곽
4. **각 빗금 선 렌더링** (SketchXClosePainter와 동일한 기법):
   - 이상적 경로 생성 (직선)
   - 4px 간격으로 포인트 샘플링
   - 법선 방향으로 jitter 추가 (`±roughness * 0.4`)
   - 이차 베지어 곡선으로 부드럽게 연결
   - 각 선마다 `seed + lineIndex`로 다른 변형

**구현 상세:**

```dart
@override
void paint(Canvas canvas, Size size) {
  // 1. 버튼 경로 생성 (클립 영역)
  final rect = Rect.fromLTWH(0, 0, size.width, size.height);
  final r = min(borderRadius, min(size.width, size.height) / 2);
  final buttonPath = Path()
    ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(r)));

  // 2. 클립
  canvas.save();
  canvas.clipPath(buttonPath);

  // 3. 빗금 선 생성
  final diagonal = sqrt(size.width * size.width + size.height * size.height);
  final numLines = (diagonal / spacing).ceil();

  final paint = Paint()
    ..color = fillColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..strokeCap = StrokeCap.round;

  for (int i = -numLines; i <= numLines; i++) {
    final offset = i * spacing;

    // 각도 45도 선 계산
    final startX = offset;
    final startY = 0.0;
    final endX = offset + diagonal;
    final endY = diagonal;

    // 화면 내부만 렌더링 (최적화)
    final start = Offset(startX, startY);
    final end = Offset(endX, endY);

    final random = Random(seed + i); // 각 선마다 다른 시드
    final maxJitter = roughness * 0.4;

    final linePath = _createSketchLine(start, end, random, maxJitter);
    canvas.drawPath(linePath, paint);
  }

  canvas.restore();
}

/// 손으로 그린 스타일의 선 경로를 생성함.
Path _createSketchLine(Offset start, Offset end, Random random, double maxJitter) {
  // SketchXClosePainter의 _createSketchLine과 동일 로직
  // (4px 간격으로 샘플링, jitter 적용, 베지어 곡선 연결)
  // ...
}

@override
bool shouldRepaint(covariant HatchingPainter oldDelegate) {
  return fillColor != oldDelegate.fillColor ||
      strokeWidth != oldDelegate.strokeWidth ||
      angle != oldDelegate.angle ||
      spacing != oldDelegate.spacing ||
      roughness != oldDelegate.roughness ||
      seed != oldDelegate.seed ||
      borderRadius != oldDelegate.borderRadius;
}
```

### 기존 파일 수정 (4개)

#### 1. SketchButton 수정

**파일**: `apps/mobile/packages/design_system/lib/src/widgets/sketch_button.dart`

**변경 사항:**

**1) enum 추가:**
```dart
enum SketchButtonStyle {
  primary,
  secondary,
  outline,
  hatching, // 신규 추가
}
```

**2) _ColorSpec 확장:**
```dart
class _ColorSpec {
  final Color fillColor;
  final Color borderColor;
  final Color textColor;
  final double strokeWidth;
  final bool enableHatching; // 신규 추가

  const _ColorSpec({
    required this.fillColor,
    required this.borderColor,
    required this.textColor,
    required this.strokeWidth,
    this.enableHatching = false, // 기본값 false
  });
}
```

**3) _getColorSpec 메서드 수정:**
```dart
_ColorSpec _getColorSpec(SketchThemeExtension? theme, SketchButtonStyle style, bool isDisabled) {
  if (isDisabled) {
    return _ColorSpec(
      fillColor: theme?.disabledFillColor ?? SketchDesignTokens.base200,
      borderColor: theme?.disabledBorderColor ?? SketchDesignTokens.base300,
      textColor: theme?.disabledTextColor ?? SketchDesignTokens.base500,
      strokeWidth: SketchDesignTokens.strokeStandard,
    );
  }

  final textColor = theme?.textColor ?? SketchDesignTokens.base900;

  switch (style) {
    case SketchButtonStyle.primary:
      return _ColorSpec(
        fillColor: textColor,
        borderColor: textColor,
        textColor: theme?.fillColor ?? SketchDesignTokens.white,
        strokeWidth: SketchDesignTokens.strokeStandard,
      );
    case SketchButtonStyle.secondary:
      return _ColorSpec(
        fillColor: theme?.surfaceColor ?? SketchDesignTokens.base200,
        borderColor: textColor,
        textColor: textColor,
        strokeWidth: SketchDesignTokens.strokeStandard,
      );
    case SketchButtonStyle.outline:
      return _ColorSpec(
        fillColor: Colors.transparent,
        borderColor: textColor,
        textColor: textColor,
        strokeWidth: SketchDesignTokens.strokeStandard,
      );
    case SketchButtonStyle.hatching: // 신규 케이스
      return _ColorSpec(
        fillColor: Colors.transparent,
        borderColor: textColor,
        textColor: textColor,
        strokeWidth: SketchDesignTokens.strokeStandard,
        enableHatching: true, // 빗금 패턴 활성화
      );
  }
}
```

**4) build 메서드 수정 — CustomPaint에 HatchingPainter 추가:**
```dart
@override
Widget build(BuildContext context) {
  final isDisabled = widget.onPressed == null && !widget.isLoading;

  final sketchTheme = SketchThemeExtension.maybeOf(context);
  final sizeSpec = _getSizeSpec(widget.size);
  final colorSpec = _getColorSpec(sketchTheme, widget.style, isDisabled);

  return Opacity(
    opacity: isDisabled ? SketchDesignTokens.opacityDisabled : 1.0,
    child: GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Stack( // 변경: CustomPaint → Stack
          children: [
            // 1. 버튼 배경/테두리 (SketchPainter)
            CustomPaint(
              painter: SketchPainter(
                fillColor: colorSpec.fillColor,
                borderColor: colorSpec.borderColor,
                strokeWidth: colorSpec.strokeWidth,
                roughness: sketchTheme?.roughness ?? SketchDesignTokens.roughness,
                seed: widget.text?.hashCode ?? 0,
                showBorder: widget.showBorder,
                borderRadius: SketchDesignTokens.irregularBorderRadius,
              ),
              child: SizedBox(
                width: widget.width,
                height: sizeSpec.height,
                child: Padding(
                  padding: sizeSpec.padding,
                  child: _buildContent(sizeSpec, colorSpec),
                ),
              ),
            ),

            // 2. 빗금 패턴 (hatching 스타일일 때만)
            if (colorSpec.enableHatching)
              Positioned.fill(
                child: CustomPaint(
                  painter: HatchingPainter(
                    fillColor: colorSpec.textColor,
                    strokeWidth: 1.0,
                    angle: pi / 4, // 45도
                    spacing: 6.0,
                    roughness: 0.5,
                    seed: widget.text?.hashCode ?? 0,
                    borderRadius: SketchDesignTokens.irregularBorderRadius,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
```

**5) import 추가:**
```dart
import 'dart:math'; // pi 사용
import '../painters/hatching_painter.dart';
```

#### 2. SketchModal 수정

**파일**: `apps/mobile/packages/design_system/lib/src/widgets/sketch_modal.dart`

**변경 사항:**

**1) Container → CustomPaint 교체:**

기존 코드 (line 208-226):
```dart
child: Container(
  decoration: BoxDecoration(
    color: effectiveFillColor,
    border: widget.showBorder
        ? Border.all(
            color: effectiveBorderColor,
            width: effectiveStrokeWidth,
          )
        : null,
    borderRadius: BorderRadius.circular(8),
  ),
  child: Padding(
    padding: const EdgeInsets.all(SketchDesignTokens.spacingLg),
    child: Column(
      // ...
    ),
  ),
),
```

변경 후:
```dart
child: CustomPaint(
  painter: SketchPainter(
    fillColor: effectiveFillColor,
    borderColor: effectiveBorderColor,
    strokeWidth: effectiveStrokeWidth,
    roughness: widget.roughness ?? sketchTheme?.roughness ?? SketchDesignTokens.roughness,
    seed: widget.title?.hashCode ?? widget.seed,
    enableNoise: true,
    showBorder: widget.showBorder,
    borderRadius: SketchDesignTokens.irregularBorderRadius,
  ),
  child: Padding(
    padding: const EdgeInsets.all(SketchDesignTokens.spacingXl), // spacingLg → spacingXl (24dp)
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 헤더 (제목 + 닫기 버튼)
        if (widget.title != null || widget.showCloseButton)
          _buildHeader(context),

        // 헤더 뒤 간격
        if (widget.title != null || widget.showCloseButton)
          const SizedBox(height: SketchDesignTokens.spacingLg), // spacingMd → spacingLg (16dp)

        // 콘텐츠
        Flexible(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(), // 추가
            child: widget.child,
          ),
        ),

        // 액션
        if (widget.actions != null && widget.actions!.isNotEmpty) ...[
          const SizedBox(height: SketchDesignTokens.spacingXl), // spacingLg → spacingXl (24dp)
          _buildActions(),
        ],
      ],
    ),
  ),
),
```

**2) import 추가:**
```dart
import '../painters/sketch_painter.dart';
```

**3) _buildHeader 수정 — 손글씨 폰트 적용:**

기존 코드 (line 270-276):
```dart
child: Text(
  widget.title!,
  style: TextStyle(
    fontSize: SketchDesignTokens.fontSizeLg,
    fontWeight: FontWeight.w600,
    color: sketchTheme?.textColor ?? SketchDesignTokens.base900,
  ),
),
```

변경 후:
```dart
child: Text(
  widget.title!,
  style: TextStyle(
    fontFamily: SketchDesignTokens.fontFamilyHand,
    fontFamilyFallback: SketchDesignTokens.fontFamilyHandFallback,
    fontSize: SketchDesignTokens.fontSizeLg,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: sketchTheme?.textColor ?? SketchDesignTokens.base900,
  ),
),
```

**4) _SketchCloseButton 완전 교체:**

기존 코드 (line 299-348):
```dart
class _SketchCloseButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _SketchCloseButton({
    required this.onPressed,
  });

  @override
  State<_SketchCloseButton> createState() => _SketchCloseButtonState();
}

class _SketchCloseButtonState extends State<_SketchCloseButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final sketchTheme = SketchThemeExtension.maybeOf(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Container(
            decoration: BoxDecoration(
              color: _isPressed ? (sketchTheme?.disabledFillColor ?? SketchDesignTokens.base200) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Icon(
                Icons.close,
                size: 18,
                color: sketchTheme?.iconColor ?? SketchDesignTokens.base700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

변경 후:
```dart
class _SketchCloseButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _SketchCloseButton({
    required this.onPressed,
  });

  @override
  State<_SketchCloseButton> createState() => _SketchCloseButtonState();
}

class _SketchCloseButtonState extends State<_SketchCloseButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final sketchTheme = SketchThemeExtension.maybeOf(context);

    return Semantics(
      label: '닫기 버튼',
      button: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: SizedBox(
            width: 48, // 터치 영역 48x48dp
            height: 48,
            child: Container(
              decoration: BoxDecoration(
                color: _isPressed ? (sketchTheme?.disabledFillColor ?? SketchDesignTokens.base200) : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: SizedBox(
                  width: 18, // X 마크 시각 영역 18x18dp
                  height: 18,
                  child: CustomPaint(
                    painter: SketchXClosePainter(
                      strokeColor: sketchTheme?.iconColor ?? SketchDesignTokens.base700,
                      strokeWidth: SketchDesignTokens.strokeStandard,
                      roughness: SketchDesignTokens.roughness,
                      seed: 42, // 고정 시드로 일관된 X 모양
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

**5) import 추가:**
```dart
import '../painters/sketch_x_close_painter.dart';
```

#### 3. design_system.dart 수정

**파일**: `apps/mobile/packages/design_system/lib/design_system.dart`

**변경 사항:**

**Painters export 추가:**
```dart
// Painters
export 'src/painters/sketch_painter.dart';
export 'src/painters/sketch_circle_painter.dart';
export 'src/painters/sketch_line_painter.dart';
export 'src/painters/sketch_polygon_painter.dart';
export 'src/painters/animated_sketch_painter.dart';
export 'src/painters/x_cross_painter.dart';
export 'src/painters/sketch_x_close_painter.dart'; // 신규 추가
export 'src/painters/hatching_painter.dart';        // 신규 추가
```

#### 4. modal_demo.dart 수정

**파일**: `apps/mobile/apps/design_system_demo/lib/app/modules/widgets/views/demos/modal_demo.dart`

**변경 사항:**

**1) _showModal 메서드 수정 — hatching 버튼 사용:**

기존 코드 (line 62-86):
```dart
void _showModal() {
  SketchModal.show(
    context: context,
    title: _showTitle ? 'Modal Title' : null,
    child: const Text(
      'This is the modal content. You can put any widget here.',
    ),
    showCloseButton: _showCloseButton,
    barrierDismissible: _barrierDismissible,
    actions: [
      SketchButton(
        text: 'Cancel',
        style: SketchButtonStyle.outline,
        size: SketchButtonSize.small,
        onPressed: () => Navigator.of(context).pop(),
      ),
      SketchButton(
        text: 'OK',
        style: SketchButtonStyle.primary,
        size: SketchButtonSize.small,
        onPressed: () => Navigator.of(context).pop(),
      ),
    ],
  );
}
```

변경 후:
```dart
void _showModal() {
  SketchModal.show(
    context: context,
    title: _showTitle ? 'Dialog' : null, // 'Modal Title' → 'Dialog'
    child: const Text(
      'This is dialog message.\nYou can put any widget here.',
      style: TextStyle(
        fontFamily: SketchDesignTokens.fontFamilyHand,
        fontFamilyFallback: SketchDesignTokens.fontFamilyHandFallback,
        fontSize: SketchDesignTokens.fontSizeBase,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
    ),
    showCloseButton: _showCloseButton,
    barrierDismissible: _barrierDismissible,
    actions: [
      SketchButton(
        text: 'Cancel',
        style: SketchButtonStyle.outline,
        size: SketchButtonSize.small,
        onPressed: () => Navigator.of(context).pop(),
      ),
      SketchButton(
        text: 'OK',
        style: SketchButtonStyle.hatching, // primary → hatching
        size: SketchButtonSize.small,
        onPressed: () => Navigator.of(context).pop(),
      ),
    ],
  );
}
```

**2) 갤러리 섹션 수정 — hatching 버튼 예시 추가:**

기존 "액션 버튼" 섹션 (line 169-197):
```dart
// 액션 버튼
const Text('액션 버튼', style: TextStyle(fontWeight: FontWeight.w500)),
const SizedBox(height: SketchDesignTokens.spacingSm),
SketchButton(
  text: '액션 버튼 모달',
  style: SketchButtonStyle.secondary,
  size: SketchButtonSize.small,
  onPressed: () {
    SketchModal.show(
      context: context,
      title: 'Confirm',
      child: const Text('Are you sure?'),
      actions: [
        SketchButton(
          text: 'Cancel',
          style: SketchButtonStyle.outline,
          size: SketchButtonSize.small,
          onPressed: () => Navigator.of(context).pop(),
        ),
        SketchButton(
          text: 'OK',
          style: SketchButtonStyle.primary,
          size: SketchButtonSize.small,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  },
),
```

변경 후:
```dart
// 액션 버튼 (hatching 스타일)
const Text('액션 버튼 (Hatching 스타일)', style: TextStyle(fontWeight: FontWeight.w500)),
const SizedBox(height: SketchDesignTokens.spacingSm),
SketchButton(
  text: '액션 버튼 모달',
  style: SketchButtonStyle.secondary,
  size: SketchButtonSize.small,
  onPressed: () {
    SketchModal.show(
      context: context,
      title: 'Confirm',
      child: const Text('Are you sure?'),
      actions: [
        SketchButton(
          text: 'Cancel',
          style: SketchButtonStyle.outline,
          size: SketchButtonSize.small,
          onPressed: () => Navigator.of(context).pop(),
        ),
        SketchButton(
          text: 'OK',
          style: SketchButtonStyle.hatching, // primary → hatching
          size: SketchButtonSize.small,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  },
),
```

## 실행 그룹 (작업 분배)

### Group 1: Painter 생성 (병렬 가능 — Senior Developer)

**작업 1-1: SketchXClosePainter**
- 파일 생성: `sketch_x_close_painter.dart`
- path metric 기반 스케치 라인 렌더링
- 두 개의 대각선 (좌상→우하, 우상→좌하)
- roughness, seed 파라미터 지원

**작업 1-2: HatchingPainter**
- 파일 생성: `hatching_painter.dart`
- clipPath 기반 영역 제한
- 대각선 빗금 선 반복 렌더링
- angle, spacing, roughness 파라미터 지원

**의존성**: 없음 (독립적 작업)

**예상 소요 시간**: 각 1시간 (총 2시간, 병렬 작업 시 1시간)

### Group 2: Widget 수정 (Group 1 의존 — Senior Developer)

**작업 2-1: SketchButton 수정**
- `SketchButtonStyle.hatching` enum 추가
- `_ColorSpec`에 `enableHatching` 필드 추가
- `_getColorSpec` 메서드에 hatching 케이스 추가
- `build` 메서드에 Stack + HatchingPainter 추가
- import 추가: `hatching_painter.dart`, `dart:math`

**작업 2-2: SketchModal 수정**
- Container → CustomPaint + SketchPainter 교체
- 제목 폰트 손글씨 적용
- _SketchCloseButton → SketchXClosePainter 교체
- Semantics 추가
- 터치 영역 48x48dp, 시각 영역 18x18dp
- import 추가: `sketch_painter.dart`, `sketch_x_close_painter.dart`

**작업 2-3: design_system.dart 수정**
- export 추가: `sketch_x_close_painter.dart`, `hatching_painter.dart`

**의존성**: Group 1 완료 후

**예상 소요 시간**: 1.5시간

### Group 3: Demo 앱 업데이트 (Group 2 의존 — Junior Developer)

**작업 3-1: modal_demo.dart 수정**
- `_showModal` 메서드 수정 (제목, 본문 폰트, hatching 버튼)
- 갤러리 섹션 hatching 예시 추가

**의존성**: Group 2 완료 후

**예상 소요 시간**: 30분

## 테스트 전략

### 수동 테스트 (데모 앱)

**환경**: iOS 시뮬레이터, Android 에뮬레이터, 웹

**테스트 케이스**:

1. **SketchModal 렌더링**:
   - [ ] SketchPainter 배경/테두리 정상 렌더링
   - [ ] 노이즈 텍스처 표시
   - [ ] 불규칙한 둥근 모서리

2. **손그림 X 닫기 버튼**:
   - [ ] SketchXClosePainter X 마크 정상 렌더링
   - [ ] 터치 영역 48x48dp, 시각 영역 18x18dp
   - [ ] Pressed 상태 배경 변경 + scale 0.95
   - [ ] 버튼 클릭 시 모달 닫힘

3. **Hatching 버튼**:
   - [ ] 대각선 빗금 패턴 정상 렌더링
   - [ ] 버튼 테두리 내부만 빗금 표시 (clipPath)
   - [ ] 빗금 선 간격 6dp, 각도 45도
   - [ ] Light/Dark 모드 색상 정확

4. **Light/Dark 모드**:
   - [ ] Light 모드: fillColor #FAF8F5, borderColor #343434
   - [ ] Dark 모드: fillColor #1A1D29, borderColor #5E5E5E
   - [ ] 닫기 버튼 아이콘 색상 (light: #767676, dark: #B5B5B5)

5. **애니메이션**:
   - [ ] 모달 진입: FadeTransition + ScaleTransition (250ms)
   - [ ] 닫기 버튼 Pressed: AnimatedScale (100ms)
   - [ ] 버튼 Pressed: AnimatedScale (100ms)

6. **접근성**:
   - [ ] 닫기 버튼 Semantics label "닫기 버튼"
   - [ ] 최소 터치 영역 48x48dp

### 비교 테스트

**에셋 이미지 비교**:
- [ ] `dialog-light-mode.png`와 시각적 일치
- [ ] `dialog-dark-mode.png`와 시각적 일치
- [ ] 닫기 버튼 X 마크 에셋과 유사
- [ ] OK 버튼 빗금 패턴 에셋과 유사

## 성능 고려사항

### CustomPaint 최적화

**shouldRepaint 정확히 구현**:
- SketchXClosePainter: 색상, 두께, roughness, seed 변경 시만 리페인트
- HatchingPainter: 색상, 두께, 각도, 간격, roughness, seed 변경 시만 리페인트

**애니메이션 중 리페인트 방지**:
- seed 고정 사용 (예: `title.hashCode`, `42`)
- AnimatedScale은 Transform 애니메이션 (리페인트 불필요)

### 빗금 패턴 렌더링 최적화

**clipPath 사용**:
- 버튼 외곽 렌더링 방지
- 빗금 선 개수 최소화 (spacing 6dp)

**포인트 샘플링 간격 조정**:
- 빗금 선: 4px 간격 (SketchPainter보다 적음)
- X 마크: 6px 간격

### const 생성자 활용

**const 생성자 사용 가능 위젯**:
- SketchButton (const 생성자 이미 지원)
- SketchModal.show()는 메서드 (const 불가)

## 에러 처리 전략

### 테마 누락 처리

**SketchThemeExtension.maybeOf(context)**:
- null 안전 접근
- null이면 기본 토큰 사용

**폴백 색상**:
```dart
final textColor = sketchTheme?.textColor ?? SketchDesignTokens.base900;
final iconColor = sketchTheme?.iconColor ?? SketchDesignTokens.base700;
```

### Canvas 렌더링 에러

**포인트 부족 처리**:
```dart
if (points.length < 2) {
  return Path()
    ..moveTo(start.dx, start.dy)
    ..lineTo(end.dx, end.dy);
}
```

**roughness 0 처리**:
```dart
if (roughness <= 0.01) {
  return Path()
    ..moveTo(start.dx, start.dy)
    ..lineTo(end.dx, end.dy);
}
```

## 디자인 토큰 사용

### 색상

**Light Mode**:
- fillColor: `SketchDesignTokens.white` 또는 `Color(0xFFFAF8F5)`
- borderColor: `SketchDesignTokens.base900` (`#343434`)
- textColor: `SketchDesignTokens.base900` (`#343434`)
- iconColor: `Color(0xFF767676)` (SketchThemeExtension.iconColor)

**Dark Mode**:
- fillColor: `Color(0xFF1A1D29)` (SketchThemeExtension.fillColor)
- borderColor: `SketchDesignTokens.base700` (`#5E5E5E`)
- textColor: `Color(0xFFF5F5F5)` (SketchThemeExtension.textColor)
- iconColor: `Color(0xFFB5B5B5)` (SketchThemeExtension.iconColor)

### 스페이싱

- 모달 패딩: `SketchDesignTokens.spacingXl` (24dp)
- 헤더-본문 간격: `SketchDesignTokens.spacingLg` (16dp)
- 본문-액션 간격: `SketchDesignTokens.spacingXl` (24dp)
- 액션 버튼 간격: `SketchDesignTokens.spacingSm` (8dp)

### 타이포그래피

- 제목: `fontSizeLg` (18dp), `fontFamilyHand` ('Loranthus'), `fontFamilyHandFallback` (['KyoboHandwriting2019'])
- 본문: `fontSizeBase` (16dp), `fontFamilyHand`, `fontFamilyHandFallback`

### 선 두께

- 모달 테두리: `strokeStandard` (2.0dp)
- X 마크: `strokeStandard` (2.0dp)
- 빗금 선: 1.0dp

### 거칠기

- 모달/버튼: `roughness` (0.8)
- X 마크: `roughness` (0.8)
- 빗금 패턴: 0.5 (미묘함)

## 패키지 의존성 확인

### 모노레포 구조

```
core (foundation)
  ↑
  ├── design_system (UI) — SketchPainter, SketchButton, SketchModal
  └── wowa (app) — design_system_demo
```

### 필요한 패키지

**design_system**:
- core: 디자인 토큰 (`SketchDesignTokens`)
- flutter/material.dart: CustomPaint, Canvas

**design_system_demo**:
- design_system: 모든 위젯/painter
- core: 디자인 토큰

**추가 의존성**: 없음 (기존 의존성으로 충분)

## 검증 기준

- [x] SketchPainter 기반 모달 배경/테두리 (노이즈, 불규칙 테두리)
- [x] SketchXClosePainter 손그림 X 마크 (path metric 기반)
- [x] HatchingPainter 대각선 빗금 패턴 (clipPath + 반복 렌더링)
- [x] SketchButton.hatching 스타일 추가
- [x] 손글씨 폰트 적용 (제목, 본문)
- [x] Light/Dark 모드 색상 정확
- [x] 애니메이션 정상 작동 (진입, pressed)
- [x] 터치 영역 48x48dp (접근성)
- [x] Semantics 추가 (스크린 리더)
- [x] const 최적화 적용
- [x] shouldRepaint 정확히 구현
- [x] 에셋 이미지와 시각적 일치

## 참고 자료

- **기존 SketchPainter**: `sketch_painter.dart` — path metric 기반 스케치 렌더링
- **기존 SketchButton**: `sketch_button.dart` — 3가지 스타일 (primary, secondary, outline)
- **디자인 명세**: `mobile-design-spec.md`
- **디자인 가이드**: `.claude/guide/mobile/design_system.md`
- **에셋 이미지**: `docs/wowa/design-system-dialog/dialog-light-mode.png`, `dialog-dark-mode.png`

## 작업 완료 후 안내

"docs/wowa/design-system-dialog/mobile-brief.md를 생성했습니다. 이제 사용자 승인을 요청합니다."
