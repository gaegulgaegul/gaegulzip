# WOWA (오와) PRD 보강 리서치

> 작성일: 2026-02-03
> 목적: PRD의 핵심 가설을 경쟁 분석, 사용자 니즈 검증, 기술 타당성 관점에서 검증

---

## 1. 경쟁사 분석

### 1.1 분석 대상

| 앱 | 유형 | WOD 게시 권한 | 가격 (체육관) | 가격 (선수) |
|----|------|-------------|-------------|------------|
| SugarWOD | WOD 협업 플랫폼 | Programmer 역할만 | $37+/월 | 무료 |
| BTWB | 운동 기록/분석 | Gym Admin만 | 체육관별 상이 | $7.99/월 |
| Wodify | 올인원 체육관 관리 | Coach/Manager/Admin | $79+/월 | 포함 |
| WODBoard | 체육관 관리 | 관리자 | $100+/월 | 포함 |
| TrainHeroic | 코치 프로그래밍 | Coach만 | $75+/월 | 무료 |
| 와드요정 | 개인 기록 다이어리 | 역할 없음 (개인 기록) | 없음 | 무료 |

### 1.2 경쟁사 공통 패턴: 권한 기반 모델

모든 주요 경쟁사가 공유하는 전제:

> "WOD는 코치/관리자가 정하고, 회원은 수행한다"

- WOD 게시는 반드시 특정 권한 필요
- 회원은 읽기/기록만 가능
- WOD 오류 발견 시에도 회원이 직접 수정 불가
- 코치 인증/권한 관리가 운영 비용 발생

### 1.3 SugarWOD 상세 (가장 직접적 경쟁자)

**6단계 역할 계층**: Athlete → Coach → Programmer → Social Admin → Athlete Admin → Account Admin

**주요 사용자 불만**:
- 2024년 다수의 불투명한 가격 인상
- 고객 지원 응답 부재 (수주간 답변 없음)
- 멀티 박스 전환 시 로그아웃/로그인 필요
- 처방되지 않은 WOD 로깅이 불편
- 커스텀 벤치마크 WOD 트래킹 미지원

**WOWA 차별점**: SugarWOD는 Programmer 역할만 WOD 게시 가능. 현장에서 코치가 아닌 회원이 화이트보드 오류를 발견해도 직접 수정 불가.

### 1.4 BTWB 상세

**강점**: 1억 건+ 운동 결과, 업계 최고 수준의 분석/통계

**주요 불만**:
- 모바일 앱 UX 매우 열악 (웹은 우수)
- 운동당 1개 근력 운동만 기록 가능
- 정보 과잉으로 초보자에게 압도적
- 기존 WOD 편집 불가 (삭제 후 재생성만 가능)

### 1.5 Wodify 상세

**강점**: 올인원 (결제, 스케줄링, CRM, 리테일, 웹사이트 빌더)

**주요 불만**:
- 모든 짐 관리 소프트웨어 중 다운타임 가장 잦음
- 개인 데이터 삭제 불가 문제
- 5단계 역할 커스터마이징 불가
- 기능 과잉으로 압도적

### 1.6 와드요정 (한국 시장 유일 경쟁자)

- 크로스핏 소셜 다이어리 앱 (1인 개발, 2024년 1월 iOS 출시)
- WOD "공유"가 아닌 "기록" 중심 — 박스 단위 관리 없음
- AMRAP, For Time, EMOM, Strength 별 기록 시트
- 피드 공유 (팔로우 기반 SNS형)

**WOWA 차별점**: "Box + Date 단위 WOD 관리 + 합의 모델"은 와드요정에 없는 핵심 가치

### 1.7 WOWA 포지셔닝

```
           고가 / 올인원 관리
               Wodify
              WODBoard
                 |
    TrainHeroic  |
                 |
  ── 체육관 중심 ────────────── 개인 중심 ──
                 |
    SugarWOD     |                   BTWB
                 |                   와드요정
                 |
               WOWA ← Box 단위이되, 권한 없이 가벼운 모델
                 |
           무료 / WOD 특화
```

### 1.8 차별화 요약

| 기존 시장의 상식 | WOWA의 전복 |
|-----------------|-------------|
| WOD는 코치가 정한다 | 먼저 등록한 사람이 Base를 만들고, 합의로 확정 |
| 역할 관리가 필요하다 | 역할 관리 자체가 불필요 |
| 시스템이 정답을 판단한다 | 시스템은 중립, 사용자가 선택 |
| WOD는 하나다 (Rx/Scaled) | Base WOD와 Personal WOD가 공존 |

---

## 2. 사용자 니즈 검증

### 2.1 정보 파편화 문제 — 강하게 확인됨

**글로벌 상황**:
- "Wodify, SugarWOD, Zen Planner, Google Sheets를 조합해서 쓰면서 수동 작업에 파묻히고, 분리된 도구들에 좌절" (Exercise.com)
- "결제용 앱, WOD 트래킹용 앱, 스케줄링용 앱, 메시징용 앱, 선수 평가용 앱 — 5개 앱을 오가며 시간 낭비" (FLiiP)

**한국 상황**:
- 카카오톡 단체채팅방, 인스타그램 스토리/피드, 네이버 카페 등 채널 파편화
- 카카오톡: WOD 정보가 대화에 묻혀 검색 불가, 과거 기록 관리 불가능
- 인스타그램: 피드 기반이라 체계적 기록 비교 불가능
- 한국 크로스핏 커뮤니티에서 "매일 와드 올려주는 사이트나 커뮤니티가 있나?" 질문 자체가 현재 방식의 부족함을 입증

> **결론**: 정보 파편화는 글로벌/한국 모두에서 **실재하는 핵심 페인포인트**

### 2.2 WOD 사전 공개 논쟁

**찬성**: 회원이 동작 영상 미리 찾아보고 준비 가능, 프로그래밍에 대한 자신감 표시

**반대**: 체리피킹 가능성, 소규모 박스는 당일 변경이 잦아 사전 공개 비현실적

> WOWA의 "합의 기반 공유"는 이 논쟁의 중간 지점이 될 수 있음 — 코치가 먼저 올리면 자연스럽게 Base가 되고, 현장에서 변경되면 Personal WOD로 기록

### 2.3 코치-회원 간 커뮤니케이션 문제

- "한 코치가 규칙을 느슨하게, 다른 코치가 엄격히 적용하면 불필요한 갈등 유발" (CrossFit RRG)
- 같은 박스 내에서도 코치마다 동작 포커스, 강도, 접근법이 다름
- "소리 내어 읽어야 모두가 같은 페이지에 있게 된다" (CrossFit.com)

### 2.4 기존 앱 미사용 주요 이유

Quora 스레드에서 확인된 이유:
1. **비용 부담**: "이 앱들은 저렴하지 않고, 일부 오너에게는 비용 대비 효과가 낮다"
2. **추가 업무**: 코치가 별도로 앱에 입력해야 하는 작업이 추가됨
3. **간단한 방법 선호**: 일부 코치는 일지나 화이트보드 같은 전통적 방식 선호

> **핵심 발견**: "코치가 입력해야 하는" 워크플로우 자체가 채택 장벽. WOWA의 "누구나 올리고 합의" 모델은 이 부담을 분산

### 2.5 사용자들이 원하는 미충족 니즈

- Apple Watch 연동 (실시간 운동 추적)
- 커스텀 벤치마크 WOD 비교
- 멀티 박스 원활한 전환 (로그아웃 없이)
- 모바일 완전 기능 (데스크톱과 동등)
- 단순한 WOD 입력 (비처방 운동도 쉽게 기록)
- 스케일링 옵션 다양화

### 2.6 합의 모델 검증

**지지 근거**:
- UGC 신뢰도 연구: "소비자는 다른 소비자가 만든 콘텐츠를 마케팅 커뮤니케이션보다 더 신뢰"
- 피트니스 커뮤니티 선례: Reddit r/Fitness의 TheFitness.Wiki (커뮤니티 주도 운동 루틴)
- 탈중앙화 피트니스 트렌드: 중개자 없이 사용자가 직접 참여하는 모델 증가

**도전 요인**:

| 리스크 | 상세 | 심각도 |
|--------|------|--------|
| 안전 책임 | 잘못된 WOD가 합의로 확정될 경우 부상 위험 | 높음 |
| 코치 반발 | "The Coach Holds the Standard" — CrossFit 공식 입장과 충돌 | 높음 |
| Know-It-All 회원 | 경험 많지만 자격 없는 회원이 WOD 주도 위험 | 중간 |
| 합의 도달 어려움 | 다수결이 항상 정확한 WOD를 의미하지는 않음 | 중간 |
| 한국 문화적 저항 | 코치-수강생 관계가 비교적 위계적 | 중간 |

### 2.7 가설 수정 제안

**원래 가설**:
> "역할 기반 권한을 제거하고 커뮤니티 합의로 당일 WOD를 확정하면, 권한 관리 복잡성 없이 정보 파편화를 줄일 수 있다"

**수정 권장**:
> "역할 기반 권한을 **명시적으로 부여하지 않되**, 자연스러운 커뮤니티 합의 메커니즘을 통해 WOD를 확정함으로써, 코치에게 추가 업무 부담을 주지 않으면서 정보 파편화를 줄일 수 있다. 다만 **최소한의 품질 안전장치**(예: 비정상적 중량/볼륨 경고, 신뢰도 점수)가 필요하다."

핵심 변경:
1. "권한 제거"가 아닌 "명시적 권한 부여를 하지 않음" — 코치가 자연스럽게 신뢰를 얻는 구조
2. 품질 안전장치 메커니즘 추가 — 합의된 WOD의 안전성 검증
3. 코치 반발 최소화 — 코치도 동등한 참여자로서 자연스럽게 영향력 행사

---

## 3. 기술 타당성 검토

### 3.1 종합 평가

| 기술 영역 | 타당성 | 구현 난이도 | 월 비용 |
|----------|--------|-----------|--------|
| OCR + AI 화이트보드 인식 | 중간~높음 | 중간 | $1~5 |
| 실시간 알림 시스템 | 높음 | 낮음 | 무료 (FCM) |
| WOD 구조적 비교 | 높음 | 낮음 | 무료 |
| 이미지 업로드/처리 | 높음 | 낮음~중간 | Supabase Free Plan 포함 |
| 기술 스택 적합성 | 높음 | - | - |

### 3.2 OCR + AI 화이트보드 인식

**권장 전략: Multimodal LLM 직접 활용 (전통 OCR 생략)**

2025년 이후 기술 트렌드는 전통적 OCR 파이프라인 대신, 멀티모달 LLM에 이미지를 직접 전달하여 구조화된 JSON을 추출하는 방식으로 전환.

**LLM 비용 비교**:

| 모델 | 이미지당 비용 | 응답 시간 | 구조화 출력 |
|------|-------------|----------|-----------|
| **Gemini 2.5 Flash (권장)** | ~$0.001 | ~1초 | JSON Schema 지원 |
| GPT-4o | ~$0.005 | ~2초 | Structured Output |
| Claude Haiku 3.5 | ~$0.002 | ~1초 | Structured Output |

**비용 추정**: Box 1개, 일 1회 = 월 30건 × $0.001 = **$0.03/월** (Gemini Flash 기준)

**파이프라인**:
```
사진 촬영 → 이미지 압축 → Supabase Storage 업로드 → Multimodal LLM → 구조화 JSON → 사용자 확인/수정
```

**폴백 전략**:
1. Multimodal LLM (Gemini Flash) — 이미지 → JSON 직접 변환
2. Google Cloud Vision OCR → LLM 텍스트 파싱 (2단계)
3. 수동 입력 UI (최종 폴백)

**크로스핏 용어 처리**: LLM 프롬프트에 도메인 특화 약어 사전 포함
```
AMRAP, EMOM, RFT, C&J=Clean & Jerk, DU=Double Under,
T2B=Toes to Bar, HSPU=Handstand Push-up, MU=Muscle-up
```

### 3.3 실시간 알림 시스템

**현재 상태**: `firebase-admin` 이미 설치됨, `/apps/server/src/modules/push-alert/fcm.ts`에 FCM 인프라 구현 완료

**FCM Topic 기반 설계**:

| 시나리오 | Topic | 구독 대상 |
|---------|-------|----------|
| Box WOD 등록 | `box_{boxId}_wod` | Box 전체 회원 |
| Personal WOD 변경 | 개별 토큰 발송 | WOD 원 게시자 |
| 공지사항 | `box_{boxId}_notice` | Box 전체 회원 |

**비용**: FCM 완전 무료 (발송 건수 무제한)

### 3.4 WOD 구조적 비교

**LLM/NLP 불필요** — 구조화된 JSON 필드별 비교로 충분

| 비교 항목 | 동일 | 상이 |
|----------|------|------|
| WOD 타입 | AMRAP == AMRAP | AMRAP != ForTime |
| 시간 | 15분 == 15분 | 15분 != 12분 |
| 운동명 | pull-up == pullup (정규화) | pull-up != push-up |
| 반복 횟수 | 10 == 10 | 10 != 8 |

**운동명 정규화**: 동의어 매핑 (`pullup` → `pull-up`, `c&j` → `clean-and-jerk`)

### 3.5 이미지 업로드/처리 파이프라인

**처리 지연시간 예측**:

| 단계 | 예상 시간 |
|------|----------|
| 이미지 압축 (Flutter) | ~400ms |
| 업로드 (4G/LTE, ~500KB) | 1~3초 |
| LLM API 호출 | 1~3초 |
| JSON 검증 + 응답 | <100ms |
| **총 소요시간** | **3~7초** |

**저장소**: Supabase Free Plan (1GB 스토리지) — 초기 단계 충분

### 3.6 기술 스택 적합성

현재 스택과의 호환성:

| 기술 요소 | 현재 스택 | 호환성 |
|----------|----------|--------|
| FCM 푸시 알림 | firebase-admin 설치됨 | 완벽 |
| 이미지 저장 | Supabase 사용 중 | 완벽 |
| LLM API 호출 | axios 설치됨 | 완벽 |
| JSON 검증 | zod 설치됨 | 완벽 |
| DB 저장 | Drizzle ORM + PostgreSQL | 완벽 |

**추가 필요 패키지**:
- Server: `@google/generative-ai` (Gemini API)
- Flutter: `image_picker`, `flutter_image_compress`, `firebase_messaging`

**핵심 결론**: 현재 기술 스택 변경 없이 모든 기능 구현 가능. 초기 월 운영비 $5 이하.

---

## 4. 종합 결론

### 4.1 가설 검증 요약

| 가설 요소 | 검증 결과 | 신뢰도 |
|-----------|----------|--------|
| 정보 파편화가 실재하는 문제인가? | **강하게 확인** | 높음 |
| 역할 기반 권한이 채택 장벽인가? | **부분 확인** — 비용이 더 큰 요인 | 중간 |
| 합의 모델이 파편화를 해결할 수 있는가? | **조건부 가능** — 품질 통제 필수 | 중간 |
| 코치 권위 제거가 수용 가능한가? | **높은 리스크** — 프레이밍 변경 필요 | 낮음 |
| 기술적으로 구현 가능한가? | **높음** — 현재 스택으로 충분 | 높음 |

### 4.2 PRD 보강 권장사항

1. **핵심 설계 원칙 수정**: "권한 제거"가 아닌 "명시적 권한 부여 불필요" 프레이밍
2. **안전장치 추가**: 비정상적 중량/볼륨 경고, 운동 화이트리스트 검증
3. **신뢰도 시스템 로드맵**: 향후 확장 방향에서 우선순위 상향
4. **코치 채택 전략**: 코치가 먼저 등록하면 자연스럽게 Base가 되는 시나리오 강조
5. **WOD 입력 UX**: 화이트보드 사진 → AI 구조화 (경쟁사 없는 차별 기능)
6. **한국 시장 집중**: 와드요정이 유일한 한국 경쟁자이나 Box 단위 관리 미지원

### 4.3 잠재적 리스크와 완화 방안

| 리스크 | 완화 방안 |
|--------|----------|
| 코치 권위 상실 우려 | 코치가 먼저 등록 → 자연스럽게 Base. "도우미" 프레이밍 |
| 악의적/스팸 WOD | Box 구성원만 등록 가능, 신뢰도 시스템 |
| Base 선점 경쟁 | 변경 제안/승인으로 합의 도달 |
| 손글씨 인식 실패 | Multimodal LLM + 수동 입력 폴백 |
| 안전 사고 | 비정상 중량/볼륨 경고, 운동 화이트리스트 |

---

## 출처

### 경쟁사 분석
- [SugarWOD 공식](https://www.sugarwod.com/)
- [SugarWOD 가격](https://www.sugarwod.com/pricing/)
- [SugarWOD 권한 관리](https://help.sugarwod.com/hc/en-us/articles/360037792334)
- [BTWB 공식](https://beyondthewhiteboard.com/)
- [BTWB 리뷰 (Garage Gym Reviews)](https://www.garagegymreviews.com/beyond-the-whiteboard-review)
- [Wodify 공식](https://www.wodify.com/)
- [Wodify 역할/권한](https://help.wodify.com/hc/en-us/articles/360060499674)
- [Wodify Capterra 리뷰](https://www.capterra.com/p/159663/Wodify/reviews/)
- [WODBoard](https://www.wodboard.com/features)
- [TrainHeroic](https://www.trainheroic.com/)
- [와드요정 App Store](https://apps.apple.com/kr/app/%EC%99%80%EB%93%9C%EC%9A%94%EC%A0%95/id6476688386)
- [크로스핏 WOD 앱 비교 (FitBudd)](https://www.fitbudd.com/post/8-best-apps-for-crossfit-box-owners-in-2026)

### 사용자 니즈 검증
- [Exercise.com - Best Apps for CrossFit Box Owners](https://www.exercise.com/grow/best-apps-for-crossfit-box-owners/)
- [Quora - Why don't most CrossFit gyms preload WODs?](https://www.quora.com/Why-dont-most-crossfit-gyms-preload-their-WODs-into-apps-such-as-BTWB-or-Wodify)
- [CrossFit.com - Whiteboard](https://www.crossfit.com/pro-coach/crossfit-roots-whiteboard)
- [CrossFit.com - The Coach Holds the Standard](https://www.crossfit.com/pro-coach/the-coach-holds-the-standard)
- [CrossFit RRG - Communicate Gym Policies](https://crossfitrrg.com/how-do-you-communicate-gym-policies-without-upsetting-members/)
- [JustUseApp - SugarWOD Reviews](https://justuseapp.com/en/app/665516348/sugarwod/reviews)
- [Trustpilot - Wodify Reviews](https://www.trustpilot.com/review/wodify.store)
- [FLiiP - CrossFit Gym Management Software](https://myfliip.com/blog/crossfit-gym-management-software/)
- [TheFitness.Wiki](https://thefitness.wiki/)
- [ResearchGate - Consumer Digital Trust in UGC](https://www.researchgate.net/publication/375751639)
- [ResearchGate - Trust-Based Consensus Model](https://www.researchgate.net/publication/273766862)

### 기술 타당성
- [Document Data Extraction: LLMs vs OCRs](https://www.vellum.ai/blog/document-data-extraction-llms-vs-ocrs)
- [How to Use Gemini for OCR](https://blog.roboflow.com/how-to-use-gemini-for-ocr/)
- [Gemini API Pricing](https://ai.google.dev/gemini-api/docs/pricing)
- [FCM Topic Messaging](https://firebase.google.com/docs/cloud-messaging/topic-messaging)
- [flutter_image_compress](https://pub.dev/packages/flutter_image_compress)
- [Supabase Storage](https://supabase.com/docs/reference/dart/storage-from-upload)
