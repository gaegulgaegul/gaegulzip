# Plan: SketchSwitch 디자인 리빌드

## 구현 전략

기존 `SketchPainter`(pill shape)와 `SketchCirclePainter`(원형)를 조합하여
`SketchSwitch`의 트랙과 썸을 스케치 스타일로 렌더링한다.

## 작업 순서

### Step 1: SketchSwitch 내부 CustomPainter 전환

**파일**: `apps/mobile/packages/design_system/lib/src/widgets/sketch_switch.dart`

현재 `Container` + `BoxDecoration` 기반 렌더링을 `CustomPaint` 기반으로 전환:

1. **트랙 렌더링**: `SketchPainter` 사용
   - `borderRadius: 9999` (pill shape)
   - `enableNoise: true` (노이즈 텍스처)
   - 채우기 색상: 애니메이션 보간으로 inactive → active 전환
   - `showBorder: false` (에셋 이미지에 별도 테두리 없음 — 채우기만)

2. **썸 렌더링**: `SketchCirclePainter` 사용
   - 원형 도형 + 불규칙한 가장자리
   - `enableNoise: true`
   - 크기: 기존 `thumbSize = height - 8.0` 유지

3. **색상 매핑** (SketchThemeExtension 활용):
   | 상태 | 트랙 색상 | 썸 색상 |
   |------|----------|---------|
   | ON (Light) | `textColor` (#343434) | `fillColor` (#FAF8F5) |
   | OFF (Light) | `borderColor` (#343434) opacity 0.3 | `fillColor` (#FAF8F5) |
   | ON (Dark) | `textColor` (#F5F5F5) | `fillColor` (#1A1D29) |
   | OFF (Dark) | `borderColor` (#5E5E5E) | `fillColor` (#1A1D29) |

4. **기존 유지 항목**:
   - 위젯 크기: width=50, height=28
   - 애니메이션: 200ms easeInOut
   - 비활성화: opacity 0.5
   - 공개 API (파라미터 시그니처)

### Step 2: Demo 앱 검증

**파일**: `apps/mobile/apps/design_system_demo/lib/app/modules/widgets/views/demos/switch_demo.dart`

- 기존 데모 코드로 light/dark mode 전환 시 정상 렌더링 확인
- 추가 수정 불필요 예상 (기존 데모가 ON/OFF/Disabled 모두 커버)

## 의존성 그래프

```
SketchPainter (기존, 수정 없음)
    ↑
SketchCirclePainter (기존, 수정 없음)
    ↑
SketchSwitch (핵심 수정)
    ↑
switch_demo.dart (검증만)
```

## 리스크

- `SketchPainter`/`SketchCirclePainter`의 roughness/seed가 작은 크기(50x28)에서
  과도하게 보일 수 있음 → roughness 값 조절 필요할 수 있음
- 애니메이션 중 `CustomPaint` 재렌더링 성능 → seed 고정으로 불필요한 변형 방지
