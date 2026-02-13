# Technical Brief: SketchBottomNavigationBar 스케치 스타일 적용

## 개요

SketchBottomNavigationBar의 테두리를 `BoxDecoration` → `SketchPainter` 기반으로 변경하여 손그림 스케치 스타일 적용. 기존 API 100% 호환.

## 변경 파일

| 파일 | 변경 유형 | 설명 |
|------|---------|------|
| `design_system/lib/src/widgets/sketch_bottom_navigation_bar.dart` | 수정 | SketchPainter 래핑 적용 |
| `design_system_demo/.../demos/bottom_nav_bar_demo.dart` | 수정 | 데모 확인 (필요시) |

## 구현 상세

### 1. build() 메서드 변경

**변경 전:**
```dart
return Container(
  height: height,
  decoration: BoxDecoration(
    color: theme.fillColor,
    border: showBorder
        ? Border(top: BorderSide(color: theme.borderColor, width: 1.0))
        : null,
  ),
  child: Row(...),
);
```

**변경 후:**
```dart
return CustomPaint(
  painter: SketchPainter(
    fillColor: theme.fillColor,
    borderColor: theme.borderColor,
    strokeWidth: SketchDesignTokens.strokeBold,
    roughness: theme.roughness,
    bowing: theme.bowing,
    seed: 42,
    enableNoise: true,
    showBorder: showBorder,
    borderRadius: SketchDesignTokens.irregularBorderRadius,
  ),
  child: SizedBox(
    height: height,
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SketchDesignTokens.strokeBold / 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) { ... }),
      ),
    ),
  ),
);
```

### 2. overflow 해결

현재 선택된 아이콘(28px) + 라벨(12px) + 패딩(8*2) + SizedBox(4px) = ~60px이지만, `Column(mainAxisSize: MainAxisSize.min)`으로 인해 일부 조건에서 64px를 초과.

**해결 방법:**
- 기본 height를 `64.0` → `68.0`으로 조정
- 선택된 아이콘 크기를 `28` → `26`으로 축소 (비선택: 24 유지)
- 내부 패딩을 `vertical: 8` → `vertical: 6`으로 축소

### 3. import 추가

```dart
import '../painters/sketch_painter.dart';
```

## 의존성

- `SketchPainter` (기존 — 변경 없음)
- `SketchThemeExtension` (기존 — 변경 없음)
- `SketchDesignTokens` (기존 — 변경 없음)

## 기존 API 변경 없음

- `SketchBottomNavigationBar` 생성자 파라미터 동일
- `SketchNavItem` 데이터 클래스 동일
- `SketchNavLabelBehavior` enum 동일
- `showBorder` 파라미터가 `SketchPainter.showBorder`로 전달됨

## 테스트 포인트

1. 라이트/다크 모드에서 스케치 테두리 렌더링
2. 3~5개 아이템 레이아웃 overflow 없음
3. 배지 카운트 표시 정상
4. 라벨 동작 모드 3가지 (alwaysShow, onlyShowSelected, neverShow)
5. 항목 선택 시 아이콘/라벨 색상 변경

## 리스크

- **낮음**: 변경 범위가 1개 파일, 렌더링 레이어만 교체
- `SketchPainter`는 이미 `SketchInput`, `SketchContainer` 등에서 검증됨
