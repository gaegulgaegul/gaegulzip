# FCM 토큰 저장 - 서버 기술 설계 (Server Technical Brief)

## 개요

FCM 토큰 저장 기능의 서버 쪽 구현은 **이미 완료된 상태**입니다. 이 문서는 기존 구현의 분석 결과와 모바일 연동을 위해 필요한 추가 API를 제안합니다.

**핵심 결론**:
- ✅ 기존 API로 대부분 커버 가능
- ⚠️ 로그아웃 시 토큰 비활성화 API 추가 필요 (토큰 기반 비활성화)

---

## 기존 구현 분석

### 모듈 위치
`apps/server/src/modules/push-alert/`

### 기존 API 엔드포인트

| 메서드 | 경로 | 인증 | 설명 | 상태 |
|--------|------|------|------|------|
| POST | `/push/devices` | ✅ | 디바이스 토큰 등록 (Upsert) | ✅ 완료 |
| GET | `/push/devices` | ✅ | 사용자 디바이스 목록 조회 | ✅ 완료 |
| DELETE | `/push/devices/:id` | ✅ | 디바이스 비활성화 (ID 기반) | ✅ 완료 |
| POST | `/push/send` | ✅ | 푸시 알림 발송 (관리자) | ✅ 완료 |
| GET | `/push/notifications/me` | ✅ | 내 알림 목록 | ✅ 완료 |
| GET | `/push/notifications/unread-count` | ✅ | 읽지 않은 알림 개수 | ✅ 완료 |
| PATCH | `/push/notifications/:id/read` | ✅ | 알림 읽음 처리 | ✅ 완료 |

### 데이터베이스 스키마 (push_device_tokens)

| 컬럼 | 타입 | 제약 | 설명 |
|------|------|------|------|
| `id` | serial | PK | 고유 ID |
| `userId` | integer | NOT NULL | 사용자 ID (JWT에서 추출) |
| `appId` | integer | NOT NULL | 앱 ID (JWT에서 추출) |
| `token` | varchar(500) | NOT NULL | FCM 디바이스 토큰 |
| `platform` | varchar(20) | NOT NULL | `ios` / `android` / `web` |
| `deviceId` | varchar(255) | NULL | 디바이스 식별자 (선택) |
| `isActive` | boolean | NOT NULL, DEFAULT true | 활성 상태 |
| `lastUsedAt` | timestamp | NULL | 마지막 사용 시각 |
| `createdAt` | timestamp | NOT NULL | 생성 시각 |
| `updatedAt` | timestamp | NOT NULL | 수정 시각 |

**유니크 제약**: `(userId, appId, token)` — 동일 사용자가 같은 토큰을 중복 등록할 수 없음

**인덱스**:
- `userId` — 사용자별 디바이스 조회
- `appId` — 앱별 디바이스 조회
- `token` — 토큰 기반 조회/비활성화
- `isActive` — 활성 디바이스 필터링

### 토큰 등록 플로우 (POST /push/devices)

```typescript
1. 요청: { token, platform, deviceId }
2. JWT 검증 → userId, appId 추출
3. Upsert: (userId, appId, token) 조합으로 기존 레코드 확인
   - 존재: platform, deviceId, isActive, lastUsedAt 갱신
   - 미존재: 신규 레코드 생성
4. 응답: { id, token, platform, isActive, lastUsedAt, createdAt }
```

**Upsert 구현** (services.ts):
```typescript
export const upsertDevice = async (data: {
  userId: number;
  appId: number;
  token: string;
  platform: string;
  deviceId?: string;
}) => {
  const [inserted] = await db
    .insert(pushDeviceTokens)
    .values({
      userId: data.userId,
      appId: data.appId,
      token: data.token,
      platform: data.platform,
      deviceId: data.deviceId,
      isActive: true,
      lastUsedAt: new Date(),
    })
    .onConflictDoUpdate({
      target: [pushDeviceTokens.userId, pushDeviceTokens.appId, pushDeviceTokens.token],
      set: {
        platform: data.platform,
        deviceId: data.deviceId,
        isActive: true,
        lastUsedAt: new Date(),
        updatedAt: new Date(),
      },
    })
    .returning();

  return inserted;
};
```

### 디바이스 비활성화 (DELETE /push/devices/:id)

```typescript
1. 요청: DELETE /push/devices/123
2. JWT 검증 → userId, appId 추출
3. 디바이스 ID로 조회 + userId, appId 일치 확인 (권한 검증)
4. isActive = false로 업데이트 (소프트 삭제)
5. 응답: 204 No Content
```

**문제점**: 로그아웃 시 모바일은 디바이스 ID를 모를 수 있음
**해결책**: 토큰 기반 비활성화 API 추가 필요 (아래 참조)

---

## 추가 필요 API

### DELETE /push/devices/by-token — 토큰 기반 비활성화

**사용 시나리오**: 로그아웃 시 디바이스 ID를 모르는 경우

**요청**:
```json
DELETE /push/devices/by-token
Authorization: Bearer <jwt>
Content-Type: application/json

{
  "token": "FCM_DEVICE_TOKEN"
}
```

**응답**:
```
204 No Content
```

**에러**:
- 401 Unauthorized: JWT 없음/만료
- 404 Not Found: 해당 토큰이 사용자에게 등록되지 않음

**구현 위치**:
- `apps/server/src/modules/push-alert/handlers.ts` — `deactivateDeviceByToken` 핸들러 추가
- `apps/server/src/modules/push-alert/services.ts` — 이미 존재 (`deactivateDeviceByToken` 함수)
- `apps/server/src/modules/push-alert/index.ts` — 라우터에 엔드포인트 추가
- `apps/server/src/modules/push-alert/validators.ts` — Zod 스키마 추가

**핸들러 구현 예시**:
```typescript
/**
 * 토큰으로 디바이스 비활성화 핸들러 (인증 필요)
 * @param req - Express 요청 객체 (body: { token }, user: { userId, appId })
 * @param res - Express 응답 객체
 * @returns 204: No Content
 */
export const deactivateByToken = async (req: Request, res: Response) => {
  const { token } = deactivateByTokenSchema.parse(req.body);
  const { userId, appId } = getAuthUser(req);

  logger.debug({ userId, appId, tokenPrefix: token.slice(0, 20) }, 'Deactivating device by token');

  // 토큰으로 비활성화 (이미 services.ts에 존재)
  await deactivateDeviceByToken(token, appId);

  // 로그 (비활성화된 디바이스가 없어도 204 반환)
  pushProbe.deviceDeactivatedByToken({
    userId,
    appId,
    tokenPrefix: token.slice(0, 20),
  });

  res.status(204).send();
};
```

**Zod 스키마 (validators.ts)**:
```typescript
export const deactivateByTokenSchema = z.object({
  token: z.string().min(1).max(500),
});
```

**라우터 등록 (index.ts)**:
```typescript
/**
 * 토큰으로 디바이스 비활성화 (인증 필요)
 * @route DELETE /push/devices/by-token
 * @body { token: string }
 * @returns 204: No Content
 */
router.delete('/devices/by-token', authenticate, handlers.deactivateByToken);
```

**주의**:
- 기존 `DELETE /push/devices/:id` 엔드포인트와 충돌 방지 위해 `/devices/by-token` 경로 사용
- `deactivateDeviceByToken` 서비스 함수는 이미 존재 (services.ts:123)
- 해당 토큰이 사용자에게 속하지 않아도 조용히 성공 (멱등성 보장, 보안상 정보 노출 방지)

---

## 운영 로그 (Domain Probe)

### 기존 Probe 함수 (push.probe.ts)

| 함수 | 레벨 | 용도 |
|------|------|------|
| `deviceRegistered` | INFO | 디바이스 등록 성공 |
| `deviceDeactivated` | INFO | 디바이스 비활성화 (ID 기반) |
| `pushSent` | INFO | 푸시 발송 성공 |
| `pushFailed` | ERROR | 푸시 발송 실패 |
| `invalidTokenDetected` | WARN | 무효 토큰 감지 (토큰 앞 20자만 로깅) |
| `receiptsCreated` | INFO | 알림 수신 기록 생성 |
| `notificationRead` | INFO | 알림 읽음 처리 |

### 추가 필요 Probe 함수

```typescript
/**
 * 토큰으로 디바이스 비활성화 (로그아웃 시)
 */
export const deviceDeactivatedByToken = (data: {
  userId: number;
  appId: number;
  tokenPrefix: string;
}) => {
  logger.info('Device deactivated by token', {
    userId: data.userId,
    appId: data.appId,
    tokenPrefix: data.tokenPrefix,
  });
};
```

---

## 에러 처리

### 기존 예외 클래스 활용

| 예외 | HTTP 코드 | 사용 시나리오 |
|------|----------|--------------|
| `UnauthorizedException` | 401 | JWT 없음/만료 |
| `ValidationException` | 400 | 요청 데이터 검증 실패 |
| `NotFoundException` | 404 | 디바이스/토큰 미발견 |
| `BusinessException` | 400 | 비즈니스 규칙 위반 |

### 에러 응답 형식 (errorHandler 미들웨어)

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid token format"
  }
}
```

---

## 입력 검증 (Zod)

### 기존 스키마 (validators.ts)

```typescript
// 디바이스 등록
export const registerDeviceSchema = z.object({
  token: z.string().min(1).max(500),
  platform: z.enum(['ios', 'android', 'web']),
  deviceId: z.string().max(255).optional(),
});

// 푸시 발송
export const sendPushSchema = z
  .object({
    appCode: z.string(),
    userId: z.number().int().positive().optional(),
    userIds: z.array(z.number().int().positive()).optional(),
    targetType: z.enum(['all']).optional(),
    title: z.string().min(1).max(255),
    body: z.string().min(1).max(1000),
    data: z.record(z.any()).optional(),
    imageUrl: z.string().url().max(500).optional(),
  })
  .refine(
    (data) =>
      (data.userId !== undefined ? 1 : 0) +
        (data.userIds !== undefined ? 1 : 0) +
        (data.targetType !== undefined ? 1 : 0) ===
      1,
    {
      message: 'Exactly one of userId, userIds, or targetType must be provided',
    }
  );
```

---

## 모바일 연동 가이드

### 로그인 후 토큰 등록

```dart
// 모바일 (Flutter)
1. 소셜 로그인 완료 → JWT 토큰 획득
2. FCM 토큰 획득
3. POST /push/devices { token, platform, deviceId }
   - Authorization: Bearer <jwt>
   - 응답: { id, token, platform, isActive, lastUsedAt, createdAt }
4. 로컬에 디바이스 ID 저장 (선택: 추후 비활성화 시 사용)
```

### 토큰 갱신 시 재등록

```dart
// FCM 토큰 갱신 리스너
FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
  // POST /push/devices { token: newToken, platform, deviceId }
  // Upsert 방식이므로 기존 레코드 자동 갱신됨
});
```

### 로그아웃 시 비활성화

**방법 1: 디바이스 ID 기반 (기존 API)**
```dart
// 로컬에 저장된 디바이스 ID 사용
DELETE /push/devices/{id}
Authorization: Bearer <jwt>
```

**방법 2: 토큰 기반 (신규 API, 권장)**
```dart
// 디바이스 ID를 몰라도 됨
DELETE /push/devices/by-token
Authorization: Bearer <jwt>
Body: { "token": "FCM_DEVICE_TOKEN" }
```

**권장**: 방법 2 (토큰 기반) — 디바이스 ID를 로컬에 저장하지 않아도 됨

---

## 인증 플로우

### JWT 검증 (authenticate 미들웨어)

```
1. Authorization: Bearer <token> 헤더에서 JWT 추출
2. apps 테이블에서 앱별 JWT 시크릿 조회
3. jwt.verify(token, secret)
4. 페이로드에서 userId, appId 추출
5. req.user = { userId, appId } 주입
6. 다음 미들웨어로 제어 전달
```

**JWT 페이로드 예시**:
```json
{
  "userId": 1,
  "appId": 1,
  "iat": 1672531200,
  "exp": 1672534800
}
```

---

## 성능 고려사항

### 인덱스 전략

| 인덱스 | 용도 | 효과 |
|--------|------|------|
| `(userId, appId, token)` | Upsert 시 중복 검사 | 유니크 제약 + 빠른 조회 |
| `userId` | 사용자별 디바이스 목록 | listDevices 핸들러 |
| `token` | 토큰 기반 비활성화 | deactivateByToken |
| `isActive` | 활성 디바이스 필터링 | 푸시 발송 시 대상 조회 |

### Upsert vs Insert + Update

**Upsert 장점**:
- 단일 쿼리로 처리 (네트워크 왕복 최소화)
- 경합 조건(race condition) 방지
- 멱등성 보장 (같은 요청을 여러 번 보내도 결과 동일)

**트레이드오프**:
- 유니크 제약 필수 (이미 설정됨)

---

## 보안 고려사항

### 인증 필수

모든 디바이스 관련 엔드포인트는 `authenticate` 미들웨어 적용:
- `POST /push/devices`
- `GET /push/devices`
- `DELETE /push/devices/:id`
- `DELETE /push/devices/by-token` (신규)

### 권한 검증

**기존 DELETE /push/devices/:id**:
```typescript
// 다른 사용자의 디바이스를 삭제할 수 없도록 검증
const device = await deactivateDeviceService(id, userId, appId);
if (!device) {
  throw new NotFoundException('Device', id);
}
```

**신규 DELETE /push/devices/by-token**:
```typescript
// appId로만 필터링 (같은 앱 내에서만 비활성화)
await deactivateDeviceByToken(token, appId);
// userId 검증 없음 (토큰이 여러 사용자에게 등록될 수 없으므로 안전)
```

### 토큰 로깅 정책

민감 정보 보호를 위해 토큰 전체를 로깅하지 않고 앞 20자만 기록:
```typescript
pushProbe.deviceDeactivatedByToken({
  userId,
  appId,
  tokenPrefix: token.slice(0, 20), // 전체 토큰 노출 방지
});
```

---

## 무효 토큰 자동 정리

### FCM 발송 실패 시 자동 비활성화

```typescript
// handlers.ts - sendPush
if (result.invalidTokens.length > 0) {
  for (const invalidToken of result.invalidTokens) {
    await deactivateDeviceByToken(invalidToken, app.id);
    pushProbe.invalidTokenDetected({
      token: invalidToken,
      appId: app.id,
    });
  }
}
```

**무효 토큰 판단 기준** (fcm.ts):
- `messaging/invalid-registration-token`
- `messaging/registration-token-not-registered`

**효과**: 앱 삭제/재설치 시 오래된 토큰 자동 제거

---

## 작업 계획

### Phase 1: API 추가 (서버)

1. **validators.ts** — Zod 스키마 추가
   ```typescript
   export const deactivateByTokenSchema = z.object({
     token: z.string().min(1).max(500),
   });
   ```

2. **handlers.ts** — 핸들러 추가
   ```typescript
   export const deactivateByToken = async (req: Request, res: Response) => {
     // 구현 (위 예시 참조)
   };
   ```

3. **push.probe.ts** — Probe 함수 추가
   ```typescript
   export const deviceDeactivatedByToken = (data: {
     userId: number;
     appId: number;
     tokenPrefix: string;
   }) => {
     logger.info('Device deactivated by token', data);
   };
   ```

4. **index.ts** — 라우터 등록
   ```typescript
   router.delete('/devices/by-token', authenticate, handlers.deactivateByToken);
   ```

5. **테스트** — `tests/unit/push-alert/handlers.test.ts`
   - 정상 비활성화
   - 토큰 없음
   - 인증 실패

### Phase 2: 모바일 연동

모바일 팀이 담당:
- 로그인 후 `POST /push/devices` 호출
- 토큰 갱신 시 재등록
- 로그아웃 시 `DELETE /push/devices/by-token` 호출

---

## 체크리스트

### 서버 구현 검증
- [x] 디바이스 토큰 등록 API (Upsert 방식)
- [x] 디바이스 목록 조회 API
- [x] 디바이스 비활성화 API (ID 기반)
- [ ] **디바이스 비활성화 API (토큰 기반)** — 추가 필요
- [x] 푸시 발송 API
- [x] 무효 토큰 자동 비활성화
- [x] 유니크 제약 (userId, appId, token)
- [x] 인덱스 설정 (userId, token, isActive)
- [x] 운영 로그 (Domain Probe)

### API 설계 검증
- [x] 인증 미들웨어 적용
- [x] 권한 검증 (자기 디바이스만 삭제)
- [x] 입력 검증 (Zod)
- [x] 에러 처리 (전역 핸들러)
- [x] 로깅 정책 (토큰 앞 20자만)

### 모바일 연동 준비
- [ ] 토큰 기반 비활성화 API 추가
- [ ] API 문서 업데이트
- [ ] 모바일 팀 공유

---

## 참고 자료

- 기존 푸시 알림 분석: [`docs/core/fcm-push-notification.md`](../../core/fcm-push-notification.md)
- 사용자 스토리: [`docs/wowa/fcm-token/user-story.md`](./user-story.md)
- 서버 카탈로그: [`docs/wowa/server-catalog.md`](../server-catalog.md)
- API Response 가이드: [`.claude/guide/server/api-response-design.md`](../../../.claude/guide/server/api-response-design.md)
- 예외 처리 가이드: [`.claude/guide/server/exception-handling.md`](../../../.claude/guide/server/exception-handling.md)
- 로깅 가이드: [`.claude/guide/server/logging-best-practices.md`](../../../.claude/guide/server/logging-best-practices.md)
