# core — 모바일 공통 기반 패키지

## 개요

- **역할**: 모든 Flutter 패키지와 앱이 의존하는 최하위 기반 레이어
- **사용처**: design_system, auth_sdk, push, notice, qna, admob, wowa 앱 전체
- **독립성**: 외부 의존 최소화 (Flutter SDK, logger, flutter_secure_storage만 사용). 다른 내부 패키지에 의존하지 않음

## 연동 가이드

```dart
// pubspec.yaml
dependencies:
  core:
    path: ../core

// 사용
import 'package:core/core.dart';

Logger.info('정보 메시지');
Logger.error('에러 발생', error: e, stackTrace: stackTrace);

final storage = SecureStorageService();
await storage.saveAccessToken('token_value');
```

## Public API

`core.dart`에서 export하는 전체 목록:

| 클래스/파일 | 역할 | 사용 예 |
|------------|------|---------|
| `Logger` | 디버그 모드 전용 로깅 (info/warn/error/debug) | `Logger.info('메시지')` |
| `SecureStorageService` | 토큰, 사용자 정보 암호화 저장 | `storage.saveAccessToken(token)` |
| `AuthException` | 인증 예외 (code, message, data) | `throw AuthException(code: 'invalid_token', message: '...')` |
| `NetworkException` | 네트워크 예외 (message, statusCode) | `throw NetworkException(message: '...', statusCode: 500)` |
| `BusinessException` | 비즈니스 규칙 예외 (code, message) | `throw BusinessException(code: 'already_joined', message: '...')` |
| `SketchDesignTokens` | 디자인 토큰 상수 (색상, 폰트, 간격 등) | `SketchDesignTokens.accentPrimary` |
| `SketchColorPalettes` | 컬러 팔레트 정의 | `SketchColorPalettes.bluePalette` |

## Configuration

별도 설정 불필요. `import 'package:core/core.dart';`로 즉시 사용.

## Architecture

```
lib/
├── core.dart                    # 배럴 파일 (모든 export 정의)
├── sketch_design_tokens.dart    # 디자인 토큰 상수
├── sketch_color_palettes.dart   # 컬러 팔레트 정의
└── src/
    ├── exceptions/
    │   ├── auth_exception.dart       # 인증 예외
    │   ├── network_exception.dart    # 네트워크 예외
    │   └── business_exception.dart   # 비즈니스 예외
    ├── services/
    │   └── secure_storage_service.dart  # 암호화 저장소 (토큰, 사용자 정보)
    └── utils/
        └── logger.dart               # 디버그 모드 로깅 유틸리티
```

- `Logger`는 `kDebugMode`에서만 출력 (릴리스 빌드에서 자동 제거)
- `SecureStorageService`는 `flutter_secure_storage` 래핑 (iOS Keychain, Android EncryptedSharedPreferences)
- 예외 클래스는 모두 `Exception` 구현, `toString()` 오버라이드

## 확장/수정 시

1. 새 유틸리티: `lib/src/` 하위에 파일 추가 후 `lib/core.dart`에 export 추가
2. 새 예외 클래스: `lib/src/exceptions/`에 추가 (기존 패턴: code + message)
3. `melos bootstrap` 실행하여 의존 패키지 반영

## 의존성

| 패키지 | 역할 |
|--------|------|
| `get` | GetX (Get.find, Get.put 등 DI 유틸) |
| `logger` | 로깅 라이브러리 (현재 직접 print 사용) |
| `flutter_secure_storage` | 토큰 암호화 저장 |
