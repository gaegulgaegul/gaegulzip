# 소셜 로그인 (Social Login) - 구현 분석

## 개요

gaegulzip 프로젝트의 소셜 로그인 기능 분석 결과를 정리한 문서입니다.
멀티테넌트 구조로 설계되어, `apps` 테이블에 앱별 OAuth 인증 정보를 관리하며
하나의 서버로 여러 앱의 소셜 로그인을 처리합니다.

## 지원 프로바이더

| 프로바이더 | 서버 구현 | 모바일 구현 |
|-----------|----------|-----------|
| 카카오 (Kakao) | ✅ 완료 | ❌ 스텁 |
| 네이버 (Naver) | ✅ 완료 | ❌ 스텁 |
| 구글 (Google) | ✅ 완료 | ❌ 스텁 |
| 애플 (Apple) | ⚠️ 서명 검증 미구현 | ❌ 스텁 |

## 서버 구현 (apps/server)

### 모듈 구조

```
apps/server/src/modules/auth/
├── index.ts                 # 라우터 export
├── handlers.ts              # OAuth 로그인/콜백/토큰 갱신 핸들러
├── services.ts              # 비즈니스 로직 (upsert user, JWT 생성, 토큰 로테이션)
├── schema.ts                # Drizzle 스키마 (apps, users, refresh_tokens)
├── types.ts                 # OAuth 응답 타입 정의
├── validators.ts            # Zod 스키마 검증
├── refresh-token.utils.ts   # 토큰 해싱, 만료 계산
├── auth.probe.ts            # 운영 로그 (Domain Probe 패턴)
└── providers/
    ├── base.ts              # IOAuthProvider 인터페이스
    ├── kakao.ts             # 카카오 구현
    ├── naver.ts             # 네이버 구현
    ├── google.ts            # 구글 구현
    └── apple.ts             # 애플 구현
```

### 데이터베이스 스키마

#### apps 테이블 (OAuth 인증 정보)

| 컬럼 | 설명 |
|------|------|
| `id`, `code`, `name` | 앱 식별 정보 |
| `kakaoRestApiKey`, `kakaoClientSecret` | 카카오 인증 키 |
| `naverClientId`, `naverClientSecret` | 네이버 인증 키 |
| `googleClientId`, `googleClientSecret` | 구글 인증 키 |
| `appleClientId`, `appleTeamId`, `appleKeyId`, `applePrivateKey` | 애플 인증 키 |
| `jwtSecret`, `jwtExpiresIn` | JWT 설정 (기본 7일) |
| `accessTokenExpiresIn` | Access Token 만료 (기본 30분) |
| `refreshTokenExpiresIn` | Refresh Token 만료 (기본 14일) |

#### users 테이블

| 컬럼 | 설명 |
|------|------|
| `id`, `appId` | 사용자 및 앱 ID |
| `provider`, `providerId` | OAuth 프로바이더 정보 |
| `email`, `nickname`, `profileImage` | 사용자 프로필 |
| `appMetadata` (JSONB) | 앱별 메타데이터 |
| `lastLoginAt` | 마지막 로그인 |

- 유니크 제약: `(appId, provider, providerId)`

#### refresh_tokens 테이블

| 컬럼 | 설명 |
|------|------|
| `tokenHash` | bcrypt 해시 (유니크) |
| `jti` | JWT ID (UUID v4, 유니크) |
| `tokenFamily` | 토큰 패밀리 (UUID v4) |
| `revoked`, `revokedAt` | 폐기 상태 |
| `expiresAt` | 만료 시각 |

- 인덱스: `tokenHash`, `userId`, `expiresAt`, `tokenFamily`

### API 엔드포인트

#### POST /auth/oauth - 소셜 로그인

```json
// Request
{
  "code": "wowa",
  "provider": "kakao",
  "accessToken": "OAuth_프로바이더_액세스_토큰"
}

// Response
{
  "accessToken": "JWT_액세스_토큰",
  "refreshToken": "JWT_리프레시_토큰",
  "tokenType": "Bearer",
  "expiresIn": 1800,
  "user": {
    "id": 1,
    "email": "user@example.com",
    "nickname": "닉네임",
    "profileImage": "https://..."
  }
}
```

#### POST /auth/refresh - 토큰 갱신

```json
// Request
{ "refreshToken": "기존_리프레시_토큰" }

// Response
{
  "accessToken": "새_액세스_토큰",
  "refreshToken": "새_리프레시_토큰",
  "tokenType": "Bearer",
  "expiresIn": 1800
}
```

#### POST /auth/logout - 로그아웃

```json
// Request
{
  "refreshToken": "리프레시_토큰",
  "revokeAll": false  // true: 전체 세션 종료
}

// Response: 204 No Content
```

#### GET /auth/oauth/callback - 카카오 Authorization Code 콜백

- 카카오 인가 코드 플로우 전용
- `code`, `state` 쿼리 파라미터 수신
- 테스트용 HTML 페이지로 응답

### OAuth 로그인 플로우

```
1. 모바일: OAuth SDK로 프로바이더 액세스 토큰 획득
2. 모바일 → 서버: POST /auth/oauth { code, provider, accessToken }
3. 서버: 앱 코드로 앱 설정 조회
4. 서버: 프로바이더 인스턴스 생성 (Factory 패턴)
5. 서버 → 프로바이더: 토큰 검증 API 호출
6. 서버 → 프로바이더: 사용자 정보 API 호출
7. 서버: 사용자 Upsert (신규 생성 또는 정보 갱신)
8. 서버: Access Token (JWT, 30분) 생성
9. 서버: Refresh Token (JWT, 14일) 생성 + bcrypt 해시 저장
10. 서버 → 모바일: { accessToken, refreshToken, user }
```

### 토큰 관리 전략

#### Access Token
- JWT (HS256), 앱별 시크릿으로 서명
- 페이로드: `{ sub, appId, email, nickname }`
- 만료: 30분 (앱별 설정 가능)
- `Authorization: Bearer <token>` 헤더로 전달

#### Refresh Token
- JWT 기반, 페이로드: `{ sub, appId, jti, tokenFamily }`
- DB에 bcrypt 해시로 저장
- 만료: 14일 (앱별 설정 가능)

#### 토큰 로테이션

```
사용자: Refresh Token 제출
  → 서버: 기존 토큰 revoked=true 처리
  → 서버: 같은 tokenFamily로 새 토큰 발급
  → 사용자: 새 토큰으로 교체
```

#### 재사용 탐지

```
폐기된 토큰 재사용 시:
  → 5초 이내: Grace Period (네트워크 race condition 허용)
  → 5초 초과: 전체 Token Family 폐기 (보안 경고)
```

### 프로바이더별 검증 방식

| 프로바이더 | 토큰 검증 | 사용자 정보 |
|-----------|----------|-----------|
| 카카오 | `GET kapi.kakao.com/v1/user/access_token_info` | `GET kapi.kakao.com/v2/user/me` |
| 네이버 | `GET openapi.naver.com/v1/nid/me` | 동일 엔드포인트 |
| 구글 | `GET googleapis.com/oauth2/v1/tokeninfo` | `GET googleapis.com/oauth2/v2/userinfo` |
| 애플 | JWT 디코딩 (만료/발급자 검증) | JWT 페이로드에서 추출 |

### 에러 처리

```
AppException (500)
├── BusinessException (400)
│   └── ValidationException
├── UnauthorizedException (401)
│   - INVALID_TOKEN, EXPIRED_TOKEN, INVALID_REFRESH_TOKEN
├── NotFoundException (404)
│   - 앱/사용자 미발견
└── ExternalApiException (502)
    - OAuth 프로바이더 API 실패
```

### 운영 로그 (Domain Probe)

| 이벤트 | 레벨 | 용도 |
|--------|------|------|
| `loginSuccess` | INFO | 로그인 성공 추적 |
| `loginFailed` | WARN | 로그인 실패 디버깅 |
| `userRegistered` | INFO | 신규 가입 추적 |
| `refreshTokenIssued` | INFO | 토큰 발급 감사 |
| `refreshTokenRotated` | INFO | 토큰 갱신 추적 |
| `refreshTokenRevoked` | INFO | 로그아웃/폐기 감사 |
| `refreshTokenReuseDetected` | ERROR | 토큰 도난 의심 경고 |

### 인증 미들웨어

`apps/server/src/middleware/auth.ts`의 `authenticate()`:

1. `Authorization: Bearer <token>` 헤더에서 토큰 추출
2. JWT 디코딩 (base64)하여 `appId` 획득
3. 앱 조회 후 앱별 `jwtSecret`으로 서명 검증
4. `req.user = { userId, appId }` 설정

---

## 모바일 구현 (apps/mobile)

### 현재 상태: UI 스켈레톤

```
apps/mobile/apps/wowa/lib/app/modules/login/
├── login_controller.dart   # GetX 컨트롤러 (스텁 핸들러)
├── login_view.dart          # UI 렌더링
└── login_binding.dart       # DI 바인딩
```

### 구현된 부분

#### SocialLoginButton 위젯

`packages/design_system/lib/src/widgets/social_login_button.dart`

| 플랫폼 | 배경색 | 텍스트색 | 모서리 |
|--------|--------|---------|--------|
| 카카오 | #FEE500 | 검정 | 12px |
| 네이버 | #03C75A | 흰색 | 8px |
| 애플 | 검정/흰색 | 흰색 | 6px |
| 구글 | 흰색 | 검정 | 4px |

- 3가지 사이즈: Small(40), Medium(48), Large(56)
- 로딩 인디케이터 통합
- SVG 로고 에셋

#### LoginController (스텁)

```dart
// 현재 상태: 실제 로직 없이 2초 딜레이 후 성공 스낵바 표시
final isKakaoLoading = false.obs;
final isNaverLoading = false.obs;
final isAppleLoading = false.obs;
final isGoogleLoading = false.obs;

Future<void> handleKakaoLogin() async {
  isKakaoLoading.value = true;
  await Future.delayed(Duration(seconds: 2));  // 스텁
  _showSuccessSnackbar();
  isKakaoLoading.value = false;
}
```

#### 예외 클래스

- `AuthException`: code(`user_cancelled`, `invalid_token`), message
- `NetworkException`: message, statusCode

### 미구현 항목

| 항목 | 필요 패키지 | 설명 |
|------|-----------|------|
| OAuth SDK 연동 | `kakao_flutter_sdk`, `google_sign_in`, `sign_in_with_apple` 등 | 프로바이더별 네이티브 로그인 |
| 서버 API 통신 | `packages/api`에 구현 | POST /auth/oauth 호출 |
| 토큰 저장 | `flutter_secure_storage` | Access/Refresh Token 영속화 |
| 인증 상태 관리 | GetX Service | 앱 재시작 시 상태 복원 |
| 자동 토큰 갱신 | Dio Interceptor | 401 응답 시 자동 refresh |

---

## 평가 요약

### 강점

1. **멀티테넌트 설계**: 앱별 OAuth 키/JWT 설정으로 다중 앱 지원
2. **토큰 보안**: bcrypt 해시 저장 + Token Family 로테이션 + 재사용 탐지
3. **프로바이더 추상화**: `IOAuthProvider` 인터페이스로 새 프로바이더 추가 용이
4. **운영 로그**: Domain Probe 패턴으로 보안 이벤트 추적
5. **UI 컴포넌트 재사용**: 디자인 시스템에 SocialLoginButton 위젯화

### 개선 필요 사항

| 우선순위 | 항목 | 위험도 |
|---------|------|--------|
| 1 | Apple ID Token 공개키 서명 검증 구현 | 🔴 높음 |
| 2 | 모바일 OAuth SDK 연동 | 🔴 높음 (기능 미완성) |
| 3 | 모바일 토큰 저장/갱신 로직 | 🔴 높음 (기능 미완성) |
| 4 | OAuth 시크릿 암호화 저장 | 🟡 중간 |
| 5 | Rate Limiting 적용 | 🟡 중간 |
| 6 | Kakao redirect URI 설정화 | 🟢 낮음 |
