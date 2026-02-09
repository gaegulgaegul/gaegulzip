# Server CTO Review: wowa-box

**Feature**: wowa-box (박스 관리 기능 개선)
**Platform**: Server (Node.js/Express)
**Reviewer**: CTO
**Date**: 2026-02-09

---

## 검증 결과 요약

### 테스트 결과
- **전체 테스트**: 277 tests passed (100%)
- **박스 기능 테스트**: 44 tests (handlers: 13, services: 31)
- **실행 시간**: 9.24s
- **상태**: ✅ ALL PASSED

### 빌드 결과
- **TypeScript 컴파일**: ✅ 성공
- **Drizzle Schema**: ✅ 정상
- **Migration**: ✅ 정상 (DB 스키마 변경 없음)

---

## 코드 품질 평가

### 1. Express 미들웨어 패턴 준수 ✅

**handlers.ts**:
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

- ✅ Express RequestHandler 타입 사용
- ✅ Controller/Service 패턴 사용 안 함 (NestJS 스타일 금지)
- ✅ 비즈니스 로직을 service 레이어로 분리
- ✅ 전역 에러 핸들러 활용 (try-catch 불필요)
- ✅ 입력 검증은 Zod validator 사용

### 2. Drizzle ORM 올바른 사용 ✅

**schema.ts**:
```typescript
export const boxes = pgTable('boxes', {
  id: serial('id').primaryKey(),
  name: varchar('name', { length: 255 }).notNull(),
  region: varchar('region', { length: 255 }).notNull(),
  description: text('description'),
  createdBy: integer('created_by').notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull().$onUpdate(() => new Date()),
}, (table) => ({
  createdByIdx: index('idx_boxes_created_by').on(table.createdBy),
  nameIdx: index('idx_boxes_name').on(table.name),
  regionIdx: index('idx_boxes_region').on(table.region),
}));

export const boxMembers = pgTable('box_members', {
  id: serial('id').primaryKey(),
  boxId: integer('box_id').notNull(),
  userId: integer('user_id').notNull(),
  role: varchar('role', { length: 20 }).notNull().default('member'),
  joinedAt: timestamp('joined_at').defaultNow().notNull(),
}, (table) => ({
  uniqueBoxUser: unique().on(table.boxId, table.userId),
  boxIdIdx: index('idx_box_members_box_id').on(table.boxId),
  userIdIdx: index('idx_box_members_user_id').on(table.userId),
}));
```

- ✅ JSDoc 주석 포함 (한국어)
- ✅ FK 사용 안 함 (애플리케이션 레벨 관계 관리)
- ✅ Index 적절히 설정 (검색 최적화)
- ✅ Unique 제약 설정 (boxId + userId)
- ✅ defaultNow(), $onUpdate() 올바른 사용

### 3. 트랜잭션 구현 ✅ (핵심 개선 사항)

**services.ts - createBoxWithMembership**:
```typescript
export async function createBoxWithMembership(data: CreateBoxInput): Promise<CreateBoxResponse> {
  return await db.transaction(async (tx) => {
    // 1. 박스 생성
    const [box] = await tx.insert(boxes).values({
      name: data.name,
      region: data.region,
      description: data.description ?? null,
      createdBy: data.createdBy,
    }).returning();

    // 2. 기존 박스 멤버십 확인 및 삭제 (단일 박스 정책)
    const [existingMembership] = await tx.select()
      .from(boxMembers)
      .where(eq(boxMembers.userId, data.createdBy))
      .limit(1);

    let previousBoxId: number | null = null;
    if (existingMembership) {
      previousBoxId = existingMembership.boxId;
      await tx.delete(boxMembers).where(eq(boxMembers.id, existingMembership.id));
    }

    // 3. 생성자를 새 박스의 멤버로 등록
    const [rawMembership] = await tx.insert(boxMembers).values({
      boxId: box.id,
      userId: data.createdBy,
      role: 'member',
    }).returning();

    // ... 로깅 ...

    return { box, membership, previousBoxId };
  });
}
```

**강점**:
- ✅ 박스 생성 + 멤버 등록을 단일 트랜잭션으로 처리
- ✅ 데이터 정합성 보장 (부분 실패 시 전체 롤백)
- ✅ 단일 박스 정책 구현 (기존 멤버십 자동 탈퇴)
- ✅ previousBoxId 반환으로 클라이언트에 상태 전달
- ✅ 멤버십 중복 방지 (uniqueBoxUser 제약 + 애플리케이션 로직)

**비교 (이전 구현)**:
- ❌ 박스 생성과 멤버 등록이 별도 쿼리
- ❌ 박스 생성 성공 후 멤버 등록 실패 시 고아 박스 생성
- ❌ 동시성 문제 (race condition)

### 4. 통합 키워드 검색 구현 ✅

**services.ts - searchBoxes**:
```typescript
export async function searchBoxes(input: SearchBoxInput): Promise<BoxWithMemberCount[]> {
  // keyword 우선 처리 (통합 검색)
  if (input.keyword !== undefined) {
    const trimmedKeyword = input.keyword.trim();

    // 빈 키워드는 빈 배열 반환
    if (!trimmedKeyword) {
      return [];
    }

    // name OR region ILIKE 검색
    const results = await db
      .select({
        id: boxes.id,
        name: boxes.name,
        region: boxes.region,
        description: boxes.description,
        memberCount: sql<number>`COALESCE(COUNT(${boxMembers.id}), 0)`,
      })
      .from(boxes)
      .leftJoin(boxMembers, eq(boxes.id, boxMembers.boxId))
      .where(
        or(
          ilike(boxes.name, `%${trimmedKeyword}%`),
          ilike(boxes.region, `%${trimmedKeyword}%`)
        )
      )
      .groupBy(boxes.id);

    return results as BoxWithMemberCount[];
  }

  // 기존 name/region 개별 검색 (하위 호환성)
  if (!input.name && !input.region) {
    return [];
  }
  // ...
}
```

**강점**:
- ✅ 통합 키워드 검색 (name OR region)
- ✅ 하위 호환성 유지 (name, region 파라미터 지원)
- ✅ ILIKE 사용 (대소문자 무시)
- ✅ memberCount 집계 (LEFT JOIN + GROUP BY)
- ✅ 빈 키워드 처리 (빈 배열 반환)
- ✅ SQL Injection 방지 (Drizzle ORM 파라미터 바인딩)

### 5. JSDoc 주석 품질 ✅

**services.ts - 샘플**:
```typescript
/**
 * 박스 생성 + 생성자 자동 멤버 등록 (트랜잭션)
 *
 * 박스 생성과 멤버 등록을 단일 트랜잭션으로 처리하여 데이터 정합성을 보장합니다.
 * 단일 박스 정책: 사용자가 이미 다른 박스에 가입되어 있으면 자동으로 탈퇴합니다.
 *
 * @param data - 박스 생성 데이터
 * @param data.name - 박스 이름 (2-255자)
 * @param data.region - 박스 지역 (2-255자)
 * @param data.description - 박스 설명 (선택, 최대 1000자)
 * @param data.createdBy - 생성자 사용자 ID
 * @returns 생성된 박스, 멤버십, 이전 박스 ID (없으면 null)
 * @throws 트랜잭션 실패 시 전체 롤백
 */
export async function createBoxWithMembership(data: CreateBoxInput): Promise<CreateBoxResponse> {
  // ...
}
```

- ✅ 한국어 주석 (CLAUDE.md 표준)
- ✅ @param, @returns, @throws 명시
- ✅ 비즈니스 로직 설명 (단일 박스 정책)
- ✅ 트랜잭션 동작 명확히 기술

### 6. 로깅 (Domain Probe 패턴) ✅

**box.probe.ts**:
```typescript
import { logger } from '../../utils/logger';

/**
 * 박스 생성 성공 (INFO)
 * @param data - 박스 정보 (boxId, name, region, createdBy)
 */
export const created = (data: {
  boxId: number;
  name: string;
  region: string;
  createdBy: number;
}) => {
  logger.info({
    boxId: data.boxId,
    region: data.region,
    createdBy: data.createdBy,
  }, `Box created successfully`, { domain: data.name });
};

/**
 * 사용자 박스 가입 (INFO)
 * @param data - 가입 정보 (boxId, userId)
 */
export const memberJoined = (data: { boxId: number; userId: number }) => {
  logger.info({
    boxId: data.boxId,
    userId: data.userId,
  }, 'User joined box');
};

/**
 * 사용자 박스 변경 (INFO)
 * @param data - 변경 정보 (userId, previousBoxId, newBoxId)
 */
export const boxSwitched = (data: {
  userId: number;
  previousBoxId: number;
  newBoxId: number;
}) => {
  logger.info({
    userId: data.userId,
    previousBoxId: data.previousBoxId,
    newBoxId: data.newBoxId,
  }, 'User switched box');
};
```

**강점**:
- ✅ Domain Probe 패턴 준수 (별도 파일 분리)
- ✅ INFO 레벨 (비즈니스 이벤트)
- ✅ 구조화된 로그 (JSON)
- ✅ 민감 정보 제외
- ✅ 도메인별 추적 가능 (boxId, userId)

**handlers.ts - DEBUG 로그**:
```typescript
logger.debug({ userId, name, region }, 'Creating box with transaction');
logger.debug({ keyword, resultCount: boxes.length }, 'Search completed');
```

- ✅ 디버그 로그는 handler에 직접 작성 (Domain Probe 아님)
- ✅ 개발 환경에서만 출력

### 7. 유효성 검증 (Zod) ✅

**validators.ts**:
```typescript
export const createBoxSchema = z.object({
  name: z.string()
    .min(2, '박스 이름은 2자 이상이어야 합니다')
    .max(255, '박스 이름은 255자 이하여야 합니다')
    .trim(),
  region: z.string()
    .min(2, '지역은 2자 이상이어야 합니다')
    .max(255, '지역은 255자 이하여야 합니다')
    .trim(),
  description: z.string()
    .max(1000, '설명은 1000자 이하여야 합니다')
    .trim()
    .optional(),
});

export const searchBoxQuerySchema = z.object({
  keyword: z.string().optional(),
  name: z.string().optional(),
  region: z.string().optional(),
});
```

- ✅ 명확한 에러 메시지 (한국어)
- ✅ .trim() 사용 (공백 제거)
- ✅ min/max 길이 검증
- ✅ optional 필드 명시

---

## API Contract 검증 (Server ↔ Mobile)

### 1. 박스 검색 API

**Server API**:
```
GET /boxes/search?keyword=강남
```

**Server Response**:
```json
{
  "boxes": [
    {
      "id": 1,
      "name": "CrossFit Seoul",
      "region": "서울 강남구",
      "description": "Best gym",
      "memberCount": 15
    }
  ]
}
```

**Mobile API Client**:
```dart
Future<List<BoxModel>> searchBoxes(String keyword) async {
  final response = await _dio.get(
    '/boxes/search',
    queryParameters: {'keyword': keyword},
  );

  final searchResponse = BoxSearchResponse.fromJson(response.data);
  return searchResponse.boxes;
}
```

**Mobile Model**:
```dart
@freezed
class BoxModel with _$BoxModel {
  const factory BoxModel({
    required int id,
    required String name,
    required String region,
    String? description,
    int? memberCount,
    String? joinedAt,
  }) = _BoxModel;
}
```

**검증 결과**: ✅ 일치
- ✅ 엔드포인트 경로: `/boxes/search` (일치)
- ✅ 쿼리 파라미터: `keyword` (일치)
- ✅ 응답 필드: `boxes` (일치)
- ✅ BoxModel 필드: id, name, region, description, memberCount (일치)
- ℹ️ `joinedAt` 필드는 검색 응답에 없음 (nullable이므로 문제 없음)

### 2. 박스 생성 API

**Server API**:
```
POST /boxes
```

**Server Request**:
```json
{
  "name": "CrossFit Gangnam",
  "region": "서울 강남구",
  "description": "Best gym"
}
```

**Server Response**:
```json
{
  "box": {
    "id": 5,
    "name": "CrossFit Gangnam",
    "region": "서울 강남구",
    "description": "Best gym",
    "createdBy": 123,
    "createdAt": "2026-02-09T10:30:00Z",
    "updatedAt": "2026-02-09T10:30:00Z"
  },
  "membership": {
    "id": 10,
    "boxId": 5,
    "userId": 123,
    "role": "member",
    "joinedAt": "2026-02-09T10:30:00Z"
  },
  "previousBoxId": null
}
```

**Mobile API Client**:
```dart
Future<BoxCreateResponse> createBox(CreateBoxRequest request) async {
  final response = await _dio.post(
    '/boxes',
    data: request.toJson(),
  );
  return BoxCreateResponse.fromJson(response.data);
}
```

**Mobile Models**:
```dart
@freezed
class CreateBoxRequest with _$CreateBoxRequest {
  const factory CreateBoxRequest({
    required String name,
    required String region,
    String? description,
  }) = _CreateBoxRequest;
}

@freezed
class BoxCreateResponse with _$BoxCreateResponse {
  const factory BoxCreateResponse({
    required BoxModel box,
    required MembershipModel membership,
    int? previousBoxId,
  }) = _BoxCreateResponse;
}
```

**검증 결과**: ✅ 일치
- ✅ 엔드포인트 경로: `/boxes` (일치)
- ✅ HTTP Method: POST (일치)
- ✅ Request 필드: name, region, description (일치)
- ✅ Response 필드: box, membership, previousBoxId (일치)
- ⚠️ **주의**: Server는 `box` 객체에 `createdBy`, `createdAt`, `updatedAt` 포함하지만, Mobile `BoxModel`에는 이 필드들이 없음
  - **영향**: Mobile에서 받을 때 무시됨 (Freezed는 알 수 없는 필드 무시)
  - **권장**: Mobile `BoxModel`에 선택 필드로 추가 (향후 사용 가능)

### 3. 박스 가입 API

**Server API**:
```
POST /boxes/:boxId/join
```

**Server Response**:
```json
{
  "membership": {
    "id": 6,
    "boxId": 2,
    "userId": 42,
    "role": "member",
    "joinedAt": "2026-02-09T10:30:00Z"
  },
  "previousBoxId": 1
}
```

**Mobile API Client**:
```dart
Future<MembershipModel> joinBox(int boxId) async {
  final response = await _dio.post('/boxes/$boxId/join');
  return MembershipModel.fromJson(response.data['membership']);
}
```

**검증 결과**: ⚠️ 부분 일치
- ✅ 엔드포인트 경로: `/boxes/:boxId/join` (일치)
- ✅ HTTP Method: POST (일치)
- ⚠️ **불일치**: Server는 `{ membership, previousBoxId }` 반환하지만, Mobile은 `membership`만 파싱
  - **영향**: `previousBoxId` 정보를 Mobile에서 사용하지 못함 (단일 박스 정책 UX 개선 기회 상실)
  - **권장**: Mobile에서 `previousBoxId` 파싱하여 "이전 박스에서 탈퇴되었습니다" 메시지 표시

---

## 테스트 커버리지 분석

### Unit Tests

**handlers.test.ts** (13 tests):
- ✅ create: 2개 (트랜잭션 처리, createdBy 설정)
- ✅ getMyBox: 2개 (멤버십 있음/없음)
- ✅ search: 4개 (keyword, name, region, 빈 파라미터)
- ✅ join: 2개 (가입, 박스 변경)
- ✅ getById: 2개 (상세 조회, memberCount 포함)
- ✅ getMembers: 1개 (멤버 목록)

**services.test.ts** (31 tests):
- ✅ createBox: 1개
- ✅ joinBox: 5개 (가입, 존재하지 않는 박스, 중복 가입, 자동 탈퇴, role 기본값)
- ✅ getBoxById: 3개 (상세 조회, 존재하지 않는 ID, memberCount)
- ✅ searchBoxes (name/region): 6개 (name, region, AND, 빈 파라미터, memberCount, 결과 없음)
- ✅ searchBoxes (keyword): 6개 (빈 키워드, name, region, 대소문자, memberCount, 공백 trim)
- ✅ getCurrentBox: 4개 (조회, 없음, memberCount, joinedAt)
- ✅ getBoxMembers: 3개 (목록, joinedAt, 빈 목록)
- ✅ createBoxWithMembership: 3개 (트랜잭션, 기존 멤버십 제거, previousBoxId)

**커버리지 평가**: ✅ 우수
- 핵심 비즈니스 로직 모두 커버
- Edge case 테스트 포함 (빈 값, 존재하지 않는 ID, 중복 가입)
- 트랜잭션 동작 검증
- 단일 박스 정책 검증 (자동 탈퇴, previousBoxId)

---

## 발견된 이슈 및 권장 사항

### 이슈 없음 ✅

모든 코드가 CLAUDE.md 표준을 준수하고 있으며, 테스트가 모두 통과했습니다.

### 권장 사항 (선택 사항)

#### 1. Mobile API Contract 개선 (낮음)

**현재**:
```dart
Future<MembershipModel> joinBox(int boxId) async {
  final response = await _dio.post('/boxes/$boxId/join');
  return MembershipModel.fromJson(response.data['membership']);
}
```

**권장**:
```dart
Future<JoinBoxResponse> joinBox(int boxId) async {
  final response = await _dio.post('/boxes/$boxId/join');
  return JoinBoxResponse.fromJson(response.data);
}

@freezed
class JoinBoxResponse with _$JoinBoxResponse {
  const factory JoinBoxResponse({
    required MembershipModel membership,
    int? previousBoxId,
  }) = _JoinBoxResponse;
}
```

**이유**: `previousBoxId` 정보를 활용하여 "이전 박스에서 탈퇴되었습니다" UX 개선

#### 2. BoxModel 확장 (낮음)

**현재**:
```dart
@freezed
class BoxModel with _$BoxModel {
  const factory BoxModel({
    required int id,
    required String name,
    required String region,
    String? description,
    int? memberCount,
    String? joinedAt,
  }) = _BoxModel;
}
```

**권장**:
```dart
@freezed
class BoxModel with _$BoxModel {
  const factory BoxModel({
    required int id,
    required String name,
    required String region,
    String? description,
    int? memberCount,
    String? joinedAt,
    int? createdBy,         // 추가
    String? createdAt,      // 추가
    String? updatedAt,      // 추가
  }) = _BoxModel;
}
```

**이유**: Server가 반환하는 모든 필드를 수용하여 향후 확장성 확보 (Freezed는 알 수 없는 필드 무시하므로 하위 호환성 유지)

#### 3. 검색 성능 최적화 (낮음, 향후)

**현재**: ILIKE 쿼리 (부분 일치)

**향후**: PostgreSQL Full-Text Search (박스 수가 10,000개 이상일 때)
```sql
ALTER TABLE boxes
ADD COLUMN search_vector tsvector
GENERATED ALWAYS AS (
  to_tsvector('korean', name || ' ' || region)
) STORED;

CREATE INDEX idx_boxes_search_vector ON boxes USING GIN(search_vector);
```

**이유**: 현재는 박스 수가 적어 문제 없지만, 향후 대규모 데이터에서 성능 개선 가능

---

## Quality Scores

| 항목 | 점수 | 평가 |
|------|------|------|
| **코드 품질** | 9.5/10 | Express 패턴 완벽 준수, 트랜잭션 구현 우수 |
| **테스트 커버리지** | 9.0/10 | 핵심 로직 모두 커버, Edge case 테스트 포함 |
| **API 설계** | 9.0/10 | RESTful 준수, 하위 호환성 유지, Mobile과 일치 |
| **에러 처리** | 9.5/10 | NotFoundException, BusinessException 적절히 사용 |
| **로깅** | 9.5/10 | Domain Probe 패턴 준수, 구조화된 로그 |
| **문서화** | 9.0/10 | JSDoc 주석 충실, 한국어 사용 |
| **성능** | 9.0/10 | Index 설정, memberCount 집계 최적화 |
| **보안** | 9.5/10 | SQL Injection 방지, 인증 미들웨어 적용 |

**종합 점수**: **9.3/10** (우수)

---

## 최종 승인

### 승인 상태: ✅ **APPROVED**

**승인 근거**:
1. 모든 테스트 통과 (277 tests, 100%)
2. Express 미들웨어 패턴 완벽 준수
3. 트랜잭션 구현으로 데이터 정합성 보장
4. 통합 키워드 검색 구현 완료
5. Mobile API Contract 일치 (일부 권장 사항 있음)
6. Domain Probe 로깅 패턴 준수
7. JSDoc 문서화 충실

**다음 단계**:
1. Mobile CTO Review 진행
2. Independent Reviewer 검증
3. 문서 생성 (DONE.md)
4. PR 생성 및 배포

---

**Reviewer**: CTO
**Date**: 2026-02-09
**Signature**: ✅ Approved
