# FCM 푸시 알림 (Push Notification) - 구현 분석

## 개요

gaegulzip 프로젝트의 FCM 푸시 알림 기능 분석 결과를 정리한 문서입니다.
서버에서 Firebase Admin SDK를 사용하여 알림을 발송하며,
앱별 Firebase 프로젝트 인증 정보를 `apps` 테이블에서 관리하는 멀티테넌트 구조입니다.

## 구현 상태

| 영역 | 상태 | 평가 |
|------|------|------|
| **서버 - 디바이스 토큰 관리** | ✅ CRUD + Upsert | 우수 |
| **서버 - 알림 발송** | ✅ 단건/다건/전체 발송 | 우수 |
| **서버 - 배치 처리** | ✅ 500건 단위 배치 | 우수 |
| **서버 - 무효 토큰 정리** | ✅ 자동 비활성화 | 우수 |
| **서버 - 발송 이력 관리** | ✅ push_alerts 테이블 | 우수 |
| **서버 - FCM 인스턴스 캐싱** | ✅ 앱별 캐시 | 우수 |
| **서버 - 운영 로그** | ✅ Domain Probe 패턴 | 우수 |
| **모바일 - Firebase 설정** | ❌ 패키지 미설치 | 미구현 |
| **모바일 - 토큰 등록** | ❌ 미구현 | 미구현 |
| **모바일 - 알림 수신 처리** | ❌ 미구현 | 미구현 |

---

## 서버 구현 (apps/server)

### 모듈 구조

```
apps/server/src/modules/push-alert/
├── index.ts            # 라우터 export
├── handlers.ts         # 디바이스 등록/발송/조회 핸들러
├── services.ts         # DB 조작 비즈니스 로직
├── schema.ts           # Drizzle 스키마 (push_device_tokens, push_alerts)
├── validators.ts       # Zod 스키마 검증
├── fcm.ts              # Firebase Admin SDK 래퍼
└── push.probe.ts       # 운영 로그 (Domain Probe 패턴)
```

### 데이터베이스 스키마

#### push_device_tokens 테이블

| 컬럼 | 타입 | 설명 |
|------|------|------|
| `id` | PK | 고유 식별자 |
| `userId` | integer | 사용자 ID |
| `appId` | integer | 앱 ID |
| `token` | varchar(500) | FCM 디바이스 토큰 |
| `platform` | enum | `ios` / `android` / `web` |
| `deviceId` | varchar | 디바이스 식별자 (선택) |
| `isActive` | boolean | 활성 상태 |
| `lastUsedAt` | timestamp | 마지막 사용 시각 |
| `createdAt`, `updatedAt` | timestamp | 생성/수정 시각 |

- 유니크 제약: `(userId, appId, token)`
- 인덱스: `userId`, `appId`, `token`, `isActive`

#### push_alerts 테이블

| 컬럼 | 타입 | 설명 |
|------|------|------|
| `id` | PK | 알림 ID |
| `appId` | integer | 앱 ID |
| `userId` | integer | 대상 사용자 (단건 발송) |
| `title` | varchar(255) | 알림 제목 |
| `body` | varchar(1000) | 알림 본문 |
| `data` | jsonb | 커스텀 데이터 페이로드 |
| `imageUrl` | varchar(500) | 이미지 URL (선택) |
| `targetType` | enum | `single` / `multiple` / `all` |
| `targetUserIds` | jsonb | 대상 사용자 ID 배열 |
| `sentCount` | integer | 발송 성공 건수 |
| `failedCount` | integer | 발송 실패 건수 |
| `status` | enum | `pending` / `completed` / `failed` |
| `errorMessage` | text | 실패 시 에러 메시지 |
| `sentAt`, `createdAt` | timestamp | 발송/생성 시각 |

- 인덱스: `appId`, `userId`, `status`, `createdAt`

#### apps 테이블 (FCM 인증 정보)

| 컬럼 | 설명 |
|------|------|
| `fcmProjectId` | Firebase 프로젝트 ID |
| `fcmPrivateKey` | Service Account 프라이빗 키 (JSON) |
| `fcmClientEmail` | Service Account 이메일 |

### API 엔드포인트

#### 디바이스 토큰 관리 (인증 필요)

##### POST /push/devices - 디바이스 토큰 등록

```json
// Request (Authorization: Bearer <token>)
{
  "token": "FCM_디바이스_토큰",
  "platform": "ios",
  "deviceId": "디바이스_식별자"  // 선택
}

// Response (201)
{
  "id": 1,
  "token": "FCM_디바이스_토큰",
  "platform": "ios",
  "isActive": true,
  "lastUsedAt": "2026-02-03T...",
  "createdAt": "2026-02-03T..."
}
```

- Upsert 방식: 이미 존재하면 `platform`, `deviceId`, `isActive`, `lastUsedAt` 갱신

##### GET /push/devices - 디바이스 목록 조회

```json
// Response (200)
{
  "devices": [
    {
      "id": 1,
      "token": "...",
      "platform": "ios",
      "isActive": true,
      "lastUsedAt": "..."
    }
  ]
}
```

##### DELETE /push/devices/:id - 디바이스 비활성화

```
// Response: 204 No Content
// isActive = false로 변경 (소프트 삭제)
```

#### 알림 발송

##### POST /push/send - 푸시 알림 발송

```json
// 단건 발송
{
  "appCode": "wowa",
  "userId": 1,
  "title": "새 메시지",
  "body": "새로운 메시지가 도착했습니다",
  "data": { "type": "message", "messageId": "123" },
  "imageUrl": "https://example.com/image.png"
}

// 다건 발송
{
  "appCode": "wowa",
  "userIds": [1, 2, 3],
  "title": "공지사항",
  "body": "새로운 공지가 등록되었습니다"
}

// 전체 발송
{
  "appCode": "wowa",
  "targetType": "all",
  "title": "업데이트 안내",
  "body": "새 버전이 출시되었습니다"
}

// Response (200)
{
  "alertId": 1,
  "sentCount": 5,
  "failedCount": 1,
  "status": "completed"
}
```

- 검증: `userId`, `userIds`, `targetType` 중 하나만 지정 가능

##### GET /push/notifications - 알림 이력 조회

```
// Query: ?appCode=wowa&limit=50&offset=0
// Response (200)
{
  "alerts": [...],
  "total": 100
}
```

##### GET /push/notifications/:id - 알림 상세 조회

```
// Query: ?appCode=wowa
// Response (200): 전체 알림 정보
```

### 알림 발송 플로우

```
1. POST /push/send 요청 수신
2. 앱 코드로 앱 설정 조회 (FCM 인증 정보 포함)
3. 대상 사용자 결정
   - single: userId로 직접 조회
   - multiple: userIds 배열로 조회
   - all: 앱의 전체 활성 사용자 조회
4. push_alerts 레코드 생성 (status: pending)
5. 대상 사용자들의 활성 디바이스 토큰 조회
6. FCM 인스턴스 획득 (캐시 또는 신규 생성)
7. Firebase Admin SDK로 배치 발송 (최대 500건)
8. 무효 토큰 자동 비활성화
9. push_alerts 상태 업데이트 (sentCount, failedCount, status)
10. 결과 응답
```

### FCM 모듈 (fcm.ts)

#### 인스턴스 캐싱

```
앱 ID → Firebase Admin App (캐시)
  - 최초 요청 시 Service Account 인증으로 초기화
  - 이후 요청은 캐시에서 인스턴스 반환
  - 앱별 독립적인 Firebase 프로젝트 지원
```

#### 단건 발송 (sendToDevice)

```typescript
결과: { success: boolean, messageId?: string, error?: string, isInvalidToken?: boolean }
```

#### 배치 발송 (sendToMultipleDevices)

```typescript
결과: {
  successCount: number,
  failureCount: number,
  results: Array<{ token, success, messageId?, error? }>,
  invalidTokens: string[]  // 자동 비활성화 대상
}
```

- 최대 500건 제한 (Firebase API 제약)

#### 무효 토큰 감지

다음 FCM 에러 코드 발생 시 자동 비활성화:
- `messaging/invalid-registration-token`
- `messaging/registration-token-not-registered`

### 에러 처리

| 예외 | 상황 |
|------|------|
| `BusinessException` (FCM_NOT_CONFIGURED) | 앱에 FCM 인증 정보 미설정 |
| `BusinessException` (PUSH_SEND_FAILED) | 전체 발송 실패 |
| `NotFoundException` | 앱 또는 디바이스 미발견 |
| `ValidationException` | 요청 데이터 검증 실패 |

### 운영 로그 (Domain Probe)

| 이벤트 | 레벨 | 용도 |
|--------|------|------|
| `deviceRegistered` | INFO | 디바이스 토큰 등록 추적 |
| `deviceDeactivated` | INFO | 디바이스 비활성화 추적 |
| `pushSent` | INFO | 발송 성공 + 통계 |
| `pushFailed` | ERROR | 발송 실패 + 에러 상세 |
| `invalidTokenDetected` | WARN | 무효 토큰 발견 (토큰 앞 20자만 로깅) |

### 입력 검증 (Zod)

| 필드 | 규칙 |
|------|------|
| `token` | 1~500자 문자열 |
| `platform` | `ios` / `android` / `web` |
| `title` | 1~255자 문자열 |
| `body` | 1~1000자 문자열 |
| `imageUrl` | 유효한 URL, 최대 500자 |
| `data` | JSON 객체 (선택) |

---

## 모바일 구현 (apps/mobile)

### 현재 상태: 미구현

모바일 측에는 Firebase/FCM 관련 코드가 전혀 없는 상태입니다.

- `firebase_core`, `firebase_messaging` 패키지 미설치
- `google-services.json` (Android) 없음
- `GoogleService-Info.plist` (iOS) 없음
- FCM 초기화 코드 없음
- 토큰 등록/갱신 코드 없음
- 알림 수신 처리 코드 없음

### 미구현 항목

| 항목 | 필요 패키지 | 위치 | 설명 |
|------|-----------|------|------|
| Firebase 초기화 | `firebase_core` | `wowa/lib/main.dart` | 앱 시작 시 초기화 |
| FCM 토큰 획득 | `firebase_messaging` | `packages/core` | 토큰 발급 및 갱신 리스너 |
| 토큰 서버 등록 | `packages/api` | Dio 클라이언트 | POST /push/devices 호출 |
| 포그라운드 알림 | `flutter_local_notifications` | `packages/core` | 앱 사용 중 알림 표시 |
| 백그라운드 처리 | `firebase_messaging` | `wowa/lib/main.dart` | 네이티브 알림 처리 |
| 딥링킹 | GetX 라우팅 | `wowa` | 알림 탭 시 화면 이동 |
| 권한 요청 | `firebase_messaging` | `packages/core` | iOS 알림 권한 요청 |

---

## 전체 알림 플로우

```
[디바이스 토큰 등록]
모바일 앱 시작/로그인
  → Firebase 초기화
  → FCM 토큰 획득
  → POST /push/devices { token, platform, deviceId }
  → 서버: push_device_tokens에 Upsert
  → 토큰 갱신 리스너로 자동 재등록

[알림 발송]
관리자/시스템 → POST /push/send { appCode, userId, title, body, data }
  → 서버: 대상 사용자의 활성 디바이스 토큰 조회
  → 서버: Firebase Admin SDK로 FCM에 발송
  → FCM → 디바이스로 알림 전달

[알림 수신]
  포그라운드: onMessage 리스너 → 로컬 알림 표시
  백그라운드: 네이티브 알림 시스템에서 표시
  종료 상태: 네이티브 알림 → 알림 탭 시 앱 실행

[무효 토큰 정리]
  발송 실패 (invalid token)
  → 서버: isActive=false 처리
  → 다음 발송 시 제외됨
  → 모바일 재시작/재로그인 시 새 토큰으로 재등록
```

---

## 평가 요약

### 강점

1. **멀티테넌트 FCM**: 앱별 Firebase 프로젝트 지원, 인스턴스 캐싱
2. **배치 발송**: 최대 500건 단위 배치 처리
3. **무효 토큰 자동 정리**: FCM 에러 코드 기반 자동 비활성화
4. **발송 이력 관리**: push_alerts로 통계 및 감사 추적
5. **소프트 삭제**: 디바이스 토큰 비활성화 (하드 삭제 안 함)
6. **보안 로깅**: 토큰 앞 20자만 로깅

### 개선 필요 사항

| 우선순위 | 항목 | 위험도 |
|---------|------|--------|
| 1 | 모바일 Firebase/FCM 구현 | 🔴 높음 (기능 미완성) |
| 2 | push/send 엔드포인트 인증/인가 | 🔴 높음 (보안) |
| 3 | 발송 실패 시 재시도 로직 | 🟡 중간 |
| 4 | Rate Limiting 적용 | 🟡 중간 |
| 5 | 알림 스케줄링 (예약 발송) | 🟢 낮음 |
| 6 | 토픽 구독 기반 발송 | 🟢 낮음 |
| 7 | 알림 수신 확인/읽음 추적 | 🟢 낮음 |
| 8 | 오래된 비활성 토큰 정리 배치 | 🟢 낮음 |
