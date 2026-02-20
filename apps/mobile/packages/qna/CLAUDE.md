# qna — Q&A 질문 제출 SDK

## 개요

- **역할**: 사용자 질문을 서버(GitHub Issues 연동)에 제출하는 UI + API SDK
- **사용처**: wowa 앱, design_system_demo 앱
- **독립성**: `core`, `design_system`에 의존. `appCode`로 앱별 GitHub 레포지토리를 구분하는 멀티테넌트 설계

## 연동 가이드

```dart
// 라우트 등록 (app_pages.dart)
GetPage(
  name: '/qna',
  page: () => const QnaSubmitView(),
  binding: QnaBinding(appCode: 'wowa'),
),

// 화면 이동
Get.toNamed('/qna');
```

## Public API

| 클래스/함수 | 역할 | 사용 예 |
|------------|------|---------|
| `QnaBinding` | 바인딩 (appCode 주입 -> Repository -> Controller) | `QnaBinding(appCode: 'wowa')` |
| `QnaSubmitView` | 질문 작성/제출 화면 | 라우트에 등록 |
| `QnaController` | 폼 상태 관리, 제출 로직 | Binding에서 자동 생성 |
| `QnaRepository` | 비즈니스 로직 (appCode 포함 요청 생성) | Binding에서 자동 생성 |
| `QnaApiService` | API 통신 (POST /qna/questions) | Binding에서 자동 생성 |
| `QnaSubmitRequest` | 질문 제출 요청 모델 (Freezed) | Repository 내부 |
| `QnaSubmitResponse` | 질문 제출 응답 모델 (Freezed) | API 응답 |

## Configuration

`QnaBinding` 생성자로 `appCode` 전달:
- 서버에서 `appCode`로 GitHub 레포지토리 매핑
- 별도 설정 객체 없음

## Architecture

```
lib/
├── qna.dart                    # 배럴 파일
└── src/
    ├── bindings/               # QnaBinding (appCode 주입)
    ├── controllers/            # QnaController (폼 상태, 제출)
    ├── models/                 # Freezed 모델 (QnaSubmitRequest, QnaSubmitResponse)
    ├── repositories/           # QnaRepository (appCode 포함 요청 생성)
    ├── services/               # QnaApiService (POST /qna/questions)
    └── views/                  # QnaSubmitView (질문 작성 폼)
```

- DI 체인: `QnaBinding` -> `QnaApiService` + `QnaRepository(appCode)` + `QnaController`
- Repository가 appCode를 QnaSubmitRequest에 주입

## 확장/수정 시

1. 질문 양식 수정: `QnaSubmitView` + `QnaController` 수정
2. API 변경: `QnaApiService` 수정, 필요 시 Freezed 모델 수정 후 `melos generate`
3. 새 기능 (질문 목록 등): `src/`에 controller, view, service 추가 후 `qna.dart`에 export

## 의존성

| 패키지 | 역할 |
|--------|------|
| `core` | Logger |
| `design_system` | UI 컴포넌트 |
| `dio` | HTTP 클라이언트 |
| `freezed_annotation` / `json_annotation` | 데이터 모델 |
