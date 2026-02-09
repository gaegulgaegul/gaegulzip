# API Package

HTTP 통신 레이어 및 데이터 모델 (Dio + Freezed)

## 구조

```
api/
├── clients/     # 도메인별 API 클라이언트 (Box, WOD, Proposal)
├── models/      # Freezed + json_serializable 모델
└── services/    # Push 알림 API 서비스
```

## 사용 가이드

### 1. API 클라이언트 사용

Box, WOD, Proposal 기능:
```dart
import 'package:api/api.dart';

final boxClient = BoxApiClient();
final boxes = await boxClient.searchBoxes();
```

### 2. 인증 API

**주의:** 인증 관련 API는 `api` 패키지가 아닌 `auth_sdk` 사용:
```dart
import 'package:auth_sdk/auth_sdk.dart';

final authSdk = AuthSdk(appCode: 'wowa', apiBaseUrl: '...');
await authSdk.login(provider: 'kakao', accessToken: '...');
```

**이유**: `auth_sdk`의 `AuthApiService`는 동적 appCode 주입 지원 (multi-tenant)

### 3. 새 API 클라이언트 추가

1. `lib/src/clients/` 또는 `lib/src/services/`에 클라이언트 생성
2. `lib/src/models/`에 Freezed 모델 추가
3. `melos generate` 실행 (코드 생성)
4. `lib/api.dart`에 export 추가

예시:
```dart
// lib/src/clients/my_api_client.dart
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class MyApiClient {
  final Dio _dio = Get.find<Dio>();

  Future<MyModel> fetchData() async {
    final response = await _dio.get('/my-endpoint');
    return MyModel.fromJson(response.data);
  }
}
```

### 4. Freezed 모델 작성

```dart
// lib/src/models/my_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_model.freezed.dart';
part 'my_model.g.dart';

@freezed
class MyModel with _$MyModel {
  const factory MyModel({
    required int id,
    required String name,
  }) = _MyModel;

  factory MyModel.fromJson(Map<String, dynamic> json) =>
      _$MyModelFromJson(json);
}
```

그 다음 `melos generate`를 실행하면 `.freezed.dart`와 `.g.dart` 파일이 자동 생성됩니다.

## 의존성

- `core` - 기초 유틸, DI, 로깅
- `dio` - HTTP 클라이언트
- `freezed` - 불변 모델
- `json_serializable` - JSON 직렬화

## SDK API Client Policy

**SDK별 API 클라이언트 구현:**
- `auth_sdk` - 자체 `AuthApiService` (multi-tenant 지원)
- `notice`, `qna` - 자체 `*ApiService` (독립성 유지)
- **일반 도메인 로직** - `packages/api` 공유 클라이언트 사용

**중복 방지 원칙:**
- 동일한 엔드포인트에 대한 클라이언트는 한 곳에만 존재
- 인증 관련: `auth_sdk` 우선
- 공통 CRUD: `api` 패키지 우선
