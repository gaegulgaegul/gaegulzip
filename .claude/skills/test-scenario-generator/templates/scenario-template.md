# [기능명] 테스트 시나리오

> 생성일: [YYYY-MM-DD]
> 대상 기능: [기능에 대한 한 줄 설명]
> 참조 문서: brief.md, design-spec.md, user-stories.md

## 개요

[기능에 대한 간단한 설명 - 2-3문장]
[이 테스트 시나리오가 커버하는 범위]

## 테스트 환경

- **플랫폼**: iOS 14+, Android 7.0+
- **Flutter 버전**: [예: 3.16.0]
- **GetX 버전**: [예: 4.6.6]
- **테스트 도구**:
  - **@mobilenext/mobile-mcp** (자동화 + UI 검증): `.mcp.json`에 등록된 MCP 서버

## 사전 조건

- [ ] 앱이 빌드되고 에뮬레이터/시뮬레이터에서 실행 가능한 상태
- [ ] Flutter 개발 환경이 설정되어 있음 (`flutter doctor` 통과)
- [ ] 필요한 API 서버가 정상 동작 중 (해당하는 경우)
- [ ] 테스트 계정 정보 준비 (인증이 필요한 경우)

---

## 테스트 시나리오: [기능명]

### Scenario 1: [시나리오명] (Happy Path)

**우선순위**: High | Medium | Low
**카테고리**: 기능 테스트 | UI/UX 테스트 | 통합 테스트

**Given**: [초기 상태를 명확히 설명]
- 예: 사용자가 홈 화면에 있다
- 예: 로그인이 완료된 상태이다
- 예: 네트워크 연결이 정상이다

**When**: [사용자가 수행하는 액션]
- 예: "[위젯명]" 버튼을 탭한다
- 예: "[필드명]" 입력 필드에 "[텍스트]"를 입력한다
- 예: 화면을 아래로 스크롤한다

**Then**: [예상되는 결과 - 구체적으로]
- 예: "[화면명]" 화면으로 이동한다
- 예: "[데이터]"가 화면에 표시된다
- 예: 로딩 인디케이터가 나타났다가 사라진다
- 예: "[메시지]" 스낵바가 표시된다

**수동 테스트 절차**:
1. [단계 1 - 매우 구체적으로]
   - 예상 결과: [무엇을 확인해야 하는지]
   - 스크린샷: [캡처할 화면 또는 위젯]
2. [단계 2]
   - 예상 결과: [무엇을 확인해야 하는지]
   - 로그 확인: `flutter logs | grep "[키워드]"`
3. [단계 3]
   - 예상 결과: [무엇을 확인해야 하는지]

**자동화 테스트 및 UI 검증 (@mobilenext/mobile-mcp)**:
```
# MCP 서버(.mcp.json)에 등록됨 — Claude가 직접 도구로 호출

# 자동화 테스트 (UI 인터랙션)
- mobile_list_elements_on_screen: 화면 요소 확인
- mobile_click_on_screen_at_coordinates: "[버튼명]" 탭
- mobile_type_keys: "[필드명]에 '[텍스트]' 입력"
- mobile_take_screenshot: "[scenario_name]_before.png" 캡처

# UI 검증 (접근성 트리 기반)
- mobile_list_elements_on_screen: '[텍스트]' 요소 확인, '[레이블]' 버튼 확인
- mobile_take_screenshot: "[scenario_name]_after.png" 캡처
- 터치 영역이 44x44pt 이상인지 확인
- 색 대비가 WCAG AA 기준을 만족하는지 확인
- design-spec.md의 [화면명] 디자인과 일치하는지 비교
```

**검증 체크리스트**:
- [ ] UI가 design-spec.md의 명세와 정확히 일치하는가?
  - [ ] 색상 (Primary, Secondary, Background, Text)
  - [ ] 타이포그래피 (FontSize, FontWeight, LineHeight)
  - [ ] 스페이싱 (Padding, Margin, Gap)
  - [ ] Border Radius, Elevation
- [ ] 로딩 상태가 사용자에게 명확히 표시되는가?
- [ ] 에러 상태가 사용자에게 이해하기 쉽게 전달되는가?
- [ ] GetX 상태 관리가 정상적으로 동작하는가? (Obx 업데이트)
- [ ] 접근성 레이블이 모든 인터랙티브 요소에 있는가?
- [ ] Hot reload 후에도 상태가 유지되거나 정상 복구되는가?
- [ ] 화면 회전 시에도 레이아웃이 정상인가? (필요 시)

---

### Scenario 2: [시나리오명] (Alternative Path)

**우선순위**: High | Medium | Low
**카테고리**: 기능 테스트 | UI/UX 테스트 | 통합 테스트

**Given**: [초기 상태]

**When**: [대체 경로의 사용자 액션]
- 예: 버튼 대신 제스처 사용
- 예: 다른 순서로 액션 수행
- 예: 선택적 단계 생략

**Then**: [같은 목표에 도달하는지 확인]

**수동 테스트 절차**:
1. [단계별 절차]

**자동화 테스트 및 UI 검증 (@mobilenext/mobile-mcp)**:
```
# mobile_list_elements_on_screen, mobile_click_on_screen_at_coordinates,
# mobile_type_keys, mobile_take_screenshot 등 MCP 도구 호출
```

**검증 체크리스트**:
- [ ] [체크리스트 항목들]

---

### Scenario 3: [시나리오명] (Edge Case)

**우선순위**: Medium | Low
**카테고리**: 엣지 케이스 테스트

**엣지 케이스 유형**:
- [ ] 빈 입력
- [ ] 긴 텍스트 (UI 깨짐 확인)
- [ ] 특수 문자 (이모지, 다국어 등)
- [ ] 경계 값 (최소/최대)
- [ ] 네트워크 없음
- [ ] 느린 네트워크
- [ ] 권한 거부
- [ ] 기타: [설명]

**Given**: [엣지 케이스 초기 상태]

**When**: [엣지 케이스를 유발하는 액션]

**Then**: [앱이 어떻게 처리해야 하는지]
- 예: 유효성 검증 에러 메시지 표시
- 예: 기본값으로 대체
- 예: 사용자에게 명확한 안내 메시지

**수동 테스트 절차**:
1. [엣지 케이스 재현 방법]
2. [예상 동작 확인]

**자동화 테스트 및 UI 검증 (@mobilenext/mobile-mcp)**:
```
# mobile_list_elements_on_screen, mobile_click_on_screen_at_coordinates,
# mobile_type_keys, mobile_take_screenshot 등 MCP 도구 호출
```

**검증 체크리스트**:
- [ ] 앱이 크래시하지 않는가?
- [ ] 사용자에게 명확한 피드백이 제공되는가?
- [ ] 복구 방법이 제시되는가?
- [ ] UI가 깨지지 않는가?

---

### Scenario 4: [시나리오명] (Error Case)

**우선순위**: High | Medium
**카테고리**: 에러 핸들링 테스트

**에러 유형**:
- [ ] API 에러 (400, 401, 403, 404, 500)
- [ ] 네트워크 타임아웃
- [ ] JSON 파싱 에러
- [ ] 유효성 검증 실패
- [ ] 중복 액션 (버튼 중복 클릭)
- [ ] 기타: [설명]

**Given**: [에러 발생 조건 설정]
- 예: API 서버가 500 에러를 반환하도록 설정
- 예: 네트워크 연결을 끊은 상태
- 예: 잘못된 형식의 데이터 입력

**When**: [에러를 유발하는 액션]

**Then**: [에러 처리 동작]
- 예: "[에러 메시지]"가 스낵바로 표시된다
- 예: 재시도 버튼이 나타난다
- 예: 이전 화면으로 돌아간다
- 예: 로딩 인디케이터가 사라진다

**수동 테스트 절차**:
1. [에러 조건 재현 방법]
   - 예: Chrome DevTools에서 네트워크 throttling 설정
   - 예: API 응답을 모킹하여 에러 반환
2. [에러 발생 트리거]
3. [에러 메시지 및 UI 상태 확인]
4. [복구 시나리오 테스트]

**자동화 테스트 및 UI 검증 (@mobilenext/mobile-mcp)**:
```
# 에러 시뮬레이션 및 검증
- mobile_list_elements_on_screen: 에러 메시지 요소 확인
- mobile_take_screenshot: "error_state.png" 캡처
- mobile_click_on_screen_at_coordinates: 재시도 버튼 탭
- 접근성 트리에서 에러 아이콘 표시 확인
```

**검증 체크리스트**:
- [ ] 에러 메시지가 사용자 친화적인가? (기술적 용어 지양)
- [ ] 복구 방법이 명확히 제시되는가?
- [ ] 로딩 인디케이터가 멈추지 않고 사라지는가?
- [ ] 앱이 응답 없음 상태가 되지 않는가?
- [ ] 에러 로그가 콘솔에 출력되는가?
- [ ] 사용자 데이터가 손실되지 않는가?

---

## 통합 테스트 시나리오

### End-to-End Scenario: [전체 플로우 이름]

**시나리오 설명**: [여러 기능을 연결한 전체 사용자 플로우]

**플로우 단계**:
1. [기능 A] → [기능 B] → [기능 C]
2. 각 단계에서 상태가 올바르게 전달되는지 확인
3. 최종 결과가 일관되게 나타나는지 확인

**수동 테스트 절차**:
1. [전체 플로우를 처음부터 끝까지 수행]
2. [각 화면 전환 확인]
3. [데이터 일관성 확인]

**자동화 테스트 및 UI 검증 (@mobilenext/mobile-mcp)**:
```
# 전체 플로우 자동화 — mobile_* 도구로 순차 실행
```

---

## 접근성 테스트

### WCAG 2.1 Level AA 준수 확인

**색 대비** (WCAG Success Criterion 1.4.3):
- [ ] 일반 텍스트: 최소 4.5:1 대비
- [ ] 큰 텍스트 (18pt 이상 또는 14pt Bold): 최소 3:1 대비
- [ ] UI 구성 요소 및 그래픽 객체: 최소 3:1 대비

**터치 타겟 크기** (WCAG Success Criterion 2.5.5):
- [ ] 모든 인터랙티브 요소가 최소 44x44pt (CSS 픽셀 기준)
- [ ] 버튼, 링크, 입력 필드 모두 충분한 터치 영역

**접근성 레이블** (WCAG Success Criterion 4.1.2):
- [ ] 모든 인터랙티브 요소에 명확한 레이블 (Semantics widget)
- [ ] 아이콘 버튼에 의미 있는 접근성 레이블
- [ ] 이미지에 대체 텍스트 (decorative image 제외)

**키보드 접근성** (WCAG Success Criterion 2.1.1) - 웹/데스크톱:
- [ ] 모든 기능이 키보드로 접근 가능
- [ ] 포커스 순서가 논리적
- [ ] 포커스 표시가 명확

**스크린 리더 테스트**:
- **iOS**: VoiceOver 활성화하여 테스트
- **Android**: TalkBack 활성화하여 테스트
- [ ] 모든 화면 요소를 스크린 리더로 읽을 수 있음
- [ ] 읽는 순서가 논리적
- [ ] 동적 콘텐츠 변경이 알림됨 (Announcement)

---

## 성능 테스트

**로딩 성능**:
- [ ] 앱 초기 실행: 3초 이내에 첫 화면 표시
- [ ] 화면 전환: 300ms 이내에 애니메이션 시작
- [ ] API 호출: 5초 이내에 응답 또는 타임아웃

**애니메이션 성능**:
- [ ] 60fps 유지 (Flutter DevTools Performance 탭 확인)
- [ ] 화면 전환 시 프레임 드롭 없음
- [ ] 스크롤이 부드럽게 동작

**메모리 관리**:
- [ ] 메모리 누수 없음 (Flutter DevTools Memory 탭 확인)
- [ ] 화면 이동 후 이전 화면 리소스 해제
- [ ] GetX Controller onClose() 정상 호출

**Hot Reload**:
- [ ] Hot reload가 정상 동작
- [ ] 상태가 유지되거나 예상대로 초기화
- [ ] Hot restart 후에도 정상 동작

---

## 실행 요약

### 수동 테스트 실행 방법

1. **앱 준비**:
   ```bash
   cd apps/wowa
   flutter run --debug
   ```

2. **각 시나리오 실행**:
   - 위의 "수동 테스트 절차" 섹션을 순서대로 수행
   - 각 단계의 예상 결과와 실제 결과 비교
   - 스크린샷 캡처 (before/after)
   - 발견된 이슈를 별도 문서에 기록

3. **검증 체크리스트 확인**:
   - 모든 체크리스트 항목을 하나씩 검증
   - 통과/실패 여부 표시

### 자동화 테스트 및 UI 검증 실행 방법 (@mobilenext/mobile-mcp)

```bash
# 1. 앱이 에뮬레이터/시뮬레이터에서 실행 중인지 확인
flutter devices

# 2. mobile-mcp는 .mcp.json에 MCP 서버로 등록됨
#    Claude가 mobile_* 도구를 직접 호출하여 테스트 수행

# 3. 자동화 테스트 (UI 인터랙션)
#    - mobile_list_elements_on_screen: 화면 요소 목록
#    - mobile_click_on_screen_at_coordinates: 탭
#    - mobile_type_keys: 텍스트 입력
#    - mobile_swipe_on_screen: 스크롤/스와이프

# 4. UI 검증
#    - mobile_take_screenshot: 스크린샷 캡처
#    - mobile_list_elements_on_screen: 접근성 트리 검증
#    - design-spec.md와 비교 (색상, 타이포, 스페이싱)

# 5. 실패한 시나리오는 수동으로 재확인
```

---

## 이슈 리포트 양식

발견된 버그나 문제점은 다음 형식으로 기록:

### Issue #[번호]: [간단한 제목]

**심각도**: Critical | High | Medium | Low
**재현율**: Always | Sometimes | Rare

**환경**:
- Platform: iOS / Android
- Device: [기기명 또는 에뮬레이터]
- Flutter Version: [버전]
- App Version: [버전]

**재현 단계**:
1. [단계 1]
2. [단계 2]
3. [단계 3]

**예상 결과**:
[무엇이 일어나야 하는지]

**실제 결과**:
[실제로 무엇이 일어났는지]

**스크린샷**:
[첨부]

**로그**:
```
[관련 에러 로그]
```

**추가 정보**:
[기타 참고 사항]

---

## 참고 사항

### 테스트 원칙
- **독립성**: 각 테스트는 독립적으로 실행 가능해야 함
- **반복 가능성**: 같은 조건에서 같은 결과가 나와야 함
- **명확성**: 테스트 의도와 기대 결과가 명확해야 함
- **Clean State**: 각 테스트는 clean state에서 시작
- **실패 시 정보**: 실패 시 충분한 디버깅 정보 제공

### 테스트 데이터
- 테스트용 계정: [제공된 경우]
- 샘플 데이터: [제공된 경우]
- API Mocking: [필요한 경우]

### 문의 및 리포팅
- 테스트 결과 리포팅 경로: [예: Jira, GitHub Issues]
- 긴급 이슈 에스컬레이션: [담당자 정보]

---

**템플릿 버전**: 1.0
**최종 업데이트**: [날짜]
