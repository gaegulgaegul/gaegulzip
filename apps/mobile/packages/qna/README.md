# QnA SDK Package

멀티테넌트 Flutter 앱을 위한 재사용 가능한 QnA 기능 SDK입니다.

## 특징

- ✅ UI 포함 (질문 작성 화면)
- ✅ GetX 상태 관리
- ✅ Freezed API 모델
- ✅ appCode 파라미터화 (앱별 GitHub 레포지토리 매핑)
- ✅ 에러 처리 완비

## 통합 가이드

### 1. 의존성 추가

```yaml
dependencies:
  qna:
    path: ../../packages/qna
  core:
    path: ../../packages/core
  design_system:
    path: ../../packages/design_system
```

### 2. melos bootstrap

```bash
cd apps/mobile
melos bootstrap
```

### 3. 라우트 등록

```dart
import 'package:get/get.dart';
import 'package:qna/qna.dart';

GetPage(
  name: '/qna',
  page: () => const QnaSubmitView(),
  binding: QnaBinding(appCode: 'your-app'), // 필수: appCode 주입
  transition: Transition.cupertino,
)
```

### 4. 화면 이동

```dart
Get.toNamed('/qna');
```

## appCode 파라미터

`appCode`는 **필수** 파라미터입니다. 각 앱의 질문이 독립적인 GitHub 레포지토리에 등록되도록 보장합니다.

**예시**:
- wowa 앱: `QnaBinding(appCode: 'wowa')`
- other-app: `QnaBinding(appCode: 'other-app')`

**누락 시**: 컴파일 오류 발생

## 의존성 그래프

```
core (NetworkException, Logger)
  ↑
design_system (SketchButton, SketchInput, SketchModal)
  ↑
qna (SDK)
  ↑
your-app
```

## 라이선스

Private — gaegulzip 내부 사용
