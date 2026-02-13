# Mobile Technical Brief: SketchImagePlaceholder 디자인 개선

## 1. 개요

`XCrossPainter`에 **tapered stroke(가변 두께 선)** 렌더링을 추가하여 레퍼런스 이미지의 펜/마커 질감을 재현한다.

## 2. 수정 대상 파일 및 영향도

### 직접 수정
| 파일 | 변경 범위 | 영향도 |
|------|---------|--------|
| `x_cross_painter.dart` | **핵심 변경** — tapered stroke 렌더링 로직 추가 | 높음 |
| `sketch_image_placeholder.dart` | 색상 매핑 개선 (테두리/대각선 색상 통합) | 중간 |

### 영향 없음 (변경 불필요)
| 파일 | 이유 |
|------|------|
| `sketch_theme_extension.dart` | 기존 테마 색상으로 충분 |
| `image_placeholder_demo.dart` | 기존 데모가 변경 자동 반영 |
| `sketch_painter.dart` | 별도 컴포넌트, 의존성 없음 |

## 3. XCrossPainter 변경 상세

### 3.1 Tapered Stroke 알고리즘

기존의 `Paint.strokeWidth` 기반 렌더링을 **닫힌 Path fill** 방식으로 교체.

**핵심 메서드**: `_createTaperedLine(Offset start, Offset end, Random random)`

```
알고리즘:
1. start → end를 N개 세그먼트로 분할
2. 각 세그먼트 위치 t (0.0~1.0)에서:
   a. 기본 점 계산 (선형 보간)
   b. roughness 적용 (법선 방향 jitter)
   c. 두께 계산: width(t) = strokeWidth * taperedWidthProfile(t)
      - taperedWidthProfile(t) = taperRatio + (1.0 - taperRatio) * sin(t * π)
      - taperRatio = 0.3 (시작/끝 두께 비율)
   d. 법선 방향으로 ±width/2 오프셋하여 상단/하단 윤곽 점 생성
3. 상단 윤곽 점 순방향 + 하단 윤곽 점 역방향 연결
4. Path.close()로 닫힌 형태 완성
5. PaintingStyle.fill로 렌더링
```

### 3.2 테두리 변경

기존 `_drawBorder`도 tapered stroke 적용:
- 4개 변(top, right, bottom, left)을 각각 tapered line으로 렌더링
- 기존 `_createIrregularRect` 대체

### 3.3 색상 통합

레퍼런스에서 테두리와 대각선이 동일 색상이므로:
- `lineColor`와 `borderColor`를 **내부적으로 동일하게** 처리
- 위젯 API는 호환성을 위해 유지하되, `XCrossPainter` 내부에서 `borderColor` = `lineColor`로 통합

### 3.4 파라미터 변경

```dart
class XCrossPainter extends CustomPainter {
  // 기존 유지
  final Color lineColor;
  final Color backgroundColor;
  final double strokeWidth;
  final double roughness;
  final int seed;

  // 추가
  final double taperRatio; // 기본값 0.3 — 시작/끝 두께 비율

  // 제거 (lineColor로 통합)
  // final Color borderColor; → lineColor 사용
}
```

## 4. SketchImagePlaceholder 변경 상세

### 4.1 색상 매핑 개선

```dart
// 변경 전:
final effectiveLineColor = lineColor ?? sketchTheme?.textSecondaryColor ?? ...;
final effectiveBorderColor = borderColor ?? sketchTheme?.borderColor ?? ...;

// 변경 후:
// 테두리와 대각선을 동일 색상으로 통합
final effectiveStrokeColor = lineColor ?? sketchTheme?.borderColor ?? ...;
```

### 4.2 XCrossPainter 호출 변경

```dart
XCrossPainter(
  lineColor: effectiveStrokeColor,   // 통합 색상
  backgroundColor: effectiveBgColor,
  strokeWidth: strokeWidth,
  roughness: roughness,
  taperRatio: 0.3,                   // 신규 파라미터
)
```

## 5. 실행 순서

| 순서 | 작업 | 의존성 |
|------|------|--------|
| 1 | `XCrossPainter` tapered stroke 구현 | 없음 |
| 2 | `SketchImagePlaceholder` 색상 매핑 개선 | XCrossPainter 완료 후 |
| 3 | 데모 앱에서 확인 | 위 2개 완료 후 |

## 6. 검증 기준

- [ ] XS/SM/MD/LG 프리셋에서 가변 두께 선 렌더링 확인
- [ ] Light 모드: 검정 선 + 흰 배경
- [ ] Dark 모드: 흰 선 + 어두운 배경
- [ ] 기존 API (생성자 파라미터) 호환성 유지
- [ ] 프리셋 크기 동일
- [ ] 데모 앱에서 시각적 확인
