# 기술 아키텍처 설계: SketchCheckbox 스케치 스타일 적용

## 개요

SketchCheckbox 위젯의 테두리와 체크마크를 `SketchPainter` 기반 손그림(스케치) 스타일로 개선합니다. 기존 `Container` + `Border.all()` 직선 테두리를 `CustomPaint` + `SketchPainter`의 불규칙한 스케치 테두리로 교체하고, 체크마크에 roughness 기반 jitter를 적용하여 SketchButton과 일관된 Frame0 스타일을 달성합니다.

## 핵심 변경 사항

### 1. 테두리: Container + BoxDecoration → CustomPaint + SketchPainter

**현재 구조** (`sketch_checkbox.dart` line 217-228):
```dart
Container(
  decoration: BoxDecoration(
    color: backgroundColor,         // 체크 시 activeColor로 채움
    border: Border.all(
      color: borderColor,
      width: effectiveStrokeWidth,
    ),
    borderRadius: BorderRadius.circular(4),
  ),
)
```

**새로운 구조**:
```dart
CustomPaint(
  painter: SketchPainter(
    fillColor: Colors.transparent,   // 에셋 이미지처럼 배경 없음
    borderColor: borderColor,        // 라이트=검정, 다크=흰색
    strokeWidth: effectiveStrokeWidth,
    roughness: effectiveRoughness,
    seed: widget.seed,
    showBorder: widget.showBorder,
    borderRadius: 4,
  ),
  child: SizedBox(
    width: widget.size,
    height: widget.size,
  ),
)
```

**SketchPainter 동작** (`sketch_painter.dart` line 136-193):
- RRect 기본 경로 생성 → Path metrics로 포인트 샘플링 (6px마다)
- 각 포인트에 법선 방향 jitter 적용 (maxJitter = roughness * 0.6)
- quadraticBezierTo로 부드럽게 연결 → 손그림 느낌

### 2. 체크마크: 직선 drawLine → Path + roughness jitter

**현재 구조** (`sketch_checkbox.dart` line 302-315):
```dart
// 완벽한 직선
canvas.drawLine(p1Start, currentEnd, paint);
canvas.drawLine(p2Start, currentEnd, paint);
```

**새로운 구조**:
```dart
// 1. 각 선분을 여러 포인트로 샘플링 (6~8개)
final line1Points = _samplePoints(p1Start, p1End, numPoints: 6);
final line2Points = _samplePoints(p2Start, p2End, numPoints: 8);

// 2. Jitter 적용
final random = Random(seed);
final maxJitter = roughness * 0.3;  // 테두리보다 약간 작게

final jitteredLine1 = line1Points.map((p) {
  // 선분 방향 벡터
  final direction = (p1End - p1Start).normalize();
  // 법선 벡터 (선분에 수직)
  final normal = Offset(-direction.dy, direction.dx);
  // 법선 방향으로 jitter 추가
  final jitter = (random.nextDouble() - 0.5) * 2 * maxJitter;
  return p + normal * jitter;
}).toList();

// 3. Path로 부드럽게 연결
final path = Path();
path.moveTo(jitteredLine1.first.dx, jitteredLine1.first.dy);
for (int i = 0; i < jitteredLine1.length - 1; i++) {
  final curr = jitteredLine1[i];
  final next = jitteredLine1[i + 1];
  final midX = (curr.dx + next.dx) / 2;
  final midY = (curr.dy + next.dy) / 2;
  path.quadraticBezierTo(curr.dx, curr.dy, midX, midY);
}
// line2Points도 동일하게 처리 후 path에 추가

canvas.drawPath(path, paint);
```

### 3. 색상 로직 변경 (에셋 이미지 기반)

**현재 로직** (`sketch_checkbox.dart` line 202-212):
```dart
// 체크 시 배경 채움
final backgroundColor = widget.value == true
    ? effectiveActiveColor
    : widget.value == null && widget.tristate
        ? effectiveActiveColor
        : Colors.transparent;

final borderColor = widget.value == true ||
        (widget.value == null && widget.tristate)
    ? effectiveActiveColor
    : effectiveInactiveColor;
```

**새로운 로직**:
```dart
// 에셋 이미지 분석: checked 상태에서도 배경 없음, 테두리만 표시
final fillColor = Colors.transparent;

// 상태와 무관하게 textColor 사용 (라이트=검정, 다크=흰색)
final borderColor = isDisabled
    ? (sketchTheme?.disabledBorderColor ?? SketchDesignTokens.base300)
    : (sketchTheme?.textColor ?? SketchDesignTokens.base900);

// 체크마크도 textColor 사용 (에셋과 일치)
final checkColor = isDisabled
    ? (sketchTheme?.disabledTextColor ?? SketchDesignTokens.base500)
    : (sketchTheme?.textColor ?? SketchDesignTokens.base900);
```

## Widget 구조 (Stack 계층)

```dart
SketchCheckbox (StatefulWidget)
└── Opacity (비활성화 시 opacityDisabled)
    └── GestureDetector (onTap 핸들링)
        └── SizedBox (width: size, height: size)
            └── AnimatedBuilder (체크 애니메이션)
                └── Stack
                    ├── CustomPaint (테두리 — SketchPainter)
                    │   └── painter: SketchPainter(
                    │         fillColor: Colors.transparent,
                    │         borderColor: borderColor,
                    │         strokeWidth: effectiveStrokeWidth,
                    │         roughness: effectiveRoughness,
                    │         seed: widget.seed,
                    │         showBorder: widget.showBorder,
                    │         borderRadius: 4,
                    │       )
                    │
                    └── [조건부 렌더링]
                        ├── if (value == true)
                        │   └── Padding(EdgeInsets.all(size * 0.2))
                        │       └── CustomPaint (체크마크 — _SketchCheckMarkPainter)
                        │           └── painter: _SketchCheckMarkPainter(
                        │                 color: checkColor,
                        │                 strokeWidth: effectiveStrokeWidth,
                        │                 roughness: effectiveRoughness,
                        │                 seed: widget.seed + 1,
                        │                 progress: _checkAnimation.value,
                        │               )
                        │
                        └── else if (value == null && tristate)
                            └── Center (대시 — 기존 Container 유지)
                                └── Container(
                                      width: size * 0.4,
                                      height: effectiveStrokeWidth,
                                      color: checkColor,
                                    )
```

## 색상 매핑 (SketchThemeExtension 기반)

### Light Mode

#### Unchecked (미체크)
- **fillColor**: `Colors.transparent`
- **borderColor**: `sketchTheme.textColor` (기본값: `Color(0xFF343434)`, base900)
- **checkColor**: `sketchTheme.textColor` (표시 안 됨)

#### Checked (체크됨)
- **fillColor**: `Colors.transparent` (에셋: 배경 채우기 없음)
- **borderColor**: `sketchTheme.textColor` (기본값: `Color(0xFF343434)`, base900)
- **checkColor**: `sketchTheme.textColor` (에셋과 일치, 기본값: base900)

#### Tristate (일부 선택)
- **fillColor**: `Colors.transparent`
- **borderColor**: `sketchTheme.textColor`
- **dashColor**: `sketchTheme.textColor`

#### Disabled (비활성화)
- **fillColor**: `Colors.transparent`
- **borderColor**: `sketchTheme.disabledBorderColor` (기본값: `Color(0xFFDCDCDC)`, base300)
- **checkColor**: `sketchTheme.disabledTextColor` (기본값: `Color(0xFF8E8E8E)`, base500)
- **opacity**: `SketchDesignTokens.opacityDisabled` (0.5)

### Dark Mode

#### Unchecked (미체크)
- **fillColor**: `Colors.transparent`
- **borderColor**: `sketchTheme.textColor` (기본값: `Color(0xFFF5F5F5)`, textOnDark)
- **checkColor**: `sketchTheme.textColor`

#### Checked (체크됨)
- **fillColor**: `Colors.transparent`
- **borderColor**: `sketchTheme.textColor` (기본값: `Color(0xFFF5F5F5)`, textOnDark)
- **checkColor**: `sketchTheme.textColor` (에셋과 일치, 기본값: textOnDark)

#### Tristate (일부 선택)
- **fillColor**: `Colors.transparent`
- **borderColor**: `sketchTheme.textColor`
- **dashColor**: `sketchTheme.textColor`

#### Disabled (비활성화)
- **fillColor**: `Colors.transparent`
- **borderColor**: `sketchTheme.disabledBorderColor` (기본값: `Color(0xFF5E5E5E)`, outlinePrimaryDark)
- **checkColor**: `sketchTheme.disabledTextColor` (기본값: `Color(0xFF6E6E6E)`, textDisabledDark)
- **opacity**: `SketchDesignTokens.opacityDisabled` (0.5)

## 체크마크 Jitter 알고리즘

### 헬퍼 메서드: _samplePoints

```dart
/// 두 점 사이를 균등하게 샘플링
List<Offset> _samplePoints(Offset start, Offset end, int numPoints) {
  final points = <Offset>[];
  for (int i = 0; i <= numPoints; i++) {
    final t = i / numPoints;
    points.add(Offset.lerp(start, end, t)!);
  }
  return points;
}
```

### 헬퍼 메서드: _createSketchCheckPath

```dart
/// roughness 기반 스케치 스타일 체크마크 Path 생성
Path _createSketchCheckPath(
  Offset p1Start,
  Offset p1End,
  Offset p2Start,
  Offset p2End,
  double progress,
  double roughness,
  int seed,
) {
  final random = Random(seed);
  final maxJitter = roughness * 0.3;
  final path = Path();

  // 첫 번째 선 (짧은 선)
  if (progress > 0) {
    final currentProgress = (progress * 2).clamp(0.0, 1.0);
    final currentEnd = Offset.lerp(p1Start, p1End, currentProgress)!;

    // 샘플링
    final line1Points = _samplePoints(p1Start, currentEnd, 6);

    // 선분 방향 벡터
    final direction = (p1End - p1Start);
    final length = direction.distance;
    final normalized = direction / length;
    // 법선 벡터 (선분에 수직)
    final normal = Offset(-normalized.dy, normalized.dx);

    // Jitter 적용
    final jitteredPoints = line1Points.map((p) {
      final jitter = (random.nextDouble() - 0.5) * 2 * maxJitter;
      return p + normal * jitter;
    }).toList();

    // Path 생성
    if (jitteredPoints.isNotEmpty) {
      path.moveTo(jitteredPoints.first.dx, jitteredPoints.first.dy);
      for (int i = 0; i < jitteredPoints.length - 1; i++) {
        final curr = jitteredPoints[i];
        final next = jitteredPoints[i + 1];
        final midX = (curr.dx + next.dx) / 2;
        final midY = (curr.dy + next.dy) / 2;
        path.quadraticBezierTo(curr.dx, curr.dy, midX, midY);
      }
      // 마지막 포인트
      final last = jitteredPoints.last;
      path.lineTo(last.dx, last.dy);
    }
  }

  // 두 번째 선 (긴 선)
  if (progress > 0.5) {
    final currentProgress = ((progress - 0.5) * 2).clamp(0.0, 1.0);
    final currentEnd = Offset.lerp(p2Start, p2End, currentProgress)!;

    // 샘플링 (더 많은 포인트로 긴 선 표현)
    final line2Points = _samplePoints(p2Start, currentEnd, 8);

    // 선분 방향 벡터
    final direction = (p2End - p2Start);
    final length = direction.distance;
    final normalized = direction / length;
    final normal = Offset(-normalized.dy, normalized.dx);

    // Jitter 적용 (다른 seed로 다른 변형)
    final random2 = Random(seed + 100);
    final jitteredPoints = line2Points.map((p) {
      final jitter = (random2.nextDouble() - 0.5) * 2 * maxJitter;
      return p + normal * jitter;
    }).toList();

    // Path에 추가
    if (jitteredPoints.isNotEmpty) {
      path.moveTo(jitteredPoints.first.dx, jitteredPoints.first.dy);
      for (int i = 0; i < jitteredPoints.length - 1; i++) {
        final curr = jitteredPoints[i];
        final next = jitteredPoints[i + 1];
        final midX = (curr.dx + next.dx) / 2;
        final midY = (curr.dy + next.dy) / 2;
        path.quadraticBezierTo(curr.dx, curr.dy, midX, midY);
      }
      final last = jitteredPoints.last;
      path.lineTo(last.dx, last.dy);
    }
  }

  return path;
}
```

### _SketchCheckMarkPainter.paint() 수정

```dart
@override
void paint(Canvas canvas, Size size) {
  final paint = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..strokeCap = StrokeCap.round;

  // 좌표 계산
  final p1Start = Offset(size.width * 0.2, size.height * 0.5);
  final p1End = Offset(size.width * 0.4, size.height * 0.7);
  final p2Start = p1End;
  final p2End = Offset(size.width * 0.8, size.height * 0.2);

  // 스케치 스타일 Path 생성
  final path = _createSketchCheckPath(
    p1Start, p1End, p2Start, p2End,
    progress, roughness, seed
  );

  canvas.drawPath(path, paint);
}
```

## 스케치 파라미터

### Roughness (거칠기)

- **기본값**: `SketchDesignTokens.roughness` (0.8)
- **범위**: 0.0 (부드러움) ~ 1.0+ (거친 손그림)
- **역할**: 테두리와 체크마크의 흔들림 강도 제어
- **SketchPainter**: 샘플링된 포인트에 법선 방향 jitter 적용 (maxJitter = roughness * 0.6)
- **체크마크**: 각 선분 포인트에 jitter 적용 (maxJitter = roughness * 0.3, 테두리보다 약간 작게)

### Stroke Width (선 두께)

- **기본값**: `SketchDesignTokens.strokeStandard` (2.0)
- **용도**: 테두리와 체크마크 선 두께
- **SketchTheme 연동**: `sketchTheme?.strokeWidth`로 테마별 두께 조정 가능

### Seed (무작위 시드)

- **테두리 seed**: `widget.seed` (기본 0)
- **체크마크 seed**: `widget.seed + 1` (테두리와 다른 변형)
- **역할**: 동일한 시드 = 동일한 스케치 모양 (재현 가능성)
- **활용**: 각 체크박스마다 다른 시드 사용 시 각기 다른 손그림 느낌

### Border Radius (모서리 반경)

- **기본값**: `4.0` (작은 둥근 모서리)
- **SketchPainter**: RRect 경로 생성 후 roughness 적용
- **결과**: 둥근 모서리가 약간 불규칙하게 흔들림

## 애니메이션 유지

### 체크 애니메이션 (기존 유지)

**Duration**: `200ms`

**Curve**: `Curves.easeInOut`

**상태 전환**:
- `false → true`: `_animationController.forward()` (0.0 → 1.0)
- `true → false`: `_animationController.reverse()` (1.0 → 0.0)
- `false → null` (tristate): `_animationController.animateTo(0.5)` (0.0 → 0.5)
- `true → null` (tristate): `_animationController.animateTo(0.5)` (1.0 → 0.5)

**체크마크 그리기 단계**:
- `progress 0.0 ~ 0.5`: 첫 번째 선 그리기 (왼쪽→중간)
- `progress 0.5 ~ 1.0`: 두 번째 선 그리기 (중간→오른쪽)

**Painter 업데이트**: `AnimatedBuilder`로 `_checkAnimation` 리스닝, progress 변화 시 CustomPaint 리빌드

## API 호환성 (100% 유지)

### Public API (변경 없음)

```dart
const SketchCheckbox({
  super.key,
  required this.value,          // bool? — 체크 상태
  this.onChanged,               // ValueChanged<bool?>? — 상태 변경 콜백
  this.tristate = false,        // bool — 3가지 상태 지원
  this.activeColor,             // Color? — 체크됐을 때 색상 (deprecated 예정이지만 호환성 유지)
  this.inactiveColor,           // Color? — 체크 안됐을 때 색상 (deprecated 예정이지만 호환성 유지)
  this.checkColor,              // Color? — 체크마크 색상
  this.size = 24.0,             // double — 체크박스 크기
  this.strokeWidth,             // double? — 선 두께
  this.roughness,               // double? — 거칠기
  this.seed = 0,                // int — 무작위 시드
  this.showBorder = true,       // bool — 테두리 표시 여부
})
```

### 내부 구현 변경 사항

- **activeColor, inactiveColor 파라미터**: 기존 API 호환성을 위해 유지하지만, 내부적으로는 무시하고 `sketchTheme.textColor`로 통일
- **checkColor 파라미터**: 기존처럼 사용하되, null이면 `sketchTheme.textColor` 사용 (기본값 변경: `Colors.white` → `sketchTheme.textColor`)

## 성능 최적화 전략

### const 생성자 사용

- **정적 위젯**: const 생성자 사용 (SizedBox, EdgeInsets 등)
- **Padding**: `const EdgeInsets.all(size * 0.2)` → `EdgeInsets.all(size * 0.2)` (size는 동적이므로 const 불가)

### CustomPaint 최적화

- **shouldRepaint**: 색상, strokeWidth, roughness, seed, progress 변경 시에만 리빌드
- **Path 캐싱**: 동일한 파라미터면 동일한 Path 생성 (Random(seed) 기반)

### AnimatedBuilder 최소화

- **범위 제한**: Stack 전체가 아닌 필요한 부분만 AnimatedBuilder로 감싸기
- **현재 구조 유지**: 기존 코드가 이미 최적화되어 있음 (Stack 전체를 AnimatedBuilder로 감싸되, CustomPaint는 shouldRepaint로 제어)

## 구현 시 주의사항

### 1. SketchPainter import 확인

```dart
import '../painters/sketch_painter.dart';
```

### 2. Offset 벡터 연산 (extension 필요 시)

```dart
// Offset.distance와 나눗셈은 기본 제공
final distance = offset.distance;
final normalized = offset / distance;

// extension으로 normalize 추가 (필요 시)
extension OffsetExtension on Offset {
  Offset normalize() {
    final d = distance;
    return d == 0 ? Offset.zero : this / d;
  }
}
```

### 3. Random 시드 분리

- **테두리**: `widget.seed`
- **체크마크 첫 번째 선**: `widget.seed + 1`
- **체크마크 두 번째 선**: `widget.seed + 100`

각기 다른 시드로 각기 다른 변형 생성

### 4. 애니메이션 progress 계산

```dart
// 첫 번째 선: 0.0 ~ 0.5
final line1Progress = (progress * 2).clamp(0.0, 1.0);

// 두 번째 선: 0.5 ~ 1.0
final line2Progress = ((progress - 0.5) * 2).clamp(0.0, 1.0);
```

### 5. 체크마크 Padding 유지

```dart
Padding(
  padding: EdgeInsets.all(widget.size * 0.2),
  child: CustomPaint(
    painter: _SketchCheckMarkPainter(...),
    child: const SizedBox.expand(),
  ),
)
```

## 작업 분배 계획

### Senior Developer 작업

1. SketchCheckbox 위젯 수정 (`sketch_checkbox.dart`)
   - Container + BoxDecoration → CustomPaint + SketchPainter (테두리)
   - 색상 로직 변경 (fillColor=transparent, borderColor=textColor)
   - effectiveCheckColor 기본값 변경 (Colors.white → sketchTheme.textColor)

2. _SketchCheckMarkPainter 개선
   - roughness 파라미터 추가
   - _samplePoints() 헬퍼 메서드 구현
   - _createSketchCheckPath() 헬퍼 메서드 구현
   - paint() 메서드 수정 (drawLine → drawPath)

3. shouldRepaint 업데이트
   - roughness 파라미터 비교 추가

### Junior Developer 작업

1. 데모 앱 확인 (`checkbox_demo.dart`)
   - 기존 데모 코드로 충분하므로 추가 작업 불필요
   - 빌드 후 시각적 확인만 진행

### 작업 의존성

- Senior가 모든 구현 완료 후 Junior가 데모 확인
- 단일 파일 수정이므로 병렬 작업 불필요

## 검증 기준

- [ ] 테두리가 SketchPainter로 렌더링됨 (불규칙한 손그림 느낌)
- [ ] 체크마크가 roughness 기반 jitter로 렌더링됨 (미세한 곡선)
- [ ] Light 모드: 검정 테두리 + 체크마크, 투명 배경
- [ ] Dark 모드: 흰색 테두리 + 체크마크, 투명 배경
- [ ] Disabled 상태 색상 정확 (disabledBorderColor, disabledTextColor)
- [ ] 애니메이션 동작 유지 (200ms, 0.0~1.0)
- [ ] 기존 API 100% 호환 (value, onChanged, tristate, activeColor 등)
- [ ] const 최적화 적용 (가능한 부분)
- [ ] design_system_demo 앱에서 확인 가능

## 참고 자료

- **SketchPainter 구현**: `apps/mobile/packages/design_system/lib/src/painters/sketch_painter.dart`
- **SketchButton 예시**: `apps/mobile/packages/design_system/lib/src/widgets/sketch_button.dart`
- **SketchTheme**: `apps/mobile/packages/design_system/lib/src/theme/sketch_theme_extension.dart`
- **에셋 이미지**:
  - Light: `prompt/archives/checkbox-light-mode.png`
  - Dark: `prompt/archives/checkbox-dark-mode.png`
- **Plan**: `docs/wowa/design-system-checkbox/plan.md`
- **Design Spec**: `docs/wowa/design-system-checkbox/mobile-design-spec.md`
