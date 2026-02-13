# User Story: design-system-selectbox

## 개요

SketchDropdown(Selectbox) 위젯을 Frame0 스케치 디자인 에셋에 맞게 리빌드한다.

## 사용자 스토리

**사용자로서**, 드롭다운/셀렉트박스를 사용할 때 다른 스케치 디자인 시스템 컴포넌트(SketchButton, SketchInput 등)와 동일한 손그림 스타일 질감을 경험하고 싶다.

## 요구사항

### 핵심 요구사항

1. **SketchPainter 적용**: `BoxDecoration` → `CustomPaint` + `SketchPainter`로 변경하여 손그림 질감 표현
2. **Label 지원**: SketchInput처럼 selectbox 위에 옵셔널 label 텍스트 표시
3. **Light/Dark 모드**: SketchThemeExtension을 통한 라이트/다크 모드 지원
4. **크기 유지**: 기존 height(44.0px) 동일하게 유지
5. **Overlay(드롭다운 목록)에도 SketchPainter 적용**: 열린 상태의 옵션 목록도 스케치 스타일

### 에셋 참조

| 모드 | 파일 | 특징 |
|------|------|------|
| Light | `prompt/archives/select-light-mode.png` | 검정 두꺼운 손그림 테두리, 흰 배경, 검정 텍스트, 손그림 chevron |
| Dark | `prompt/archives/select-dark-mode.png` | 흰 손그림 테두리, 어두운 배경, 흰 텍스트, 흰 chevron |
| Label Light | `prompt/archives/input-light-mode.png` | Label 텍스트가 입력 필드 위에 위치 |
| Label Dark | `prompt/archives/input-dark-mode.png` | 다크 모드 Label 스타일 |

### 상세 변경사항

#### 1. `sketch_dropdown.dart` 수정

**메인 버튼 영역:**
- `Container` + `BoxDecoration` → `CustomPaint` + `SketchPainter`
- SketchButton 패턴 참조 (`seed` = hint/value hashCode 기반)
- `arrow_drop_down` Material 아이콘 → 손그림 스타일 chevron (SketchPainter의 roughness로 Icon 대신 CustomPaint로 chevron 그리기 또는 스케치 스타일에 맞는 아이콘 사용)

**Label 추가:**
- `String? label` 파라미터 추가
- SketchInput의 label 렌더링 패턴 동일 적용
- Column(label → SizedBox(6) → selectbox) 구조

**Overlay (드롭다운 목록):**
- `Container` + `BoxDecoration` → `CustomPaint` + `SketchPainter`
- 선택된 항목 하이라이트도 스케치 테마 적용

**테마 색상:**
- Light: borderColor = base900, fillColor = white/background
- Dark: borderColor = base700, fillColor = backgroundDark
- SketchThemeExtension에서 자동 적용

#### 2. `dropdown_demo.dart` 수정

- Label이 있는 셀렉트박스 데모 추가
- Label이 없는 셀렉트박스 데모 유지
- 비활성화 상태 데모 유지

## 영향 범위

| 파일 | 변경 유형 |
|------|----------|
| `sketch_dropdown.dart` | 주요 수정 - SketchPainter 적용, label 추가 |
| `dropdown_demo.dart` | 데모 업데이트 - label 변형 추가 |

## 플랫폼

- **Mobile** (Flutter design_system 패키지)
