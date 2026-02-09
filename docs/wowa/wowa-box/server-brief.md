# 서버 기술 설계: 박스 관리 기능 개선

## 개요

사용자가 박스를 쉽게 검색하고 안정적으로 생성할 수 있도록 개선합니다. 검색 API를 통합 키워드 방식으로 변경하고, 박스 생성 시 발생하는 오류를 분석하여 수정합니다.

## 변경 사항 요약

### 1. API 명세 변경: 통합 키워드 검색

**현재 (분리 검색)**:
```
GET /boxes/search?name=강남&region=서울
```

**변경 (통합 검색)**:
```
GET /boxes/search?keyword=강남 크로스핏
```

**변경 이유**:
- 사용자 경험 개선: 하나의 검색창에 자유롭게 입력
- "강남 크로스핏", "CrossFit Seoul" 같은 자연어 검색 지원
- 박스 이름과 지역을 동시에 검색하여 관련성 높은 결과 제공

### 2. 박스 생성 오류 분석

**현재 구현 분석**:

```typescript
// apps/server/src/modules/box/handlers.ts
export const create: RequestHandler = async (req, res) => {
  const { userId } = (req as AuthenticatedRequest).user;
  const { name, region, description } = createBoxSchema.parse(req.body);

  const box = await createBox({
    name,
    region,
    description,
    createdBy: userId,
  });

  // 생성자를 자동으로 멤버로 등록 (단일 박스 정책: 기존 박스 자동 탈퇴)
  const membership = await joinBoxService({ boxId: box.id, userId });

  res.status(201).json({ box, membership });
};
```

```typescript
// apps/server/src/modules/box/services.ts
export async function joinBox(data: JoinBoxInput) {
  // 1. 박스 존재 확인
  const [box] = await db.select().from(boxes).where(eq(boxes.id, data.boxId)).limit(1);
  if (!box) {
    throw new NotFoundException('Box', data.boxId);
  }

  // 2. 같은 박스에 이미 가입되어 있으면 기존 멤버십 반환 (멱등성)
  const [existingSameBox] = await db.select().from(boxMembers)
    .where(and(eq(boxMembers.boxId, data.boxId), eq(boxMembers.userId, data.userId)))
    .limit(1);
  if (existingSameBox) {
    return {
      membership: existingSameBox,
      previousBoxId: null,
    };
  }

  // 3. 다른 박스에 가입되어 있으면 자동 탈퇴 (단일 박스 정책)
  const [existingOtherBox] = await db.select().from(boxMembers)
    .where(eq(boxMembers.userId, data.userId))
    .limit(1);

  let previousBoxId: number | null = null;
  if (existingOtherBox) {
    previousBoxId = existingOtherBox.boxId;
    await db.delete(boxMembers).where(eq(boxMembers.id, existingOtherBox.id));
  }

  // 4. 새 멤버 등록
  const [member] = await db.insert(boxMembers).values({
    boxId: data.boxId,
    userId: data.userId,
  }).returning();

  // ... 로그 생략 ...
}
```

**분석 결과**:

✅ **단일 박스 정책 구현 확인**:
- `joinBox` 함수에서 기존 박스 자동 탈퇴 로직이 올바르게 구현되어 있음
- 같은 박스 중복 가입 시 멱등성 보장 (기존 멤버십 반환)
- 박스 생성 시 `joinBoxService` 호출하여 생성자를 자동으로 멤버로 등록

**잠재적 오류 원인**:

1. **트랜잭션 부재**:
   - 박스 생성(`createBox`)과 멤버 등록(`joinBox`)이 별도 쿼리로 실행
   - 박스 생성 성공 후 멤버 등록 실패 시 고아 박스 생성 가능
   - 데이터 정합성 보장 필요

2. **동시성 문제**:
   - 같은 사용자가 동시에 여러 박스 생성 시 단일 박스 정책 위반 가능
   - `joinBox`의 "기존 박스 확인 → 삭제 → 새 멤버 추가" 사이에 race condition 발생 가능

3. **에러 처리 누락**:
   - `joinBox`에서 발생한 예외가 박스 생성 후 발생 시, 박스는 생성되었으나 멤버 등록 실패
   - 클라이언트는 박스 생성 실패로 인식하지만 DB에는 박스만 남음

**해결 방안**:

1. **트랜잭션 추가**: 박스 생성 + 멤버 등록을 단일 트랜잭션으로 처리
2. **동시성 제어**: 사용자별 박스 가입/생성 시 락(Lock) 적용 또는 유니크 제약 활용
3. **에러 처리 개선**: 멤버 등록 실패 시 박스 롤백 또는 명확한 에러 메시지

### 3. DB 스키마 변경

**현재 스키마**:

```typescript
// boxes 테이블
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

// box_members 테이블
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

**변경 필요 여부**: ❌ 스키마 변경 불필요

**이유**:
- 통합 검색은 애플리케이션 레벨에서 처리 가능 (name + region ILIKE 검색)
- 단일 박스 정책은 `box_members` 테이블의 `unique(boxId, userId)` 제약으로 중복 방지
- 추가 필드 불필요

**최적화 가능 사항**:
- 검색 성능 개선 필요 시 Full-Text Search 인덱스 추가 고려 (향후)
- PostgreSQL `tsvector`, `tsquery` 활용 가능하지만 현재는 ILIKE로 충분

## 비즈니스 로직 설계

### 1. 통합 키워드 검색 로직

**API 엔드포인트**:
```
GET /boxes/search?keyword={keyword}
```

**구현 전략**:

```typescript
// services.ts
export async function searchBoxes(keyword: string): Promise<BoxWithMemberCount[]> {
  // 빈 키워드는 빈 배열 반환
  if (!keyword || keyword.trim() === '') {
    return [];
  }

  const searchTerm = keyword.trim();

  // 박스 이름 또는 지역에서 키워드 검색 (ILIKE, OR 조건)
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
        ilike(boxes.name, `%${searchTerm}%`),
        ilike(boxes.region, `%${searchTerm}%`)
      )
    )
    .groupBy(boxes.id);

  return results as BoxWithMemberCount[];
}
```

**검색 동작**:
- 키워드가 박스 이름 또는 지역에 포함되면 매칭
- 대소문자 무시 (ILIKE)
- "강남 크로스핏" 입력 시:
  - `name ILIKE '%강남 크로스핏%'` → "강남 크로스핏", "크로스핏 강남점" 매칭
  - `region ILIKE '%강남 크로스핏%'` → "서울 강남구" 매칭 안 됨
- 부분 일치로 유연한 검색 제공

**제한 사항**:
- 공백으로 구분된 복수 키워드 검색 미지원 (예: "강남 서울" → "강남 서울" 전체 문자열 검색)
- 향후 필요 시 키워드 분리 + 다중 조건 검색으로 개선 가능

### 2. 박스 생성 트랜잭션 처리

**문제**: 박스 생성과 멤버 등록이 별도 쿼리로 실행되어 데이터 정합성 보장 안 됨

**해결책**: Drizzle ORM 트랜잭션 사용

```typescript
// services.ts
import { db } from '../../config/database';

/**
 * 박스 생성 + 생성자 자동 멤버 등록 (트랜잭션)
 * @param data - 박스 생성 데이터
 * @returns 생성된 박스 및 멤버십
 */
export async function createBoxWithMembership(data: CreateBoxInput) {
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
    const [membership] = await tx.insert(boxMembers).values({
      boxId: box.id,
      userId: data.createdBy,
    }).returning();

    // 4. 로깅
    if (previousBoxId) {
      boxProbe.boxSwitched({
        userId: data.createdBy,
        previousBoxId,
        newBoxId: box.id,
      });
    } else {
      boxProbe.created({
        boxId: box.id,
        name: box.name,
        region: box.region,
        createdBy: box.createdBy,
      });
      boxProbe.memberJoined({
        boxId: box.id,
        userId: data.createdBy,
      });
    }

    return { box, membership, previousBoxId };
  });
}
```

**핸들러 수정**:

```typescript
// handlers.ts
export const create: RequestHandler = async (req, res) => {
  const { userId } = (req as AuthenticatedRequest).user;
  const { name, region, description } = createBoxSchema.parse(req.body);

  // 트랜잭션으로 박스 생성 + 멤버 등록
  const result = await createBoxWithMembership({
    name,
    region,
    description,
    createdBy: userId,
  });

  res.status(201).json(result);
};
```

**장점**:
- ✅ 박스 생성 실패 시 멤버 등록도 롤백
- ✅ 멤버 등록 실패 시 박스 생성도 롤백
- ✅ 데이터 정합성 보장
- ✅ 단일 박스 정책 적용 (기존 박스 자동 탈퇴)

### 3. 동시성 제어

**문제**: 같은 사용자가 동시에 여러 박스 생성 시 단일 박스 정책 위반 가능

**현재 제약 조건**:
```typescript
// box_members 테이블
uniqueBoxUser: unique().on(table.boxId, table.userId)
```
- `boxId + userId` 조합의 유니크 제약
- 같은 박스에 중복 가입 방지
- 다른 박스에는 가입 가능 (단일 박스 정책 미보장)

**해결책 1: 유니크 제약 추가 (권장)**

```typescript
// schema.ts
export const boxMembers = pgTable('box_members', {
  id: serial('id').primaryKey(),
  boxId: integer('box_id').notNull(),
  userId: integer('user_id').notNull(),
  role: varchar('role', { length: 20 }).notNull().default('member'),
  joinedAt: timestamp('joined_at').defaultNow().notNull(),
}, (table) => ({
  uniqueBoxUser: unique().on(table.boxId, table.userId),
  uniqueUser: unique().on(table.userId), // 사용자는 하나의 박스에만 가입 가능
  boxIdIdx: index('idx_box_members_box_id').on(table.boxId),
  userIdIdx: index('idx_box_members_user_id').on(table.userId),
}));
```

**장점**:
- ✅ DB 레벨에서 단일 박스 정책 강제
- ✅ 동시성 문제 완전 해결
- ✅ 애플리케이션 로직 단순화

**단점**:
- ⚠️ 기존 박스 탈퇴 후 새 박스 가입 시 `uniqueUser` 제약 위반 (트랜잭션 필요)
- ⚠️ 마이그레이션 시 기존 데이터 정합성 확인 필요 (중복 멤버십 존재 시 마이그레이션 실패)

**해결책 2: 애플리케이션 락 (대안)**

```typescript
// services.ts
import { db } from '../../config/database';
import { sql } from 'drizzle-orm';

export async function createBoxWithMembership(data: CreateBoxInput) {
  return await db.transaction(async (tx) => {
    // 1. 사용자에 대한 Advisory Lock 획득 (PostgreSQL)
    await tx.execute(sql`SELECT pg_advisory_xact_lock(${data.createdBy})`);

    // 2. 박스 생성 + 멤버 등록 (락이 보장된 상태)
    // ... 기존 로직 ...
  });
}
```

**장점**:
- ✅ DB 스키마 변경 불필요
- ✅ 유연성 (향후 다중 박스 지원 시 변경 용이)

**단점**:
- ⚠️ PostgreSQL 전용 (DB 종속성)
- ⚠️ 복잡도 증가

**최종 권장**: **해결책 1 (유니크 제약 추가)** — DB 레벨 강제가 가장 안전하고 명확

### 4. 에러 처리 개선

**현재 문제**:
- `joinBox`에서 `NotFoundException` 발생 시 박스는 생성되었으나 멤버 등록 실패
- 클라이언트는 박스 생성 실패로 인식

**해결책**: 트랜잭션 사용으로 자동 해결
- 트랜잭션 내 예외 발생 시 전체 롤백
- 박스 생성과 멤버 등록이 모두 성공하거나 모두 실패

**추가 검증**:

```typescript
// validators.ts
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
  keyword: z.string()
    .max(255, '검색어는 255자 이하여야 합니다')
    .optional(),
});
```

**에러 메시지 개선**:

```typescript
// box.probe.ts
export const creationFailed = (data: {
  userId: number;
  name: string;
  error: string;
}) => {
  logger.error({
    userId: data.userId,
    name: data.name,
    error: data.error,
  }, 'Box creation failed');
};
```

## API 명세 (최종)

### 1. 박스 검색 (통합 키워드)

**변경 전**:
```
GET /boxes/search?name=강남&region=서울
```

**변경 후**:
```
GET /boxes/search?keyword=강남 크로스핏
```

**요청**:
```typescript
interface SearchBoxRequest {
  keyword?: string; // 선택적, 빈 값이면 빈 배열 반환
}
```

**응답** (200 OK):
```typescript
interface SearchBoxResponse {
  boxes: BoxWithMemberCount[];
}

interface BoxWithMemberCount {
  id: number;
  name: string;
  region: string;
  description: string | null;
  memberCount: number;
}
```

**예시**:
```bash
# 요청
GET /boxes/search?keyword=강남

# 응답
{
  "boxes": [
    {
      "id": 1,
      "name": "CrossFit Seoul",
      "region": "서울 강남구",
      "description": "강남 최고의 크로스핏 박스",
      "memberCount": 42
    },
    {
      "id": 2,
      "name": "강남 크로스핏",
      "region": "서울 서초구",
      "description": null,
      "memberCount": 15
    }
  ]
}
```

### 2. 박스 생성 (트랜잭션 적용)

**엔드포인트**: `POST /boxes` (변경 없음)

**요청**:
```typescript
interface CreateBoxRequest {
  name: string;        // 필수, 2-255자
  region: string;      // 필수, 2-255자
  description?: string; // 선택, 최대 1000자
}
```

**응답** (201 Created):
```typescript
interface CreateBoxResponse {
  box: Box;
  membership: BoxMember;
  previousBoxId: number | null; // 기존 박스에서 탈퇴한 경우 이전 박스 ID
}

interface Box {
  id: number;
  name: string;
  region: string;
  description: string | null;
  createdBy: number;
  createdAt: string; // ISO-8601
  updatedAt: string; // ISO-8601
}

interface BoxMember {
  id: number;
  boxId: number;
  userId: number;
  role: string;
  joinedAt: string; // ISO-8601
}
```

**예시**:
```bash
# 요청
POST /boxes
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "name": "CrossFit Gangnam",
  "region": "서울 강남구",
  "description": "최고의 크로스핏 박스"
}

# 응답 (기존 박스 없는 경우)
{
  "box": {
    "id": 5,
    "name": "CrossFit Gangnam",
    "region": "서울 강남구",
    "description": "최고의 크로스핏 박스",
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

# 응답 (기존 박스에서 자동 탈퇴한 경우)
{
  "box": { /* ... */ },
  "membership": { /* ... */ },
  "previousBoxId": 3  // 이전 박스 ID
}
```

**에러 응답**:
- `400 Bad Request`: 입력 유효성 검증 실패
  ```json
  {
    "error": {
      "code": "VALIDATION_ERROR",
      "message": "박스 이름은 2자 이상이어야 합니다"
    }
  }
  ```
- `401 Unauthorized`: 인증 실패 (토큰 없음/만료)
- `500 Internal Server Error`: 서버 오류 (트랜잭션 롤백)

### 3. 기타 엔드포인트 (변경 없음)

**내 현재 박스 조회**:
```
GET /boxes/me
Authorization: Bearer {token}
```

**박스 가입**:
```
POST /boxes/:boxId/join
Authorization: Bearer {token}
```

**박스 상세 조회**:
```
GET /boxes/:boxId
Authorization: Bearer {token}
```

**박스 멤버 목록**:
```
GET /boxes/:boxId/members
Authorization: Bearer {token}
```

## 마이그레이션 계획

### 1. DB 스키마 변경 (선택 사항)

**옵션 A: 유니크 제약 추가 (권장)**

```sql
-- box_members 테이블에 userId 유니크 제약 추가
ALTER TABLE box_members
ADD CONSTRAINT unique_user_single_box UNIQUE (user_id);
```

**사전 작업**:
1. 현재 중복 멤버십 확인:
   ```sql
   SELECT user_id, COUNT(*) as membership_count
   FROM box_members
   GROUP BY user_id
   HAVING COUNT(*) > 1;
   ```
2. 중복 멤버십이 있으면 수동으로 정리 (가장 최근 가입만 남기기):
   ```sql
   -- 각 사용자의 가장 최근 멤버십을 제외한 나머지 삭제
   DELETE FROM box_members
   WHERE id NOT IN (
     SELECT DISTINCT ON (user_id) id
     FROM box_members
     ORDER BY user_id, joined_at DESC
   );
   ```
3. 유니크 제약 추가

**옵션 B: 스키마 변경 없음**

- 애플리케이션 레벨에서 트랜잭션으로 처리
- 마이그레이션 불필요
- 동시성 문제는 Advisory Lock으로 해결

**최종 권장**: **옵션 A** (DB 레벨 강제가 더 안전)

### 2. 코드 배포

**단계**:
1. 서버 코드 변경 (트랜잭션 추가)
2. 마이그레이션 실행 (유니크 제약 추가, 선택 사항)
3. 배포
4. 모바일 앱 업데이트 (검색 API 변경)

**하위 호환성**:
- ⚠️ 검색 API는 Breaking Change (쿼리 파라미터 변경)
- 모바일 앱 강제 업데이트 필요 또는 버전 분기 처리

**대안 (하위 호환성 유지)**:
```typescript
// handlers.ts
export const search: RequestHandler = async (req, res) => {
  const { keyword, name, region } = req.query;

  // 신규 API (keyword 우선)
  if (keyword) {
    const boxes = await searchBoxes(keyword as string);
    return res.json({ boxes });
  }

  // 구 API (name, region 지원)
  const boxes = await searchBoxesLegacy({
    name: name as string | undefined,
    region: region as string | undefined,
  });

  res.json({ boxes });
};
```

## 테스트 계획

### 1. 단위 테스트

**`tests/unit/box/services.test.ts`**:

```typescript
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { createBoxWithMembership, searchBoxes } from '../../../src/modules/box/services';
import { db } from '../../../src/config/database';
import { boxes, boxMembers } from '../../../src/modules/box/schema';

describe('Box Services', () => {
  beforeEach(async () => {
    // 테스트 데이터 초기화
    await db.delete(boxMembers);
    await db.delete(boxes);
  });

  describe('createBoxWithMembership', () => {
    it('should create box and add creator as member in transaction', async () => {
      const result = await createBoxWithMembership({
        name: 'Test Box',
        region: 'Test Region',
        createdBy: 1,
      });

      expect(result.box.name).toBe('Test Box');
      expect(result.membership.userId).toBe(1);
      expect(result.previousBoxId).toBeNull();
    });

    it('should remove previous membership when creating new box', async () => {
      // 첫 번째 박스 생성
      await createBoxWithMembership({
        name: 'First Box',
        region: 'Region 1',
        createdBy: 1,
      });

      // 두 번째 박스 생성 (자동 탈퇴)
      const result = await createBoxWithMembership({
        name: 'Second Box',
        region: 'Region 2',
        createdBy: 1,
      });

      expect(result.previousBoxId).toBe(1);

      // 이전 멤버십 삭제 확인
      const memberships = await db.select().from(boxMembers).where(eq(boxMembers.userId, 1));
      expect(memberships).toHaveLength(1);
      expect(memberships[0].boxId).toBe(result.box.id);
    });
  });

  describe('searchBoxes', () => {
    beforeEach(async () => {
      await db.insert(boxes).values([
        { id: 1, name: 'CrossFit Seoul', region: '서울 강남구', createdBy: 1 },
        { id: 2, name: '강남 크로스핏', region: '서울 서초구', createdBy: 2 },
        { id: 3, name: 'Busan Box', region: '부산 해운대구', createdBy: 3 },
      ]);
    });

    it('should return empty array for empty keyword', async () => {
      const results = await searchBoxes('');
      expect(results).toEqual([]);
    });

    it('should search boxes by name', async () => {
      const results = await searchBoxes('CrossFit');
      expect(results).toHaveLength(1);
      expect(results[0].name).toBe('CrossFit Seoul');
    });

    it('should search boxes by region', async () => {
      const results = await searchBoxes('강남');
      expect(results).toHaveLength(2);
    });

    it('should be case insensitive', async () => {
      const results = await searchBoxes('crossfit');
      expect(results).toHaveLength(1);
    });
  });
});
```

### 2. 통합 테스트 (선택 사항)

**동시성 테스트**:
```typescript
it('should handle concurrent box creation correctly', async () => {
  const userId = 1;

  // 동시에 여러 박스 생성
  const promises = [
    createBoxWithMembership({ name: 'Box 1', region: 'Region 1', createdBy: userId }),
    createBoxWithMembership({ name: 'Box 2', region: 'Region 2', createdBy: userId }),
    createBoxWithMembership({ name: 'Box 3', region: 'Region 3', createdBy: userId }),
  ];

  const results = await Promise.all(promises);

  // 마지막 박스만 멤버십 유지
  const finalMemberships = await db.select().from(boxMembers).where(eq(boxMembers.userId, userId));
  expect(finalMemberships).toHaveLength(1);
});
```

## 로깅 전략

### 1. 새 Probe 함수 추가

```typescript
// box.probe.ts

/**
 * 박스 검색 실행 (DEBUG)
 * @param data - 검색 조건 (keyword)
 */
export const searchExecuted = (data: { keyword: string; resultCount: number }) => {
  logger.debug({
    keyword: data.keyword,
    resultCount: data.resultCount,
  }, 'Box search executed');
};

/**
 * 박스 생성 실패 (ERROR)
 * @param data - 실패 정보 (userId, name, error)
 */
export const creationFailed = (data: {
  userId: number;
  name: string;
  error: string;
}) => {
  logger.error({
    userId: data.userId,
    name: data.name,
    error: data.error,
  }, 'Box creation failed');
};

/**
 * 트랜잭션 롤백 (WARN)
 * @param data - 롤백 정보 (userId, reason)
 */
export const transactionRolledBack = (data: {
  userId: number;
  reason: string;
}) => {
  logger.warn({
    userId: data.userId,
    reason: data.reason,
  }, 'Box creation transaction rolled back');
};
```

### 2. 핸들러에서 로깅 사용

```typescript
// handlers.ts
export const search: RequestHandler = async (req, res) => {
  const { keyword } = searchBoxQuerySchema.parse(req.query);

  const boxes = await searchBoxes(keyword ?? '');

  // 디버그 로그 (개발 환경)
  logger.debug({ keyword, resultCount: boxes.length }, 'Box search executed');

  res.json({ boxes });
};

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
    // 트랜잭션 실패 로그
    boxProbe.creationFailed({
      userId,
      name,
      error: error instanceof Error ? error.message : 'Unknown error',
    });
    throw error; // 전역 에러 핸들러로 전달
  }
};
```

## 성능 고려사항

### 1. 검색 성능

**현재 접근법**: ILIKE 쿼리 (부분 일치)
- 인덱스 활용: `idx_boxes_name`, `idx_boxes_region`
- PostgreSQL ILIKE는 패턴이 `%keyword%` 형태일 때 인덱스 활용 제한적
- 현재 박스 수가 적으면(~10,000개 미만) 문제 없음

**최적화 (필요 시)**:
1. Full-Text Search 인덱스 추가:
   ```sql
   ALTER TABLE boxes
   ADD COLUMN search_vector tsvector
   GENERATED ALWAYS AS (
     to_tsvector('korean', name || ' ' || region)
   ) STORED;

   CREATE INDEX idx_boxes_search_vector ON boxes USING GIN(search_vector);
   ```

2. 검색 쿼리 변경:
   ```typescript
   .where(sql`search_vector @@ to_tsquery('korean', ${searchTerm})`)
   ```

### 2. 트랜잭션 성능

**잠재적 병목**:
- 트랜잭션 중 여러 쿼리 실행 (박스 생성, 기존 멤버십 조회, 삭제, 새 멤버 추가)
- 트랜잭션 격리 수준에 따라 락(Lock) 대기 발생 가능

**최적화**:
- READ COMMITTED (기본값) 유지 — 대부분의 경우 충분
- 필요 시 Advisory Lock으로 사용자별 직렬화

### 3. memberCount 집계

**현재 접근법**: 검색마다 LEFT JOIN + COUNT 집계
- 박스 수가 적으면 문제 없음
- 박스 수가 많아지면(~100,000개 이상) 쿼리 비용 증가

**최적화 (필요 시)**:
1. 박스 테이블에 `memberCount` 컬럼 추가 (캐싱)
2. 멤버 추가/삭제 시 `memberCount` 업데이트 (트리거 또는 애플리케이션)
3. 검색 쿼리에서 JOIN 제거

## 모니터링 및 알람

### 1. 핵심 메트릭

**박스 생성**:
- 생성 성공률 (INFO 로그 카운트)
- 생성 실패율 (ERROR 로그 카운트)
- 평균 생성 시간 (트랜잭션 완료 시간)

**박스 검색**:
- 검색 쿼리 수 (DEBUG 로그 카운트)
- 평균 응답 시간
- 빈 결과 비율 (resultCount = 0)

### 2. 알람 설정

**ERROR 로그**:
- 임계값: 분당 5개 이상
- `boxProbe.creationFailed` 발생 시 알람
- 원인: DB 연결 실패, 트랜잭션 타임아웃, 유니크 제약 위반 등

**WARN 로그**:
- 임계값: 분당 20개 이상
- `boxProbe.transactionRolledBack` 발생 시 알람
- 원인: 동시성 충돌, 유효성 검증 실패

## 작업 분배

### Senior Developer 작업

1. **서비스 레이어 수정**:
   - `searchBoxes` 함수를 통합 키워드 검색으로 변경
   - `createBoxWithMembership` 트랜잭션 함수 작성
   - 기존 `createBox` 함수 유지 (재사용 가능)

2. **Validators 수정**:
   - `searchBoxQuerySchema`를 `keyword` 파라미터로 변경
   - `createBoxSchema` 검증 강화 (min 길이, trim)

3. **Types 수정**:
   - `SearchBoxInput` → `keyword: string`으로 변경
   - `CreateBoxResponse` 타입 추가 (`previousBoxId` 포함)

4. **Probe 함수 추가**:
   - `searchExecuted`, `creationFailed`, `transactionRolledBack`

5. **마이그레이션** (선택 사항):
   - 유니크 제약 추가 스크립트 작성
   - 중복 멤버십 정리 스크립트 작성

6. **단위 테스트 작성**:
   - 트랜잭션 테스트
   - 검색 테스트
   - 동시성 테스트

### Junior Developer 작업

1. **핸들러 수정**:
   - `search` 핸들러에서 `keyword` 파라미터 사용
   - `create` 핸들러에서 `createBoxWithMembership` 호출
   - 에러 핸들링 추가

2. **라우터 수정** (필요 시):
   - 변경 없음 (엔드포인트 경로 동일)

3. **통합 테스트** (선택 사항):
   - E2E 시나리오 테스트
   - 실제 DB 대상 테스트

## 검증 기준

- [ ] 통합 키워드 검색이 박스 이름과 지역에서 모두 동작
- [ ] 박스 생성과 멤버 등록이 단일 트랜잭션으로 처리
- [ ] 트랜잭션 실패 시 전체 롤백 확인
- [ ] 단일 박스 정책이 동시성 환경에서도 보장
- [ ] 기존 박스 탈퇴 시 `previousBoxId` 반환
- [ ] 입력 유효성 검증 강화 (min 길이, trim)
- [ ] 단위 테스트 커버리지 80% 이상
- [ ] 로깅이 적절히 추가 (DEBUG, INFO, ERROR)
- [ ] CLAUDE.md 표준 준수 (에러 클래스, 응답 형식, 로깅 패턴)

## 참고 자료

- 서버 CLAUDE.md: `/apps/server/CLAUDE.md`
- API Response 설계 가이드: `/.claude/guide/server/api-response-design.md`
- 예외 처리 가이드: `/.claude/guide/server/exception-handling.md`
- 로깅 베스트 프랙티스: `/.claude/guide/server/logging-best-practices.md`
- 서버 카탈로그: `/docs/wowa/server-catalog.md`
- Drizzle Transactions: https://orm.drizzle.team/docs/transactions
