# 공지사항 기능 리서치

## 1. 개요

### 목적
모든 제품(앱)에서 공통으로 사용할 수 있는 공지사항 기능을 설계한다.
- 서버: 모듈(`modules/notice/`)로 구현하여 멀티테넌트 지원
- 모바일: SDK 패키지(`packages/notice/`)로 제공하여 앱에서 재사용

### 핵심 요구사항
- `appCode`로 제품별 공지사항 분리
- 서버는 기존 모듈 패턴(`handlers → services → schema`) 유지
- 모바일은 패키지로 분리하여 어떤 앱에서든 import 가능
- 관리자 작성/편집, 사용자 조회의 기본 CRUD

---

## 2. 기존 아키텍처 분석

### 2.1 멀티테넌트 패턴 (이미 확립됨)

현재 `apps` 테이블이 멀티테넌트의 핵심 역할:
```
apps 테이블
├── code (PK) — "wowa", "app-b" 등 앱 식별자
├── name — 앱 표시명
├── oauth_* — 앱별 OAuth 자격증명
├── jwt_* — 앱별 JWT 설정
└── fcm_* — 앱별 FCM 자격증명
```

**기존 API 흐름**: `요청 → JWT에서 appCode 추출 → 앱별 설정 로드 → 처리`

공지사항도 동일 패턴 적용:
- 공지사항 테이블에 `app_code` 컬럼 추가
- 앱별로 독립된 공지사항 관리 가능

### 2.2 서버 모듈 구조 (참조: auth, push-alert)

```
src/modules/[feature]/
├── index.ts          # Router
├── handlers.ts       # Express 핸들러 (Controller/Service 분리 X)
├── services.ts       # 복잡한 DB 로직만 분리 (YAGNI)
├── schema.ts         # Drizzle 테이블 정의
├── validators.ts     # Zod 유효성 검증
├── types.ts          # TypeScript 타입
└── [feature].probe.ts # Domain Probe 운영 로그
```

**핵심 원칙**:
- 핸들러에 비즈니스 로직 직접 작성 (복잡하지 않으면 services.ts 불필요)
- FK 제약조건 사용 안 함 (앱 레벨 관계 관리)
- 모든 테이블/컬럼에 comment 필수
- Zod로 입력 유효성 검증

### 2.3 모바일 패키지 구조 (참조: core, api, design_system)

```
apps/mobile/packages/
├── core/           # 기반 유틸리티 (의존성 없음)
├── api/            # Dio HTTP, Freezed 모델
├── design_system/  # UI 컴포넌트
└── admob/          # 광고 (core 의존)
```

**의존성 방향**: `core ← api ← design_system ← app`

공지사항 패키지 위치:
```
apps/mobile/packages/
├── core/
├── api/
├── design_system/
└── notice/          # ← 새로 추가
    ├── lib/
    │   ├── notice.dart              # barrel export
    │   └── src/
    │       ├── models/              # Freezed 데이터 모델
    │       ├── services/            # API 호출
    │       ├── controllers/         # GetX Controller
    │       ├── views/               # 재사용 가능한 View
    │       └── widgets/             # 공지사항 전용 위젯
    └── pubspec.yaml
```

---

## 3. 기능 범위 분석

### 3.1 핵심 기능 (MVP)

| 기능 | 서버 | 모바일 | 설명 |
|------|------|--------|------|
| 공지사항 목록 조회 | GET /notices | ListView | appCode별 필터링, 페이지네이션 |
| 공지사항 상세 조회 | GET /notices/:id | DetailView | 조회수 증가, 마크다운 렌더링 |
| 공지사항 작성 | POST /notices | - | 관리자 전용 (admin 권한) |
| 공지사항 수정 | PUT /notices/:id | - | 관리자 전용 |
| 공지사항 삭제 | DELETE /notices/:id | - | soft delete |
| 고정 공지 | pinned 필드 | 상단 고정 UI | 중요 공지 상단 표시 |
| 읽음 처리 | POST /notices/:id/read | 로컬 표시 | 안 읽은 공지 뱃지 |

### 3.2 확장 가능 기능 (향후)

| 기능 | 설명 | 우선순위 |
|------|------|----------|
| 카테고리 분류 | 공지 유형별 필터 (업데이트, 점검, 이벤트) | 중 |
| 예약 발행 | 지정 시간에 자동 공개 | 낮음 |
| 푸시 연동 | 새 공지 등록 시 push-alert 모듈과 연동 | 중 |
| 대상 지정 | 특정 사용자 그룹에만 공지 | 낮음 |
| 첨부파일 | 이미지/파일 첨부 | 낮음 |

---

## 4. 데이터 모델 설계 (초안)

### 4.1 서버 DB 스키마

```
notices 테이블
├── id (uuid, PK)
├── app_code (varchar, NOT NULL) — 앱 식별자
├── title (varchar, NOT NULL) — 제목
├── content (text, NOT NULL) — 본문 (마크다운)
├── category (varchar) — 카테고리 (optional)
├── is_pinned (boolean, default false) — 상단 고정
├── is_published (boolean, default true) — 공개 여부
├── view_count (integer, default 0) — 조회수
├── author_id (uuid) — 작성자
├── created_at (timestamp)
├── updated_at (timestamp)
└── deleted_at (timestamp, nullable) — soft delete

notice_reads 테이블 (읽음 추적)
├── id (uuid, PK)
├── notice_id (uuid, NOT NULL)
├── user_id (uuid, NOT NULL)
├── read_at (timestamp)
└── UNIQUE(notice_id, user_id)
```

### 4.2 모바일 Freezed 모델

```dart
// Notice 모델
@freezed
class Notice with _$Notice {
  factory Notice({
    required String id,
    required String title,
    required String content,
    String? category,
    required bool isPinned,
    required int viewCount,
    required DateTime createdAt,
    DateTime? updatedAt,
    bool? isRead,  // 읽음 여부 (서버에서 user별로 join)
  }) = _Notice;
}

// NoticeList 응답
@freezed
class NoticeListResponse with _$NoticeListResponse {
  factory NoticeListResponse({
    required List<Notice> items,
    required int totalCount,
    required bool hasMore,
  }) = _NoticeListResponse;
}
```

---

## 5. API 설계 (초안)

### 5.1 사용자용 API

```
GET    /notices              — 공지사항 목록 (appCode 필터 자동)
GET    /notices/:id          — 공지사항 상세 (조회수 +1)
POST   /notices/:id/read     — 읽음 처리
GET    /notices/unread-count  — 안 읽은 공지 수
```

### 5.2 관리자용 API

```
POST   /notices              — 공지사항 작성
PUT    /notices/:id          — 공지사항 수정
DELETE /notices/:id          — 공지사항 삭제 (soft)
PATCH  /notices/:id/pin      — 고정/해제 토글
```

### 5.3 쿼리 파라미터

```
GET /notices?page=1&limit=20&category=update&pinned=true
```

---

## 6. 기술 결정 사항

### 6.1 서버

| 항목 | 결정 | 근거 |
|------|------|------|
| 모듈 위치 | `src/modules/notice/` | 기존 패턴 준수 |
| ORM | Drizzle (기존) | 일관성 |
| 유효성 검증 | Zod (기존) | 일관성 |
| 본문 형식 | 마크다운 텍스트 | 관리자 도구 유연성, 앱에서 렌더링 |
| 삭제 방식 | Soft delete (`deleted_at`) | 데이터 보존, 복구 가능 |
| 인증 | 기존 JWT 미들웨어 사용 | `appCode`는 JWT에서 추출 |
| 관리자 권한 | 별도 admin 미들웨어 또는 role 체크 | 기존 auth 모듈 확장 |
| 페이지네이션 | Cursor 기반 또는 Offset 기반 | 공지사항 특성상 offset이 단순하고 적합 |

### 6.2 모바일

| 항목 | 결정 | 근거 |
|------|------|------|
| 패키지 위치 | `packages/notice/` | 재사용 가능한 SDK |
| 의존성 | `core`, `api` 패키지 의존 | 기존 패턴 |
| 모델 | Freezed + json_serializable | 기존 패턴 |
| 상태관리 | GetX Controller | 기존 패턴 |
| UI 컴포넌트 | design_system 활용 + 공지 전용 위젯 | 일관된 UI |
| 마크다운 | flutter_markdown 패키지 | 본문 렌더링 |
| 읽음 상태 | 서버 API + 로컬 캐시 | 오프라인 지원 |

---

## 7. 아키텍처 다이어그램

```
┌─────────────────────────────────────────────────────┐
│                    Server (모듈)                      │
│  src/modules/notice/                                 │
│  ├── schema.ts    (notices, notice_reads)            │
│  ├── handlers.ts  (CRUD + 읽음처리)                   │
│  ├── validators.ts (Zod 스키마)                       │
│  └── notice.probe.ts (운영 로그)                      │
│                                                      │
│  appCode로 멀티테넌트 분리                              │
│  JWT 미들웨어로 인증                                    │
└──────────────────────┬──────────────────────────────┘
                       │ REST API
┌──────────────────────┴──────────────────────────────┐
│               Mobile SDK (패키지)                     │
│  packages/notice/                                    │
│  ├── models/     (Freezed: Notice, NoticeList)       │
│  ├── services/   (NoticeApiService - Dio)            │
│  ├── controllers/(NoticeListController, Detail...)   │
│  ├── views/      (NoticeListView, DetailView)        │
│  └── widgets/    (NoticeCard, UnreadBadge...)        │
│                                                      │
│  의존: core, api, design_system                       │
└──────────────────────┬──────────────────────────────┘
                       │ import
┌──────────────────────┴──────────────────────────────┐
│                 App (wowa 등)                         │
│  app/modules/notice/ (앱별 커스텀 바인딩만)             │
│  ├── bindings/notice_binding.dart                    │
│  └── routes에 등록                                    │
│                                                      │
│  SDK의 View/Controller를 그대로 사용하거나               │
│  앱 특화 커스터마이징 가능                                │
└─────────────────────────────────────────────────────┘
```

---

## 8. 기존 유사 기능과의 비교

| 비교 항목 | Social Login | Push Alert | **Notice (신규)** |
|-----------|-------------|------------|-------------------|
| 서버 모듈 | `auth/` | `push-alert/` | `notice/` |
| 멀티테넌트 | ✅ `apps.oauth_*` | ✅ `apps.fcm_*` | ✅ `app_code` 컬럼 |
| 모바일 패키지 | 없음 (앱 직접 구현) | 없음 | ✅ `packages/notice/` |
| CRUD 복잡도 | 높음 (OAuth flow) | 중간 (배치 발송) | 낮음 (기본 CRUD) |
| UI 컴포넌트 | SocialLoginButton | 없음 | ListView, DetailView |

---

## 9. 리스크 및 고려사항

### 9.1 관리자 권한
- 현재 auth 모듈에 role/permission 시스템이 없음
- 공지사항 작성/수정/삭제에 관리자 권한이 필요
- **옵션 A**: `users` 테이블에 `role` 컬럼 추가
- **옵션 B**: 별도 `admin_users` 테이블
- **옵션 C**: 앱 레벨에서 관리자 앱을 분리 (다른 appCode)

### 9.2 모바일 SDK 경계
- SDK(패키지)는 **재사용 가능한 로직과 기본 UI** 제공
- 앱 특화 커스터마이징은 **앱 레벨에서** 오버라이드
- SDK가 너무 많은 UI를 포함하면 유연성 저하 → 적절한 경계 설정 필요

### 9.3 마크다운 렌더링
- 서버는 plain text로 저장, 렌더링은 클라이언트 책임
- 이미지 URL이 포함된 마크다운의 경우 보안 검증 필요

---

## 10. 결론 및 다음 단계

공지사항 기능은 **기존 아키텍처 패턴을 그대로 따르면서** 구현 가능한 기능입니다.

### 플랫폼 판단
- **Fullstack**: 서버(API) + 모바일(SDK 패키지) 모두 필요

### 다음 단계
1. `/pdca plan notice` — PO가 사용자 스토리 작성 → CTO가 플랫폼 라우팅
2. `/pdca design notice` — Tech Lead가 서버 설계, UI/UX Designer가 모바일 설계
3. `/pdca do notice` — 개발자 에이전트가 TDD로 구현
