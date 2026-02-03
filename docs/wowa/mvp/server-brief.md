# WOWA MVP Server Technical Design Brief

> Feature: wowa
> Created: 2026-02-03
> Status: Draft
> Phase: Technical Design

---

## 1. Overview

This document provides comprehensive technical architecture for WOWA MVP server implementation, covering Phases 1-3 from plan.md (Box management, WOD management, and selection/recording features).

**Key Design Principles**:
- Consensus-based model (no role-based permissions)
- First-come Base WOD designation
- Structural comparison for Personal WOD classification
- Immutable record snapshots

**Tech Stack**:
- Framework: Express 5.x (middleware-based)
- ORM: Drizzle ORM
- Database: PostgreSQL (Supabase)
- Testing: Vitest (unit tests)
- Logging: Pino (Domain Probe pattern)

---

## 2. Module Structure

```
src/modules/
├── box/
│   ├── index.ts              # Router export
│   ├── handlers.ts           # Request handlers
│   ├── schema.ts             # Drizzle schema (boxes, box_members)
│   ├── validators.ts         # Zod validation schemas
│   ├── services.ts           # Box business logic
│   └── box.probe.ts          # Operational logging (INFO/WARN/ERROR)
│
└── wod/
    ├── index.ts              # Router export
    ├── handlers.ts           # Request handlers
    ├── schema.ts             # Drizzle schema (wods, proposed_changes, wod_selections)
    ├── validators.ts         # Zod validation schemas
    ├── services.ts           # WOD business logic
    ├── comparison.ts         # Structural comparison logic
    ├── normalization.ts      # Exercise name normalization
    └── wod.probe.ts          # Operational logging
```

---

## 3. Database Schema Design

### 3.1 Box Management (Phase 1)

#### Table: `boxes`

박스(CrossFit gym) 정보를 저장하는 테이블.

```typescript
// src/modules/box/schema.ts
import { pgTable, serial, varchar, text, timestamp, integer, index } from 'drizzle-orm/pg-core';

/**
 * 박스(CrossFit gym) 테이블
 */
export const boxes = pgTable('boxes', {
  /** 박스 고유 ID */
  id: serial('id').primaryKey(),
  /** 박스 이름 (예: 'CrossFit Seoul') */
  name: varchar('name', { length: 255 }).notNull(),
  /** 박스 설명/소개 */
  description: text('description'),
  /** 초대 코드 (6자리 영숫자, 예: 'A3F9K2') */
  inviteCode: varchar('invite_code', { length: 6 }).notNull().unique(),
  /** 박스 생성자 사용자 ID (FK 제약조건 없음, users.id 참조) */
  createdBy: integer('created_by').notNull(),
  /** 생성 시간 */
  createdAt: timestamp('created_at').defaultNow(),
  /** 수정 시간 */
  updatedAt: timestamp('updated_at').defaultNow(),
}, (table) => ({
  inviteCodeIdx: index('idx_boxes_invite_code').on(table.inviteCode),
  createdByIdx: index('idx_boxes_created_by').on(table.createdBy),
}));
```

**Design Notes**:
- `inviteCode`: 박스 가입용 6자리 코드 (UNIQUE 제약조건)
- `createdBy`: 박스 생성자 (향후 권한 관리 시 활용 가능)
- FK 제약조건 없음 (애플리케이션 레벨에서 관계 관리)

#### Table: `box_members`

박스-사용자 관계를 저장하는 중간 테이블.

```typescript
/**
 * 박스 멤버 테이블 (박스-사용자 다대다 관계)
 */
export const boxMembers = pgTable('box_members', {
  /** 멤버 고유 ID */
  id: serial('id').primaryKey(),
  /** 박스 ID (FK 제약조건 없음, boxes.id 참조) */
  boxId: integer('box_id').notNull(),
  /** 사용자 ID (FK 제약조건 없음, users.id 참조) */
  userId: integer('user_id').notNull(),
  /** 멤버 역할 (MVP: 'member'만, 향후 확장 가능) */
  role: varchar('role', { length: 20 }).notNull().default('member'),
  /** 가입 시간 */
  joinedAt: timestamp('joined_at').defaultNow(),
}, (table) => ({
  uniqueBoxUser: unique().on(table.boxId, table.userId),
  boxIdIdx: index('idx_box_members_box_id').on(table.boxId),
  userIdIdx: index('idx_box_members_user_id').on(table.userId),
}));
```

**Design Notes**:
- `role`: MVP에서는 'member'만 사용, Post-MVP에서 'coach', 'admin' 추가 가능
- UNIQUE(boxId, userId): 중복 가입 방지
- 인덱스: boxId, userId 조회 성능 최적화

### 3.2 WOD Management (Phase 1-2)

#### Table: `wods`

WOD(Workout of the Day) 정보를 저장하는 테이블.

```typescript
// src/modules/wod/schema.ts
import { pgTable, serial, integer, date, jsonb, text, boolean, timestamp, index, unique } from 'drizzle-orm/pg-core';

/**
 * WOD 테이블 (Workout of the Day)
 */
export const wods = pgTable('wods', {
  /** WOD 고유 ID */
  id: serial('id').primaryKey(),
  /** 박스 ID (FK 제약조건 없음, boxes.id 참조) */
  boxId: integer('box_id').notNull(),
  /** WOD 날짜 (YYYY-MM-DD) */
  date: date('date').notNull(),
  /** 구조화된 WOD 데이터 (JSONB 형식) */
  programData: jsonb('program_data').notNull(),
  /** 원본 텍스트 (사용자 입력) */
  rawText: text('raw_text').notNull(),
  /** Base WOD 여부 (true: 기준, false: Personal) */
  isBase: boolean('is_base').notNull().default(false),
  /** 등록자 사용자 ID (FK 제약조건 없음, users.id 참조) */
  createdBy: integer('created_by').notNull(),
  /** 생성 시간 */
  createdAt: timestamp('created_at').defaultNow(),
  /** 수정 시간 */
  updatedAt: timestamp('updated_at').defaultNow(),
}, (table) => ({
  uniqueBoxDateBase: unique().on(table.boxId, table.date, table.isBase).where(eq(table.isBase, true)),
  boxIdDateIdx: index('idx_wods_box_id_date').on(table.boxId, table.date),
  createdByIdx: index('idx_wods_created_by').on(table.createdBy),
}));
```

**Design Notes**:
- `programData`: JSONB 형식으로 유연한 WOD 구조 저장
  ```json
  {
    "type": "AMRAP | ForTime | EMOM | Strength | Custom",
    "timeCap": 15,
    "rounds": null,
    "movements": [
      { "name": "Pull-up", "reps": 10, "weight": null, "unit": null },
      { "name": "Push-up", "reps": 20, "weight": null, "unit": null }
    ]
  }
  ```
- `isBase`: 해당 날짜/박스의 Base WOD는 단 하나 (UNIQUE 제약조건)
- `rawText`: 원본 입력 보존 (디버깅, 감사 목적)
- 인덱스: (boxId, date) 복합 인덱스로 날짜별 조회 최적화

#### Table: `proposed_changes`

Base WOD 변경 제안을 저장하는 테이블.

```typescript
/**
 * WOD 변경 제안 테이블 (Phase 2)
 */
export const proposedChanges = pgTable('proposed_changes', {
  /** 제안 고유 ID */
  id: serial('id').primaryKey(),
  /** 대상 WOD ID (FK 제약조건 없음, wods.id 참조) */
  wodId: integer('wod_id').notNull(),
  /** 제안자 사용자 ID (FK 제약조건 없음, users.id 참조) */
  proposedBy: integer('proposed_by').notNull(),
  /** 제안된 WOD 데이터 (JSONB 형식) */
  proposedProgramData: jsonb('proposed_program_data').notNull(),
  /** 제안 상태 ('pending' | 'approved' | 'rejected') */
  status: varchar('status', { length: 20 }).notNull().default('pending'),
  /** 승인/거부자 사용자 ID (FK 제약조건 없음, users.id 참조) */
  resolvedBy: integer('resolved_by'),
  /** 승인/거부 시간 */
  resolvedAt: timestamp('resolved_at'),
  /** 생성 시간 */
  createdAt: timestamp('created_at').defaultNow(),
}, (table) => ({
  wodIdIdx: index('idx_proposed_changes_wod_id').on(table.wodId),
  statusIdx: index('idx_proposed_changes_status').on(table.status),
}));
```

**Design Notes**:
- `status`: enum('pending', 'approved', 'rejected')
- `proposedProgramData`: Personal WOD의 programData 복사본
- 승인 시 기존 Base WOD 업데이트 + 제안자 WOD를 Base로 승격

### 3.3 WOD Selection & Recording (Phase 3)

#### Table: `wod_selections`

사용자의 WOD 선택 기록을 저장하는 테이블 (불변성 보장).

```typescript
/**
 * WOD 선택 테이블 (Phase 3) - 기록 불변성 보장
 */
export const wodSelections = pgTable('wod_selections', {
  /** 선택 고유 ID */
  id: serial('id').primaryKey(),
  /** 사용자 ID (FK 제약조건 없음, users.id 참조) */
  userId: integer('user_id').notNull(),
  /** 선택한 WOD ID (FK 제약조건 없음, wods.id 참조) */
  wodId: integer('wod_id').notNull(),
  /** 박스 ID (FK 제약조건 없음, boxes.id 참조) */
  boxId: integer('box_id').notNull(),
  /** WOD 날짜 (YYYY-MM-DD, 조회 성능 최적화) */
  date: date('date').notNull(),
  /** 선택 시점의 WOD 스냅샷 (JSONB, 불변성 보장) */
  snapshotData: jsonb('snapshot_data').notNull(),
  /** 생성 시간 */
  createdAt: timestamp('created_at').defaultNow(),
}, (table) => ({
  uniqueUserDate: unique().on(table.userId, table.boxId, table.date),
  userIdIdx: index('idx_wod_selections_user_id').on(table.userId),
  boxIdDateIdx: index('idx_wod_selections_box_id_date').on(table.boxId, table.date),
}));
```

**Design Notes**:
- `snapshotData`: 선택 시점의 WOD programData 복사본 (이후 변경 무관)
- UNIQUE(userId, boxId, date): 하루에 한 박스당 하나의 WOD만 선택 가능
- 불변성: 생성 후 UPDATE 불가 (애플리케이션 레벨 제약)

---

## 4. API Endpoints

### 4.1 Box Module (Phase 1)

#### POST `/boxes` - 박스 생성

**Request**:
```typescript
{
  "name": "CrossFit Seoul",
  "description": "Best CrossFit gym in Seoul"
}
```

**Response** (201):
```typescript
{
  "id": 1,
  "name": "CrossFit Seoul",
  "description": "Best CrossFit gym in Seoul",
  "inviteCode": "A3F9K2",
  "createdBy": 123,
  "createdAt": "2026-02-03T10:00:00Z",
  "updatedAt": "2026-02-03T10:00:00Z"
}
```

**Authentication**: Required (JWT from auth module)

#### POST `/boxes/join` - 박스 가입

**Request**:
```typescript
{
  "inviteCode": "A3F9K2"
}
```

**Response** (200):
```typescript
{
  "id": 5,
  "boxId": 1,
  "userId": 123,
  "role": "member",
  "joinedAt": "2026-02-03T10:05:00Z"
}
```

**Authentication**: Required

#### GET `/boxes/:boxId` - 박스 상세 조회

**Response** (200):
```typescript
{
  "id": 1,
  "name": "CrossFit Seoul",
  "description": "Best CrossFit gym in Seoul",
  "inviteCode": "A3F9K2",
  "memberCount": 15,
  "createdAt": "2026-02-03T10:00:00Z"
}
```

**Authentication**: Required

#### GET `/boxes/:boxId/members` - 박스 멤버 목록

**Response** (200):
```typescript
{
  "members": [
    {
      "id": 5,
      "userId": 123,
      "role": "member",
      "joinedAt": "2026-02-03T10:05:00Z",
      "user": {
        "id": 123,
        "nickname": "John Doe",
        "profileImage": "https://example.com/profile.jpg"
      }
    }
  ],
  "totalCount": 15
}
```

**Authentication**: Required

### 4.2 WOD Module (Phase 1-3)

#### POST `/wods` - WOD 등록

**Request**:
```typescript
{
  "boxId": 1,
  "date": "2026-02-03",
  "rawText": "AMRAP 15min\n10 Pull-ups\n20 Push-ups\n30 Air Squats",
  "programData": {
    "type": "AMRAP",
    "timeCap": 15,
    "rounds": null,
    "movements": [
      { "name": "Pull-up", "reps": 10, "weight": null, "unit": null },
      { "name": "Push-up", "reps": 20, "weight": null, "unit": null },
      { "name": "Air Squat", "reps": 30, "weight": null, "unit": null }
    ]
  }
}
```

**Response** (201):
```typescript
{
  "id": 100,
  "boxId": 1,
  "date": "2026-02-03",
  "programData": { ... },
  "rawText": "AMRAP 15min...",
  "isBase": true,  // 첫 등록이므로 자동으로 Base
  "createdBy": 123,
  "comparisonResult": "identical",  // Base와 비교 결과 (자기 자신이므로 identical)
  "createdAt": "2026-02-03T10:00:00Z"
}
```

**Authentication**: Required

**Business Logic**:
1. 해당 날짜/박스에 Base WOD가 없으면 → `isBase = true`
2. Base WOD가 이미 존재하면 → 구조적 비교 후 `isBase = false` (Personal WOD)

#### GET `/wods/:boxId/:date` - 날짜별 WOD 조회

**Response** (200):
```typescript
{
  "baseWod": {
    "id": 100,
    "boxId": 1,
    "date": "2026-02-03",
    "programData": { ... },
    "rawText": "AMRAP 15min...",
    "isBase": true,
    "createdBy": 123,
    "createdAt": "2026-02-03T10:00:00Z"
  },
  "personalWods": [
    {
      "id": 101,
      "boxId": 1,
      "date": "2026-02-03",
      "programData": { ... },
      "rawText": "AMRAP 12min...",
      "isBase": false,
      "createdBy": 456,
      "comparisonResult": "different",  // Base와 다름
      "createdAt": "2026-02-03T10:05:00Z"
    }
  ]
}
```

**Authentication**: Required

#### POST `/wods/:wodId/propose` - 변경 제안 (Phase 2)

**Request**:
```typescript
{
  "proposedProgramData": {
    "type": "AMRAP",
    "timeCap": 12,
    "movements": [ ... ]
  }
}
```

**Response** (201):
```typescript
{
  "id": 50,
  "wodId": 100,
  "proposedBy": 456,
  "proposedProgramData": { ... },
  "status": "pending",
  "createdAt": "2026-02-03T10:10:00Z"
}
```

**Authentication**: Required

**Business Logic**:
- Personal WOD 등록 시 Base와 구조적으로 다르면 자동으로 변경 제안 생성
- Base WOD 등록자(createdBy)에게 푸시 알림 발송

#### POST `/wods/:wodId/approve` - 변경 승인 (Phase 2)

**Request**:
```typescript
{
  "proposalId": 50
}
```

**Response** (200):
```typescript
{
  "approved": true,
  "oldBaseWodId": 100,
  "newBaseWodId": 101,
  "updatedAt": "2026-02-03T10:15:00Z"
}
```

**Authentication**: Required

**Business Logic**:
1. 제안된 Personal WOD → Base WOD로 승격 (`isBase = true`)
2. 기존 Base WOD → Personal WOD로 강등 (`isBase = false`)
3. 제안 상태 업데이트 (`status = 'approved'`)
4. 기존 Base 선택자들에게 푸시 알림 발송

#### POST `/wods/:wodId/select` - WOD 선택 (Phase 3)

**Request**:
```typescript
{
  "boxId": 1,
  "date": "2026-02-03"
}
```

**Response** (201):
```typescript
{
  "id": 200,
  "userId": 123,
  "wodId": 100,
  "boxId": 1,
  "date": "2026-02-03",
  "snapshotData": { ... },  // 선택 시점의 WOD 스냅샷
  "createdAt": "2026-02-03T11:00:00Z"
}
```

**Authentication**: Required

**Business Logic**:
- 선택 시점의 `wods.programData`를 `snapshotData`로 복사 (불변성)
- 이후 Base WOD가 변경되어도 기록은 유지됨
- UNIQUE 제약조건으로 하루에 하나만 선택 가능 (멱등성)

#### GET `/wods/selections/:date` - 선택 조회 (Phase 3)

**Response** (200):
```typescript
{
  "selection": {
    "id": 200,
    "userId": 123,
    "wodId": 100,
    "boxId": 1,
    "date": "2026-02-03",
    "snapshotData": { ... },
    "createdAt": "2026-02-03T11:00:00Z"
  }
}
```

**Authentication**: Required

---

## 5. Business Logic

### 5.1 Base WOD Auto-Designation (Phase 1)

**Logic**: 해당 날짜/박스의 첫 WOD 등록 → `isBase = true` 자동 설정

```typescript
// src/modules/wod/services.ts

/**
 * WOD 등록 비즈니스 로직
 */
export const registerWod = async (data: {
  boxId: number;
  date: string;
  programData: ProgramData;
  rawText: string;
  createdBy: number;
}): Promise<Wod> => {
  // 1. Base WOD 존재 여부 확인
  const [existingBase] = await db
    .select()
    .from(wods)
    .where(
      and(
        eq(wods.boxId, data.boxId),
        eq(wods.date, data.date),
        eq(wods.isBase, true)
      )
    );

  // 2. Base가 없으면 현재 WOD를 Base로 지정
  const isBase = !existingBase;

  // 3. WOD 생성
  const [newWod] = await db
    .insert(wods)
    .values({
      boxId: data.boxId,
      date: data.date,
      programData: data.programData,
      rawText: data.rawText,
      isBase,
      createdBy: data.createdBy,
    })
    .returning();

  // 4. Base WOD가 이미 존재하면 Personal WOD로 비교
  let comparisonResult: ComparisonResult = 'identical';
  if (!isBase && existingBase) {
    comparisonResult = compareWods(existingBase.programData, data.programData);

    // 5. 구조적으로 다르면 변경 제안 생성
    if (comparisonResult === 'different') {
      await createProposal({
        wodId: existingBase.id,
        proposedBy: data.createdBy,
        proposedProgramData: data.programData,
      });
    }
  }

  return { ...newWod, comparisonResult };
};
```

### 5.2 Personal WOD Detection (Phase 2)

**Logic**: Base WOD와 구조적 비교 → 다르면 `isBase = false` + 변경 제안

**Comparison Strategy**:
- LLM/NLP 불필요 (구조화된 JSON 필드별 비교)
- 운동명은 정규화 테이블로 동의어 처리
- 결과: `identical | similar | different`

```typescript
// src/modules/wod/comparison.ts

export type ComparisonResult = 'identical' | 'similar' | 'different';

/**
 * WOD 구조적 비교
 */
export const compareWods = (
  base: ProgramData,
  personal: ProgramData
): ComparisonResult => {
  // 1. Type 비교
  if (base.type !== personal.type) {
    return 'different';
  }

  // 2. TimeCap 비교 (±10% 허용)
  if (base.timeCap && personal.timeCap) {
    const diff = Math.abs(base.timeCap - personal.timeCap);
    if (diff > base.timeCap * 0.1) {
      return 'different';
    }
  }

  // 3. Movements 개수 비교
  if (base.movements.length !== personal.movements.length) {
    return 'different';
  }

  // 4. Movements 상세 비교
  for (let i = 0; i < base.movements.length; i++) {
    const baseMovement = base.movements[i];
    const personalMovement = personal.movements[i];

    // 4-1. 운동명 정규화 후 비교
    const normalizedBase = normalizeExerciseName(baseMovement.name);
    const normalizedPersonal = normalizeExerciseName(personalMovement.name);

    if (normalizedBase !== normalizedPersonal) {
      return 'different';
    }

    // 4-2. Reps 비교 (±10% 허용)
    if (baseMovement.reps && personalMovement.reps) {
      const diff = Math.abs(baseMovement.reps - personalMovement.reps);
      if (diff > baseMovement.reps * 0.1) {
        return 'similar';  // 운동은 같지만 reps 다름
      }
    }

    // 4-3. Weight 비교 (±5% 허용)
    if (baseMovement.weight && personalMovement.weight) {
      const diff = Math.abs(baseMovement.weight - personalMovement.weight);
      if (diff > baseMovement.weight * 0.05) {
        return 'similar';  // 운동은 같지만 weight 다름
      }
    }
  }

  return 'identical';
};
```

### 5.3 Exercise Name Normalization (Phase 2)

**Logic**: 동의어 매핑 테이블로 운동명 정규화

```typescript
// src/modules/wod/normalization.ts

/**
 * 운동명 동의어 매핑 테이블
 */
const EXERCISE_SYNONYMS: Record<string, string> = {
  // Pull-up variants
  'pullup': 'pull-up',
  'pull up': 'pull-up',
  'kipping pull-up': 'pull-up',

  // Clean & Jerk variants
  'c&j': 'clean-and-jerk',
  'c and j': 'clean-and-jerk',
  'clean and jerk': 'clean-and-jerk',

  // Snatch variants
  'sq snatch': 'squat-snatch',
  'squat snatch': 'squat-snatch',

  // Box Jump variants
  'box jump': 'box-jump',
  'boxjump': 'box-jump',

  // 100+ common CrossFit movements...
};

/**
 * 운동명 정규화
 */
export const normalizeExerciseName = (name: string): string => {
  const lowercased = name.toLowerCase().trim();

  // 동의어 테이블 조회
  if (EXERCISE_SYNONYMS[lowercased]) {
    return EXERCISE_SYNONYMS[lowercased];
  }

  // 기본 정규화 (공백 제거, 하이픈 통일)
  return lowercased
    .replace(/\s+/g, '-')
    .replace(/_/g, '-');
};
```

**Initial Seed Data**:
- 주요 크로스핏 운동 100여 개 매핑 (Pull-up, Clean, Snatch, Box Jump 등)
- Post-MVP: 사용자 피드백으로 점진적 확장

### 5.4 Change Proposal Flow (Phase 2)

**Logic**: Personal WOD 등록 → 구조적 비교 → 다르면 제안 생성 + 알림

```typescript
// src/modules/wod/services.ts

/**
 * 변경 제안 생성
 */
export const createProposal = async (data: {
  wodId: number;
  proposedBy: number;
  proposedProgramData: ProgramData;
}): Promise<ProposedChange> => {
  // 1. 제안 생성
  const [proposal] = await db
    .insert(proposedChanges)
    .values({
      wodId: data.wodId,
      proposedBy: data.proposedBy,
      proposedProgramData: data.proposedProgramData,
      status: 'pending',
    })
    .returning();

  // 2. Base WOD 등록자에게 푸시 알림 (Phase 5)
  // await sendPushNotification({
  //   userId: baseWod.createdBy,
  //   type: 'WOD_DIFFERENCE_DETECTED',
  //   data: { proposalId: proposal.id }
  // });

  return proposal;
};

/**
 * 변경 승인
 */
export const approveProposal = async (proposalId: number): Promise<void> => {
  // 1. 제안 조회
  const [proposal] = await db
    .select()
    .from(proposedChanges)
    .where(eq(proposedChanges.id, proposalId));

  if (!proposal) {
    throw new NotFoundException('ProposedChange', proposalId);
  }

  // 2. 트랜잭션으로 Base 교체
  await db.transaction(async (tx) => {
    // 2-1. 기존 Base WOD → Personal로 강등
    await tx
      .update(wods)
      .set({ isBase: false })
      .where(eq(wods.id, proposal.wodId));

    // 2-2. 제안된 Personal WOD → Base로 승격
    const [personalWod] = await tx
      .select()
      .from(wods)
      .where(
        and(
          eq(wods.createdBy, proposal.proposedBy),
          eq(wods.programData, proposal.proposedProgramData)
        )
      );

    if (personalWod) {
      await tx
        .update(wods)
        .set({ isBase: true })
        .where(eq(wods.id, personalWod.id));
    }

    // 2-3. 제안 상태 업데이트
    await tx
      .update(proposedChanges)
      .set({
        status: 'approved',
        resolvedAt: new Date(),
      })
      .where(eq(proposedChanges.id, proposalId));
  });

  // 3. 기존 Base 선택자들에게 푸시 알림 (Phase 5)
  // await sendPushNotification({
  //   userIds: previousBaseSelectors,
  //   type: 'BASE_WOD_CHANGED',
  //   data: { oldWodId: proposal.wodId, newWodId: personalWod.id }
  // });
};
```

### 5.5 WOD Selection with Immutability (Phase 3)

**Logic**: 선택 시점의 WOD 스냅샷 저장 → 이후 변경 무관

```typescript
/**
 * WOD 선택 비즈니스 로직
 */
export const selectWod = async (data: {
  userId: number;
  wodId: number;
  boxId: number;
  date: string;
}): Promise<WodSelection> => {
  // 1. WOD 조회
  const [wod] = await db
    .select()
    .from(wods)
    .where(eq(wods.id, data.wodId));

  if (!wod) {
    throw new NotFoundException('WOD', data.wodId);
  }

  // 2. 스냅샷 데이터 복사 (불변성 보장)
  const snapshotData = { ...wod.programData };

  // 3. 선택 저장 (UNIQUE 제약조건으로 멱등성 보장)
  const [selection] = await db
    .insert(wodSelections)
    .values({
      userId: data.userId,
      wodId: data.wodId,
      boxId: data.boxId,
      date: data.date,
      snapshotData,
    })
    .onConflictDoUpdate({
      target: [wodSelections.userId, wodSelections.boxId, wodSelections.date],
      set: {
        wodId: data.wodId,
        snapshotData,
        createdAt: new Date(),
      },
    })
    .returning();

  return selection;
};
```

**Immutability Guarantee**:
- `snapshotData`는 선택 시점의 `programData` 복사본
- 이후 Base WOD가 변경되어도 `snapshotData`는 변하지 않음
- UPDATE 불가 (애플리케이션 레벨에서 제약)

---

## 6. Error Handling

### 6.1 Custom Error Types

```typescript
// src/utils/errors.ts (기존 확장)

/**
 * 박스 찾을 수 없음
 */
export class BoxNotFoundException extends NotFoundException {
  constructor(identifier: string | number) {
    super('Box', identifier);
  }
}

/**
 * WOD 찾을 수 없음
 */
export class WodNotFoundException extends NotFoundException {
  constructor(identifier: string | number) {
    super('WOD', identifier);
  }
}

/**
 * 중복 박스 가입 시도
 */
export class DuplicateBoxMemberException extends BusinessException {
  constructor(boxId: number, userId: number) {
    super(`User ${userId} is already a member of box ${boxId}`, 'DUPLICATE_BOX_MEMBER');
  }
}

/**
 * 유효하지 않은 초대 코드
 */
export class InvalidInviteCodeException extends BusinessException {
  constructor(inviteCode: string) {
    super(`Invalid invite code: ${inviteCode}`, 'INVALID_INVITE_CODE');
  }
}

/**
 * WOD 선택 충돌 (같은 날짜에 이미 선택됨)
 */
export class DuplicateWodSelectionException extends BusinessException {
  constructor(date: string) {
    super(`WOD already selected for date: ${date}`, 'DUPLICATE_WOD_SELECTION');
  }
}

/**
 * 변경 제안 찾을 수 없음
 */
export class ProposalNotFoundException extends NotFoundException {
  constructor(proposalId: number) {
    super('ProposedChange', proposalId);
  }
}
```

### 6.2 Error Code Mappings

```typescript
// src/utils/errors.ts (기존 ErrorCode enum 확장)

export enum ErrorCode {
  // ... 기존 코드들

  // Box
  BOX_NOT_FOUND = 'BOX_NOT_FOUND',
  INVALID_INVITE_CODE = 'INVALID_INVITE_CODE',
  DUPLICATE_BOX_MEMBER = 'DUPLICATE_BOX_MEMBER',

  // WOD
  WOD_NOT_FOUND = 'WOD_NOT_FOUND',
  DUPLICATE_WOD_SELECTION = 'DUPLICATE_WOD_SELECTION',
  PROPOSAL_NOT_FOUND = 'PROPOSAL_NOT_FOUND',

  // Validation
  INVALID_PROGRAM_DATA = 'INVALID_PROGRAM_DATA',
}
```

### 6.3 HTTP Status Mappings

| Error Type | HTTP Status | Code |
|-----------|-------------|------|
| BoxNotFoundException | 404 | BOX_NOT_FOUND |
| WodNotFoundException | 404 | WOD_NOT_FOUND |
| InvalidInviteCodeException | 400 | INVALID_INVITE_CODE |
| DuplicateBoxMemberException | 409 | DUPLICATE_BOX_MEMBER |
| DuplicateWodSelectionException | 409 | DUPLICATE_WOD_SELECTION |
| ProposalNotFoundException | 404 | PROPOSAL_NOT_FOUND |

---

## 7. Notification Integration Points (Phase 5)

알림은 Phase 5에서 구현하지만, 발송 시점을 미리 설계합니다.

### 7.1 Event Types

```typescript
// 향후 구현 시 참조
export enum WodEventType {
  /** 오늘의 WOD가 등록되었습니다 */
  WOD_REGISTERED = 'WOD_REGISTERED',

  /** 오늘 WOD가 다르게 등록된 것 같습니다 */
  WOD_DIFFERENCE_DETECTED = 'WOD_DIFFERENCE_DETECTED',

  /** Base WOD가 변경되었습니다 */
  BASE_WOD_CHANGED = 'BASE_WOD_CHANGED',
}
```

### 7.2 Notification Triggers

**1. WOD_REGISTERED (Base WOD 최초 등록)**
- **Trigger**: `registerWod()` - Base WOD 생성 시
- **Recipients**: 해당 박스의 모든 멤버
- **Data**: `{ wodId, boxId, date }`

**2. WOD_DIFFERENCE_DETECTED (Personal WOD 등록 시 차이 발견)**
- **Trigger**: `createProposal()` - 변경 제안 생성 시
- **Recipients**: Base WOD 등록자 (`wods.createdBy`)
- **Data**: `{ proposalId, wodId, proposedBy }`

**3. BASE_WOD_CHANGED (변경 승인)**
- **Trigger**: `approveProposal()` - Base 교체 완료 시
- **Recipients**: 기존 Base WOD를 선택한 사용자들
- **Data**: `{ oldWodId, newWodId, boxId, date }`

**Implementation Placeholder**:
```typescript
// src/modules/wod/services.ts (Phase 5에서 활성화)

// await sendPushNotification({
//   type: WodEventType.WOD_REGISTERED,
//   recipients: boxMembers,
//   data: { wodId, boxId, date }
// });
```

---

## 8. TDD Plan

### 8.1 Test File Structure

```
tests/unit/
├── box/
│   ├── handlers.test.ts          # Box handler tests
│   ├── services.test.ts          # Box business logic tests
│   └── box.probe.test.ts         # Box logging tests
│
└── wod/
    ├── handlers.test.ts          # WOD handler tests
    ├── services.test.ts          # WOD business logic tests
    ├── comparison.test.ts        # WOD comparison logic tests
    ├── normalization.test.ts     # Exercise name normalization tests
    └── wod.probe.test.ts         # WOD logging tests
```

### 8.2 TDD Test Plan (Phase 1-3)

**IMPORTANT**: Follow Kent Beck's TDD cycle strictly:
1. Write a **failing test** first (Red)
2. Implement **minimum code** to make it pass (Green)
3. **Refactor** only after tests are passing

**Test Execution**:
- Run all tests except long-running ones each time
- Use `vitest --watch` during development

#### Phase 1: Box Module

```markdown
## Box Module Tests

### Box Creation
- [ ] should create box with valid data
- [ ] should auto-generate unique 6-char invite code
- [ ] should throw ValidationException for missing name
- [ ] should set createdBy to authenticated user

### Box Join
- [ ] should join box with valid invite code
- [ ] should throw InvalidInviteCodeException for invalid code
- [ ] should throw DuplicateBoxMemberException for duplicate join
- [ ] should set role to 'member' by default

### Box Query
- [ ] should return box details by id
- [ ] should throw BoxNotFoundException for non-existent id
- [ ] should return member count in box details

### Box Members
- [ ] should list all members with user info
- [ ] should paginate members list
- [ ] should include joinedAt timestamp

## WOD Module Tests (Phase 1)

### WOD Registration
- [ ] should create Base WOD when first for date/box
- [ ] should auto-set isBase=true for first WOD
- [ ] should validate programData structure with Zod
- [ ] should store rawText as-is
- [ ] should throw ValidationException for invalid programData

### WOD Query
- [ ] should return Base WOD for given date/box
- [ ] should return empty personalWods array when none exist
- [ ] should throw WodNotFoundException for non-existent date
```

#### Phase 2: Personal WOD & Proposals

```markdown
## WOD Comparison Tests (Phase 2)

### Structural Comparison
- [ ] should return 'identical' for same structure
- [ ] should return 'different' for different type
- [ ] should return 'different' for different movements count
- [ ] should return 'different' for >10% timeCap difference
- [ ] should return 'similar' for >10% reps difference
- [ ] should return 'similar' for >5% weight difference

### Exercise Normalization
- [ ] should normalize 'pullup' to 'pull-up'
- [ ] should normalize 'c&j' to 'clean-and-jerk'
- [ ] should normalize 'box jump' to 'box-jump'
- [ ] should return lowercase and trimmed name

## Proposal Tests (Phase 2)

### Proposal Creation
- [ ] should create proposal when Personal WOD differs from Base
- [ ] should set status to 'pending' by default
- [ ] should not create proposal for 'identical' WODs
- [ ] should associate proposal with Base WOD

### Proposal Approval
- [ ] should swap Base and Personal WOD on approval
- [ ] should set old Base isBase=false
- [ ] should set new Base isBase=true
- [ ] should update proposal status to 'approved'
- [ ] should throw ProposalNotFoundException for invalid id
```

#### Phase 3: WOD Selection

```markdown
## WOD Selection Tests (Phase 3)

### Selection Creation
- [ ] should create selection with snapshot of current WOD
- [ ] should copy programData to snapshotData
- [ ] should enforce UNIQUE(userId, boxId, date)
- [ ] should throw DuplicateWodSelectionException for duplicate

### Selection Immutability
- [ ] should preserve snapshotData when Base WOD changes
- [ ] should not update snapshotData on subsequent calls
- [ ] should return same selection for same date

### Selection Query
- [ ] should return selection by userId and date
- [ ] should return null for non-existent selection
- [ ] should include snapshotData in response
```

### 8.3 Test Example (TDD Approach)

**Step 1: Write Failing Test (RED)**

```typescript
// tests/unit/box/services.test.ts
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { createBox } from '../../../src/modules/box/services';
import { ValidationException } from '../../../src/utils/errors';

describe('Box Services', () => {
  beforeEach(() => {
    // DB mock setup
  });

  it('should create box with valid data', async () => {
    const boxData = {
      name: 'CrossFit Seoul',
      description: 'Best gym',
      createdBy: 123,
    };

    const result = await createBox(boxData);

    expect(result).toMatchObject({
      id: expect.any(Number),
      name: 'CrossFit Seoul',
      inviteCode: expect.stringMatching(/^[A-Z0-9]{6}$/),
      createdBy: 123,
    });
  });

  it('should throw ValidationException for missing name', async () => {
    const invalidData = { description: 'Test', createdBy: 123 };

    await expect(createBox(invalidData)).rejects.toThrow(ValidationException);
  });
});
```

**Step 2: Implement Minimum Code (GREEN)**

```typescript
// src/modules/box/services.ts
import { db } from '../../config/database';
import { boxes } from './schema';
import { ValidationException } from '../../utils/errors';
import { generateInviteCode } from '../../utils/invite-code';

export const createBox = async (data: {
  name: string;
  description?: string;
  createdBy: number;
}) => {
  if (!data.name) {
    throw new ValidationException('Box name is required');
  }

  const inviteCode = generateInviteCode();

  const [box] = await db.insert(boxes).values({
    name: data.name,
    description: data.description,
    inviteCode,
    createdBy: data.createdBy,
  }).returning();

  return box;
};
```

**Step 3: Refactor (if needed)**

```typescript
// src/modules/box/validators.ts (Zod로 검증 로직 분리)
import { z } from 'zod';

export const createBoxSchema = z.object({
  name: z.string().min(1, 'Box name is required').max(255),
  description: z.string().optional(),
});

// services.ts에서 사용
export const createBox = async (data: CreateBoxInput) => {
  // Zod로 검증 (Refactoring)
  const validated = createBoxSchema.parse(data);

  // ... 나머지 로직
};
```

---

## 9. Logging with Domain Probe Pattern

### 9.1 Box Probe

```typescript
// src/modules/box/box.probe.ts
import { logger } from '../../utils/logger';

/**
 * 박스 생성 성공 (INFO)
 */
export const created = (data: {
  boxId: number;
  name: string;
  createdBy: number;
}) => {
  logger.info({
    boxId: data.boxId,
    name: data.name,
    createdBy: data.createdBy,
  }, 'Box created successfully');
};

/**
 * 박스 가입 성공 (INFO)
 */
export const memberJoined = (data: {
  boxId: number;
  userId: number;
}) => {
  logger.info({
    boxId: data.boxId,
    userId: data.userId,
  }, 'User joined box');
};

/**
 * 유효하지 않은 초대 코드 (WARN)
 */
export const invalidInviteCode = (inviteCode: string) => {
  logger.warn({ inviteCode }, 'Invalid invite code attempted');
};

/**
 * 중복 가입 시도 (WARN)
 */
export const duplicateJoinAttempt = (data: {
  boxId: number;
  userId: number;
}) => {
  logger.warn({
    boxId: data.boxId,
    userId: data.userId,
  }, 'Duplicate box join attempt');
};
```

### 9.2 WOD Probe

```typescript
// src/modules/wod/wod.probe.ts
import { logger } from '../../utils/logger';

/**
 * Base WOD 등록 성공 (INFO)
 */
export const baseWodRegistered = (data: {
  wodId: number;
  boxId: number;
  date: string;
  createdBy: number;
}) => {
  logger.info({
    wodId: data.wodId,
    boxId: data.boxId,
    date: data.date,
    createdBy: data.createdBy,
  }, 'Base WOD registered');
};

/**
 * Personal WOD 등록 성공 (INFO)
 */
export const personalWodRegistered = (data: {
  wodId: number;
  boxId: number;
  date: string;
  createdBy: number;
  comparisonResult: string;
}) => {
  logger.info({
    wodId: data.wodId,
    boxId: data.boxId,
    date: data.date,
    createdBy: data.createdBy,
    comparisonResult: data.comparisonResult,
  }, 'Personal WOD registered');
};

/**
 * 변경 제안 생성 (INFO)
 */
export const proposalCreated = (data: {
  proposalId: number;
  wodId: number;
  proposedBy: number;
}) => {
  logger.info({
    proposalId: data.proposalId,
    wodId: data.wodId,
    proposedBy: data.proposedBy,
  }, 'WOD change proposal created');
};

/**
 * 변경 승인 (INFO)
 */
export const proposalApproved = (data: {
  proposalId: number;
  oldBaseWodId: number;
  newBaseWodId: number;
}) => {
  logger.info({
    proposalId: data.proposalId,
    oldBaseWodId: data.oldBaseWodId,
    newBaseWodId: data.newBaseWodId,
  }, 'WOD change proposal approved');
};

/**
 * WOD 선택 (INFO)
 */
export const wodSelected = (data: {
  userId: number;
  wodId: number;
  boxId: number;
  date: string;
}) => {
  logger.info({
    userId: data.userId,
    wodId: data.wodId,
    boxId: data.boxId,
    date: data.date,
  }, 'User selected WOD for date');
};

/**
 * 중복 선택 시도 (WARN)
 */
export const duplicateSelectionAttempt = (data: {
  userId: number;
  boxId: number;
  date: string;
}) => {
  logger.warn({
    userId: data.userId,
    boxId: data.boxId,
    date: data.date,
  }, 'Duplicate WOD selection attempt');
};
```

### 9.3 Handler Usage Example

```typescript
// src/modules/box/handlers.ts
import { Request, Response } from 'express';
import { createBoxSchema } from './validators';
import { createBox } from './services';
import * as boxProbe from './box.probe';
import { logger } from '../../utils/logger';

/**
 * 박스 생성 핸들러
 */
export const create = async (req: Request, res: Response) => {
  const data = createBoxSchema.parse(req.body);

  logger.debug('Creating box', { name: data.name });  // DEBUG only

  const box = await createBox({
    ...data,
    createdBy: req.user!.id,
  });

  boxProbe.created({  // Operational log
    boxId: box.id,
    name: box.name,
    createdBy: box.createdBy,
  });

  res.status(201).json(box);
};
```

---

## 10. Validation with Zod

### 10.1 Box Validators

```typescript
// src/modules/box/validators.ts
import { z } from 'zod';

/**
 * 박스 생성 요청 검증
 */
export const createBoxSchema = z.object({
  name: z.string().min(1, 'Box name is required').max(255),
  description: z.string().optional(),
});

/**
 * 박스 가입 요청 검증
 */
export const joinBoxSchema = z.object({
  inviteCode: z.string().length(6, 'Invite code must be 6 characters'),
});
```

### 10.2 WOD Validators

```typescript
// src/modules/wod/validators.ts
import { z } from 'zod';

/**
 * Movement 스키마
 */
const movementSchema = z.object({
  name: z.string().min(1, 'Movement name is required'),
  reps: z.number().int().positive().optional(),
  weight: z.number().positive().optional(),
  unit: z.enum(['kg', 'lb', 'bw']).optional(),
});

/**
 * ProgramData 스키마
 */
const programDataSchema = z.object({
  type: z.enum(['AMRAP', 'ForTime', 'EMOM', 'Strength', 'Custom']),
  timeCap: z.number().int().positive().optional(),
  rounds: z.number().int().positive().optional(),
  movements: z.array(movementSchema).min(1, 'At least one movement required'),
});

/**
 * WOD 등록 요청 검증
 */
export const registerWodSchema = z.object({
  boxId: z.number().int().positive(),
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Date must be YYYY-MM-DD format'),
  rawText: z.string().min(1, 'Raw text is required'),
  programData: programDataSchema,
});

/**
 * 변경 제안 요청 검증
 */
export const proposeChangeSchema = z.object({
  proposedProgramData: programDataSchema,
});

/**
 * WOD 선택 요청 검증
 */
export const selectWodSchema = z.object({
  boxId: z.number().int().positive(),
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
});
```

---

## 11. Type Definitions

### 11.1 Box Types

```typescript
// src/modules/box/types.ts

export interface Box {
  id: number;
  name: string;
  description: string | null;
  inviteCode: string;
  createdBy: number;
  createdAt: Date;
  updatedAt: Date;
}

export interface BoxMember {
  id: number;
  boxId: number;
  userId: number;
  role: string;
  joinedAt: Date;
}

export interface CreateBoxInput {
  name: string;
  description?: string;
  createdBy: number;
}

export interface JoinBoxInput {
  inviteCode: string;
  userId: number;
}
```

### 11.2 WOD Types

```typescript
// src/modules/wod/types.ts

export type WodType = 'AMRAP' | 'ForTime' | 'EMOM' | 'Strength' | 'Custom';
export type WeightUnit = 'kg' | 'lb' | 'bw';
export type ComparisonResult = 'identical' | 'similar' | 'different';
export type ProposalStatus = 'pending' | 'approved' | 'rejected';

export interface Movement {
  name: string;
  reps?: number;
  weight?: number;
  unit?: WeightUnit;
}

export interface ProgramData {
  type: WodType;
  timeCap?: number;
  rounds?: number;
  movements: Movement[];
}

export interface Wod {
  id: number;
  boxId: number;
  date: string;
  programData: ProgramData;
  rawText: string;
  isBase: boolean;
  createdBy: number;
  createdAt: Date;
  updatedAt: Date;
}

export interface ProposedChange {
  id: number;
  wodId: number;
  proposedBy: number;
  proposedProgramData: ProgramData;
  status: ProposalStatus;
  resolvedBy: number | null;
  resolvedAt: Date | null;
  createdAt: Date;
}

export interface WodSelection {
  id: number;
  userId: number;
  wodId: number;
  boxId: number;
  date: string;
  snapshotData: ProgramData;
  createdAt: Date;
}
```

---

## 12. Implementation Checklist

### Phase 1: Box + WOD 기본 구조
- [ ] Box schema 정의 (boxes, box_members)
- [ ] Box handlers (create, join, getById, getMembers)
- [ ] Box services (business logic)
- [ ] Box validators (Zod schemas)
- [ ] Box probe (operational logging)
- [ ] WOD schema 정의 (wods)
- [ ] WOD handlers (register, query)
- [ ] WOD services (Base auto-designation)
- [ ] WOD validators (programData validation)
- [ ] WOD probe (operational logging)

### Phase 2: Base/Personal WOD 분리
- [ ] WOD comparison logic (structural comparison)
- [ ] Exercise normalization (synonym mapping)
- [ ] Proposal schema 정의 (proposed_changes)
- [ ] Proposal handlers (propose, approve)
- [ ] Proposal services (business logic)
- [ ] Proposal validators
- [ ] Proposal probe (operational logging)

### Phase 3: WOD 선택 및 기록
- [ ] Selection schema 정의 (wod_selections)
- [ ] Selection handlers (select, query)
- [ ] Selection services (snapshot logic)
- [ ] Selection validators
- [ ] Selection probe (operational logging)

### Testing
- [ ] Box unit tests (handlers, services)
- [ ] WOD unit tests (handlers, services, comparison, normalization)
- [ ] Proposal unit tests
- [ ] Selection unit tests
- [ ] Integration tests (optional)

---

## 13. Next Steps

### Phase 4: Mobile API Models (Mobile Team)
- Freezed models for Box, Wod, ProposedChange, WodSelection
- Dio client integration
- Error handling

### Phase 5: Notification Integration
- FCM push notification triggers
- Event type definitions
- Recipient determination logic

### Post-MVP
- Box 신뢰도 시스템
- 코치 배지 (optional role upgrade)
- 변경 히스토리 시각화
- 난이도 계산 시스템

---

## 14. Dependencies

### Existing Infrastructure
- ✅ `apps/server/src/modules/auth/` - JWT + OAuth 완료
- ✅ `apps/server/src/modules/push-alert/` - FCM 완료
- ✅ `apps/server/src/middleware/authenticate.ts` - JWT 검증 미들웨어
- ✅ `apps/server/src/middleware/error-handler.ts` - 글로벌 에러 핸들러
- ✅ `apps/server/src/utils/errors.ts` - AppException 계층 구조
- ✅ `apps/server/src/utils/logger.ts` - Pino 로거

### New Dependencies (필요 시)
- 없음 (기존 스택으로 구현 가능)

---

## 15. References

- **Plan**: `/Users/lms/dev/repository/feature-wowa-mvp/docs/wowa/plan.md`
- **PRD**: `/Users/lms/dev/repository/feature-wowa-mvp/docs/wowa/prd.md`
- **Server CLAUDE.md**: `/Users/lms/dev/repository/feature-wowa-mvp/apps/server/CLAUDE.md`
- **API Response Guide**: `/Users/lms/dev/repository/feature-wowa-mvp/.claude/guide/server/api-response-design.md`
- **Exception Handling Guide**: `/Users/lms/dev/repository/feature-wowa-mvp/.claude/guide/server/exception-handling.md`
- **Logging Best Practices**: `/Users/lms/dev/repository/feature-wowa-mvp/.claude/guide/server/logging-best-practices.md`
- **Auth Module Reference**: `/Users/lms/dev/repository/feature-wowa-mvp/apps/server/src/modules/auth/`

---

**End of Document**

This brief is ready for CTO review and developer implementation. Follow the TDD plan strictly and refer to the existing auth module for implementation patterns.
