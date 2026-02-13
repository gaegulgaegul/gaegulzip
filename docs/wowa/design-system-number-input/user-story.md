# User Story: SketchInput Number 모드

## 개요

디자인 시스템의 숫자 입력 컴포넌트를 리디자인한다.
기존 독립 위젯 `SketchNumberInput`을 폐지하고, `SketchInput`에 `number` 모드를 추가하여 통합한다.
새 디자인은 에셋 이미지(number-input-light-mode.png, number-input-dark-mode.png)의 질감을 충실히 재현해야 한다.

## 사용자 스토리

**As a** 앱 개발자,
**I want to** `SketchInput(mode: SketchInputMode.number)` 형태로 숫자 입력을 사용할 수 있기를,
**So that** 별도의 위젯 없이 일관된 API로 모든 입력 모드를 사용할 수 있다.

## 요구사항

### 디자인 요구사항
1. **에셋 이미지 기반 디자인**: 라이트/다크 모드별 에셋 이미지의 레이아웃과 질감을 재현
   - 둥근 사각형 컨테이너 안에 숫자 텍스트 + 오른쪽에 세로 구분선 + 위/아래 chevron 버튼
   - SketchPainter 기반 스케치 테두리와 노이즈 텍스처 유지
2. **크기**: 기존 SketchInput과 동일한 높이(44px) 유지
3. **Light/Dark 모드**: 각각 적용
4. **Label**: 항상 상단 고정, 옵셔널

### 기능 요구사항
1. **SketchInputMode.number** enum 값 추가
2. **Number 모드 전용 기능**:
   - 숫자 전용 키보드
   - 증가/감소 chevron 버튼 (컨테이너 내부 오른쪽)
   - min/max 범위 제한
   - step 단위 증감
   - 소수점 자릿수(decimalPlaces) 지원
   - 접미사(suffix) 지원
3. **SketchInput에 number 관련 파라미터 추가**:
   - `numberValue`: 현재 숫자 값
   - `onNumberChanged`: 숫자 변경 콜백
   - `min`, `max`: 범위
   - `step`: 증감 단위 (기본 1.0)
   - `decimalPlaces`: 소수점 자릿수 (기본 0)
   - `suffix`: 접미사 텍스트

### 통합 요구사항
1. 기존 `SketchNumberInput`은 위젯 카탈로그에서 제거
2. 데모 앱에서 `SketchInput` 데모 내에서 number 모드를 확인 가능하도록 변경
3. `NumberInputDemo`는 삭제 또는 `InputDemo`로 통합

## 에셋 이미지 분석

### Light Mode (number-input-light-mode.png)
- 배경: 흰색
- 테두리: 굵은 검정 손그림 스타일
- 텍스트: "365" 왼쪽 정렬
- 오른쪽: 세로 구분선 | 위(^) 아래(v) chevron 스택
- 전체 형태: 둥근 사각형 (pill에 가까움)

### Dark Mode (number-input-dark-mode.png)
- 배경: 어두운색
- 테두리: 흰색 손그림 스타일
- 텍스트: "365" 흰색
- 오른쪽: 세로 구분선 | 위(^) 아래(v) chevron 흰색
- 전체 형태: 동일한 둥근 사각형

## 수용 기준

- [ ] `SketchInput(mode: SketchInputMode.number)` 사용 가능
- [ ] 에셋 이미지와 동일한 레이아웃 (텍스트 + 세로 구분선 + 위/아래 버튼)
- [ ] Light/Dark 모드에서 각각 올바른 색상 적용
- [ ] 기존 SketchInput과 동일한 높이 유지
- [ ] min/max 범위 제한 동작
- [ ] step 단위 증감 동작
- [ ] Label 상단 고정, 옵셔널
- [ ] SketchNumberInput이 카탈로그에서 제거됨
- [ ] design_system_demo의 SketchInput 데모에서 number 모드 확인 가능

## 플랫폼

**Mobile** — `apps/mobile/packages/design_system/` + `apps/mobile/apps/design_system_demo/`

## 영향 범위

| 파일 | 변경 내용 |
|------|----------|
| `sketch_input.dart` | `SketchInputMode.number` 추가, number 관련 파라미터 추가, number 모드 build 로직 |
| `widget_catalog_controller.dart` | `SketchNumberInput` 항목 제거 |
| `widget_demo_view.dart` | `SketchNumberInput` case 제거 |
| `input_demo.dart` | number 모드 데모 추가 |
| `number_input_demo.dart` | 삭제 또는 InputDemo로 통합 |
| `README.md` | SketchNumberInput → SketchInput number 모드로 문서 업데이트 |
