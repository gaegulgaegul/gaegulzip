# User Story: demo-system 로깅 강화

## 배경

QnA 질문 등록 시 에러가 발생하지만 로그가 출력되지 않아 디버깅이 불가능한 상황.
QnA와 Notice 모듈의 서버/모바일 양쪽에 체계적인 로깅을 추가하여 운영 가시성을 확보한다.

## 사용자 스토리

### US-1: QnA 에러 추적 (서버)

**As a** 서버 운영자,
**I want** QnA 질문 등록 과정의 각 단계(앱 조회 → GitHub Issue 생성 → DB 저장)에서 발생하는 에러를 로그로 확인할 수 있기를,
**So that** 에러 원인을 신속하게 파악하고 대응할 수 있다.

**인수 조건:**
- services.ts의 createQuestion() 각 단계에 debug 로그 추가
- github.ts의 에러 처리에서 기존 logger.error() → probe 패턴으로 전환
- 미사용 probe 함수(rateLimitWarning, githubApiError) 실제 호출 연결

### US-2: Notice 로깅 보완 (서버)

**As a** 서버 운영자,
**I want** Notice 모듈의 appCode 해석 과정과 조회수/읽음 처리에서도 디버그 로그를 확인할 수 있기를,
**So that** 공지사항 조회 관련 이슈를 추적할 수 있다.

**인수 조건:**
- getAppCode(), resolveAppCode() 함수에 debug 로그 추가
- 조회수 증가/읽음 처리 실패 시 warn 로그 추가

### US-3: QnA 로깅 추가 (모바일)

**As a** 모바일 개발자,
**I want** QnA 질문 제출 과정에서 요청/응답/에러 로그를 확인할 수 있기를,
**So that** 제출 실패 시 원인을 디버깅할 수 있다.

**인수 조건:**
- QnaController: 제출 시작, 성공, 실패(NetworkException/일반) 로그
- QnaRepository: API 호출 시작, DioException 에러 매핑 시 원본 정보 로그
- QnaApiService: 요청 페이로드, 응답 수신 debug 로그

### US-4: Notice 로깅 추가 (모바일)

**As a** 모바일 개발자,
**I want** Notice 목록/상세 조회, 새로고침, 무한 스크롤 과정에서 로그를 확인할 수 있기를,
**So that** 공지사항 로딩 이슈를 디버깅할 수 있다.

**인수 조건:**
- NoticeListController: 초기 로드, 새로고침, 무한 스크롤, 에러 로그
- NoticeDetailController: 상세 조회 시작, 성공, 에러 로그
- NoticeApiService: 요청/응답 debug 로그

## 범위

- **플랫폼**: Fullstack (Server + Mobile)
- **대상 모듈**: QnA, Notice
- **변경 유형**: 기존 코드에 로깅 추가 (기능 변경 없음)

## 기존 로깅 현황

### 서버 (양호 — 부분 개선 필요)

| 모듈 | Probe 패턴 | DEBUG | INFO/WARN/ERROR |
|------|-----------|-------|-----------------|
| QnA | O (미사용 함수 있음) | O (handler만) | O (일부 누락) |
| Notice | O | O (전체) | O (전체) |

### 모바일 (미흡 — 전면 추가 필요)

| 모듈 | Logger 사용 | 요청 로그 | 에러 로그 |
|------|-----------|----------|----------|
| QnA | X | X | X |
| Notice | X | X | X |
