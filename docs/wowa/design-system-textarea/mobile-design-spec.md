# SketchTextArea - Mobile Design Spec

## 비주얼 레퍼런스

| 모드 | 에셋 |
|------|------|
| Light | `prompt/archives/textarea-light-mode.png` |
| Dark | `prompt/archives/textarea-dark-mode.png` |

## 디자인 요소

### 레이아웃
- 여러 줄 텍스트 입력 영역
- 상단 좌측: 힌트 텍스트 ("Text area")
- 우하단: Resize Handle (장식용 대각선 2줄)
- 모서리: 불규칙한 둥근 모서리 (irregularBorderRadius = 12.0)

### 테두리
- **렌더링 방식**: `CustomPaint` + `SketchPainter`
- **기본 두께**: `strokeBold` (3.0) — 레퍼런스 이미지의 두꺼운 테두리와 일치
- **포커스 두께**: `strokeThick` (4.0) — SketchInput과 동일 패턴
- **에러 두께**: `strokeBold` (3.0) + 빨간색
- **비활성화 두께**: `strokeStandard` (2.0) + 흐림 색상
- **노이즈 텍스처**: `enableNoise: true`

### Resize Handle
- 위치: 우하단 코너 (padding 내부)
- 모양: 평행한 대각선 2줄 (좌하→우상 방향)
- 길이: 약 12-14px
- 간격: 4px
- 두께: 2.0px
- 색상: 테두리 색상과 동일 (light=검정, dark=흰색)
- 기능: 없음 (순수 장식)

### 색상 (Light Mode)
| 요소 | 색상 |
|------|------|
| 배경 | `fillColor` (theme) — 흰색 계열 |
| 테두리 | `borderColor` (theme) — base900 (0xFF343434) |
| 텍스트 | `textColor` (theme) — base900 |
| 힌트 | `textSecondaryColor` (theme) — base500 |
| Resize Handle | `borderColor`와 동일 |

### 색상 (Dark Mode)
| 요소 | 색상 |
|------|------|
| 배경 | `fillColor` (theme) — backgroundDark (0xFF1A1D29) |
| 테두리 | `borderColor` (theme) — base700 (0xFF5E5E5E) |
| 텍스트 | `textColor` (theme) — textOnDark (0xFFF5F5F5) |
| 힌트 | `textSecondaryColor` (theme) — textSecondaryOnDark (0xFFB0B0B0) |
| Resize Handle | `borderColor`와 동일 |

### 타이포그래피
- 폰트: `fontFamilyHand` + `fontFamilyHandFallback`
- 힌트 크기: `fontSizeBase` (16.0)
- 라벨 크기: `fontSizeSm` (14.0)
- 카운터 크기: `fontSizeXs` (12.0) + `fontFamilyMono`

### 상태별 동작
| 상태 | 테두리 색상 | 테두리 두께 | 배경 |
|------|-----------|-----------|------|
| 일반 | theme.borderColor | strokeBold (3.0) | theme.fillColor |
| 포커스 | theme.focusBorderColor | strokeThick (4.0) | theme.fillColor |
| 에러 | error (red) | strokeBold (3.0) | theme.fillColor |
| 비활성화 | theme.disabledBorderColor | strokeStandard (2.0) | theme.disabledFillColor |

## 크기
- minLines: 3 (기본)
- maxLines: 10 (기본)
- 높이 = minLines × lineHeight + padding
- 가로: 부모 너비에 맞춤 (stretch)
