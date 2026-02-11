# Mobile Brief: demo-system 로깅 강화

## 변경 대상

| 파일 | 변경 유형 |
|------|----------|
| `packages/qna/lib/src/controllers/qna_controller.dart` | Logger 호출 추가 (제출 시작/성공/실패) |
| `packages/qna/lib/src/repositories/qna_repository.dart` | Logger 호출 추가 (API 호출, 에러 매핑) |
| `packages/qna/lib/src/services/qna_api_service.dart` | Logger 호출 추가 (요청/응답) |
| `packages/notice/lib/src/controllers/notice_list_controller.dart` | Logger 호출 추가 (로드/새로고침/에러) |
| `packages/notice/lib/src/controllers/notice_detail_controller.dart` | Logger 호출 추가 (조회/에러) |
| `packages/notice/lib/src/services/notice_api_service.dart` | Logger 호출 추가 (요청/응답) |

## Logger 사용 패턴

`core` 패키지의 `Logger` 클래스 사용:
```dart
import 'package:core/core.dart';

Logger.debug('...');
Logger.info('...');
Logger.warn('...');
Logger.error('...', error: e, stackTrace: stackTrace);
```

## 변경 상세

### 1. QnA Controller — qna_controller.dart

```dart
// submitQuestion() 내:

// 제출 시작 (try 직전)
Logger.debug('QnA: 질문 제출 시작 - title=${titleController.text.substring(0, min(30, titleController.text.length))}');

// API 호출 성공 후
Logger.info('QnA: 질문 제출 성공');

// NetworkException catch
Logger.error('QnA: 질문 제출 실패 - NetworkException', error: e);

// 일반 catch
Logger.error('QnA: 질문 제출 실패 - 예상치 못한 오류', error: e);
```

### 2. QnA Repository — qna_repository.dart

```dart
// submitQuestion() 내:

// API 호출 직전
Logger.debug('QnA: API 호출 시작 - appCode=$appCode');

// 성공 반환 직전
Logger.debug('QnA: API 호출 성공 - questionId=${response.questionId}');

// _mapDioError() 내 — 에러 변환 시 원본 정보 로깅 (핵심!)
Logger.error(
  'QnA: DioException 발생 - '
  'type=${e.type}, statusCode=${e.response?.statusCode}, '
  'message=${e.message}, responseData=${e.response?.data}',
  error: e,
);
```

> **이 부분이 "에러는 발생하는데 로그는 안 나와" 문제의 핵심.**
> 현재 `_mapDioError()`에서 DioException을 NetworkException으로 변환하면서
> 원본 에러 정보(statusCode, response body, error message)가 모두 소실됨.

### 3. QnA API Service — qna_api_service.dart

```dart
// submitQuestion() 내:

// 요청 직전
Logger.debug('QnA: POST /api/qna/questions 요청');

// 응답 수신
Logger.debug('QnA: POST /api/qna/questions 응답 - status=${response.statusCode}');

// DioException rethrow 전
Logger.warn('QnA: POST /api/qna/questions 실패 - ${e.type} ${e.response?.statusCode}');
```

### 4. Notice List Controller — notice_list_controller.dart

```dart
// fetchNotices() 내:

// 초기 로드 시작
Logger.debug('Notice: 목록 조회 시작 - page=$_currentPage');

// 성공 후
Logger.debug('Notice: 목록 조회 성공 - count=${notices.length}, pinned=${pinnedNotices.length}, hasMore=${hasMore.value}');

// DioException catch
Logger.error('Notice: 목록 조회 실패 - DioException', error: e);

// 일반 catch
Logger.error('Notice: 목록 조회 실패 - 예상치 못한 오류', error: e);

// loadMoreNotices() 내:

// 다음 페이지 로드 시작
Logger.debug('Notice: 추가 로드 시작 - page=$nextPage');

// 성공 후
Logger.debug('Notice: 추가 로드 성공 - added=${response.items.length}, total=${notices.length}');

// DioException catch
Logger.error('Notice: 추가 로드 실패', error: e);
```

### 5. Notice Detail Controller — notice_detail_controller.dart

```dart
// onInit() 내 — 잘못된 인자:
Logger.warn('Notice: 상세 조회 - 잘못된 arguments: $args');

// fetchNoticeDetail() 내:

// 조회 시작
Logger.debug('Notice: 상세 조회 시작 - id=$noticeId');

// 성공 후
Logger.debug('Notice: 상세 조회 성공 - id=$noticeId, title=${response.title}');

// 404 에러
Logger.warn('Notice: 상세 조회 - 공지 미존재 - id=$noticeId');

// DioException catch (404 외)
Logger.error('Notice: 상세 조회 실패 - DioException', error: e);

// 일반 catch
Logger.error('Notice: 상세 조회 실패 - 예상치 못한 오류', error: e);
```

### 6. Notice API Service — notice_api_service.dart

```dart
// getNotices() 내:

// 요청 직전
Logger.debug('Notice: GET /notices 요청 - page=$page, limit=$limit, pinnedOnly=$pinnedOnly');

// getNoticeDetail() 내:

// 요청 직전
Logger.debug('Notice: GET /notices/$id 요청');

// getUnreadCount() 내:

// 요청 직전
Logger.debug('Notice: GET /notices/unread-count 요청');
```

## 변경하지 않을 것

- `core/Logger` 클래스 자체 변경 없음 (현재 구현으로 충분)
- View(UI) 파일 — 로깅 불필요
- Binding 파일 — 로깅 불필요
- Freezed 모델 파일 — 로깅 불필요

## 로그 접두사 규칙

- QnA 관련: `QnA:` 접두사
- Notice 관련: `Notice:` 접두사
- 레벨 사용:
  - `debug`: 요청/응답 흐름 추적 (개발 중)
  - `info`: 주요 비즈니스 이벤트 성공
  - `warn`: 예상 가능한 실패 (404, 잘못된 인자)
  - `error`: 예상치 못한 실패 (네트워크 오류, 서버 오류)
