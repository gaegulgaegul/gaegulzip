# 기술 아키텍처 설계: SketchAvatar 스케치 스타일 적용

## 개요

SketchAvatar 위젯의 테두리를 `SketchCirclePainter`/`SketchPainter` 기반 손그림 스타일로 교체하고, 플레이스홀더를 간결한 사람 아이콘으로 변경하여 다른 디자인 시스템 컴포넌트(SketchButton, SketchContainer 등)와 시각적 일관성을 확보한다.

**핵심 전략**:
1. `Border.all()` → `CustomPaint` + `SketchCirclePainter` (원형) / `SketchPainter` (사각형)
2. `ClipOval`/`ClipRRect` → `ClipPath` + 스케치 경로 기반 클리핑
3. `SketchImagePlaceholder` (X-cross) → `Container + Icon(Icons.person)` (사람 아이콘만)
4. 이미지 URL/이니셜 hashCode 기반 일관된 seed 생성

## 위젯 트리 구조 변경

### 현재 구조 (Border.all 기반)

```
SketchAvatar
└── GestureDetector (onTap이 있는 경우만)
    └── Container (Border.all)
        └── ClipOval (circle) / ClipRRect (roundedSquare)
            └── 컨텐츠 (Image/Initials/Placeholder)
```

**문제점**:
- `Border.all()`로 완벽한 원/사각형 → 스케치 스타일 없음
- `ClipOval`/`ClipRRect`로 정확한 클리핑 → 스케치 경로와 불일치
- `SketchImagePlaceholder` X-cross 패턴 → 디자인 명세 불일치

### 변경 후 구조 (CustomPaint 기반)

```
SketchAvatar
└── GestureDetector (onTap이 있는 경우만)
    └── Stack
        ├── CustomPaint (스케치 테두리)
        │   └── SketchCirclePainter (circle)
        │       또는 SketchPainter (roundedSquare)
        │
        └── ClipPath (스케치 경로로 클리핑)
            └── 컨텐츠 (Image/Initials/Placeholder)
```

**개선점**:
- `CustomPaint`로 손그림 테두리 렌더링 → Frame0 스케치 미학
- `ClipPath`로 스케치 경로 기반 클리핑 → 테두리와 정확히 일치
- `Container + Icon(Icons.person)` → X-cross 제거, 간결한 플레이스홀더

## CustomPaint 통합 방식

### 원형 테두리 (SketchAvatarShape.circle)

```dart
CustomPaint(
  painter: SketchCirclePainter(
    fillColor: Colors.transparent, // 채우기 없음 (컨텐츠로 채움)
    borderColor: effectiveBorderColor,
    strokeWidth: effectiveStrokeWidth,
    roughness: 0.8, // Frame0 기본값
    seed: _generateSeed(), // 이미지URL/이니셜 기반
    segments: 16, // 부드러운 곡선
    enableNoise: false, // 테두리만 그리므로 불필요
  ),
  child: SizedBox(
    width: size.size,
    height: size.size,
  ),
)
```

**파라미터 설계**:
- `fillColor`: `Colors.transparent` — 컨텐츠(이미지/이니셜/플레이스홀더)가 채우기 역할
- `borderColor`: `borderColor` prop → 테마 `borderColor` → `SketchDesignTokens.base900` (라이트) / `base700` (다크)
- `strokeWidth`: `strokeWidth` prop → 크기별 기본값 (아래 표 참조)
- `roughness`: `0.8` 고정 — Frame0 기본값, 일관된 스케치 느낌
- `seed`: `_generateSeed()` — 이미지URL/이니셜 hashCode 기반 (재현 가능)
- `segments`: `16` 고정 — 원형 곡선의 부드러움과 성능 균형
- `enableNoise`: `false` — 테두리만 그리므로 노이즈 불필요

### 사각형 테두리 (SketchAvatarShape.roundedSquare)

```dart
CustomPaint(
  painter: SketchPainter(
    fillColor: Colors.transparent,
    borderColor: effectiveBorderColor,
    strokeWidth: effectiveStrokeWidth,
    roughness: 0.8,
    bowing: 0.5, // 직선 휘어짐
    seed: _generateSeed(),
    enableNoise: false,
    showBorder: true,
    borderRadius: 6.0, // 둥근 모서리
  ),
  child: SizedBox(
    width: size.size,
    height: size.size,
  ),
)
```

**파라미터 설계**:
- `bowing`: `0.5` 고정 — Frame0 기본값, 직선의 자연스러운 휘어짐
- `borderRadius`: `6.0` 고정 — 디자인 명세 참조
- 나머지는 원형과 동일

### showBorder: false 처리

```dart
if (showBorder) {
  // CustomPaint 렌더링
} else {
  // CustomPaint 없이 ClipPath만 사용
  // (테두리 없는 클리핑된 컨텐츠)
}
```

## 클리핑 전략

### ClipPath로 스케치 경로 클리핑

**문제점**: `SketchCirclePainter`/`SketchPainter`는 `CustomPainter`이므로 경로를 직접 추출할 수 없음.

**해결책**: `SketchCirclePainter`/`SketchPainter` 내부의 경로 생성 로직을 공유하는 헬퍼 메서드 추가.

```dart
// sketch_circle_painter.dart에 추가
/// 외부에서 ClipPath에 사용할 수 있도록 경로를 생성하는 정적 메서드.
static Path createClipPath({
  required Size size,
  required double roughness,
  required int seed,
  int segments = 16,
}) {
  final random = Random(seed);
  final center = Offset(size.width / 2, size.height / 2);
  final radiusX = size.width / 2;
  final radiusY = size.height / 2;

  // _createIrregularCircle 로직 재사용
  // (현재 private 메서드를 static으로 추출)
  return _createIrregularCircleStatic(center, radiusX, radiusY, random, roughness, segments);
}
```

```dart
// sketch_painter.dart에 추가
/// 외부에서 ClipPath에 사용할 수 있도록 경로를 생성하는 정적 메서드.
static Path createClipPath({
  required Size size,
  required double roughness,
  required int seed,
  required double borderRadius,
  double strokeWidth = 0,
}) {
  final random = Random(seed);
  final inset = strokeWidth / 2;
  final rect = Rect.fromLTWH(
    inset,
    inset,
    size.width - inset * 2,
    size.height - inset * 2,
  );
  final r = min(borderRadius, min(rect.width, rect.height) / 2);

  // _createSketchPath 로직 재사용
  return _createSketchPathStatic(rect, r, random, roughness);
}
```

### ClipPath 적용

```dart
Widget _buildClippedContent(BuildContext context, _SizeConfig config) {
  final clippingPath = shape == SketchAvatarShape.circle
      ? SketchCirclePainter.createClipPath(
          size: Size(size.size, size.size),
          roughness: 0.8,
          seed: _generateSeed(),
          segments: 16,
        )
      : SketchPainter.createClipPath(
          size: Size(size.size, size.size),
          roughness: 0.8,
          seed: _generateSeed(),
          borderRadius: 6.0,
          strokeWidth: effectiveStrokeWidth,
        );

  return ClipPath(
    clipper: _SketchClipper(clippingPath),
    child: _buildAvatarContent(context, config),
  );
}

/// ClipPath용 CustomClipper.
class _SketchClipper extends CustomClipper<Path> {
  final Path path;

  _SketchClipper(this.path);

  @override
  Path getClip(Size size) => path;

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
```

**대안: 기존 ClipOval/ClipRRect 유지**

만약 정확한 스케치 경로 클리핑이 복잡하다면, 기존 `ClipOval`/`ClipRRect`을 유지하고 테두리만 스케치 스타일로 변경할 수 있습니다. 이 경우 컨텐츠가 테두리 밖으로 약간 삐져나갈 수 있지만, roughness가 0.8 정도면 시각적으로 큰 문제는 없습니다.

**권장**: `ClipPath` 방식 — 테두리와 컨텐츠의 완벽한 일치, Frame0 스타일 충실도 높음

## seed 생성 로직

### 일관된 seed 생성

**목적**: 동일한 이미지 URL/이니셜을 가진 아바타는 항상 동일한 스케치 패턴을 렌더링해야 함.

```dart
/// 이미지 URL 또는 이니셜 기반 일관된 seed 생성.
int _generateSeed() {
  // 1. 이미지 URL이 있으면 URL hashCode 사용
  if (imageUrl != null && imageUrl!.isNotEmpty) {
    return imageUrl!.hashCode.abs() % 10000;
  }

  // 2. Asset 경로가 있으면 경로 hashCode 사용
  if (assetPath != null && assetPath!.isNotEmpty) {
    return assetPath!.hashCode.abs() % 10000;
  }

  // 3. 이니셜이 있으면 이니셜 hashCode 사용
  if (initials != null && initials!.isNotEmpty) {
    return initials!.hashCode.abs() % 10000;
  }

  // 4. 플레이스홀더는 항상 동일한 seed (0)
  return 0;
}
```

**설계 근거**:
- `hashCode.abs() % 10000`: 0~9999 범위의 일관된 seed 생성
- **imageUrl 우선**: 이미지 URL이 있으면 URL 기반 seed
- **assetPath 차선**: Asset 경로가 있으면 경로 기반 seed
- **initials 최후**: 이니셜이 있으면 이니셜 기반 seed
- **플레이스홀더 고정**: 모든 플레이스홀더는 동일한 스케치 패턴 (seed: 0)

**주의**: Flutter의 `hashCode`는 동일한 세션 내에서만 일관성 보장. 앱 재시작 시 다른 hashCode 생성될 수 있음. 하지만 사용자 경험 상 문제 없음 (항상 동일한 URL/이니셜이면 동일 세션 내에서 동일 패턴).

## 플레이스홀더 개선

### 현재 플레이스홀더 (X-cross 패턴)

```dart
Widget _buildPlaceholder(_SizeConfig config) {
  return SketchImagePlaceholder(
    width: size.size,
    height: size.size,
    centerIcon: placeholderIcon ?? Icons.person_outline,
    showBorder: false,
  );
}
```

**문제점**:
- X-cross 패턴 + person_outline 아이콘 → 디자인 명세와 불일치
- `SketchImagePlaceholder` 의존성 → 불필요한 컴포넌트

### 변경 후 플레이스홀더 (사람 아이콘만)

```dart
Widget _buildPlaceholder(BuildContext context, _SizeConfig config) {
  final sketchTheme = SketchThemeExtension.maybeOf(context);
  final effectiveBackgroundColor = backgroundColor ??
      sketchTheme?.fillColor ??
      SketchDesignTokens.base100; // 라이트: #F7F7F7
  final effectiveIconColor = iconColor ??
      sketchTheme?.iconColor ??
      SketchDesignTokens.base600; // 라이트: #767676

  return Container(
    width: size.size,
    height: size.size,
    color: effectiveBackgroundColor,
    child: Center(
      child: Icon(
        placeholderIcon ?? Icons.person, // person_outline → person
        size: config.iconSize, // 아바타 크기의 40%
        color: effectiveIconColor,
      ),
    ),
  );
}
```

**변경 사항**:
1. **X-cross 제거**: `SketchImagePlaceholder` 사용 중단
2. **아이콘 변경**: `Icons.person_outline` → `Icons.person` (filled 버전)
3. **아이콘 크기**: 아바타 크기의 40% (기존 30%보다 크게)
4. **배경 색상**: 테마 `fillColor` 또는 `backgroundColor` prop
5. **아이콘 색상**: 테마 `iconColor` 또는 새로운 `iconColor` prop

### iconColor prop 추가

```dart
class SketchAvatar extends StatelessWidget {
  // 기존 props...

  /// 아이콘 색상 (플레이스홀더 아이콘).
  final Color? iconColor;

  const SketchAvatar({
    // 기존 params...
    this.iconColor,
  });
}
```

### 크기별 아이콘 크기 계산

```dart
class _SizeConfig {
  final double fontSize; // 이니셜용
  final double borderWidth;
  final double iconSize; // 플레이스홀더 아이콘용 (새로 추가)

  const _SizeConfig({
    required this.fontSize,
    required this.borderWidth,
    required this.iconSize,
  });
}

_SizeConfig _getSizeConfig(SketchAvatarSize size) {
  switch (size) {
    case SketchAvatarSize.xs: // 24px
      return const _SizeConfig(
        fontSize: 10,
        borderWidth: 1.0,
        iconSize: 9.6, // 24 * 0.4
      );
    case SketchAvatarSize.sm: // 32px
      return const _SizeConfig(
        fontSize: 14,
        borderWidth: 1.5,
        iconSize: 12.8, // 32 * 0.4
      );
    case SketchAvatarSize.md: // 40px
      return const _SizeConfig(
        fontSize: 18,
        borderWidth: 2.0,
        iconSize: 16, // 40 * 0.4
      );
    case SketchAvatarSize.lg: // 56px
      return const _SizeConfig(
        fontSize: 20,
        borderWidth: 2.0,
        iconSize: 22.4, // 56 * 0.4
      );
    case SketchAvatarSize.xl: // 80px
      return const _SizeConfig(
        fontSize: 28,
        borderWidth: 2.5,
        iconSize: 32, // 80 * 0.4
      );
    case SketchAvatarSize.xxl: // 120px
      return const _SizeConfig(
        fontSize: 36,
        borderWidth: 3.0,
        iconSize: 48, // 120 * 0.4
      );
  }
}
```

## 크기별 시각적 사양

| Size | 크기(px) | borderWidth | fontSize (이니셜) | iconSize (플레이스홀더) | roughness | seed 생성 |
|------|---------|-------------|------------------|----------------------|-----------|----------|
| xs | 24 | 1.0 | 10 | 9.6 (40%) | 0.8 | hashCode % 10000 |
| sm | 32 | 1.5 | 14 | 12.8 (40%) | 0.8 | hashCode % 10000 |
| md | 40 | 2.0 | 18 | 16 (40%) | 0.8 | hashCode % 10000 |
| lg | 56 | 2.0 | 20 | 22.4 (40%) | 0.8 | hashCode % 10000 |
| xl | 80 | 2.5 | 28 | 32 (40%) | 0.8 | hashCode % 10000 |
| xxl | 120 | 3.0 | 36 | 48 (40%) | 0.8 | hashCode % 10000 |

## 수정 대상 파일 및 영향도

### 파일 1: sketch_circle_painter.dart

**위치**: `apps/mobile/packages/design_system/lib/src/painters/sketch_circle_painter.dart`

**수정 내용**:
1. `createClipPath()` 정적 메서드 추가
2. `_createIrregularCircle()` 로직을 정적 메서드로 추출 (재사용)

**영향도**: ✅ 낮음 — 기존 API 100% 호환, 새로운 정적 메서드만 추가

### 파일 2: sketch_painter.dart

**위치**: `apps/mobile/packages/design_system/lib/src/painters/sketch_painter.dart`

**수정 내용**:
1. `createClipPath()` 정적 메서드 추가
2. `_createSketchPath()` 로직을 정적 메서드로 추출 (재사용)

**영향도**: ✅ 낮음 — 기존 API 100% 호환, 새로운 정적 메서드만 추가

### 파일 3: sketch_avatar.dart

**위치**: `apps/mobile/packages/design_system/lib/src/widgets/sketch_avatar.dart`

**수정 내용**:
1. `Border.all()` 제거, `CustomPaint` + `SketchCirclePainter`/`SketchPainter` 사용
2. `ClipOval`/`ClipRRect` 제거, `ClipPath` + 스케치 경로 사용
3. `_buildPlaceholder()` 개선 (X-cross 제거, `Icons.person` 사용)
4. `iconColor` prop 추가
5. `_generateSeed()` 메서드 추가
6. `_SizeConfig.iconSize` 필드 추가
7. `_SketchClipper` 내부 클래스 추가

**영향도**: ✅ 낮음 — 기존 API 100% 호환 (iconColor만 선택적 추가)

### 파일 4: avatar_demo.dart (선택)

**위치**: `apps/mobile/apps/design_system_demo/lib/app/modules/widgets/views/demos/avatar_demo.dart`

**수정 내용**:
- 데모 업데이트 (필요시)

**영향도**: ✅ 없음 — 데모 앱만 영향

### 제거 대상

**sketch_image_placeholder.dart**:
- `SketchAvatar`에서 더 이상 사용하지 않음
- 하지만 다른 컴포넌트에서 사용 중일 수 있으므로 **제거하지 않음**
- `SketchAvatar`의 import만 제거

## 구현 단계별 계획

### 단계 1: SketchCirclePainter 확장 (Senior Developer)

**작업**:
1. `createClipPath()` 정적 메서드 추가
2. `_createIrregularCircle()` 로직을 `_createIrregularCircleStatic()` 정적 메서드로 추출
3. 기존 `_createIrregularCircle()` 내부에서 `_createIrregularCircleStatic()` 호출 (중복 제거)

**검증**:
- 기존 `SketchCirclePainter` 사용처 정상 동작 확인

### 단계 2: SketchPainter 확장 (Senior Developer)

**작업**:
1. `createClipPath()` 정적 메서드 추가
2. `_createSketchPath()` 로직을 `_createSketchPathStatic()` 정적 메서드로 추출
3. 기존 `_createSketchPath()` 내부에서 `_createSketchPathStatic()` 호출 (중복 제거)

**검증**:
- 기존 `SketchPainter` 사용처 정상 동작 확인

### 단계 3: SketchAvatar 리팩토링 (Senior Developer)

**작업**:
1. `iconColor` prop 추가
2. `_SizeConfig.iconSize` 필드 추가
3. `_generateSeed()` 메서드 구현
4. `_SketchClipper` 내부 클래스 추가
5. `build()` 메서드 재구성:
   - `Container(Border.all)` → `Stack + CustomPaint + ClipPath`
6. `_buildPlaceholder()` 개선:
   - `SketchImagePlaceholder` → `Container + Icon(Icons.person)`
   - `iconSize` 사용
7. Import 정리 (`sketch_image_placeholder.dart` 제거)

**검증**:
- 기존 API 호환성 확인 (모든 props 동일하게 작동)
- 시각적 확인: 스케치 테두리, 사람 아이콘 플레이스홀더

### 단계 4: 데모 앱 업데이트 (Junior Developer, 선택)

**작업**:
- `avatar_demo.dart`에서 변경 사항 확인
- 필요시 추가 예제 (iconColor prop 사용)

**검증**:
- 데모 앱에서 다양한 크기/형태 확인

## API 호환성 체크리스트

- [x] 기존 props 모두 유지 (`imageUrl`, `assetPath`, `initials`, `placeholderIcon`, `size`, `shape`, `backgroundColor`, `textColor`, `borderColor`, `strokeWidth`, `onTap`, `showBorder`)
- [x] 새로운 prop `iconColor`는 선택적 (기본값: 테마 `iconColor`)
- [x] 기존 static 메서드 `getInitials()` 유지
- [x] 기존 동작 100% 호환 (이미지 → 이니셜 → 플레이스홀더 우선순위)
- [x] showBorder: false 정상 동작 (CustomPaint 없이 ClipPath만 사용)

## 성능 고려사항

### CustomPaint 최적화

**장점**:
- `shouldRepaint()`로 불필요한 리페인트 방지
- seed 기반 일관된 렌더링 → 캐싱 가능

**단점**:
- `ClipPath`보다 `ClipOval`/`ClipRRect`이 더 빠름
- 하지만 아바타는 작은 위젯이므로 성능 영향 미미

### enableNoise: false

**이유**:
- 아바타 테두리는 노이즈 텍스처 불필요 (fillColor가 Colors.transparent)
- 성능 최적화

### seed 고정

**이유**:
- `_generateSeed()`로 일관된 seed 생성
- 동일한 imageUrl/initials = 동일한 스케치 패턴
- 불필요한 리렌더링 방지

## 접근성 (Accessibility)

### Semantics 추가 (선택)

```dart
Widget build(BuildContext context) {
  // ...

  Widget avatar = ...;

  // Semantics 추가
  avatar = Semantics(
    label: _getSemanticsLabel(),
    button: onTap != null,
    child: avatar,
  );

  if (onTap != null) {
    return GestureDetector(
      onTap: onTap,
      child: avatar,
    );
  }

  return avatar;
}

String _getSemanticsLabel() {
  if (imageUrl != null || assetPath != null) {
    return '사용자 아바타';
  }
  if (initials != null) {
    return '$initials 아바타';
  }
  return '프로필 플레이스홀더';
}
```

**우선순위**: Medium (필수는 아니지만 권장)

## 에러 처리 전략

### 이미지 로딩 실패

**현재**: `errorBuilder`로 플레이스홀더 표시 → 유지

**개선**: 없음 (기존 로직 충분)

### ClipPath 생성 실패

**문제**: `createClipPath()` 실패 시 대체 전략 필요

**해결**:
```dart
Widget _buildClippedContent(BuildContext context, _SizeConfig config) {
  try {
    final clippingPath = shape == SketchAvatarShape.circle
        ? SketchCirclePainter.createClipPath(...)
        : SketchPainter.createClipPath(...);

    return ClipPath(
      clipper: _SketchClipper(clippingPath),
      child: _buildAvatarContent(context, config),
    );
  } catch (e) {
    // 실패 시 기존 ClipOval/ClipRRect로 fallback
    if (shape == SketchAvatarShape.circle) {
      return ClipOval(child: _buildAvatarContent(context, config));
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: _buildAvatarContent(context, config),
      );
    }
  }
}
```

**우선순위**: Low (실패 확률 거의 없음, 하지만 안전장치로 권장)

## 테마 색상 연동

### 라이트 모드

**테두리 색상**:
- `borderColor` prop → `SketchThemeExtension.borderColor` → `SketchDesignTokens.base900` (#343434)

**플레이스홀더**:
- 배경: `backgroundColor` prop → `SketchThemeExtension.fillColor` (라이트: #FAF8F5)
- 아이콘: `iconColor` prop → `SketchThemeExtension.iconColor` (#767676 — base600)

### 다크 모드

**테두리 색상**:
- `borderColor` prop → `SketchThemeExtension.dark().borderColor` (#5E5E5E — base700)

**플레이스홀더**:
- 배경: `backgroundColor` prop → `SketchThemeExtension.dark().fillColor` (#1A1D29)
- 아이콘: `iconColor` prop → `SketchThemeExtension.dark().iconColor` (#B5B5B5 — base400)

## 작업 분배 계획

### Senior Developer 작업

1. **SketchCirclePainter 확장** (우선순위: High)
   - `createClipPath()` 정적 메서드 추가
   - `_createIrregularCircleStatic()` 정적 메서드 추출

2. **SketchPainter 확장** (우선순위: High)
   - `createClipPath()` 정적 메서드 추가
   - `_createSketchPathStatic()` 정적 메서드 추출

3. **SketchAvatar 리팩토링** (우선순위: High)
   - CustomPaint + ClipPath 통합
   - 플레이스홀더 개선
   - seed 생성 로직 구현
   - 테마 색상 연동

4. **검증** (우선순위: High)
   - 기존 API 호환성 확인
   - 시각적 QA (다양한 크기/형태)

### Junior Developer 작업

1. **데모 앱 업데이트** (우선순위: Low, 선택)
   - `avatar_demo.dart` 업데이트
   - 추가 예제 작성 (iconColor prop 사용)

### 작업 의존성

- Junior는 Senior의 SketchAvatar 리팩토링 완료 후 시작
- 데모 앱 업데이트는 선택 사항 (기능 구현과 독립적)

## 검증 기준

- [ ] 기존 API 100% 호환 (`iconColor` 제외 모든 props 동일)
- [ ] 스케치 테두리 정상 렌더링 (원형/사각형)
- [ ] ClipPath로 정확한 클리핑
- [ ] 플레이스홀더: X-cross 제거, `Icons.person` 사용, 40% 크기
- [ ] seed 기반 일관된 스케치 패턴 (동일 imageUrl/initials = 동일 패턴)
- [ ] showBorder: false 정상 동작
- [ ] 라이트/다크 모드 테마 색상 정상 적용
- [ ] 이미지 로딩/에러 상태 정상 처리
- [ ] 성능: 불필요한 리페인트 없음

## 참고 자료

- **SketchCirclePainter**: `apps/mobile/packages/design_system/lib/src/painters/sketch_circle_painter.dart`
- **SketchPainter**: `apps/mobile/packages/design_system/lib/src/painters/sketch_painter.dart`
- **SketchThemeExtension**: `apps/mobile/packages/design_system/lib/src/theme/sketch_theme_extension.dart`
- **디자인 명세**: `docs/wowa/design-system-avatar/mobile-design-spec.md`
- **User Story**: `docs/wowa/design-system-avatar/user-story.md`
- **참조 이미지**:
  - `prompt/archives/img_19.png`: 다크 모드 사람 실루엣 (흰 테두리)
  - `prompt/archives/img_20.png`: 라이트 모드 사람 실루엣 (검은 테두리)
  - `prompt/archives/img_21.png`: 현재 SketchAvatar 데모
