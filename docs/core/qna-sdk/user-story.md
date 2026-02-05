# 사용자 스토리: QnA SDK

## 개요

기존 wowa 앱의 QnA 기능을 **재사용 가능한 Flutter SDK 패키지**로 추출하여, 멀티테넌시 구조의 다른 앱에서도 동일한 질문 제출 기능을 사용할 수 있게 만드는 기능입니다. 각 앱은 자신의 앱 코드만 주입하면 별도의 GitHub 레포지토리에 질문이 자동 등록됩니다.

**비즈니스 가치**:
- QnA 기능을 한 번 개발하여 모든 제품에서 재사용 → 개발 비용 절감
- 각 제품의 질문이 독립적인 GitHub 레포지토리에 관리되어 운영팀 효율성 증대
- 새 제품 출시 시 즉시 사용자 피드백 채널 확보

---

## 사용자 페르소나

### 1. SDK 통합 개발자 (Primary)
- **특징**: 새 앱을 개발하는 개발자, Flutter/GetX 사용
- **니즈**: QnA 기능을 빠르게 통합하고, 자신의 앱 코드만 설정하면 즉시 사용 가능해야 함
- **행동**: SDK 패키지를 pubspec.yaml에 추가, 라우트 등록 시 appCode 파라미터 전달, 화면 사용

### 2. 최종 사용자 (Secondary)
- **특징**: 여러 제품(wowa, other-app 등) 사용자
- **니즈**: 어떤 앱을 사용하든 동일한 UX로 질문을 제출하고 싶음
- **행동**: 앱 내 "질문하기" 화면에서 질문 작성 및 제출

### 3. 운영팀/관리자 (Tertiary)
- **특징**: 여러 제품을 관리하는 팀, 제품별로 다른 GitHub 레포지토리 접근 권한 보유
- **니즈**: 각 제품의 질문이 독립적인 레포지토리에 관리되어야 함
- **행동**: 제품별 GitHub Issues에서 질문 확인 및 답변

---

## 사용자 스토리

### US-1: SDK 패키지 통합
- **As a** SDK 통합 개발자
- **I want to** QnA 패키지를 pubspec.yaml에 추가하고 라우트만 등록하면 즉시 사용할 수 있다
- **So that** 질문 제출 기능을 처음부터 구현하지 않고 빠르게 통합할 수 있다

### US-2: 앱 코드 외부 주입
- **As a** SDK 통합 개발자
- **I want to** 라우트 등록 시 또는 바인딩 생성 시 appCode를 파라미터로 전달할 수 있다
- **So that** 각 앱의 질문이 서로 다른 GitHub 레포지토리에 자동 등록된다

### US-3: UI까지 포함된 SDK
- **As a** SDK 통합 개발자
- **I want to** QnA 화면(View)이 SDK 패키지에 포함되어 있어 별도 UI 개발 없이 바로 사용할 수 있다
- **So that** 디자인 시스템을 따르는 일관된 UX를 모든 앱에서 제공할 수 있다

### US-4: 기존 wowa 앱과의 호환성
- **As a** SDK 통합 개발자
- **I want to** 기존 wowa 앱이 새 SDK 패키지를 import하여 사용하도록 전환할 수 있다
- **So that** 중복 코드를 제거하고 SDK 패키지만 유지보수하면 된다

### US-5: 일관된 사용자 경험
- **As a** 최종 사용자
- **I want to** 어떤 앱을 사용하든 동일한 UI와 플로우로 질문을 제출할 수 있다
- **So that** 익숙한 방식으로 여러 제품에서 질문할 수 있다

### US-6: 독립적인 질문 관리 (운영팀)
- **As a** 운영팀
- **I want to** 각 제품의 질문이 서로 다른 GitHub 레포지토리에 등록된다
- **So that** 제품별로 우선순위를 설정하고 독립적으로 관리할 수 있다

### US-7: 질문 제출 기능 (기존 QnA 유지)
- **As a** 최종 사용자
- **I want to** 앱 내에서 간편하게 질문을 작성하고 제출할 수 있다
- **So that** 제품 사용 중 궁금한 점을 즉시 해결할 수 있다

---

## 사용자 시나리오

### 시나리오 1: 새 앱에 SDK 통합 (정상 플로우)
1. 개발자가 새 앱 프로젝트를 생성한다
2. `pubspec.yaml`에 `qna` 패키지를 의존성으로 추가한다
3. `melos bootstrap` 명령어를 실행하여 의존성을 설치한다
4. `app_pages.dart`에서 QnA 라우트를 등록할 때 `QnaBinding(appCode: 'new-app')`을 전달한다
5. 앱을 실행하고 "질문하기" 화면으로 이동한다
6. 사용자가 질문을 작성하고 제출한다
7. 서버가 `new-app` appCode를 인식하여 해당 앱의 GitHub 레포지토리에 Issue를 생성한다
8. **결과**: 개발자는 최소한의 설정만으로 QnA 기능을 통합하고, 질문이 올바른 레포지토리에 등록된다

### 시나리오 2: 기존 wowa 앱을 SDK 패키지로 전환
1. wowa 앱의 `apps/wowa/lib/app/modules/qna/` 디렉토리를 삭제 준비한다
2. wowa 앱의 `pubspec.yaml`에 `qna` 패키지를 의존성으로 추가한다
3. `app_pages.dart`에서 import 경로를 SDK 패키지 경로로 변경한다
4. `QnaBinding(appCode: 'wowa')`을 전달하도록 수정한다
5. `melos bootstrap`을 실행하여 의존성을 업데이트한다
6. 앱을 실행하고 QnA 화면을 테스트한다
7. **결과**: 기존 wowa 앱은 SDK 패키지를 사용하도록 전환되고, 중복 코드가 제거된다

### 시나리오 3: 사용자가 여러 앱에서 질문 제출
1. 사용자가 wowa 앱에서 "질문하기" 메뉴를 선택한다
2. 질문 작성 화면에서 질문을 입력하고 제출한다
3. 성공 메시지를 확인하고 앱 사용을 계속한다
4. 나중에 other-app을 다운로드하여 사용한다
5. other-app에서도 동일한 "질문하기" 화면을 발견한다
6. 익숙한 UI로 질문을 작성하고 제출한다
7. **결과**: 사용자는 여러 앱에서 일관된 경험으로 질문을 제출하고, 각 앱의 운영팀은 독립적으로 질문을 관리한다

### 시나리오 4: appCode 파라미터 누락 시
1. 개발자가 새 앱에 QnA 라우트를 등록하지만 appCode를 전달하지 않는다
2. 앱을 실행하고 "질문하기" 화면으로 이동한다
3. 사용자가 질문을 작성하고 제출 버튼을 누른다
4. SDK 내부 로직이 appCode 누락을 감지한다 (또는 기본값 사용)
5. 개발 모드에서는 에러 로그를 출력하거나 예외를 발생시킨다
6. **결과**: 개발자는 appCode 파라미터가 필수임을 인지하고 수정한다

### 시나리오 5: 운영팀이 여러 제품의 질문 관리
1. 운영팀 멤버가 wowa GitHub 레포지토리의 Issues 탭을 연다
2. wowa 앱 사용자의 질문 목록을 확인한다
3. 우선순위를 설정하고 답변을 작성한다
4. other-app GitHub 레포지토리의 Issues 탭을 연다
5. other-app 사용자의 질문 목록을 별도로 확인한다
6. 각 제품의 특성에 맞게 독립적으로 관리한다
7. **결과**: 운영팀은 제품별로 질문을 체계적으로 관리하고, 컨텍스트 스위칭 비용을 줄인다

---

## 인수 조건 (Acceptance Criteria)

### SDK 패키지 구조
- [ ] `packages/qna/` 디렉토리가 생성된다
- [ ] `pubspec.yaml`에 필수 의존성이 정의된다 (core, api, design_system, dio, get, freezed_annotation)
- [ ] SDK 패키지는 독립적으로 빌드 및 코드 생성이 가능하다

### SDK 패키지 포함 항목
- [ ] 데이터 모델 (QnaSubmitRequest, QnaSubmitResponse) — 기존 api 패키지에서 이동 또는 재사용
- [ ] API 서비스 (QnaApiService) — 기존 api 패키지에서 이동 또는 재사용
- [ ] Repository (QnaRepository) — appCode를 생성자 또는 메서드 파라미터로 받음
- [ ] Controller (QnaController) — GetxController 상태 관리
- [ ] Binding (QnaBinding) — appCode를 외부에서 주입받아 Repository에 전달
- [ ] View (QnaSubmitView) — 질문 작성 화면 UI

### appCode 파라미터화
- [ ] QnaRepository는 appCode를 하드코딩하지 않는다
- [ ] appCode는 QnaBinding 생성 시 또는 Repository 메서드 호출 시 파라미터로 전달된다
- [ ] appCode가 누락된 경우 명확한 에러 메시지를 제공한다 (개발 모드)

### 기존 wowa 앱 전환
- [ ] wowa 앱의 기존 QnA 모듈 코드를 삭제한다
- [ ] wowa 앱의 pubspec.yaml에 `qna` 패키지를 추가한다
- [ ] wowa 앱의 라우트 등록에서 `QnaBinding(appCode: 'wowa')`을 전달한다
- [ ] 기존 기능이 동일하게 작동한다 (회귀 테스트)

### 사용자 경험 일관성
- [ ] SDK를 사용하는 모든 앱에서 동일한 UI가 표시된다
- [ ] 질문 제출 플로우(입력 → 검증 → 제출 → 성공/실패 모달)가 일관되다
- [ ] 에러 메시지가 일관되다

### 서버 연동
- [ ] SDK는 기존 서버 API(`POST /api/qna/questions`)를 그대로 사용한다
- [ ] appCode 파라미터가 서버로 정확히 전달된다
- [ ] 서버가 appCode에 따라 올바른 GitHub 레포지토리를 선택한다

---

## 엣지 케이스

### SDK 통합
- **appCode 파라미터 누락**: 개발 모드에서 명확한 에러 로그 또는 예외 발생, 프로덕션에서는 기본값 사용 또는 제출 실패
- **잘못된 appCode 전달**: 서버가 404 에러 반환 → "서비스 설정 오류" 메시지 표시
- **의존성 버전 충돌**: pubspec.yaml에서 명시적으로 버전 관리, melos bootstrap 실패 시 명확한 에러 메시지

### 질문 제출 (기존 QnA 유지)
- **빈 제목 또는 본문**: "제목과 내용을 입력해주세요" 에러 메시지 표시, 제출 불가
- **과도하게 긴 제목/본문**: 제목 256자, 본문 65536자 이내로 제한
- **네트워크 타임아웃**: "네트워크 연결을 확인해주세요" 메시지 표시
- **GitHub API 장애 (5xx)**: "서비스 오류가 발생했습니다. 잠시 후 다시 시도해주세요" 메시지

### 멀티테넌시
- **같은 시간에 여러 앱에서 질문 제출**: 각 앱의 appCode가 정확히 전달되어 올바른 레포지토리에 등록
- **appCode와 레포지토리 매핑 없음**: 서버가 404 에러 반환, 사용자에게는 "서비스 설정 오류" 메시지

---

## 비즈니스 규칙

### BR-1: SDK 패키지 독립성
- SDK 패키지는 특정 앱에 종속되지 않습니다
- SDK 패키지는 core, api, design_system 패키지에 의존할 수 있습니다
- SDK 패키지는 wowa 앱이나 다른 앱 코드를 import하지 않습니다

### BR-2: appCode 외부 주입 강제
- SDK 내부에서 appCode를 하드코딩하지 않습니다
- appCode는 반드시 외부에서 주입받아야 합니다 (생성자 또는 메서드 파라미터)
- appCode 누락 시 명확한 에러를 제공합니다

### BR-3: UI 포함 SDK
- SDK는 View(화면)까지 포함합니다
- 통합 앱은 별도로 UI를 구현하지 않고 SDK의 View를 사용합니다
- 커스터마이징이 필요한 경우 SDK View를 참조하여 새로 작성할 수 있습니다 (선택적)

### BR-4: 기존 QnA 비즈니스 규칙 유지
- 앱별 레포지토리 매핑 (BR-1 from original user-story)
- 익명 질문 허용 (BR-2)
- GitHub Issue 자동 라벨링 (BR-3)
- 메타데이터 포함 규칙 (BR-4)
- 입력 검증 (BR-5)
- 질문 수정/삭제 불가 (BR-6)

### BR-5: 서버 API 불변성
- SDK는 기존 서버 API를 변경하지 않습니다
- 서버는 이미 멀티테넌시를 지원합니다 (appCode 파라미터)
- SDK는 클라이언트 측 변경만 수행합니다

---

## 필요한 데이터

### SDK 통합 데이터 (개발자 → SDK)
| 데이터 | 타입 | 필수 | 설명 |
|--------|------|------|------|
| appCode | string | ✅ | 앱 식별 코드 (예: "wowa", "other-app") |

### 질문 제출 데이터 (기존 QnA 유지)
| 데이터 | 타입 | 필수 | 설명 |
|--------|------|------|------|
| title | string | ✅ | 질문 제목 (1~256자) |
| body | string | ✅ | 질문 내용 (1~65536자) |
| userId | number/null | ❌ | 질문자 사용자 ID (로그인 시), 비로그인 시 null |

### SDK → 서버 데이터
| 데이터 | 타입 | 필수 | 설명 |
|--------|------|------|------|
| appCode | string | ✅ | SDK가 주입받은 앱 코드 |
| title | string | ✅ | 사용자가 입력한 제목 |
| body | string | ✅ | 사용자가 입력한 본문 |

### 서버 → SDK 데이터
| 데이터 | 타입 | 필수 | 설명 |
|--------|------|------|------|
| questionId | number | ✅ | 생성된 질문 ID |
| issueNumber | number | ✅ | GitHub Issue 번호 |
| issueUrl | string | ✅ | GitHub Issue URL |
| createdAt | string | ✅ | 생성 시각 (ISO 8601) |

---

## 비기능 요구사항

### 성능
- **SDK 크기**: 최소화 (불필요한 의존성 제외)
- **빌드 시간**: 코드 생성 포함 30초 이내
- **응답 시간**: 기존 QnA 기능과 동일 (5초 이내)

### 보안
- **appCode 검증**: SDK는 appCode 형식을 검증하지 않고 서버에 위임
- **민감 정보 제외**: SDK 코드에 특정 앱의 API 키나 비밀 정보 하드코딩 금지

### 가용성
- **독립적 빌드**: SDK 패키지는 다른 앱 코드 없이도 빌드 가능
- **Graceful Degradation**: SDK 초기화 실패 시에도 앱 전체가 중단되지 않음

### 확장성
- **새 앱 추가**: pubspec.yaml 한 줄 + 라우트 등록 한 줄로 통합 가능
- **커스터마이징**: SDK View를 상속하거나 참조하여 커스텀 UI 작성 가능 (선택적)

### 유지보수성
- **단일 소스**: SDK 패키지만 수정하면 모든 앱에 반영
- **버전 관리**: SDK 패키지 버전을 명시적으로 관리 (pubspec.yaml version 필드)
- **문서화**: README.md에 통합 가이드, 예제 코드 포함

### 에러 처리
- **명확한 에러 메시지**: appCode 누락, 의존성 문제 등에 대해 개발자 친화적 에러 메시지
- **사용자 피드백**: 기존 QnA 기능과 동일한 에러 처리 (모달, 스낵바)

---

## 스코프

### Phase 1 (현재)
- [x] 기존 QnA 기능 구현 완료 (wowa 앱)
- [ ] SDK 패키지 생성 (`packages/qna/`)
- [ ] SDK 패키지에 기존 코드 이동 (models, services, repository, controller, binding, view)
- [ ] appCode 파라미터화 (QnaRepository, QnaBinding)
- [ ] 기존 wowa 앱을 SDK 패키지로 전환
- [ ] 회귀 테스트 (wowa 앱에서 기능 동일성 확인)
- [ ] README.md 작성 (통합 가이드)

### Phase 2 (향후)
- [ ] SDK 패키지 버전 관리 (semver)
- [ ] 다른 앱에서 SDK 통합 테스트
- [ ] SDK 커스터마이징 옵션 (UI 테마, 색상 등)
- [ ] SDK 패키지 퍼블리싱 (pub.dev 또는 private registry)

### Out of Scope (Phase 1에서 제외)
- ❌ 서버 API 변경
- ❌ 새로운 QnA 기능 추가 (기존 기능만 SDK화)
- ❌ SDK 외부에서 UI 완전 커스터마이징 (Phase 1에서는 SDK View 그대로 사용)
- ❌ SDK 패키지의 자동 버전 업데이트 로직

---

## 참고 자료

- 기존 QnA 사용자 스토리: [`docs/core/qna/user-story.md`](../qna/user-story.md)
- 기존 QnA 모바일 설계: [`docs/core/qna/mobile-design-spec.md`](../qna/mobile-design-spec.md), [`docs/core/qna/mobile-brief.md`](../qna/mobile-brief.md)
- Wowa 모바일 카탈로그: [`docs/wowa/mobile-catalog.md`](../../wowa/mobile-catalog.md)
- Flutter Multi-Tenancy Architecture: [Developing a Multi-Tenant Architecture for SmartFM using Flutter BLoC](https://medium.com/@riazaham01/developing-a-base-tenant-architecture-for-smartfm-using-flutter-bloc-f1c99d0c8b55)
- GetX Multi-Tenant Apps: [The $50M Flutter Secret: How GetX Powers Multi-Tenant Apps](https://medium.com/@alaxhenry0121/the-50m-flutter-secret-how-getx-powers-multi-tenant-apps-that-scale-to-millions-f10d032e2e08)
