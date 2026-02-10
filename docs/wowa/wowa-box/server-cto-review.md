# Server CTO Review: wowa-box (Updated with CodeRabbit Issues)

**Feature**: wowa-box (박스 관리 기능 개선)
**Platform**: Server (Node.js/Express)
**Reviewer**: CTO
**Date**: 2026-02-10 (Updated)
**PR**: #13

---

## 검증 결과 요약

### 테스트 결과
- **전체 테스트**: 277 tests passed (100%)
- **박스 기능 테스트**: 44 tests (handlers: 13, services: 31)
- **실행 시간**: 5.39s
- **상태**: ✅ ALL PASSED

### 빌드 결과
- **TypeScript 컴파일**: ✅ 성공
- **Drizzle Schema**: ✅ 정상
- **Migration**: ✅ 정상 (DB 스키마 변경 없음)

---

## CodeRabbit PR #13 지적사항 통합 검토

### 🔴 Critical Issues (2건)

#### 1. `validators.ts:7` — trim() 순서 오류로 min validation 우회 가능

**CodeRabbit 지적**:
```typescript
export const createBoxSchema = z.object({
  name: z.string().min(2, '박스 이름은 2자 이상이어야 합니다').max(255).trim(),
  //                    ^ min(2) 검증이 trim() 전에 실행됨
});
```

**문제**:
- 입력값 `"  "` (공백 2자) → min(2) 통과 → trim() 후 빈 문자열 → **DB에 빈 문자열 저장**
- 서버 응답 201 Created이지만 박스 이름이 빈 값으로 생성됨

**영향**: ⚠️ **데이터 무결성 위협** — 공백만 입력 시 유효성 검증 우회

**수정 방안**:
```typescript
export const createBoxSchema = z.object({
  name: z.string().trim().min(2, '박스 이름은 2자 이상이어야 합니다').max(255),
  //                ^ trim() 먼저 실행 → min(2) 검증
  region: z.string().trim().min(2, '지역은 2자 이상이어야 합니다').max(255),
  description: z.string().trim().max(1000).optional(),
});
```

**우선순위**: 🔴 **HIGH** — 즉시 수정 필요

---

#### 2. `box_search_controller.dart:166` — firstWhere StateError 크래시 가능 (Mobile)

**CodeRabbit 지적**:
```dart
final joinedBox = searchResults.firstWhere((box) => box.id == boxId);
// 만약 searchResults에서 해당 박스를 찾지 못하면 StateError 발생
```

**시나리오**:
1. 사용자가 박스 검색 → `searchResults`에 박스 A 포함
2. 다른 사용자가 박스 A를 삭제 (또는 접근 불가 상태로 변경)
3. 사용자가 박스 A 가입 시도 → 서버 API는 404/409 에러
4. API 실패하므로 firstWhere 로직에 도달하지 않음 (try-catch로 이동)

**현재 코드 분석**:
```dart
try {
  await _repository.joinBox(boxId);  // 실패 시 throw → catch로 이동
  final joinedBox = searchResults.firstWhere((box) => box.id == boxId);  // 도달 안 함
} on NetworkException catch (e) { ... }
```

**판정**: ⚠️ **MEDIUM** — API 실패 시 catch로 이동하므로 실제 크래시 확률 낮음, 하지만 방어 코드 추가 권장

**수정 방안** (Mobile Controller):
```dart
try {
  await _repository.joinBox(boxId);

  // firstWhereOrNull 사용 (collection 패키지)
  final joinedBox = searchResults.firstWhereOrNull((box) => box.id == boxId);
  if (joinedBox != null) {
    currentBox.value = joinedBox;
  }

  Get.snackbar(...);
} on NetworkException catch (e) { ... }
```

**우선순위**: 🟠 **MEDIUM** — 방어 코드 추가 권장

---

### 🟠 Major Issues (5건)

#### 3. BusinessException 409 처리 누락

**CodeRabbit 지적**: Server-Mobile 간 409 응답 처리 일관성 확인 필요

**Server 코드**:
- `handlers.ts` (create, join): try-catch 없음 → 전역 에러 핸들러로 위임
- 전역 에러 핸들러에서 `BusinessException` → 409 매핑 확인 필요

**Mobile Repository 코드**:
```dart
if (e.response?.statusCode == 409) {
  throw NetworkException('이미 가입된 박스입니다');
}
```

**확인 필요**: Server 전역 에러 핸들러에서 `BusinessException` → 409 매핑 동작 확인

**우선순위**: 🟠 **MEDIUM** — 통합 테스트로 검증 필요

---

#### 4. 500+ 에러 Exception 타입 불일치

**CodeRabbit 지적**: Server에서 500 에러 시 정확한 Exception 타입 확인 필요

**Server 코드**:
- `services.ts`: 500 에러 시 `NotFoundException`, `BusinessException` throw
- 전역 에러 핸들러: 500 에러 매핑 확인 필요

**Mobile Repository 코드**:
```dart
if (e.response?.statusCode == 500) {
  throw NetworkException('일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요');
}
```

**판정**: Mobile에서 500 에러를 일반 메시지로 처리하므로 UX 문제 없음

**우선순위**: 🟠 **MEDIUM** — 모니터링 및 로깅으로 추적

---

#### 5. `handlers.ts` — 트랜잭션 실패 시 Probe 로깅 누락

**CodeRabbit 지적**: 트랜잭션 실패 시 도메인 로그 부재

**현재 코드**:
```typescript
export const create: RequestHandler = async (req, res) => {
  const { userId } = (req as AuthenticatedRequest).user;
  const { name, region, description } = createBoxSchema.parse(req.body);

  const result = await createBoxWithMembership({
    name,
    region,
    description,
    createdBy: userId,
  });

  res.status(201).json(result);
};
```

**문제**: 트랜잭션 실패 시 로그 없음 (전역 에러 핸들러에서 처리되지만 Domain Probe 로그 부재)

**수정 방안**:
```typescript
export const create: RequestHandler = async (req, res) => {
  const { userId } = (req as AuthenticatedRequest).user;
  const { name, region, description } = createBoxSchema.parse(req.body);

  try {
    const result = await createBoxWithMembership({
      name,
      region,
      description,
      createdBy: userId,
    });

    res.status(201).json(result);
  } catch (error) {
    boxProbe.creationFailed({
      userId,
      name,
      error: error instanceof Error ? error.message : 'Unknown error',
    });
    throw error;  // 전역 에러 핸들러로 전달
  }
};
```

**우선순위**: 🟠 **MEDIUM** — 로깅 베스트 프랙티스 준수

---

#### 6. `services.ts` — 트랜잭션 내부 Probe 로깅

**CodeRabbit 지적**: 트랜잭션 커밋 전 로깅 → 롤백 시 로그와 실제 상태 불일치

**현재 코드**:
```typescript
export async function createBoxWithMembership(data: CreateBoxInput): Promise<CreateBoxResponse> {
  return await db.transaction(async (tx) => {
    // ...

    // 4. 로깅 (트랜잭션 내부)
    if (previousBoxId) {
      boxProbe.boxSwitched({ ... });
    } else {
      boxProbe.created({ ... });
      boxProbe.memberJoined({ ... });
    }

    return { box, membership, previousBoxId };
  });
}
```

**문제**: 트랜잭션 커밋 전에 로깅 → 롤백 시 로그와 실제 상태 불일치

**수정 방안**:
```typescript
export async function createBoxWithMembership(data: CreateBoxInput): Promise<CreateBoxResponse> {
  const result = await db.transaction(async (tx) => {
    // ...
    return { box, membership, previousBoxId };
  });

  // 트랜잭션 커밋 후 로깅
  if (result.previousBoxId) {
    boxProbe.boxSwitched({
      userId: data.createdBy,
      previousBoxId: result.previousBoxId,
      newBoxId: result.box.id,
    });
  } else {
    boxProbe.created({
      boxId: result.box.id,
      name: result.box.name,
      region: result.box.region,
      createdBy: result.box.createdBy,
    });
    boxProbe.memberJoined({
      boxId: result.box.id,
      userId: data.createdBy,
    });
  }

  return result;
}
```

**우선순위**: 🟠 **MEDIUM** — 로그 일관성 개선

---

#### 7. `services.ts` — ILIKE 와일드카드 이스케이프 미처리

**CodeRabbit 지적**: 사용자 입력 `%`, `_` 포함 시 의도하지 않은 패턴 매칭

**현재 코드**:
```typescript
.where(
  or(
    ilike(boxes.name, `%${trimmedKeyword}%`),
    ilike(boxes.region, `%${trimmedKeyword}%`)
  )
)
```

**예시**:
- 입력: `"강남%"` → `ILIKE '%강남%%'` → "강남크로스핏", "강남ABC" 모두 매칭
- 입력: `"강남_점"` → `ILIKE '%강남_점%'` → "강남1점", "강남a점" 모두 매칭

**수정 방안**:
```typescript
// 이스케이프 함수 추가
function escapeLikePattern(str: string): string {
  return str.replace(/[%_\\]/g, '\\$&');
}

// 검색 쿼리 수정
const escapedKeyword = escapeLikePattern(trimmedKeyword);
.where(
  or(
    ilike(boxes.name, `%${escapedKeyword}%`),
    ilike(boxes.region, `%${escapedKeyword}%`)
  )
)
```

**우선순위**: 🟡 **LOW** — 실무에서 `%`, `_` 입력 드묾

---

### 🟡 Minor Issues (1건)

#### 8. `types.ts` — JSDoc 누락

**CodeRabbit 지적**: 타입 정의에 JSDoc 주석 부재

**수정 방안**:
```typescript
/**
 * 박스 정보 + 멤버 수
 */
export interface BoxWithMemberCount {
  /** 박스 ID */
  id: number;
  /** 박스 이름 */
  name: string;
  /** 박스 지역 */
  region: string;
  /** 박스 설명 (선택) */
  description: string | null;
  /** 멤버 수 (집계) */
  memberCount: number;
}
```

**우선순위**: 🟢 **INFO** — 코드 가독성 향상

---

## 코드 품질 평가

### 1. Express 미들웨어 패턴 준수 ✅

- ✅ Handler 함수 구조: `(req, res) => {}` 패턴
- ✅ Controller/Service 패턴 사용 안 함
- ✅ 비즈니스 로직을 service 레이어로 분리
- ✅ 전역 에러 핸들러 활용

### 2. Drizzle ORM 올바른 사용 ✅

- ✅ 트랜잭션: `db.transaction()` 사용
- ✅ JSDoc 주석 포함
- ✅ FK 사용 안 함 (애플리케이션 레벨 관계 관리)
- ✅ Index 적절히 설정
- ✅ Unique 제약 설정 (boxId + userId)

### 3. 트랜잭션 구현 ✅ (핵심 개선 사항)

**강점**:
- ✅ 박스 생성 + 멤버 등록을 단일 트랜잭션으로 처리
- ✅ 데이터 정합성 보장 (부분 실패 시 전체 롤백)
- ✅ 단일 박스 정책 구현
- ✅ previousBoxId 반환

**개선 필요**:
- ⚠️ 트랜잭션 내부 로깅 → 커밋 후 로깅으로 이동 필요

### 4. 통합 키워드 검색 구현 ✅

**강점**:
- ✅ 통합 키워드 검색 (name OR region)
- ✅ 하위 호환성 유지
- ✅ ILIKE 사용 (대소문자 무시)
- ✅ memberCount 집계
- ✅ SQL Injection 방지

**개선 필요**:
- ⚠️ ILIKE 와일드카드 이스케이프 추가 권장

---

## Quality Scores

| 항목 | 점수 | 평가 |
|------|------|------|
| **코드 품질** | 8.5/10 | Critical 이슈 1건 (validators.ts trim 순서) |
| **테스트 커버리지** | 9.0/10 | 핵심 로직 모두 커버, Edge case 테스트 포함 |
| **API 설계** | 9.0/10 | RESTful 준수, 하위 호환성 유지 |
| **에러 처리** | 8.5/10 | BusinessException, NotFoundException 사용, 409 처리 확인 필요 |
| **로깅** | 8.5/10 | Domain Probe 패턴, 트랜잭션 로깅 위치 개선 필요 |
| **문서화** | 8.5/10 | JSDoc 주석, types.ts JSDoc 누락 |
| **성능** | 9.0/10 | Index 설정, memberCount 집계 최적화 |
| **보안** | 9.0/10 | SQL Injection 방지, 와일드카드 이스케이프 권장 |

**종합 점수**: **8.8/10** (우수, Critical 이슈 수정 후 9.3/10)

---

## 최종 승인

### 승인 상태: ⚠️ **CONDITIONAL APPROVAL**

**승인 조건**:
1. 🔴 **validators.ts:7** — trim() 순서 수정 (Critical)
2. 🟠 **handlers.ts** — 트랜잭션 실패 로깅 추가 (권장)
3. 🟠 **services.ts** — 트랜잭션 커밋 후 로깅 이동 (권장)

**승인 후 다음 단계**:
1. Critical 이슈 수정 완료
2. 테스트 재실행 (277 tests 통과 확인)
3. Mobile CTO Review 진행
4. Independent Reviewer 검증

**선택 사항 (권장)**:
- 🟡 ILIKE 와일드카드 이스케이프 함수 추가
- 🟢 types.ts JSDoc 주석 추가

---

**Reviewer**: CTO
**Date**: 2026-02-10 (Updated with CodeRabbit Issues)
**Signature**: ⚠️ Conditional Approval (Critical 이슈 수정 필수)
