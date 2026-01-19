# 사용자 스토리: 소셜 로그인 버튼 컴포넌트

## 개요

카카오, 네이버, 애플, 구글의 소셜 로그인 버튼 컴포넌트를 Sketch Design System 스타일로 구현합니다. 각 플랫폼의 공식 디자인 가이드라인을 준수하면서도 wowa 앱의 Frame0 스케치 스타일과 조화롭게 통합합니다.

## 사용자 스토리

### Story 1: 소셜 로그인 버튼 컴포넌트 구현

**As a** 사용자
**I want** 카카오, 네이버, 애플, 구글 계정으로 간편하게 로그인할 수 있는 버튼을 사용하고 싶다
**So that** 별도의 회원가입 절차 없이 빠르게 서비스를 이용할 수 있다

**인수 조건**:
- [ ] 4개 소셜 로그인 플랫폼(카카오, 네이버, 애플, 구글)의 버튼이 각각 구현되어 있다
- [ ] 각 플랫폼의 공식 디자인 가이드라인(색상, 로고, 텍스트)을 준수한다
- [ ] Sketch Design System의 손그림 스타일(불규칙한 테두리, roughness)이 적용되어 있다
- [ ] 버튼 클릭 시 각 플랫폼에 해당하는 콜백 함수가 호출된다
- [ ] 로딩 상태를 지원하여 API 호출 중 시각적 피드백을 제공한다

### Story 2: 플랫폼별 브랜드 아이덴티티 유지

**As a** 디자이너
**I want** 각 소셜 플랫폼의 브랜드 아이덴티티가 명확히 구분되도록 표현하고 싶다
**So that** 사용자가 어떤 계정으로 로그인하는지 직관적으로 인지할 수 있다

**인수 조건**:
- [ ] 카카오: 카카오 옐로우(#FEE500) 배경, 검은색 텍스트, 말풍선 로고 포함
- [ ] 네이버: 네이버 그린(#03C75A) 배경, 흰색 텍스트, 네이버 N 로고 포함
- [ ] 애플: 검은색/흰색 배경 선택 가능, 대비되는 텍스트 색상, 애플 로고 포함
- [ ] 구글: 흰색 배경, 회색 테두리, 검은색 텍스트, 구글 G 로고 포함
- [ ] 각 버튼의 로고 이미지가 SVG 또는 아이콘으로 제공된다

### Story 3: 반응형 크기 지원

**As a** 개발자
**I want** 다양한 화면 크기와 레이아웃에 맞는 버튼 크기를 선택할 수 있다
**So that** 로그인 화면, 설정 화면 등 다양한 컨텍스트에서 일관되게 사용할 수 있다

**인수 조건**:
- [ ] 3가지 크기(small, medium, large)를 지원한다
- [ ] Small: 32px 높이, 8px/16px 패딩
- [ ] Medium: 40px 높이, 12px/24px 패딩 (기본값)
- [ ] Large: 48px 높이, 16px/32px 패딩
- [ ] 터치 영역이 Material Design 최소 기준(44x44dp)을 충족한다

### Story 4: 접근성 및 상태 관리

**As a** 시각 장애가 있는 사용자
**I want** 스크린 리더가 각 버튼의 용도를 명확히 읽어주기를 원한다
**So that** 어떤 소셜 플랫폼으로 로그인하는지 정확히 이해할 수 있다

**인수 조건**:
- [ ] 각 버튼에 의미론적 레이블이 제공된다 (예: "카카오 계정으로 로그인")
- [ ] 비활성화 상태에서 불투명도가 0.4로 적용되어 시각적으로 구분된다
- [ ] 로딩 상태에서 CircularProgressIndicator가 표시되고 버튼이 비활성화된다
- [ ] 색상 대비가 WCAG AA 기준(4.5:1 이상)을 충족한다

## 사용자 시나리오

### Scenario 1: 로그인 화면에서 카카오 로그인 사용

1. 사용자가 로그인 화면에 진입한다
2. 시스템이 4개의 소셜 로그인 버튼(카카오, 네이버, 애플, 구글)을 표시한다
3. 사용자가 "카카오 계정으로 로그인" 버튼을 탭한다
4. 시스템이 버튼을 로딩 상태로 변경하고 스피너를 표시한다
5. 시스템이 카카오 OAuth 인증 플로우를 시작한다
6. 인증 성공 시 메인 화면으로 이동한다

### Scenario 2: 설정 화면에서 계정 연결

1. 사용자가 설정 화면의 "계정 연결" 섹션에 진입한다
2. 시스템이 연결 가능한 소셜 로그인 버튼들을 작은 크기(small)로 표시한다
3. 사용자가 "구글 계정 연결" 버튼을 탭한다
4. 시스템이 구글 OAuth 인증을 진행한다
5. 연결 성공 시 버튼이 "구글 계정 연결됨"으로 변경되고 비활성화된다

### Scenario 3: 에러 처리

1. 사용자가 네이버 로그인 버튼을 탭한다
2. 시스템이 로딩 상태를 표시한다
3. 네트워크 오류로 인증이 실패한다
4. 시스템이 로딩 상태를 해제하고 버튼을 다시 활성화한다
5. 시스템이 SketchModal로 에러 메시지를 표시한다

## 필요한 데이터

### 입력 데이터

- **플랫폼 타입**: enum SocialLoginPlatform { kakao, naver, apple, google }
- **버튼 크기**: enum SketchButtonSize { small, medium, large }
- **버튼 텍스트**: String? (기본값: "카카오 계정으로 로그인" 등)
- **로딩 상태**: bool isLoading
- **비활성화 상태**: bool? enabled (onPressed가 null이면 비활성화)
- **콜백 함수**: VoidCallback? onPressed

### 출력 데이터

- **사용자 액션**: 버튼 탭 시 onPressed 콜백 호출
- **시각적 피드백**: 버튼 눌림 애니메이션 (scale: 0.98, roughness +0.3)

### 외부 리소스

- **카카오 로고**: SVG 또는 PNG 에셋 (말풍선 심볼)
- **네이버 로고**: SVG 또는 PNG 에셋 (N 로고)
- **애플 로고**: SVG 또는 PNG 에셋 (애플 심볼)
- **구글 로고**: SVG 또는 PNG 에셋 (G 로고)

## UI/UX 요구사항

### 화면 구성

- **로그인 화면**: 4개 버튼이 세로로 나열, 16px 간격
- **설정 화면**: 계정 연결 섹션에 작은 크기 버튼 표시
- **빠른 로그인 모달**: 카드 형태 모달 내에 버튼 그룹 표시

### 인터랙션

- **버튼 탭**: 0.98 스케일 축소, roughness +0.3, seed 변경으로 다른 모양
- **로딩 시작**: 텍스트/로고 숨김, CircularProgressIndicator 표시
- **로딩 완료**: 원래 상태 복원 또는 다음 화면 전환
- **비활성화**: 불투명도 0.4, 탭 불가

### 모바일 UI 고려사항

- **터치 영역**: 최소 48x48dp 보장 (Large 사이즈 권장)
- **스크롤 동작**: 로그인 화면에서 버튼 4개 표시 시 스크롤 불필요
- **반응형 레이아웃**: 세로/가로 모드 모두 지원, 가로 모드에서는 2x2 그리드 고려
- **Safe Area**: iOS에서 노치/홈 인디케이터 영역 회피

### 디자인 상세

#### 카카오 버튼
```dart
fillColor: Color(0xFFFEE500)  // 카카오 옐로우
borderColor: Color(0xFFFEE500)
textColor: Color(0xFF000000)  // 검은색
logo: 말풍선 심볼
기본 텍스트: "카카오 계정으로 로그인"
```

#### 네이버 버튼
```dart
fillColor: Color(0xFF03C75A)  // 네이버 그린
borderColor: Color(0xFF03C75A)
textColor: Color(0xFFFFFFFF)  // 흰색
logo: N 로고
기본 텍스트: "네이버 계정으로 로그인"
```

#### 애플 버튼
```dart
// Dark 스타일 (기본)
fillColor: Color(0xFF000000)  // 검은색
borderColor: Color(0xFF000000)
textColor: Color(0xFFFFFFFF)  // 흰색

// Light 스타일
fillColor: Color(0xFFFFFFFF)  // 흰색
borderColor: Color(0xFF000000)
textColor: Color(0xFF000000)  // 검은색

logo: 애플 심볼
기본 텍스트: "Apple로 로그인" (애플 가이드라인 준수)
```

#### 구글 버튼
```dart
fillColor: Color(0xFFFFFFFF)  // 흰색
borderColor: Color(0xFFDCDCDC)  // 밝은 회색
textColor: Color(0xFF000000)  // 검은색
logo: 구글 G 로고 (4색 버전)
기본 텍스트: "Google 계정으로 로그인"
```

## 비기능 요구사항

### 성능

- **렌더링 시간**: 초기 렌더링 16ms 이하 (60fps 유지)
- **애니메이션**: 부드러운 탭 반응 (100ms 이내)
- **이미지 로딩**: 로고 이미지 캐싱으로 즉시 표시

### 접근성

- **색상 대비**:
  - 카카오: 검은 텍스트/노란 배경 = 16.7:1 (AAA) ✅
  - 네이버: 흰 텍스트/녹색 배경 = 3.8:1 (AA 미달 주의)
  - 애플: 흰 텍스트/검정 배경 = 21:1 (AAA) ✅
  - 구글: 검은 텍스트/흰 배경 = 21:1 (AAA) ✅
- **터치 영역**: 48x48dp 이상 (Material Design 기준)
- **스크린 리더**: Semantics 위젯으로 명확한 레이블 제공

### 에러 처리

- **네트워크 오류**: 로딩 상태 해제 후 SketchModal로 에러 표시
- **인증 실패**: 사용자에게 실패 이유 안내 (권한 거부, 계정 없음 등)
- **타임아웃**: 30초 후 자동 타임아웃, 재시도 버튼 제공
- **권한 거부**: 사용자가 OAuth 권한을 거부한 경우 정상 복귀

### 코드 품질

- **재사용성**: SocialLoginButton 위젯으로 4개 플랫폼 공통 로직 추출
- **타입 안전성**: enum으로 플랫폼 타입 정의, 잘못된 값 방지
- **테스트 용이성**: onPressed 콜백 주입으로 단위 테스트 가능
- **일관성**: SketchButton 기반으로 구현하여 디자인 시스템 일관성 유지

## 기술 제약사항

### Flutter/Dart

- **Flutter SDK**: 3.0 이상
- **Dart SDK**: 3.0 이상
- **의존성**: design_system 패키지의 SketchButton 확장

### 플랫폼 가이드라인 준수

- **카카오**: [디자인 가이드](https://developers.kakao.com/docs/latest/ko/kakaologin/design-guide) 준수
- **네이버**: 네이버 그린 색상(#03C75A) 사용, N 로고 변형 금지
- **애플**: [Apple Design Guidelines](https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple) 준수
  - 텍스트는 "Sign in with", "Sign up with", "Continue with"만 허용
  - 검은색/흰색 조합만 가능
- **구글**: [Google Branding Guidelines](https://developers.google.com/identity/branding-guidelines) 준수
  - Roboto 폰트 권장
  - 4색 G 로고 사용

### 디자인 시스템 통합

- **SketchPainter**: 손그림 스타일 테두리 렌더링
- **Roughness**: 기본값 0.8 사용
- **Stroke Width**: SketchDesignTokens.strokeStandard (2.0px)
- **NoiseTexture**: outline 스타일 제외하고 모두 적용

## 참고 자료

### 공식 디자인 가이드라인

- [카카오 로그인 디자인 가이드](https://developers.kakao.com/docs/latest/ko/kakaologin/design-guide)
- [네이버 소셜 로그인 가이드](https://developers.naver.com/docs/login/api/)
- [Apple Sign In Guidelines](https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple)
- [Google Sign-In Branding Guidelines](https://developers.google.com/identity/branding-guidelines)

### 참고 자료 및 디자인 사례

- [소셜로그인 버튼 회사별 가이드라인](https://brunch.co.kr/@bf6b5403fa344c4/43)
- [간편 로그인 디자인 UX 가이드](https://ditoday.com/간편-로그인-디자인-어떻게-할까-_-ux-디자인과-개발/)
- [Figma 커뮤니티: 카카오 네이버 로그인 디자인 가이드](https://www.figma.com/community/file/1232637617420363657)

### 내부 문서

- `.claude/guides/design_system.md` - Sketch Design System 완전 가이드
- `packages/design_system/lib/src/widgets/sketch_button.dart` - 기본 버튼 구현 참조

## 구현 범위

### Phase 1: 기본 컴포넌트 구현
- [ ] SocialLoginButton 위젯 생성
- [ ] 4개 플랫폼별 enum 및 스타일 정의
- [ ] 로고 에셋 추가 (SVG/PNG)

### Phase 2: 상태 관리 및 인터랙션
- [ ] 로딩 상태 구현
- [ ] 비활성화 상태 구현
- [ ] 탭 애니메이션 적용

### Phase 3: 접근성 및 품질
- [ ] Semantics 레이블 추가
- [ ] 색상 대비 검증
- [ ] 터치 영역 크기 검증

### Phase 4: 문서화
- [ ] 사용 예제 작성 (로그인 화면, 설정 화면)
- [ ] API 문서 작성
- [ ] 디자인 시스템 가이드에 추가

## 다음 단계

이 사용자 스토리를 기반으로 **ui-ux-designer** 에이전트가 다음 작업을 수행합니다:
1. 와이어프레임 및 UI 명세 작성
2. 컴포넌트 상세 디자인 스펙 정의
3. 사용 예제 화면 레이아웃 설계
