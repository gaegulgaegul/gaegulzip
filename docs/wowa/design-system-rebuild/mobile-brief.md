# Mobile Technical Brief: SketchInput 리빌드

## 1. 아키텍처 개요

### 변경 전
```
SketchInput (BoxDecoration — 평면 테두리)
SketchSearchInput (별도 위젯, SketchInput 래핑)
```

### 변경 후
```
SketchInput (CustomPaint + SketchPainter — 스케치 테두리)
  ├── mode: SketchInputMode.defaultMode (기본)
  ├── mode: SketchInputMode.search (검색 — SketchSearchInput 대체)
  ├── mode: SketchInputMode.date (날짜)
  ├── mode: SketchInputMode.time (시간)
  └── mode: SketchInputMode.datetime (날짜+시간)
```

## 2. 파일 변경 목록

| 파일 | 변경 내용 | 영향도 |
|------|----------|--------|
| `sketch_input.dart` | SketchPainter 적용 + SketchInputMode 추가 | **핵심** |
| `sketch_search_input.dart` | deprecated 처리, SketchInput(mode: search) 위임 | 중간 |
| `input_demo.dart` | 모드별 데모 추가 | 낮음 |
| `design_system.dart` | export 유지 (하위호환) | 낮음 |

### 영향받는 기존 사용처 (하위호환 필수)

| 파일 | 현재 사용 | 호환성 |
|------|----------|--------|
| `qna_submit_view.dart` | `SketchInput(label:, hint:)` | ✅ 기존 API 유지 |
| `wod_register_view.dart` | `SketchInput(label:, hint:, controller:)` | ✅ 기존 API 유지 |
| `box_search_view.dart` | `SketchSearchInput(hint:, onChanged:)` | ✅ deprecated 경고만 |
| `box_create_view.dart` | `SketchInput(label:, hint:)` | ✅ 기존 API 유지 |
| `theme_showcase_view.dart` | `SketchInput(label:, hint:)` | ✅ 기존 API 유지 |

## 3. API 설계

### SketchInputMode (신규 enum)

```dart
enum SketchInputMode {
  /// 기본 텍스트 입력
  defaultMode,
  /// 검색 입력 (돋보기 아이콘 + 지우기 버튼)
  search,
  /// 날짜 입력 (YYYY/MM/DD, readOnly)
  date,
  /// 시간 입력 (HH:MM AM/PM, readOnly)
  time,
  /// 날짜+시간 입력 (readOnly)
  datetime,
}
```

### SketchInput 생성자 변경

```dart
const SketchInput({
  // 신규 파라미터
  this.mode = SketchInputMode.defaultMode,
  this.onTap,              // date/time/datetime 모드에서 picker 트리거
  this.showClearButton,    // search 모드 지우기 버튼 (기본값: mode == search)

  // 기존 파라미터 (모두 유지)
  this.label,
  this.hint,
  this.helperText,
  this.errorText,
  this.prefixIcon,         // mode에 따라 자동 설정 가능
  this.suffixIcon,
  this.controller,
  this.obscureText,
  this.keyboardType,
  this.textCapitalization,
  this.maxLines,
  this.minLines,
  this.maxLength,
  this.inputFormatters,
  this.onChanged,
  this.onEditingComplete,
  this.onSubmitted,
  this.enabled,
  this.readOnly,           // date/time/datetime 모드에서 자동 true
  this.autofocus,
  this.textAlign,
  this.style,
  this.fillColor,
  this.borderColor,
  this.strokeWidth,
  this.showBorder,
});
```

## 4. 위젯 트리 구조

### 변경 전 (BoxDecoration)
```
Column
├── Text (label)
├── Container (BoxDecoration + Border.all)
│   └── Row
│       ├── prefixIcon
│       ├── TextField
│       └── suffixIcon
└── Text (helper/error)
```

### 변경 후 (CustomPaint + SketchPainter)
```
Column
├── Text (label)
├── GestureDetector (onTap — date/time/datetime 모드)
│   └── CustomPaint (SketchPainter)
│       └── SizedBox (height: 44)
│           └── Padding
│               └── Row
│                   ├── prefixIcon (mode별 자동 결정)
│                   ├── TextField
│                   └── suffixIcon (mode별 자동 결정)
└── Text (helper/error)
```

## 5. SketchPainter 통합 상세

### 색상 매핑

```dart
SketchPainter(
  fillColor: colorSpec.fillColor,
  borderColor: colorSpec.borderColor,
  strokeWidth: colorSpec.strokeWidth,  // 기본: strokeBold (3.0)
  roughness: sketchTheme?.roughness ?? SketchDesignTokens.roughness,
  seed: _computeSeed(),  // label?.hashCode ?? hint?.hashCode ?? 0
  enableNoise: true,
  showBorder: widget.showBorder,
  borderRadius: SketchDesignTokens.irregularBorderRadius,
)
```

### 상태별 스트로크 두께 변경

| 상태 | 스트로크 두께 |
|------|-------------|
| Normal | strokeBold (3.0) |
| Focused | strokeThick (4.0) |
| Error | strokeBold (3.0) |
| Disabled | strokeStandard (2.0) |

## 6. 모드별 동작 상세

### Search 모드
```dart
// prefixIcon 자동 설정 (사용자가 제공하지 않은 경우)
effectivePrefixIcon = widget.prefixIcon ?? Icon(Icons.search)

// suffixIcon 자동 설정 (지우기 버튼)
effectiveSuffixIcon = widget.suffixIcon ??
  (_hasText && showClearButton ? clearButton : null)

// hint 기본값
effectiveHint = widget.hint ?? 'Search'
```

### Date/Time/DateTime 모드
```dart
// readOnly 강제 true
effectiveReadOnly = true

// 탭 시 onTap 콜백 호출
GestureDetector(onTap: widget.onTap)

// keyboardType 무시 (readOnly이므로)
```

## 7. SketchSearchInput 하위호환

```dart
/// @deprecated SketchInput(mode: SketchInputMode.search) 사용 권장
class SketchSearchInput extends StatelessWidget {
  // ... 기존 프로퍼티 ...

  @override
  Widget build(BuildContext context) {
    return SketchInput(
      mode: SketchInputMode.search,
      hint: hint,
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      autofocus: autofocus,
      showClearButton: showClearButton,
    );
  }
}
```

StatefulWidget → StatelessWidget으로 단순화 (상태 관리는 SketchInput이 처리).

## 8. 데모 앱 업데이트

`input_demo.dart`에 추가할 섹션:

1. **모드 선택 드롭다운** — SketchInputMode 전환
2. **모드별 갤러리**:
   - Default: 기본 입력 (기존)
   - Search: 검색 입력
   - Date: 날짜 입력 (샘플 값)
   - Time: 시간 입력 (샘플 값)
   - DateTime: 날짜+시간 입력

## 9. 실행 순서

### Group 1 (병렬 가능)
- `SketchInputMode` enum 추가 (sketch_input.dart 내부)
- `SketchPainter` 테두리 교체 (BoxDecoration → CustomPaint)
- `_ColorSpec` 스트로크 두께 조정

### Group 2 (Group 1 의존)
- 모드별 동작 구현 (search/date/time/datetime)
- `SketchSearchInput` deprecated 처리

### Group 3 (Group 2 의존)
- `input_demo.dart` 업데이트
- 전체 모드/테마 조합 데모 추가

## 10. 수락 기준 체크리스트

- [ ] CustomPaint + SketchPainter로 불규칙 스케치 테두리 렌더링
- [ ] Light/Dark 모드에서 디자인 이미지와 질감 일치
- [ ] SketchInputMode로 default/search/date/time/datetime 전환
- [ ] 기존 SketchInput API 100% 하위호환
- [ ] SketchSearchInput deprecated + SketchInput(mode: search) 위임
- [ ] 데모 앱에서 모든 모드/테마 조합 확인 가능
- [ ] `melos analyze` 통과
