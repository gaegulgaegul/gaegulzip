# Mobile CTO Review: wowa-box (Rebase 후 최종 검증)

**Feature**: wowa-box (박스 관리 기능 개선)
**Platform**: Mobile (Flutter/GetX)
**Reviewer**: CTO
**Date**: 2026-02-10
**PR**: #13 (main에 squash merge 완료)
**Branch**: feature/wowa-box (rebase 완료)

---

## Rebase 후 상태 요약

### 브랜치 상태
- ✅ PR #13 main에 squash merge 완료
- ✅ feature/wowa-box rebase 완료 (main 최신 반영)
- ✅ Working tree clean (충돌 없음)

### 아키텍처 변경 (main 브랜치 반영)
**packages/api 패키지 제거**:
- ❌ 제거: `apps/mobile/packages/api/`
- ✅ 이동: 모델 → `apps/wowa/lib/app/data/models/`
- ✅ 이동: 클라이언트 → `apps/wowa/lib/app/data/clients/`
- ✅ Import 변경: `package:api/api.dart` → 상대 경로 import

**Rebase 작업 내용**:
- packages/api 의존성 제거
- import 경로 모두 상대 경로로 변경
- 모델/클라이언트 파일 위치 이동 완료

---

## 검증 결과

### 정적 분석 결과
**Flutter analyze 실행 결과**:
- ⚠️ **41 issues found**
- ❌ Errors: 28건 (SketchDesignTokens 미import)
- ⚠️ Warnings: 1건 (unused_local_variable)
- ℹ️ Info: 12건 (constant_identifier_names, use_super_parameters)

**주요 에러 원인**: `box_search_view.dart`에서 `SketchDesignTokens` 사용했지만 core 패키지 import 누락

---

## ❌ Critical Issue: SketchDesignTokens Import 누락

### 이슈 발견

**파일**: `apps/mobile/apps/wowa/lib/app/modules/box/views/box_search_view.dart`

**현재 Import** (Line 1-6):
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/box/box_model.dart';
import 'package:design_system/design_system.dart';  // ⚠️ SketchDesignTokens export 안 함
import '../controllers/box_search_controller.dart';
import '../../../routes/app_routes.dart';
```

**사용 위치 (28곳)**:
- Line 54: `SketchDesignTokens.base500` (prefixIcon color)
- Line 60: `SketchDesignTokens.base500` (suffixIcon color)
- Line 110: `SketchDesignTokens.base300` (empty state icon)
- Line 116: `SketchDesignTokens.fontSizeBase`
- Line 117: `SketchDesignTokens.base500`
- ... (28건 전체)

### 원인 분석

**SketchDesignTokens 위치**: `apps/mobile/packages/core/lib/sketch_design_tokens.dart`

**core 패키지 Export** (core/lib/core.dart):
```dart
export 'sketch_design_tokens.dart';  // ✅ Export됨
```

**design_system 패키지 Export** (design_system/lib/design_system.dart):
```dart
export 'src/widgets/sketch_button.dart';
export 'src/widgets/sketch_card.dart';
// ... 위젯들만 export
// ❌ SketchDesignTokens는 export 안 함
```

**판정**: box_search_view.dart에서 `package:core/core.dart` import 누락

---

## 🔧 수정 방안

### box_search_view.dart Import 추가

**수정 전**:
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/box/box_model.dart';
import 'package:design_system/design_system.dart';
import '../controllers/box_search_controller.dart';
import '../../../routes/app_routes.dart';
```

**수정 후**:
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';  // ✅ SketchDesignTokens import
import 'package:design_system/design_system.dart';
import '../../../data/models/box/box_model.dart';
import '../controllers/box_search_controller.dart';
import '../../../routes/app_routes.dart';
```

**영향 범위**: box_search_view.dart만 수정하면 28건 에러 모두 해결

---

## 패키지 구조 검증

### 모델 파일 (apps/wowa/lib/app/data/models/box/)

**파일 목록**:
```
✅ box_model.dart (Freezed)
✅ box_model.freezed.dart
✅ box_model.g.dart
✅ box_search_response.dart (Freezed)
✅ box_search_response.freezed.dart
✅ box_search_response.g.dart
✅ create_box_request.dart (Freezed)
✅ create_box_request.freezed.dart
✅ create_box_request.g.dart
✅ box_create_response.dart (Freezed)
✅ box_create_response.freezed.dart
✅ box_create_response.g.dart
✅ membership_model.dart (Freezed)
✅ membership_model.freezed.dart
✅ membership_model.g.dart
✅ box_member_model.dart (Freezed)
✅ box_member_model.freezed.dart
✅ box_member_model.g.dart
```

**검증**: ✅ packages/api에서 apps/wowa/lib/app/data/models/box/로 이동 완료

---

### API 클라이언트 (apps/wowa/lib/app/data/clients/)

**파일**: `box_api_client.dart`

**Import 확인**:
```dart
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/box/box_model.dart';                    // ✅ 상대 경로
import '../models/box/box_search_response.dart';         // ✅ 상대 경로
import '../models/box/create_box_request.dart';          // ✅ 상대 경로
import '../models/box/box_create_response.dart';         // ✅ 상대 경로
import '../models/box/membership_model.dart';            // ✅ 상대 경로
import '../models/box/box_member_model.dart';            // ✅ 상대 경로
```

**검증**: ✅ packages/api에서 apps/wowa/lib/app/data/clients/로 이동 완료, import 경로 정상

---

### Controller Import 확인

**box_search_controller.dart** (Line 1-6):
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';                         // ✅ Core import
import 'package:design_system/design_system.dart';       // ✅ Design System import
import '../../../data/repositories/box_repository.dart';  // ✅ 상대 경로
import '../../../data/models/box/box_model.dart';        // ✅ 상대 경로
```

**검증**: ✅ import 경로 정상

---

## GetX 패턴 검증

### Controller: BoxSearchController

**반응형 상태 (.obs)**:
```dart
final keyword = ''.obs;                      // ✅ 통합 검색 키워드
final isLoading = false.obs;                 // ✅ 로딩 상태
final searchResults = <BoxModel>[].obs;      // ✅ 검색 결과
final currentBox = Rxn<BoxModel>();          // ✅ 현재 박스 (nullable)
final errorMessage = ''.obs;                 // ✅ 에러 메시지
```

**Debounce 구현** (Line 53-57):
```dart
_debounceWorker = debounce(
  keyword,
  (_) => searchBoxes(),
  time: const Duration(milliseconds: 300),
);
```

**검증**: ✅ 300ms debounce 정상, design-spec.md 준수

---

### CodeRabbit Issue 수정 확인: firstWhere orElse

**이슈**: firstWhere가 요소를 찾지 못하면 StateError 발생

**수정 후** (box_search_controller.dart Line 165-168):
```dart
final joinedBox = searchResults.firstWhere(
  (box) => box.id == boxId,
  orElse: () => throw Exception('가입한 박스를 찾을 수 없습니다'),
);
```

**검증**: ✅ **FIXED**
- orElse로 방어 코드 추가
- StateError 대신 명확한 Exception 던짐
- API 실패 시 try-catch로 이동하므로 크래시 방지

---

## API Contract 검증 (Mobile ↔ Server)

### 1. 박스 검색
**Endpoint**: `GET /boxes/search?keyword=...`
- ✅ Client: `BoxApiClient.searchBoxes(String keyword)` (Line 36-44)
- ✅ Response: `BoxSearchResponse.fromJson()` → `List<BoxModel>`
- ✅ BoxModel 필드: id, name, region, description, memberCount, joinedAt

### 2. 박스 생성
**Endpoint**: `POST /boxes`
- ✅ Client: `BoxApiClient.createBox(CreateBoxRequest)` (Line 54-60)
- ✅ Request: `{ name, region, description }`
- ✅ Response: `BoxCreateResponse` → `{ box, membership, previousBoxId }`

### 3. 박스 가입
**Endpoint**: `POST /boxes/:boxId/join`
- ✅ Client: `BoxApiClient.joinBox(int boxId)` (Line 70-73)
- ⚠️ Response: Server는 `{ membership, previousBoxId }` 반환하지만, Mobile은 `membership`만 파싱

**검증**: ✅ API Contract 유지됨 (previousBoxId 정보 손실은 UX 개선 기회이지만 기능 동작에 문제 없음)

---

## Design Spec 준수 검증

### 레이아웃 계층
- ✅ Scaffold → AppBar + Body + FAB
- ✅ SafeArea 사용
- ✅ Column → SketchInput + Expanded(검색 결과)
- ✅ FloatingActionButton: SketchButton (primary)

### 색상 팔레트 (사용 예정이었지만 import 누락)
- ⚠️ SketchDesignTokens.error (에러 색상) — import 누락
- ⚠️ SketchDesignTokens.success (성공 색상) — controller에서 사용, import 정상
- ⚠️ SketchDesignTokens.base500 (아이콘 색상) — import 누락
- ⚠️ SketchDesignTokens.base700 (보조 텍스트) — import 누락

### 타이포그래피
- ⚠️ fontSizeLg (18px) — 카드 제목 — import 누락
- ⚠️ fontSizeBase (16px) — 입력 필드, 본문 — import 누락
- ⚠️ fontSizeSm (14px) — 지역, 설명 — import 누락
- ⚠️ fontSizeXs (12px) — 멤버 수 — import 누락

**검증**: ⚠️ design-spec.md 준수하려고 했으나 import 누락으로 에러 발생

---

## const 최적화 검증

**box_search_view.dart**:
```dart
const SizedBox(height: 16),                                    // ✅
const Icon(Icons.search, size: 64, ...),                       // ⚠️ color에 SketchDesignTokens 사용 (const 불가)
const Center(child: CircularProgressIndicator()),             // ✅
const SizedBox(height: 8),                                    // ✅
const EdgeInsets.all(16),                                     // ✅
const EdgeInsets.only(bottom: 12),                            // ✅
```

**평가**: ✅ const 최적화 적절히 적용 (SketchDesignTokens는 static const이므로 const 생성자 사용 가능)

---

## Rebase 후 Import 경로 변경 확인

### Before (packages/api 사용)
```dart
import 'package:api/api.dart';  // BoxModel, BoxSearchResponse, etc.
```

### After (상대 경로)
```dart
import '../../../data/models/box/box_model.dart';
import '../../../data/models/box/box_search_response.dart';
import '../../../data/clients/box_api_client.dart';
```

**검증 결과**:
- ✅ Controller: box_search_controller.dart — import 경로 정상
- ✅ Repository: box_repository.dart — import 경로 정상
- ✅ API Client: box_api_client.dart — import 경로 정상
- ❌ View: box_search_view.dart — core 패키지 import 누락 (SketchDesignTokens)

---

## Quality Scores (Import 수정 전)

| 항목 | 점수 | 평가 |
|------|------|------|
| **GetX 패턴** | 9.5/10 | Controller/View/Binding 완벽 분리, .obs 사용 올바름 |
| **API 모델** | 9.5/10 | Freezed 완벽 활용, json_serializable 통합 |
| **API Client** | 9.0/10 | JSDoc 충실, previousBoxId 파싱 누락 |
| **Controller-View 연결** | 9.0/10 | 실제 데이터 바인딩 확인, orElse 방어 코드 추가 |
| **Design Spec 준수** | 7.0/10 | ⚠️ import 누락으로 컴파일 에러, 의도는 올바름 |
| **에러 처리** | 9.5/10 | NetworkException 명시적 처리, 스낵바/모달 적절 |
| **const 최적화** | 9.0/10 | 정적 위젯 const 사용, Obx 범위 최소화 |
| **성능** | 9.5/10 | Debounce 300ms, ListView 최적화 |
| **Import 경로** | 8.5/10 | ⚠️ core 패키지 import 1건 누락 |

**종합 점수**: **8.8/10** (우수, import 수정 후 9.3/10 예상)

---

## 최종 승인

### 승인 상태: ⚠️ **CONDITIONAL APPROVAL**

**필수 조건** (수정 필요):
1. ❌ **box_search_view.dart — `package:core/core.dart` import 추가** (Critical)
   - 28건 SketchDesignTokens 에러 해결
   - 컴파일 성공 필수

**권장 사항** (선택):
1. 🟡 box_api_client.dart — JoinBoxResponse 모델 추가하여 previousBoxId 활용 (UX 개선)
2. 🟢 types.ts JSDoc 주석 추가 (문서화)

**Rebase 후 확인 사항**:
- ✅ packages/api 의존성 제거 완료
- ✅ import 경로 대부분 상대 경로로 변경
- ✅ 모델/클라이언트 파일 위치 이동 완료
- ❌ box_search_view.dart import 1건 누락

---

## 다음 단계

### 즉시 수정 필요
1. **box_search_view.dart Line 1-6 수정**:
   ```dart
   import 'package:core/core.dart';  // ✅ 추가
   ```

2. **flutter analyze 재실행**:
   ```bash
   cd apps/mobile/apps/wowa && flutter analyze
   ```
   - 예상: 28건 error 해결 → 13 info + 1 warning 남음 (허용 가능)

### 승인 후
3. ✅ Mobile 검증 완료
4. 🔜 Independent Reviewer 검증
5. 🔜 문서 생성 (DONE.md)

---

**Reviewer**: CTO
**Date**: 2026-02-10 (Rebase 후 최종 검증)
**Signature**: ⚠️ Conditional Approval (import 수정 필수)

---

## Appendix: Mobile 아키텍처 변경 이력

### packages/api 패키지 제거 (main 브랜치)

**Before**:
```
apps/mobile/
└── packages/
    ├── api/                    # ❌ 제거됨
    │   ├── lib/
    │   │   ├── api.dart
    │   │   ├── src/
    │   │   │   ├── models/
    │   │   │   └── clients/
    └── core/
    └── design_system/
```

**After**:
```
apps/mobile/
├── packages/
│   ├── core/
│   └── design_system/
└── apps/wowa/
    └── lib/app/data/
        ├── models/            # ✅ 모델 이동
        │   └── box/
        └── clients/           # ✅ 클라이언트 이동
            └── box_api_client.dart
```

**변경 이유**: SDK 패키지는 재사용 가능한 기능만, 앱 전용 기능은 앱 내부에서 관리 (CLAUDE.md SDK Convention 준수)
