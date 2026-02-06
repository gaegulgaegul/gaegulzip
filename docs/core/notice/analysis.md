# Gap Analysis: 공지사항 (Notice) — Fullstack

**분석일**: 2026-02-05
**분석 대상**: server-brief.md, mobile-brief.md, user-story.md vs 실제 구현
**총 매치율**: 93%

---

## 1. Server 분석 (매치율: 91%)

### 1.1 Schema (100%)

| 설계 항목 | 상태 | 비고 |
|-----------|------|------|
| notices 테이블 구조 | ✅ | 모든 컬럼 일치 |
| notice_reads 테이블 구조 | ✅ | UNIQUE 제약, 인덱스 일치 |
| 인덱스 5개 (notices) | ✅ | appCode, isPinned, deletedAt, createdAt, category |
| 인덱스 2개 (notice_reads) | ✅ | userId, noticeId |
| FK 제약 없음 | ✅ | CLAUDE.md 정책 준수 |
| DB-level comment | ⚠️ | Drizzle 0.45.1에서 미지원 (JSDoc 주석으로 대체) |

### 1.2 API Endpoints (100%)

| 엔드포인트 | 설계 | 구현 | 상태 |
|-----------|------|------|------|
| GET /notices | ✅ | ✅ | 일치 |
| GET /notices/:id | ✅ | ✅ | 일치 |
| GET /notices/unread-count | ✅ | ✅ | 일치 |
| POST /notices | ✅ | ✅ | 일치 |
| PUT /notices/:id | ✅ | ✅ | 일치 |
| DELETE /notices/:id | ✅ | ✅ | 일치 |
| PATCH /notices/:id/pin | ✅ | ✅ | 일치 |

### 1.3 비즈니스 로직 (95%)

| 항목 | 상태 | 비고 |
|------|------|------|
| appCode 멀티테넌트 분리 | ✅ | getAppCode() 헬퍼로 구현 |
| JWT → userId/appId 추출 | ✅ | AuthenticatedRequest 타입 사용 |
| appId → appCode 변환 | ⚠️ | 설계는 JWT에서 직접 appCode, 구현은 appId로 DB 조회. 기능적 동일 |
| deletedAt IS NULL 조건 | ✅ | 전체 쿼리에 적용 |
| LEFT JOIN isRead 계산 | ✅ | 목록 조회 시 적용 |
| 페이지네이션 | ✅ | page/limit/hasNext |
| 정렬 (isPinned DESC, createdAt DESC) | ✅ | |
| viewCount +1 | ✅ | sql 템플릿으로 원자적 증가 |
| 읽음 처리 (ON CONFLICT DO NOTHING) | ✅ | |
| Soft delete | ✅ | deletedAt = new Date() |

### 1.4 인증/권한 (85%)

| 항목 | 상태 | 비고 |
|------|------|------|
| JWT 인증 미들웨어 | ✅ | 라우터 레벨에서 적용 (app.ts) |
| 관리자 X-Admin-Secret 검증 | ✅ | requireAdmin 미들웨어 분리 |
| 타이밍 공격 방지 | ✅ | crypto.timingSafeEqual 사용 (설계 대비 개선) |
| 인증 미들웨어 라우터 적용 | ⚠️ | 설계: `router.use(authMiddleware)`, 구현: app.ts 레벨에서 적용. 기능적 동일 |

### 1.5 Validators (90%)

| 항목 | 상태 | 비고 |
|------|------|------|
| listNoticesSchema | ✅ | |
| createNoticeSchema | ✅ | |
| updateNoticeSchema | ✅ | refine() 포함 |
| pinNoticeSchema | ✅ | |
| noticeIdSchema | ✅ | |
| pinnedOnly z.coerce.boolean() | ⚠️ | 설계: z.coerce.boolean(), 구현: z.enum(['true','false']).transform() — 버그 수정 반영 |

### 1.6 Domain Probe (100%)

| 프로브 | 상태 |
|--------|------|
| created() | ✅ |
| updated() | ✅ |
| deleted() | ✅ |
| pinToggled() | ✅ |
| viewed() | ✅ |
| notFound() | ✅ |

### 1.7 테스트 커버리지 (95%)

- 17개 유닛 테스트 통과
- 모든 핸들러에 대한 성공/실패 시나리오 커버
- createNotice app-not-found 테스트 추가 완료

### 1.8 Server 갭 목록

| # | 갭 | 심각도 | 조치 |
|---|-----|-------|------|
| S1 | DB-level comment 미지원 | Low | Drizzle 0.45.1 제한, JSDoc으로 대체 |
| S2 | appId→appCode 변환 방식 차이 | Low | 기능적 동일, 보안상 더 안전 |
| S3 | 인증 미들웨어 적용 위치 차이 | Low | app.ts 레벨 적용, 기능적 동일 |
| S4 | pinnedOnly 검증 방식 차이 | Low | z.coerce.boolean() 버그 수정 반영 |

---

## 2. Mobile 분석 (매치율: 93%)

### 2.1 패키지 구조 (100%)

| 설계 | 구현 | 상태 |
|------|------|------|
| models/ | ✅ | NoticeModel, NoticeListResponse, UnreadCountResponse |
| services/ | ✅ | NoticeApiService |
| controllers/ | ✅ | NoticeListController, NoticeDetailController |
| views/ | ✅ | NoticeListView, NoticeDetailView |
| widgets/ | ✅ | NoticeListCard, UnreadNoticeBadge |
| notice.dart (barrel) | ✅ | Public API export |

### 2.2 데이터 모델 (100%)

| 모델 | 상태 | 비고 |
|------|------|------|
| NoticeModel | ✅ | Freezed, 모든 필드 일치 |
| NoticeListResponse | ✅ | items, totalCount, page, limit, hasNext |
| UnreadCountResponse | ✅ | unreadCount |

### 2.3 API Service (95%)

| 항목 | 상태 | 비고 |
|------|------|------|
| getNotices() | ✅ | 쿼리 파라미터 일치 |
| getNoticeDetail() | ✅ | |
| getUnreadCount() | ✅ | |
| Dio DI | ⚠️ | 설계: `final Dio _dio = Get.find()`, 구현: `Dio get _dio => Get.find()` — DI 타이밍 수정 |

### 2.4 Controllers (90%)

| 항목 | 상태 | 비고 |
|------|------|------|
| NoticeListController 상태 관리 | ✅ | notices, pinnedNotices, isLoading 등 |
| fetchNotices() 병렬 조회 | ✅ | Future.wait으로 고정/일반 병렬 (설계 대비 개선) |
| refreshNotices() | ✅ | |
| loadMoreNotices() | ✅ | isLoading 가드 추가 (설계 대비 개선) |
| markAsRead() | ✅ | |
| NoticeDetailController | ✅ | |
| 에러 처리 (DioException + catch) | ✅ | 일반 Exception 핸들링 추가 |

### 2.5 Views (85%)

| 항목 | 상태 | 비고 |
|------|------|------|
| NoticeListView 레이아웃 | ✅ | |
| 무한 스크롤 | ⚠️ | 설계: SliverChildBuilderDelegate 내 트리거, 구현: ScrollController 방식 — 빌드 사이드이펙트 수정 |
| 중첩 Obx 제거 | ✅ | 구현에서 수정 완료 |
| NoticeDetailView | ✅ | 마크다운 렌더링, 메타 정보 |
| 에러/빈/로딩 상태 | ✅ | |
| Design System 활용 | ✅ | SketchButton, SketchCard, SketchChip |

### 2.6 Widgets (100%)

| 위젯 | 상태 |
|------|------|
| NoticeListCard | ✅ |
| UnreadNoticeBadge | ✅ |

### 2.7 Mobile 갭 목록

| # | 갭 | 심각도 | 조치 |
|---|-----|-------|------|
| M1 | Dio DI 방식 차이 (getter) | Low | 런타임 안정성 개선 |
| M2 | 무한 스크롤 트리거 방식 차이 | Low | 빌드 사이드이펙트 수정 |
| M3 | fetchNotices 병렬 조회 | Low | 성능 개선 (설계 대비 향상) |

---

## 3. User Story 매치율 (100%)

| User Story | 서버 | 모바일 |
|-----------|------|--------|
| US-1: 목록 조회 | ✅ | ✅ |
| US-2: 상세 조회 | ✅ | ✅ |
| US-3: 읽음 처리 | ✅ | ✅ |
| US-4: 읽지 않은 개수 | ✅ | ✅ |
| US-5: 고정 공지 | ✅ | ✅ |
| US-6: 작성 (관리자) | ✅ | N/A (서버만) |
| US-7: 수정 (관리자) | ✅ | N/A (서버만) |
| US-8: 삭제 (관리자) | ✅ | N/A (서버만) |
| US-9: 고정/해제 (관리자) | ✅ | N/A (서버만) |
| US-10: 앱별 분리 | ✅ | ✅ |

---

## 4. 설계 대비 개선 사항

구현 과정에서 설계보다 더 나은 방식으로 개선된 항목:

1. **타이밍 공격 방지**: `crypto.timingSafeEqual()` (설계: 단순 `!==` 비교)
2. **Admin auth 미들웨어 분리**: `requireAdmin` 미들웨어 (설계: 각 핸들러 내 인라인)
3. **z.coerce.boolean() 버그 수정**: `.enum(['true','false']).transform()` (설계: z.coerce.boolean())
4. **AuthenticatedRequest 타입**: 타입 안전한 req.user 접근 (설계: `(req as any).user`)
5. **병렬 API 호출**: `Future.wait()` (설계: 순차 호출)
6. **DI 안전성**: `Dio get _dio => Get.find()` getter (설계: 필드 초기화)
7. **무한 스크롤 안전성**: ScrollController (설계: 빌드 콜백 내 사이드이펙트)

---

## 5. 총평

| 영역 | 매치율 | 판정 |
|------|--------|------|
| Server | 91% | ✅ Pass |
| Mobile | 93% | ✅ Pass |
| User Stories | 100% | ✅ Pass |
| Test Coverage | 95% | ✅ Pass |
| **종합** | **93%** | **✅ Pass (≥90%)** |

모든 user story가 구현되었으며, 설계 대비 갭은 모두 Low 심각도입니다.
대부분의 갭이 "설계보다 개선된" 방향의 차이로, 기능적 결함은 없습니다.

### 권장 후속 조치

- PDCA Report 생성 (`/pdca report notice`)
- PR #4 머지 후 main 브랜치 통합
