# 사용자 스토리: SketchAppBar 스케치 스타일 개선

## 개요

디자인 시스템의 SketchAppBar 위젯을 Frame0 스케치 스타일로 개선한다.
현재 일반 `BoxDecoration`으로 렌더링되는 앱바를 `SketchPainter` 기반의 손그림 테두리 질감으로 교체하여,
다른 스케치 컴포넌트(SketchButton, SketchContainer, SketchModal 등)와 시각적 일관성을 확보한다.

## 사용자 스토리

### US-1: 스케치 테두리 적용
- **As a** 디자인 시스템 사용자
- **I want to** SketchAppBar가 손으로 그린 듯한 불규칙한 테두리 질감을 가지길
- **So that** 다른 스케치 컴포넌트와 동일한 Frame0 미학을 유지할 수 있다

### US-2: 테마 대응
- **As a** 앱 사용자
- **I want to** 라이트/다크 모드에서 적절한 색상의 스케치 테두리가 표시되길
- **So that** 어떤 테마에서든 일관된 시각적 경험을 얻을 수 있다

### US-3: 선택적 활성화
- **As a** 개발자
- **I want to** 스케치 테두리를 선택적으로 켜고 끌 수 있길
- **So that** 화면에 따라 스타일을 유연하게 조절할 수 있다

## 사용자 시나리오

### 시나리오 1: 스케치 테두리가 적용된 앱바 표시 (정상 플로우)
1. 개발자가 `SketchAppBar(showSketchBorder: true, title: '홈')`을 설정
2. 앱바가 렌더링됨
3. 앱바 하단에 손으로 그린 듯한 불규칙한 테두리가 표시됨
4. 테두리는 SketchPainter의 2-pass 렌더링으로 겹쳐진 선 질감을 가짐
5. 결과: 사용자가 SketchModal, SketchContainer와 동일한 손그림 스타일의 앱바를 확인함

### 시나리오 2: 라이트 모드에서 스케치 앱바
1. 시스템 테마가 라이트 모드로 설정됨
2. 앱바가 렌더링됨
3. 앱바 배경은 흰색/크림색
4. 스케치 테두리는 어두운 색상 (검정/네이비)
5. 제목 텍스트는 어두운 색상
6. 결과: 밝은 배경 위에 진한 손그림 테두리가 명확하게 표시됨

### 시나리오 3: 다크 모드에서 스케치 앱바
1. 시스템 테마가 다크 모드로 설정됨
2. 앱바가 렌더링됨
3. 앱바 배경은 어두운 색상 (네이비/회색)
4. 스케치 테두리는 밝은 색상 (흰색)
5. 제목 텍스트는 흰색
6. 결과: 어두운 배경 위에 밝은 손그림 테두리가 명확하게 표시됨

### 시나리오 4: 스케치 테두리 비활성화
1. 개발자가 `SketchAppBar(showSketchBorder: false, title: '설정')`을 설정
2. 앱바가 렌더링됨
3. 스케치 테두리가 표시되지 않음
4. 일반 배경색만 적용됨
5. 결과: 깔끔한 플랫 스타일 앱바가 표시됨

### 시나리오 5: 데모 앱에서 확인
1. 개발자가 `design_system_demo` 앱을 실행
2. AppBar 데모 화면으로 이동
3. 라이트/다크 모드 토글 버튼 클릭
4. 스케치 테두리가 있는/없는 앱바 비교 가능
5. roughness, seed 조절로 스케치 느낌 변화 확인 가능
6. 결과: 데모 앱에서 실시간으로 스타일 변경 사항을 확인함

## 인수 조건 (Acceptance Criteria)

### 시각적 스타일
- [ ] `showSketchBorder: true`일 때 앱바 하단에 손그림 스타일 테두리 렌더링
- [ ] SketchPainter의 2-pass 렌더링 기법 적용 (겹쳐진 불규칙한 선 질감)
- [ ] SketchContainer, SketchModal과 동일한 수준의 손그림 느낌
- [ ] 테두리는 앱바 전체 너비에 걸쳐 표시됨

### 테마 대응
- [ ] 라이트 모드: 흰색/크림색 배경 + 어두운 색상 스케치 테두리
- [ ] 다크 모드: 어두운 배경 + 밝은 색상 (흰색) 스케치 테두리
- [ ] `SketchThemeExtension`의 `borderColor`, `fillColor` 자동 연동
- [ ] 시스템 테마 변경 시 즉시 반영

### 파라미터 동작
- [ ] `showSketchBorder: false`일 때 스케치 테두리 렌더링 안 함
- [ ] `showSketchBorder: true`일 때만 SketchPainter 적용
- [ ] `backgroundColor`, `foregroundColor` 파라미터 정상 동작
- [ ] `strokeWidth`, `roughness` 등 스케치 속성 커스터마이징 가능 (선택적)

### 기존 API 호환성
- [ ] `SketchAppBar(title, titleWidget, leading, actions, height)` 기존 시그니처 유지
- [ ] `Scaffold.appBar`에서 정상 동작
- [ ] `PreferredSizeWidget` 인터페이스 유지
- [ ] 기존 사용 코드 변경 없이 동작

### 성능
- [ ] CustomPaint 사용으로 인한 성능 저하 없음
- [ ] 앱바 렌더링 시 버벅임 없음
- [ ] 불필요한 리빌드 최소화

### 데모 앱 검증
- [ ] `design_system_demo` 앱의 AppBar 데모에서 스케치 테두리 확인 가능
- [ ] 라이트/다크 모드 전환 시 테두리 색상 변경 확인
- [ ] `showSketchBorder` 토글로 테두리 on/off 확인
- [ ] 스크린샷으로 시각적 품질 검증

## 엣지 케이스

- **앱바 높이가 매우 작을 때**: 스케치 테두리가 겹치지 않도록 strokeWidth 자동 조절 또는 최소 높이 제약
- **커스텀 backgroundColor 사용**: 사용자 지정 배경색에서도 테두리가 명확히 보이도록 borderColor 대비 보장
- **그림자와 스케치 테두리 동시 사용**: `showShadow: true`와 `showSketchBorder: true`가 함께 사용될 때 시각적 충돌 없음
- **다국어 긴 제목**: 제목이 길어져도 스케치 테두리 레이아웃 깨지지 않음
- **StatusBar 높이 변화**: 노치/펀치홀 디바이스에서도 테두리가 정상 위치에 렌더링

## 비즈니스 규칙

- 스케치 테두리는 앱바 하단에만 표시 (상단, 좌우는 표시 안 함)
- 기본값 `showSketchBorder: false` 유지 (기존 앱 호환성)
- SketchPainter의 `seed` 파라미터는 고정값 사용 (매번 다른 모양 방지)
- `roughness`는 SketchThemeExtension의 기본값 사용
- 스케치 테두리 두께는 SketchDesignTokens의 strokeStandard 기준

## 필요한 데이터

| 데이터 | 타입 | 필수 | 설명 |
|--------|------|------|------|
| showSketchBorder | bool | ❌ | 스케치 테두리 표시 여부 (기본값: false) |
| strokeWidth | double? | ❌ | 스케치 테두리 두께 (null이면 테마 기본값) |
| roughness | double? | ❌ | 스케치 거칠기 (null이면 테마 기본값) |
| seed | int | ❌ | 스케치 렌더링 시드 (재현 가능한 무작위성) |
| backgroundColor | Color? | ❌ | 앱바 배경색 (null이면 테마 fillColor) |
| foregroundColor | Color? | ❌ | 텍스트/아이콘 색상 (null이면 테마 textColor) |

## 비기능 요구사항

### 성능
- CustomPaint 렌더링이 60fps 유지
- 스케치 테두리 생성에 16ms 이하 소요
- 테마 변경 시 리빌드 최소화

### 접근성
- 스케치 테두리가 텍스트 가독성에 영향 없음
- WCAG AA 기준 색상 대비 유지 (테두리 vs 배경)

### 일관성
- SketchContainer, SketchModal과 동일한 SketchPainter 파라미터 사용
- 2-pass 렌더링 기법 (seed + seed+50) 동일 적용
- `SketchDesignTokens.irregularBorderRadius` 사용

### 에러 처리
- `showSketchBorder: true`이지만 테마가 없을 때: 폴백 색상 사용 (검정)
- CustomPaint 에러 시: 기존 BoxDecoration으로 fallback
- 사용자에게 에러 메시지 표시 안 함 (조용히 처리)

## 참조 디자인

### 기존 참조 위젯
- `SketchContainer`: 2-pass SketchPainter 사용, 전체 테두리 렌더링
- `SketchModal`: 팝업 메뉴 스타일 손그림 테두리
- `SketchPainter`: RRect path metric 기반 스케치 테두리 생성

### 디자인 이미지 참조
- `img_23`, `img_24`: 팝업 메뉴 위젯의 손그림 테두리 질감
- SketchContainer의 불규칙한 둥근 모서리 스타일

### 스케치 품질 기준
- roughness: 1.4 (기본값의 1.75배, SketchContainer와 동일)
- strokeWidth: 3.0 (strokeStandard의 1.5배, SketchContainer와 동일)
- 2-pass 렌더링: 동일 영역에 seed 차이로 2번 그려 밀도 증가
- enableNoise: true (1st pass), false (2nd pass)

## 플랫폼

**Mobile** (Flutter design_system 패키지)
