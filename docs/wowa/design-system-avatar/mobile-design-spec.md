# UI/UX 디자인 명세: SketchAvatar 스케치 스타일 개선

## 개요

SketchAvatar 위젯의 테두리와 플레이스홀더를 Frame0 스케치 스타일로 개선하여 다른 디자인 시스템 컴포넌트(SketchButton, SketchContainer 등)와 시각적 일관성을 확보한다. 손으로 그린 듯한 불규칙한 테두리 질감과 간결한 사람 실루엣 아이콘으로 스케치 미학을 강화한다.

## 화면 구조

### Widget: SketchAvatar

#### 레이아웃 계층

```
SketchAvatar
└── GestureDetector (onTap이 있는 경우만)
    └── Stack
        ├── CustomPaint (스케치 테두리)
        │   └── SketchCirclePainter (원형)
        │       또는 SketchPainter (사각형)
        │
        ├── ClipPath (스케치 경로로 클리핑)
        │   └── 컨텐츠 (우선순위대로)
        │       ├── Image.network (imageUrl이 있으면)
        │       ├── Image.asset (assetPath가 있으면)
        │       ├── Container + Text (initials가 있으면)
        │       └── 플레이스홀더 (모두 없으면)
        │
        └── (테두리는 CustomPaint에서 그림)
```

#### 위젯 상세

**원형 테두리 (shape: SketchAvatarShape.circle)**

- Painter: `SketchCirclePainter`
- 렌더링: 불규칙한 원형 테두리 (2중 선)
- 속성:
  - `fillColor: Colors.transparent` (채우기 없음)
  - `borderColor`: 테마 또는 `borderColor` prop
  - `strokeWidth`: 크기별 기본값 (아래 표 참조)
  - `roughness: 0.8` (기본값 — 손그림 흔들림)
  - `seed`: Avatar 해시값 기반 (일관된 랜덤성)
  - `segments: 16` (부드러운 곡선)

**사각형 테두리 (shape: SketchAvatarShape.roundedSquare)**

- Painter: `SketchPainter`
- 렌더링: 불규칙한 둥근 사각형 테두리
- 속성:
  - `fillColor: Colors.transparent` (채우기 없음)
  - `borderColor`: 테마 또는 `borderColor` prop
  - `strokeWidth`: 크기별 기본값
  - `roughness: 0.8`
  - `bowing: 0.5` (직선 휘어짐)
  - `seed`: Avatar 해시값 기반
  - `borderRadius: 6.0` (둥근 모서리)
  - `showBorder: true`

**ClipPath**

- 스케치 테두리와 동일한 경로로 내부 컨텐츠 클리핑
- 원형: `SketchCirclePainter`가 생성한 경로
- 사각형: `SketchPainter`가 생성한 경로
- 이미지/이니셜이 테두리 밖으로 삐져나가지 않도록 보장

**플레이스홀더 (개선된 디자인)**

```dart
Container(
  width: size.size,
  height: size.size,
  color: backgroundColor ?? sketchTheme?.fillColor,
  child: Center(
    child: Icon(
      placeholderIcon ?? Icons.person, // X-cross 제거, person 아이콘만
      size: _calculateIconSize(), // 아바타 크기의 40%
      color: iconColor ?? sketchTheme?.iconColor,
    ),
  ),
)
```

- **변경 사항**:
  - X-cross 패턴 제거 (`SketchImagePlaceholder` 사용 중단)
  - `Icons.person` (filled 버전) 단독 사용
  - 아이콘 크기: 아바타 크기의 40% (기존 30%보다 크게)
  - 배경: 테마 `fillColor` 또는 `backgroundColor` prop
  - 아이콘 색상: 테마 `iconColor` 또는 `iconColor` prop

**이니셜 표시**

```dart
Container(
  width: size.size,
  height: size.size,
  color: backgroundColor ?? sketchTheme?.fillColor,
  child: Center(
    child: Text(
      initials!,
      style: TextStyle(
        fontFamily: SketchDesignTokens.fontFamilyHand,
        fontFamilyFallback: SketchDesignTokens.fontFamilyHandFallback,
        fontSize: config.fontSize,
        color: textColor ?? sketchTheme?.textColor,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
)
```

**이미지 표시**

```dart
Image.network(
  imageUrl!,
  width: size.size,
  height: size.size,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return _buildPlaceholder();
  },
)
```

## 크기별 시각적 사양

### SketchAvatarSize 속성

| Size | 크기(px) | borderWidth | fontSize (이니셜) | iconSize (플레이스홀더) | roughness | seed 생성 |
|------|---------|-------------|------------------|----------------------|-----------|----------|
| xs | 24 | 1.0 | 10 | 9.6 (40%) | 0.8 | hashCode % 10000 |
| sm | 32 | 1.5 | 14 | 12.8 (40%) | 0.8 | hashCode % 10000 |
| md | 40 | 2.0 | 18 | 16 (40%) | 0.8 | hashCode % 10000 |
| lg | 56 | 2.0 | 20 | 22.4 (40%) | 0.8 | hashCode % 10000 |
| xl | 80 | 2.5 | 28 | 32 (40%) | 0.8 | hashCode % 10000 |
| xxl | 120 | 3.0 | 36 | 48 (40%) | 0.8 | hashCode % 10000 |

### seed 생성 전략

```dart
// 이미지 URL 또는 이니셜 기반 일관된 seed 생성
int _generateSeed() {
  if (imageUrl != null && imageUrl!.isNotEmpty) {
    return imageUrl.hashCode.abs() % 10000;
  }
  if (initials != null && initials!.isNotEmpty) {
    return initials.hashCode.abs() % 10000;
  }
  // 플레이스홀더는 항상 동일한 seed (0)
  return 0;
}
```

## 색상 팔레트

### 라이트 모드

**테두리 색상**:
- 기본: `SketchDesignTokens.base900` (#343434) — Frame0 스타일 어두운 테두리
- `borderColor` prop으로 오버라이드 가능
- `showBorder: false`로 비활성화 가능

**플레이스홀더**:
- 배경: `SketchThemeExtension.fillColor` (라이트: #FAF8F5 크림색)
- 아이콘: `SketchThemeExtension.iconColor` (#767676 — base600)

**이니셜**:
- 배경: `backgroundColor` prop 또는 `SketchDesignTokens.accentSecondaryLight`
- 텍스트: `textColor` prop 또는 `Colors.white`

### 다크 모드

**테두리 색상**:
- 기본: `SketchThemeExtension.dark().borderColor` (#5E5E5E — base700)
- 다크 모드에서는 밝은 테두리 (라이트 모드보다 밝음)

**플레이스홀더**:
- 배경: `SketchThemeExtension.dark().fillColor` (#1A1D29 — 네이비 배경)
- 아이콘: `SketchThemeExtension.dark().iconColor` (#B5B5B5 — base400)

**이니셜**:
- 배경: `backgroundColor` prop 또는 어두운 배경색
- 텍스트: `textColor` prop 또는 `SketchThemeExtension.dark().textColor` (#F5F5F5)

### 참조 이미지 색상 분석

**img_19.png (다크 배경)**:
- 배경: 검은색 (#000000 또는 매우 어두운 색)
- 테두리: 흰색/밝은 회색 (2중 선, 불규칙)
- 아이콘: 흰색 사람 실루엣 (person 아이콘)

**img_20.png (라이트 배경)**:
- 배경: 흰색/밝은 회색 (#FFFFFF 또는 매우 밝은 색)
- 테두리: 검은색 (2중 선, 불규칙)
- 아이콘: 검은색 사람 실루엣 (person 아이콘)

## 타이포그래피

### 이니셜 표시 폰트

- **Font Family**: `SketchDesignTokens.fontFamilyHand` ("Kalam")
- **Fallback**: `SketchDesignTokens.fontFamilyHandFallback` (["Comic Sans MS", "Marker Felt", "sans-serif"])
- **Font Weight**: `FontWeight.w600` (semibold) — 손글씨 느낌 강조
- **Font Size**: 크기별 상이 (위 표 참조)
- **색상**: `textColor` prop 또는 테마 `textColor`

### 아이콘

- **아이콘**: `Icons.person` (filled 버전)
- **크기**: 아바타 크기의 40%
- **색상**: `iconColor` prop 또는 테마 `iconColor`

## 스페이싱 시스템

### 아바타 내부 스페이싱

- **패딩 없음**: 이미지, 이니셜, 플레이스홀더 모두 full-bleed
- **중앙 정렬**: 이니셜과 아이콘은 `Center` 위젯으로 중앙 배치

### 컴포넌트 간 스페이싱

- **리스트 아이템**: `ListTile.leading`에서 자동 스페이싱 (12dp)
- **그리드**: `SizedBox` 또는 `Padding`으로 8dp/16dp 간격
- **인라인**: `Row`에서 8dp 간격 권장

## 테두리 스타일

### 원형 (SketchAvatarShape.circle)

- **Painter**: `SketchCirclePainter`
- **특성**:
  - 2중 선으로 손그림 질감 강조
  - 불규칙한 흔들림 (roughness: 0.8)
  - 세그먼트 기반 곡선 (segments: 16)
  - seed로 일관된 랜덤성 보장
- **사용 사례**: 프로필 이미지, 사용자 아바타 (대부분의 경우)

### 사각형 (SketchAvatarShape.roundedSquare)

- **Painter**: `SketchPainter`
- **특성**:
  - 손으로 그린 둥근 사각형
  - 불규칙한 테두리 (roughness: 0.8)
  - 직선 휘어짐 (bowing: 0.5)
  - 둥근 모서리 (borderRadius: 6.0)
- **사용 사례**: 그룹 아바타, 브랜드 로고, 특별한 강조

### 테두리 비활성화

- **속성**: `showBorder: false`
- **사용 사례**: 중첩된 레이아웃, 배경과 동일한 색상, 미니멀한 디자인

## 인터랙션 상태

### 탭 가능 상태 (onTap != null)

- **Default**: 아바타 표시 (테두리 + 컨텐츠)
- **Pressed**: Flutter 기본 ripple 없음 (GestureDetector 사용)
- **시각적 피드백**: 별도 피드백 없음 (단순 탭 동작)
- **사용 사례**: 프로필 화면 이동, 상세 정보 표시

### 비탭 상태 (onTap == null)

- **표시만**: 시각적 요소로만 작동
- **사용 사례**: 리스트 아이템, 정보 표시

### 로딩 상태 (이미지 로딩 중)

- **표시**: 플레이스홀더 (사람 아이콘)
- **애니메이션 없음**: 정적 플레이스홀더 표시
- **전환**: 이미지 로드 완료 시 페이드인 (Flutter 기본 동작)

### 에러 상태 (이미지 로드 실패)

- **표시**: 플레이스홀더 (사람 아이콘)
- **재시도 없음**: 자동 재시도 없음, 플레이스홀더로 대체
- **사용 사례**: 네트워크 오류, 잘못된 URL

## 애니메이션

### 이미지 로드 애니메이션

- **페이드인**: Flutter Image 위젯 기본 동작
- **Duration**: 약 300ms (Flutter 기본값)
- **Curve**: `Curves.easeIn`

### 테두리 애니메이션

- **없음**: 테두리는 정적 (seed 기반 일관된 형태)
- **seed 변경 시**: 다른 스케치 패턴으로 리렌더링

## 반응형 레이아웃

### 크기 적응

- **고정 크기**: `SketchAvatarSize` enum 사용 (반응형 스케일링 없음)
- **크기 선택**:
  - xs (24px): 인라인 아이콘, 작은 배지
  - sm (32px): 채팅 목록, 댓글
  - md (40px): 기본 리스트 아이템
  - lg (56px): 프로필 헤더, 카드
  - xl (80px): 대형 프로필 페이지
  - xxl (120px): 프로필 편집, 초기 화면

### 터치 영역

- **최소 크기**: 24x24dp (xs)
- **권장 크기**: 40x40dp 이상 (md+)
- **탭 가능 영역**: 아바타 전체 크기

## 접근성 (Accessibility)

### 의미 전달

- **Semantics label**: "사용자 아바타" (이미지 있는 경우)
- **Semantics label**: "프로필 플레이스홀더" (플레이스홀더 표시 시)
- **Button role**: `onTap`이 있으면 탭 가능 요소로 인식

### 색상 대비

- **라이트 모드**:
  - 테두리 (base900) vs 배경 (fillColor): 충분한 대비
  - 아이콘 (base600) vs 배경 (fillColor): 3:1 이상
- **다크 모드**:
  - 테두리 (base700) vs 배경 (fillColor): 충분한 대비
  - 아이콘 (base400) vs 배경 (fillColor): 3:1 이상

### 스크린 리더 지원

```dart
Semantics(
  label: _getSemanticsLabel(),
  button: onTap != null,
  child: avatar,
)

String _getSemanticsLabel() {
  if (imageUrl != null || assetPath != null) {
    return '사용자 아바타';
  }
  if (initials != null) {
    return '$initials 아바타';
  }
  return '프로필 플레이스홀더';
}
```

## Design System 컴포넌트 활용

### 재사용 컴포넌트

**SketchCirclePainter**:
- 위치: `packages/design_system/lib/src/painters/sketch_circle_painter.dart`
- 용도: 원형 아바타 테두리 렌더링
- 속성: `fillColor`, `borderColor`, `strokeWidth`, `roughness`, `seed`, `segments`

**SketchPainter**:
- 위치: `packages/design_system/lib/src/painters/sketch_painter.dart`
- 용도: 사각형 아바타 테두리 렌더링
- 속성: `fillColor`, `borderColor`, `strokeWidth`, `roughness`, `bowing`, `seed`, `borderRadius`

### 새로운 컴포넌트 필요 여부

- **없음**: 기존 `SketchCirclePainter`, `SketchPainter`로 충분
- **수정 필요**: 없음 (현재 API로 모든 요구사항 충족)

### 제거할 의존성

- **SketchImagePlaceholder**: 플레이스홀더에서 사용 중단
- 새로운 플레이스홀더는 `Container + Icon`으로 직접 구현

## API 호환성

### 기존 API 유지

모든 기존 프로퍼티와 메서드는 그대로 유지:

```dart
class SketchAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? assetPath;
  final String? initials;
  final IconData? placeholderIcon; // 기본값을 Icons.person으로 변경
  final SketchAvatarSize size;
  final SketchAvatarShape shape;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? strokeWidth;
  final VoidCallback? onTap;
  final bool showBorder;

  // 기존 생성자 유지
  const SketchAvatar({...});

  // 기존 static 메서드 유지
  static String getInitials(String? name) {...}
}
```

### 변경 사항

1. **테두리 렌더링**:
   - `Border.all()` 제거
   - `CustomPaint` + `SketchCirclePainter` / `SketchPainter` 사용

2. **플레이스홀더**:
   - `SketchImagePlaceholder` 제거
   - `Container + Icon(Icons.person)` 직접 구현
   - 아이콘 크기: 30% → 40%

3. **기본 아이콘**:
   - `Icons.person_outline` → `Icons.person` (filled 버전)

### 마이그레이션

- **호환성**: 100% 하위 호환
- **기존 코드 수정 불필요**: 모든 기존 사용법 동일하게 작동
- **새로운 시각적 효과**: 자동으로 스케치 스타일 적용

## 구현 우선순위

1. **테두리 스케치 스타일 적용** (High):
   - `SketchCirclePainter` 통합 (원형)
   - `SketchPainter` 통합 (사각형)
   - seed 생성 로직

2. **플레이스홀더 개선** (High):
   - X-cross 제거
   - `Icons.person` 단독 표시
   - 아이콘 크기 40%로 증가

3. **ClipPath 적용** (Medium):
   - 스케치 경로로 컨텐츠 클리핑
   - 이미지/이니셜 경계 정리

4. **테마 색상 연동** (Medium):
   - 라이트/다크 모드 자동 대응
   - `SketchThemeExtension` 색상 사용

5. **접근성 개선** (Low):
   - Semantics label 추가
   - Button role 명시

## 참고 자료

- **참조 이미지**:
  - `prompt/archives/img_19.png`: 다크 모드 사람 실루엣 (흰 테두리)
  - `prompt/archives/img_20.png`: 라이트 모드 사람 실루엣 (검은 테두리)
  - `prompt/archives/img_21.png`: 현재 SketchAvatar 데모

- **기존 컴포넌트**:
  - `SketchCirclePainter`: 불규칙 원형 페인터
  - `SketchPainter`: 불규칙 사각형 페인터
  - `SketchThemeExtension`: 테마 색상 시스템

- **Frame0 스타일 가이드**:
  - 손으로 그린 듯한 불규칙한 테두리
  - 2중 선으로 스케치 질감 강조
  - 일관된 roughness (0.8) 사용
  - seed 기반 재현 가능한 랜덤성
