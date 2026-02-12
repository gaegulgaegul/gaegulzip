# Server Work Plan: FCM 토큰 저장

## 개요

FCM 토큰 저장 기능의 서버 작업은 **최소한의 추가 작업**만 필요합니다. 기존 푸시 알림 모듈에 토큰 기반 비활성화 API를 추가하여 모바일 로그아웃 시 디바이스 ID 없이도 토큰을 비활성화할 수 있도록 합니다.

**핵심 전략**:
- 기존 `push-alert` 모듈 확장
- `DELETE /push/devices/by-token` API 추가 (토큰 기반 비활성화)
- 기존 서비스 함수 재사용 (`deactivateDeviceByToken` 이미 존재)
- TDD 방식 (테스트 먼저 작성)

---

## 실행 그룹

### Group 1 (병렬) — 전체 작업

| Agent | Module | 설명 |
|-------|--------|------|
| node-developer | push-alert | 토큰 기반 비활성화 API 추가 |

**참고**: Server 작업은 단일 모듈 내 작업이므로 병렬 분배 불필요

---

## 작업 범위

### 모듈: push-alert

**위치**: `apps/server/src/modules/push-alert/`

**변경 파일**:
1. `validators.ts` — Zod 스키마 추가
2. `handlers.ts` — `deactivateByToken` 핸들러 추가
3. `push.probe.ts` — 로그 함수 추가
4. `index.ts` — 라우터 등록
5. `tests/unit/push-alert/handlers.test.ts` — 테스트 추가

**불변 파일**:
- `services.ts` — `deactivateDeviceByToken` 함수 이미 존재 (재사용)
- `schema.ts` — DB 스키마 변경 없음

---

## 작업 상세

### 1. validators.ts — Zod 스키마 추가

**파일**: `apps/server/src/modules/push-alert/validators.ts`

**추가 내용**:
```typescript
/**
 * 토큰으로 디바이스 비활성화 요청 스키마
 */
export const deactivateByTokenSchema = z.object({
  token: z.string().min(1).max(500),
});
```

**검증 사항**:
- 토큰 길이: 1~500자
- 빈 문자열 불허

---

### 2. handlers.ts — deactivateByToken 핸들러 추가

**파일**: `apps/server/src/modules/push-alert/handlers.ts`

**추가 내용**:
```typescript
/**
 * 토큰으로 디바이스 비활성화 핸들러 (인증 필요)
 *
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

**설계 근거**:
- `deactivateDeviceByToken` 서비스 함수는 이미 `services.ts:123`에 존재 (재사용)
- 토큰이 사용자에게 속하지 않아도 조용히 성공 (멱등성 보장, 보안상 정보 노출 방지)
- 토큰 전체를 로깅하지 않고 앞 20자만 기록 (민감 정보 보호)

---

### 3. push.probe.ts — 로그 함수 추가

**파일**: `apps/server/src/modules/push-alert/push.probe.ts`

**추가 내용**:
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

**로그 정책**:
- 레벨: INFO (정상 플로우)
- 토큰 전체 노출 방지 (앞 20자만 로깅)

---

### 4. index.ts — 라우터 등록

**파일**: `apps/server/src/modules/push-alert/index.ts`

**추가 내용**:
```typescript
/**
 * 토큰으로 디바이스 비활성화 (인증 필요)
 * @route DELETE /push/devices/by-token
 * @body { token: string }
 * @returns 204: No Content
 */
router.delete('/devices/by-token', authenticate, handlers.deactivateByToken);
```

**주의사항**:
- 경로: `/devices/by-token` (기존 `/devices/:id`와 충돌 방지)
- 미들웨어: `authenticate` 필수 (JWT 검증)
- HTTP 메서드: DELETE

---

### 5. tests/unit/push-alert/handlers.test.ts — 테스트 추가

**파일**: `apps/server/src/modules/push-alert/tests/unit/handlers.test.ts`

**TDD 방식**: 테스트를 먼저 작성하고 구현

**테스트 케이스**:

#### 1) 정상 비활성화 (200 OK → 204 No Content)
```typescript
describe('DELETE /push/devices/by-token', () => {
  it('should deactivate device by token and return 204', async () => {
    // Given: 디바이스 토큰 등록됨
    const registerResponse = await request(app)
      .post('/api/push/devices')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        token: 'test_fcm_token_123',
        platform: 'ios',
      });

    expect(registerResponse.status).toBe(200);

    // When: 토큰으로 비활성화
    const response = await request(app)
      .delete('/api/push/devices/by-token')
      .set('Authorization', `Bearer ${authToken}`)
      .send({ token: 'test_fcm_token_123' });

    // Then
    expect(response.status).toBe(204);

    // Verify: 디바이스가 비활성화됨
    const listResponse = await request(app)
      .get('/api/push/devices')
      .set('Authorization', `Bearer ${authToken}`);

    const devices = listResponse.body;
    const device = devices.find((d: any) => d.token === 'test_fcm_token_123');
    expect(device.isActive).toBe(false);
  });
});
```

#### 2) 토큰 없음 (멱등성 보장)
```typescript
it('should return 204 even if token does not exist (idempotent)', async () => {
  // When: 존재하지 않는 토큰 비활성화
  const response = await request(app)
    .delete('/api/push/devices/by-token')
    .set('Authorization', `Bearer ${authToken}`)
    .send({ token: 'non_existent_token' });

  // Then: 204 반환 (멱등성)
  expect(response.status).toBe(204);
});
```

#### 3) 인증 실패 (401 Unauthorized)
```typescript
it('should return 401 if not authenticated', async () => {
  // When: 인증 없이 요청
  const response = await request(app)
    .delete('/api/push/devices/by-token')
    .send({ token: 'test_fcm_token_123' });

  // Then
  expect(response.status).toBe(401);
  expect(response.body.error.code).toBe('UNAUTHORIZED');
});
```

#### 4) 입력 검증 실패 (400 Bad Request)
```typescript
it('should return 400 if token is missing', async () => {
  // When: 토큰 없이 요청
  const response = await request(app)
    .delete('/api/push/devices/by-token')
    .set('Authorization', `Bearer ${authToken}`)
    .send({});

  // Then
  expect(response.status).toBe(400);
  expect(response.body.error.code).toBe('VALIDATION_ERROR');
});

it('should return 400 if token is too long', async () => {
  // When: 토큰이 500자 초과
  const longToken = 'a'.repeat(501);
  const response = await request(app)
    .delete('/api/push/devices/by-token')
    .set('Authorization', `Bearer ${authToken}`)
    .send({ token: longToken });

  // Then
  expect(response.status).toBe(400);
});
```

---

## 기존 코드 재사용

### services.ts — deactivateDeviceByToken (이미 존재)

**위치**: `apps/server/src/modules/push-alert/services.ts:123`

**함수 시그니처**:
```typescript
/**
 * 토큰으로 디바이스 비활성화
 * @param token - FCM 디바이스 토큰
 * @param appId - 앱 ID
 */
export const deactivateDeviceByToken = async (token: string, appId: number) => {
  await db
    .update(pushDeviceTokens)
    .set({ isActive: false, updatedAt: new Date() })
    .where(
      and(
        eq(pushDeviceTokens.token, token),
        eq(pushDeviceTokens.appId, appId)
      )
    );
};
```

**특징**:
- 토큰과 appId로 필터링 (다른 앱의 토큰은 비활성화 안 됨)
- 소프트 삭제 (isActive = false)
- 해당 토큰이 없어도 에러 없음 (멱등성)

**설계 근거**: 이미 구현되어 있으므로 핸들러에서 재사용만 하면 됨

---

## API 명세

### DELETE /push/devices/by-token

**요청**:
```http
DELETE /api/push/devices/by-token
Authorization: Bearer <jwt>
Content-Type: application/json

{
  "token": "FCM_DEVICE_TOKEN"
}
```

**응답 (204 No Content)**:
```
(빈 응답)
```

**에러 응답**:

#### 401 Unauthorized
```json
{
  "error": {
    "code": "UNAUTHORIZED",
    "message": "인증이 필요합니다"
  }
}
```

#### 400 Bad Request
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid token format"
  }
}
```

---

## 인증 플로우

### JWT 검증 (authenticate 미들웨어)

```
1. Authorization: Bearer <token> 헤더에서 JWT 추출
2. apps 테이블에서 앱별 JWT 시크릿 조회
3. jwt.verify(token, secret)
4. 페이로드에서 userId, appId 추출
5. req.user = { userId, appId } 주입
6. 핸들러로 제어 전달
```

**getAuthUser 헬퍼**:
```typescript
const { userId, appId } = getAuthUser(req);
```

---

## 보안 고려사항

### 1. 권한 검증

**appId 필터링**:
- `deactivateDeviceByToken(token, appId)` — 같은 앱 내에서만 비활성화
- 다른 앱의 토큰은 영향받지 않음

### 2. 정보 노출 방지

**멱등성 보장**:
- 토큰이 사용자에게 속하지 않아도 204 반환
- 404 반환 시 공격자가 토큰 존재 여부를 알 수 있으므로 방지

### 3. 토큰 로깅 정책

**앞 20자만 로깅**:
```typescript
pushProbe.deviceDeactivatedByToken({
  userId,
  appId,
  tokenPrefix: token.slice(0, 20), // 전체 토큰 노출 방지
});
```

---

## 작업 체크리스트

### 구현
- [ ] `validators.ts`: `deactivateByTokenSchema` 추가
- [ ] `handlers.ts`: `deactivateByToken` 핸들러 추가
- [ ] `push.probe.ts`: `deviceDeactivatedByToken` 로그 함수 추가
- [ ] `index.ts`: 라우터에 `DELETE /devices/by-token` 등록

### TDD
- [ ] 테스트 먼저 작성 (5개 케이스)
- [ ] Red: 테스트 실패 확인
- [ ] Green: 구현하여 테스트 통과
- [ ] Refactor: 코드 정리 (중복 제거, 명확성 개선)

### 검증
- [ ] `pnpm test` — 모든 테스트 통과
- [ ] `pnpm build` — 빌드 성공
- [ ] Postman/curl로 수동 테스트 (정상 케이스, 에러 케이스)
- [ ] 로그 확인 (INFO 레벨로 비활성화 기록 확인)

### 코드 품질
- [ ] JSDoc 주석 (한국어)
- [ ] Express 미들웨어 패턴 준수
- [ ] Domain Probe 패턴 활용
- [ ] 에러 처리 (전역 errorHandler 미들웨어 활용)

---

## 모바일 연동 준비

### API 문서 업데이트

**모바일 팀에게 공유할 정보**:
- 엔드포인트: `DELETE /api/push/devices/by-token`
- 요청 본문: `{ token: string }`
- 응답: 204 No Content
- 에러: 401 (인증 실패), 400 (검증 실패)

### PushApiClient 구현 예상

**모바일 쪽 (참고용)**:
```dart
/// 토큰으로 디바이스 비활성화 (로그아웃 시 사용)
Future<void> deactivateDeviceByToken(String token) async {
  await _dio.delete(
    '/api/push/devices/by-token',
    data: {'token': token},
  );
}
```

---

## 참고 자료

### 기존 코드
- `apps/server/src/modules/push-alert/handlers.ts` — 기존 핸들러 패턴 참조
- `apps/server/src/modules/push-alert/services.ts` — `deactivateDeviceByToken` 함수
- `apps/server/src/modules/push-alert/validators.ts` — 기존 Zod 스키마 참조
- `apps/server/src/modules/push-alert/index.ts` — 기존 라우터 패턴

### 가이드
- API Response Design: `.claude/guide/server/api-response-design.md`
- Exception Handling: `.claude/guide/server/exception-handling.md`
- Logging Best Practices: `.claude/guide/server/logging-best-practices.md`

### 설계 문서
- server-brief.md: `docs/wowa/fcm-token/server-brief.md`
- 사용자 스토리: `docs/wowa/fcm-token/user-story.md`

---

## 예상 소요 시간

| 작업 | 예상 시간 |
|------|----------|
| 테스트 작성 (5개 케이스) | 30분 |
| 구현 (validators, handlers, probe, router) | 20분 |
| 테스트 실행 및 디버깅 | 20분 |
| 수동 테스트 (Postman) | 15분 |
| **합계** | **1시간 25분** |

---

## Developer 역할 분배

### node-developer (1명)

**담당 범위**: 전체 작업
- 모듈: `push-alert`
- 파일: `validators.ts`, `handlers.ts`, `push.probe.ts`, `index.ts`, `tests/unit/handlers.test.ts`

**작업 순서**:
1. `tests/unit/handlers.test.ts` — 테스트 작성 (TDD Red)
2. `validators.ts` — Zod 스키마 추가
3. `push.probe.ts` — 로그 함수 추가
4. `handlers.ts` — 핸들러 구현 (TDD Green)
5. `index.ts` — 라우터 등록
6. `pnpm test` — 테스트 통과 확인 (TDD Green)
7. 리팩토링 (필요한 경우) — TDD Refactor
8. `pnpm build` — 빌드 검증

---

## 완료 조건

### Acceptance Criteria
- [ ] `DELETE /push/devices/by-token` API가 정상 동작함
- [ ] 인증된 사용자만 접근 가능 (401 반환 확인)
- [ ] 토큰 기반 비활성화 성공 (204 반환, isActive=false 확인)
- [ ] 토큰이 없어도 멱등성 보장 (204 반환)
- [ ] 입력 검증 실패 시 400 반환
- [ ] 모든 단위 테스트 통과
- [ ] 로그에 비활성화 이벤트 기록 (INFO 레벨, 토큰 앞 20자만)

### Definition of Done
- [ ] 코드 리뷰 완료 (CTO 승인)
- [ ] 모든 테스트 통과 (`pnpm test`)
- [ ] 빌드 성공 (`pnpm build`)
- [ ] JSDoc 주석 작성 완료 (한국어)
- [ ] 로깅 정책 준수 (Domain Probe, 토큰 일부만 로깅)
- [ ] API 문서 업데이트 (모바일 팀 공유)
