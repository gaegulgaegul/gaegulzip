# Mobile Brief: SketchInput Number 모드

## 구현 범위

### 변경 파일 (영향도 순)

| 우선순위 | 파일 | 변경 내용 | 의존성 |
|---------|------|----------|--------|
| 1 | `sketch_input.dart` | enum 추가 + number 모드 빌드 로직 + 파라미터 추가 | 없음 (핵심) |
| 2 | `widget_catalog_controller.dart` | SketchNumberInput 항목 제거 | 1 완료 후 |
| 3 | `widget_demo_view.dart` | SketchNumberInput case 제거, import 제거 | 2와 동시 |
| 4 | `input_demo.dart` | number 모드 데모 섹션 추가 | 1 완료 후 |
| 5 | `README.md` | SketchNumberInput → SketchInput number 모드 문서 업데이트 | 1 완료 후 |

### 실행 그룹

**Group 1** (병렬 불가 — 핵심 위젯 수정):
- `sketch_input.dart` 수정

**Group 2** (Group 1 완료 후, 병렬 가능):
- `widget_catalog_controller.dart` 수정
- `widget_demo_view.dart` 수정
- `input_demo.dart` 수정
- `README.md` 수정

## 상세 구현 사양

### 1. SketchInputMode enum 수정

```dart
enum SketchInputMode {
  defaultMode,
  search,
  date,
  time,
  datetime,
  number,  // 추가
}
```

### 2. SketchInput 파라미터 추가

```dart
class SketchInput extends StatefulWidget {
  // ... 기존 파라미터 ...

  // ── Number 모드 전용 ──
  /// 현재 숫자 값 (number 모드 필수).
  final double? numberValue;

  /// 숫자 변경 콜백 (number 모드 필수).
  final ValueChanged<double>? onNumberChanged;

  /// 최소값.
  final double? min;

  /// 최대값.
  final double? max;

  /// 증감 단위 (기본 1.0).
  final double step;

  /// 소수점 자릿수 (기본 0).
  final int decimalPlaces;

  /// 접미사 (예: "kg", "회").
  final String? suffix;

  const SketchInput({
    // ... 기존 ...
    this.numberValue,
    this.onNumberChanged,
    this.min,
    this.max,
    this.step = 1.0,
    this.decimalPlaces = 0,
    this.suffix,
  });
}
```

### 3. Number 모드 빌드 로직

`_SketchInputState.build()`에서 `widget.mode == SketchInputMode.number`일 때 **별도 빌드 메서드** 호출.

기존 `_resolveModeDefaults` 패턴과 다르게, number 모드는 **레이아웃 자체가 다르므로** build 단계에서 분기한다.

```dart
@override
Widget build(BuildContext context) {
  // number 모드는 별도 빌드
  if (widget.mode == SketchInputMode.number) {
    return _buildNumberMode(context);
  }
  // ... 기존 build 로직 ...
}
```

### 4. _buildNumberMode 구현

```dart
Widget _buildNumberMode(BuildContext context) {
  final sketchTheme = SketchThemeExtension.maybeOf(context);
  final hasError = widget.errorText != null;
  final colorSpec = _getColorSpec(sketchTheme, ...);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      // Label (기존과 동일)
      if (widget.label != null) ...[
        Text(widget.label!, style: ...),
        const SizedBox(height: 6),
      ],

      // Number Input 컨테이너
      CustomPaint(
        painter: SketchPainter(
          fillColor: colorSpec.fillColor,
          borderColor: colorSpec.borderColor,
          strokeWidth: colorSpec.strokeWidth,
          roughness: sketchTheme?.roughness ?? SketchDesignTokens.roughness,
          seed: widget.label?.hashCode ?? widget.hint?.hashCode ?? 0,
          enableNoise: true,
          showBorder: widget.showBorder,
          borderRadius: SketchDesignTokens.irregularBorderRadius,
        ),
        child: SizedBox(
          height: 44.0,
          child: Row(
            children: [
              // 텍스트 입력 영역
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SketchDesignTokens.spacingMd,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _numberController,
                          focusNode: _focusNode,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: widget.decimalPlaces > 0,
                          ),
                          inputFormatters: [숫자 필터],
                          style: 텍스트 스타일,
                          decoration: InputDecoration.collapsed(hintText: '0'),
                          onChanged: _onNumberTextChanged,
                        ),
                      ),
                      if (widget.suffix != null)
                        Text(widget.suffix!, style: suffix 스타일),
                    ],
                  ),
                ),
              ),

              // 세로 구분선 (스케치 스타일)
              _buildVerticalDivider(colorSpec),

              // Chevron 버튼 영역
              SizedBox(
                width: 48,
                child: Column(
                  children: [
                    // 증가 버튼
                    Expanded(
                      child: GestureDetector(
                        onTap: _canIncrement ? _increment : null,
                        child: Icon(chevronUp, size: 16, color: ...),
                      ),
                    ),
                    // 가로 구분선
                    _buildHorizontalDivider(colorSpec),
                    // 감소 버튼
                    Expanded(
                      child: GestureDetector(
                        onTap: _canDecrement ? _decrement : null,
                        child: Icon(chevronDown, size: 16, color: ...),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Error/Helper 텍스트 (기존과 동일)
      if (widget.errorText != null || widget.helperText != null) ...[...],
    ],
  );
}
```

### 5. Number 상태 관리

Number 모드에서는 `_effectiveController`와 별도로 숫자값 동기화 로직이 필요:

- `initState`에서 `_controller.text = _formatValue(widget.numberValue)`
- `didUpdateWidget`에서 외부 값 변경 시 controller 동기화
- `_onNumberTextChanged`에서 텍스트 → 숫자 변환 → `widget.onNumberChanged` 호출
- `_increment` / `_decrement`에서 clamp 적용 후 `widget.onNumberChanged` 호출

### 6. 구분선 렌더링

**세로 구분선** — `_buildVerticalDivider`:
```dart
Widget _buildVerticalDivider(_ColorSpec colorSpec) {
  return CustomPaint(
    size: const Size(3, 44),  // strokeBold 폭
    painter: SketchLinePainter(
      start: Offset(1.5, 2),
      end: Offset(1.5, 42),
      color: colorSpec.borderColor,
      strokeWidth: colorSpec.strokeWidth,
      roughness: ...,
      seed: ...,
    ),
  );
}
```

**가로 구분선** — `_buildHorizontalDivider`:
```dart
Widget _buildHorizontalDivider(_ColorSpec colorSpec) {
  return CustomPaint(
    size: const Size(48, 2),  // strokeStandard 높이
    painter: SketchLinePainter(
      start: Offset(2, 1),
      end: Offset(46, 1),
      color: colorSpec.borderColor,
      strokeWidth: SketchDesignTokens.strokeStandard,
      roughness: ...,
      seed: ...,
    ),
  );
}
```

### 7. Widget Catalog 수정

`widget_catalog_controller.dart`에서 `SketchNumberInput` 항목 제거:
```dart
// 삭제
WidgetCatalogItem(
  name: 'SketchNumberInput',
  description: '숫자 입력 (증감 버튼, 소수점)',
),
```

`widget_demo_view.dart`에서:
```dart
// 삭제
case 'SketchNumberInput':
  return const NumberInputDemo();
```

`import 'demos/number_input_demo.dart';` 제거

### 8. InputDemo 수정

`input_demo.dart`에 number 모드 데모 섹션 추가:
- 모드 선택 버튼에 `number` 추가
- number 모드 갤러리 섹션 추가 (기본, 라벨+접미사, 범위 제한, 소수점)

### 9. README.md 수정

위젯 목록에서:
- `SketchNumberInput` 항목을 `[deprecated]`로 표시하거나 제거
- `SketchInput` 설명에 `number` 모드 추가

## 제약사항

- `SketchNumberInput` 클래스 자체는 삭제하지 않음 (기존 사용처 호환성)
- 카탈로그/데모에서만 제거
- 기존 `SketchInput`의 높이(44px)를 유지하므로 버튼 영역이 작음 → chevron 아이콘 16px로 compact하게

## 검증 기준

1. `melos analyze` 통과
2. design_system_demo 앱에서 SketchInput → number 모드 정상 표시
3. Light/Dark 전환 시 색상 올바르게 변경
4. 증가/감소 버튼 동작 (min/max clamp)
5. 텍스트 직접 입력 동작
6. 카탈로그에 SketchNumberInput 미표시
