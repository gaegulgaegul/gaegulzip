# WOWA 프로젝트 현황 분석

> 분석 기준일: 2026-02-03
> PRD 기준: `docs/wowa/prd.md` (합의 기반 모델 MVP)

---

## 1. 전체 요약

| 영역 | 진행률 | 상태 |
|------|--------|------|
| **서버 - 인증** | 100% | OAuth + JWT + Refresh Token Rotation 완성 |
| **서버 - 푸시 알림** | 100% | FCM 디바이스 관리 + 발송 완성 |
| **서버 - WOD 핵심 기능** | 0% | 미착수 |
| **모바일 - 디자인 시스템** | 100% | Frame0 스케치 스타일 12개 위젯 완성 |
| **모바일 - 로그인** | 50% | UI 완성, 실제 OAuth 연동 미완 (mock) |
| **모바일 - WOD 핵심 기능** | 0% | 미착수 |

**한 줄 평가**: 인프라(인증, 푸시, 디자인 시스템)는 갖춰졌으나, PRD의 핵심인 WOD 관련 기능은 서버/모바일 모두 미구현.

---

## 2. 완료된 기능 상세

### 2.1 서버 (apps/server)

#### 인증 모듈 (`src/modules/auth/`)

| 항목 | 상세 |
|------|------|
| DB 스키마 | `apps`, `users`, `refresh_tokens` 3개 테이블 |
| OAuth 프로바이더 | Kakao (구현 완료), Naver/Google/Apple (스캐폴딩) |
| 토큰 관리 | Access Token (30분) + Refresh Token (14일), 앱별 설정 가능 |
| 보안 | Refresh Token Rotation, Reuse Detection (5초 grace period), bcrypt 해싱 |
| API 엔드포인트 | `POST /auth/oauth`, `GET /auth/oauth/callback`, `POST /auth/refresh`, `POST /auth/logout` |
| 테스트 | handlers, services, validators, providers 단위 테스트 완비 |

#### 푸시 알림 모듈 (`src/modules/push-alert/`)

| 항목 | 상세 |
|------|------|
| DB 스키마 | `push_device_tokens`, `push_alerts` 2개 테이블 |
| FCM | 앱별 FCM 설정, 멀티 디바이스 지원 |
| 발송 대상 | 단일 사용자 / 복수 사용자 / 전체 사용자 |
| 토큰 관리 | 유효하지 않은 토큰 자동 비활성화 |
| API 엔드포인트 | `POST /push/devices`, `GET /push/devices`, `DELETE /push/devices/:id`, `POST /push/send`, `GET /push/notifications`, `GET /push/notifications/:id` |
| 테스트 | handlers 단위 테스트 |

#### 공통 인프라

- **미들웨어**: JWT 인증 (`middleware/auth.ts`), 글로벌 에러 핸들러 (`middleware/error-handler.ts`)
- **에러 체계**: `AppException` > `BusinessException` > `ValidationException`, `UnauthorizedException`, `NotFoundException` 등
- **로깅**: Pino + Domain Probe 패턴 (auth.probe, push.probe)
- **유효성 검증**: Zod 스키마
- **API 문서**: OpenAPI 3.0 (`docs/openapi.yaml`)
- **DB 마이그레이션**: Drizzle ORM, 3개 마이그레이션 파일 적용 완료

### 2.2 모바일 (apps/mobile)

#### 디자인 시스템 (`packages/design_system/`)

Frame0 스케치 스타일의 커스텀 UI 컴포넌트 라이브러리:

| 컴포넌트 | 설명 |
|----------|------|
| SketchButton | Primary/Secondary/Outline 스타일, 3가지 크기, 로딩 상태 |
| SketchCard | 헤더/바디/푸터, 엘리베이션 0-3 |
| SketchInput | 텍스트 필드 (라벨, 에러, 아이콘) |
| SketchCheckbox | 스케치 스타일 체크박스 |
| SketchSwitch | 토글 스위치 |
| SketchChip | 태그/라벨 |
| SketchDropdown | 셀렉트 드롭다운 |
| SketchSlider | 범위 슬라이더 |
| SketchProgressBar | 진행률 표시 |
| SketchModal | 다이얼로그/오버레이 |
| SketchIconButton | 아이콘 전용 버튼 |
| SketchContainer | 스케치 스타일 래퍼 |
| SocialLoginButton | 카카오/네이버/애플/구글 공식 브랜딩 |

- **Painters**: CustomPaint 기반 스케치 효과 (SketchPainter, SketchCirclePainter, SketchLinePainter 등)
- **테마**: Light/Dark 모드 지원, SketchThemeController (GetX)

#### Core 패키지 (`packages/core/`)

- 디자인 토큰: `SketchDesignTokens` (색상, 간격, 타이포그래피, roughness 등)
- 예외 클래스: `AuthException`, `NetworkException`
- GetX 로거 유틸리티

#### 로그인 모듈 (`apps/wowa/lib/app/modules/login/`)

- **LoginView**: 소셜 로그인 4종 버튼 + "둘러보기" 버튼
- **LoginController**: 로딩 상태 관리, 에러 핸들링 (mock 구현 - 2초 딜레이 후 성공 스낵바)
- **LoginBinding**: GetX 의존성 주입
- **한계**: 실제 OAuth API 호출 없음, Repository 주입 주석 처리 상태

#### 라우팅 (정의만 완료)

| 라우트 | 경로 | 상태 |
|--------|------|------|
| LOGIN | `/login` | View 구현됨 |
| HOME | `/home` | 정의만 됨, View 없음 |
| SETTINGS | `/settings` | 정의만 됨, View 없음 |

---

## 3. 미구현 기능 (PRD 기준)

### 3.1 서버 - WOD 모듈 (PRD 4~6장 전체)

#### 필요한 DB 테이블

| 테이블 | 용도 | PRD 참조 |
|--------|------|----------|
| `box` | 박스(체육관) 관리 | 4.1 |
| `box_members` | 박스 구성원 관리 | 5.1 (알림 대상) |
| `wod` | WOD 저장 (Base/Personal 구분) | 4.2, 4.3, 7장 |
| `wod_selection` | 사용자 WOD 선택 기록 | 5.4, 7장 |
| `proposed_change` | 변경 제안 및 승인 이력 | 4.4, 5.3 |

#### 필요한 API 엔드포인트

| 엔드포인트 | 용도 | PRD 참조 |
|------------|------|----------|
| `POST /wod` | WOD 등록 (텍스트/이미지) | 5.1, 6.1 |
| `GET /wod/:boxId/:date` | 날짜별 WOD 조회 (Base + Personal) | 4.1, 4.2 |
| `POST /wod/:id/propose-change` | Base WOD 변경 제안 | 4.4, 5.2 |
| `POST /wod/:id/approve` | 변경 승인 | 5.3 |
| `POST /wod/:id/select` | WOD 선택 (기록용) | 5.4 |
| `GET /wod/selection/:date` | 내 선택 조회 | 5.4 |

#### 필요한 비즈니스 로직

| 로직 | 설명 | PRD 참조 |
|------|------|----------|
| Base WOD 자동 지정 | 박스+날짜 기준 최초 등록 WOD가 Base | 4.2 |
| Personal WOD 분류 | Base와 다른 WOD는 자동으로 Personal | 4.3, 5.2 |
| 구조적 차이 감지 | Base vs Personal 비교, 변경 제안 여부 | 4.4 |
| 기록 불변성 | 선택 후 Base가 바뀌어도 기존 기록 유지 | 3장 원칙 4 |
| 난이도 계산 | 참고 지표로만 사용 | 6.3 |
| 이미지 OCR + AI | 화이트보드 사진 → 구조화 JSON | 6.1 |
| WOD 알림 | 등록/차이발생/변경승인 시 알림 | 6.4 |

### 3.2 모바일 - WOD 관련 화면 전체

#### 필요한 화면

| 화면 | 설명 | 우선순위 |
|------|------|----------|
| 홈/대시보드 | 오늘의 WOD 표시, 박스 정보 | P0 |
| WOD 등록 | 텍스트 입력 + 이미지 업로드 | P0 |
| WOD 상세 | 구조화된 WOD 뷰 (type, time, movements) | P0 |
| WOD 선택 | Base vs Personal 중 선택 | P0 |
| 변경 제안 뷰 | 차이점 비교, 승인/거절 UI | P1 |
| 알림 목록 | 푸시 알림 히스토리 | P1 |
| 박스 설정 | 박스 가입/관리 | P1 |
| 설정 | 앱 설정, 로그아웃 | P2 |

#### 필요한 API 모델 (`packages/api/`)

현재 `packages/api`는 비어 있음. 아래 Freezed 모델 필요:

- `User` - 사용자 정보
- `AuthToken` - 인증 토큰
- `Box` - 박스 정보
- `Wod` - WOD 데이터 (program_data 포함)
- `WodSelection` - 선택 기록
- `ProposedChange` - 변경 제안
- `Movement` - 운동 동작 데이터

#### 필요한 모바일 인프라

| 항목 | 설명 |
|------|------|
| 실제 OAuth 연동 | LoginController에서 mock 제거, 서버 API 호출 |
| 토큰 저장 | Secure Storage 기반 Access/Refresh Token 관리 |
| API 클라이언트 | Dio 인터셉터 (인증 헤더, 토큰 갱신, 에러 핸들링) |
| 푸시 알림 | FCM 토큰 등록, 알림 수신 처리 |
| 로컬 저장소 | WOD 캐싱, 오프라인 대응 |

---

## 4. 기술 스택 현황

### 서버

| 계층 | 기술 | 상태 |
|------|------|------|
| 런타임 | Node.js + TypeScript (ES2022) | 구축 완료 |
| 프레임워크 | Express 5.x | 구축 완료 |
| DB | PostgreSQL (Supabase) + Drizzle ORM | 구축 완료 |
| 인증 | JWT + bcrypt | 구축 완료 |
| 푸시 | Firebase Cloud Messaging | 구축 완료 |
| 유효성 검증 | Zod | 구축 완료 |
| 로깅 | Pino + Probe 패턴 | 구축 완료 |
| 테스트 | Vitest | 구축 완료 |

### 모바일

| 계층 | 기술 | 상태 |
|------|------|------|
| 프레임워크 | Flutter 3.24+ | 구축 완료 |
| 상태 관리 | GetX 4.6.6 | 구축 완료 |
| HTTP | Dio 5.4.0 | 설정만 완료 |
| 코드 생성 | Freezed + json_serializable | 설정만 완료 |
| 디자인 시스템 | Frame0 Sketch 스타일 | 구축 완료 |
| 모노레포 | Melos | 구축 완료 |

---

## 5. 권장 구현 순서

PRD MVP 기준(`9. MVP 출시 기준`)을 충족하기 위한 우선순위:

### Phase 1: 박스 + WOD 기본 구조

1. 서버: Box, WOD DB 스키마 설계 및 마이그레이션
2. 서버: WOD 등록 API (`POST /wod`) - 텍스트 입력만 우선
3. 서버: WOD 조회 API (`GET /wod/:boxId/:date`) - Base WOD 자동 지정 로직 포함
4. 모바일: API 모델 생성 (Freezed)
5. 모바일: 홈 화면 (오늘의 WOD 표시)
6. 모바일: WOD 등록 화면 (텍스트 입력)

### Phase 2: Base / Personal WOD 분리

7. 서버: Personal WOD 분류 로직 (Base와 비교)
8. 서버: 변경 제안 API
9. 서버: 변경 승인 API
10. 모바일: WOD 상세 화면 (Base vs Personal 표시)
11. 모바일: 변경 제안 UI

### Phase 3: WOD 선택 및 기록

12. 서버: WOD 선택 API
13. 서버: 기록 불변성 보장 로직
14. 모바일: WOD 선택 화면

### Phase 4: 알림 연동

15. 서버: WOD 이벤트별 푸시 알림 발송 (기존 push-alert 모듈 활용)
16. 모바일: FCM 토큰 등록 + 알림 수신

### Phase 5: 이미지 + OCR (선택)

17. 서버: 이미지 업로드 처리
18. 서버: OCR + AI 분석 연동
19. 모바일: 이미지 업로드 UI

---

## 6. MVP 출시 기준 매핑

PRD 9장 기준:

| MVP 기준 | 서버 | 모바일 | 현재 상태 |
|----------|------|--------|-----------|
| 역할 구분 없이 WOD 등록 가능 | Phase 1 | Phase 1 | 미구현 |
| Base / Personal WOD 자동 분리 | Phase 2 | Phase 2 | 미구현 |
| 변경 제안 및 승인 흐름 존재 | Phase 2 | Phase 2 | 미구현 |
| 사용자가 기록할 WOD를 직접 선택 가능 | Phase 3 | Phase 3 | 미구현 |

> Phase 1~3 완료 시 MVP 출시 가능. Phase 4~5는 UX 향상을 위한 추가 구현.
