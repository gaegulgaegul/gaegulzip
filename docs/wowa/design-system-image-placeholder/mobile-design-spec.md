# Mobile Design Spec: SketchImagePlaceholder 디자인 개선

## 1. 개요

`SketchImagePlaceholder` 위젯이 레퍼런스 이미지의 **펜/마커 질감**을 충실하게 표현하도록 `XCrossPainter`를 개선한다.

## 2. 레퍼런스 이미지 분석

### Light Mode (`prompt/archives/image-placeholder-light-mode.png`)
- **배경**: 흰색
- **선**: 검정색, 두꺼운 마커 스트로크
- **특징**: 선의 두께가 일정하지 않음 (시작/끝이 얇고 중앙이 두꺼운 자연스러운 펜 압력 표현)
- **테두리**: 굵은 불규칙 사각형
- **대각선**: 4개 모서리를 연결하는 X자 (중앙에서 교차)

### Dark Mode (`prompt/archives/image-placeholder-dark-mode.png`)
- **배경**: 검정색
- **선**: 흰색, 동일한 마커 스트로크
- **특징**: Light와 동일한 질감, 색상만 반전

### 공통 시각적 특성
1. **가변 두께(Tapered Stroke)**: 선의 시작/끝 → 얇음, 중앙 → 두꺼움
2. **2-pass 렌더링**: 테두리와 대각선 모두 2번 겹쳐 그려 더 자연스러운 질감
3. **자연스러운 곡률**: 직선이 아닌 약간 흔들리는 베지어 곡선
4. **굵은 선**: 기존보다 두꺼운 스트로크 (레퍼런스 기준 약 strokeBold~strokeThick 수준)

## 3. 색상 매핑

### Light Mode
| 요소 | 색상 | 토큰 |
|------|------|------|
| 배경 | `#FFFFFF` (white) | `fillColor` |
| 테두리 선 | `#343434` (base900) | `borderColor` |
| X-cross 대각선 | `#343434` (base900) | `borderColor` (테두리와 동일) |

### Dark Mode
| 요소 | 색상 | 토큰 |
|------|------|------|
| 배경 | `#1A1D29` (backgroundDark) | `fillColor` |
| 테두리 선 | `#F5F5F5` (textOnDark) | `textColor` |
| X-cross 대각선 | `#F5F5F5` (textOnDark) | `textColor` (테두리와 동일) |

**핵심 변경**: 레퍼런스에서 테두리와 대각선이 **동일한 색상**이므로, 현재의 `lineColor` / `borderColor` 분리 대신 **단일 스트로크 색상**으로 통합.

## 4. 크기 프리셋 (변경 없음)

| 프리셋 | 크기 | strokeWidth |
|--------|------|-------------|
| XS | 40x40 | 1.5 |
| SM | 80x80 | 2.0 |
| MD | 120x120 | 2.5 |
| LG | 200x200 | 3.0 |
| Custom | 사용자 지정 | 사용자 지정 (기본 2.0) |

## 5. Tapered Stroke 시각 사양

### 두께 프로파일
```
시작(0%) ────── 중앙(50%) ────── 끝(100%)
   얇음(0.3x)    두꺼움(1.0x)     얇음(0.3x)
```

- `taperRatio`: 0.3 (시작/끝의 두께 = strokeWidth * 0.3)
- 중앙의 두께 = strokeWidth * 1.0
- ease-in/ease-out 보간으로 자연스러운 전환

### 렌더링 방식
- 선을 균등한 세그먼트로 분할 (8~12개)
- 각 세그먼트 위치에서 법선(perpendicular) 방향으로 폭 계산
- 양쪽 윤곽 점을 연결하여 닫힌 Path 생성
- `PaintingStyle.fill`로 렌더링 (strokeWidth 미사용)

## 6. 데모 화면 요구사항

기존 `ImagePlaceholderDemo`는 유지하되, 다크모드 전환 시 자동 색상 반영을 확인 가능해야 함.
