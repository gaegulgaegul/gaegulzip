# 기술 아키텍처 설계: SketchAppBar 스케치 스타일 개선

## 개요

SketchAppBar 위젯에 SketchPainter 기반의 2-pass 렌더링을 적용하여 Frame0 스케치 스타일의 손그림 테두리를 구현합니다. 기존 BoxDecoration 방식과 새로운 CustomPaint 방식을 `showSketchBorder` 파라미터로 분기하여, 하위 호환성을 유지하면서 SketchContainer와 동일한 시각적 일관성을 확보합니다.

## 수정 대상 파일

### 1. SketchAppBar 위젯

**파일**: `apps/mobile/packages/design_system/lib/src/widgets/sketch_app_bar.dart`

#### 현재 구조
- StatelessWidget + PreferredSizeWidget
- Container + BoxDecoration으로 배경/그림자 렌더링
- showSketchBorder 파라미터 존재하지만 미구현 (주석: "향후 SketchPainter를 사용하여 구현 예정")
- 모든 경우에 동일한 렌더링 로직 사용

#### 변경 내용

**새로운 파라미터 추가**
```dart
/// 스케치 테두리의 두께 (null이면 테마 기본값 사용)
final double? strokeWidth;

/// 스케치 거칠기 (null이면 테마 기본값 사용)
final double? roughness;

/// 스케치 렌더링 시드 (재현 가능한 무작위성)
final int seed;
```

**생성자 시그니처**
```dart
const SketchAppBar({
  super.key,
  this.title,
  this.titleWidget,
  this.leading,
  this.actions,
  this.backgroundColor,
  this.foregroundColor,
  this.showShadow = true,
  this.showSketchBorder = false,  // 기존 호환성 유지
  this.height = 56.0,
  this.strokeWidth,  // 새로 추가
  this.roughness,    // 새로 추가
  this.seed = 100,   // 새로 추가 (고정값)
});
```

#### 렌더링 로직 분기

**showSketchBorder: false (기존 방식 유지)**
```dart
Container(
  decoration: BoxDecoration(
    color: effectiveBgColor,
    boxShadow: showShadow ? [...] : null,
  ),
  padding: EdgeInsets.only(
    top: statusBarHeight,
    left: SketchDesignTokens.spacingSm,
    right: SketchDesignTokens.spacingSm,
  ),
  child: SizedBox(
    height: height,
    child: Row(
      children: [leading, Expanded(title), ...actions],
    ),
  ),
)
```

**showSketchBorder: true (새 방식)**
```dart
Stack(
  children: [
    // 그림자 레이어 (showShadow: true일 때만)
    if (showShadow)
      Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: theme?.shadowColor ?? Colors.black.withValues(alpha: 0.1),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),

    // 스케치 테두리 레이어 (2-pass CustomPaint)
    CustomPaint(
      painter: SketchPainter(
        fillColor: effectiveBgColor,
        borderColor: effectiveBorderColor,
        strokeWidth: effectiveStrokeWidth * 1.5,
        roughness: effectiveRoughness * 1.75,
        seed: seed,
        enableNoise: true,
        showBorder: true,
        borderRadius: 0.0, // 앱바는 직각
      ),
      child: CustomPaint(
        painter: SketchPainter(
          fillColor: Colors.transparent,
          borderColor: effectiveBorderColor,
          strokeWidth: effectiveStrokeWidth * 1.5,
          roughness: effectiveRoughness * 1.75,
          seed: seed + 50,
          enableNoise: false,
          showBorder: true,
          borderRadius: 0.0,
        ),
        child: Container(
          padding: EdgeInsets.only(
            top: statusBarHeight,
            left: SketchDesignTokens.spacingSm,
            right: SketchDesignTokens.spacingSm,
          ),
          child: SizedBox(
            height: height,
            child: Row(
              children: [leading, Expanded(title), ...actions],
            ),
          ),
        ),
      ),
    ),
  ],
)
```

#### effective 변수 계산

```dart
@override
Widget build(BuildContext context) {
  final theme = SketchThemeExtension.maybeOf(context);
  final effectiveBgColor = backgroundColor ?? theme?.fillColor ?? SketchDesignTokens.white;
  final effectiveFgColor = foregroundColor ?? theme?.textColor ?? SketchDesignTokens.textPrimary;
  final effectiveBorderColor = theme?.borderColor ?? SketchDesignTokens.base900;
  final effectiveStrokeWidth = strokeWidth ?? theme?.strokeWidth ?? SketchDesignTokens.strokeStandard;
  final effectiveRoughness = roughness ?? theme?.roughness ?? SketchDesignTokens.roughness;
  final statusBarHeight = MediaQuery.of(context).padding.top;

  // showSketchBorder 값에 따라 분기...
}
```

#### SketchPainter 2-Pass 렌더링 전략

**1st Pass (배경 + 테두리 + 노이즈)**
- fillColor: effectiveBgColor (라이트: #FAF8F5, 다크: #23273A)
- borderColor: effectiveBorderColor (라이트: #343434, 다크: #FFFFFF)
- strokeWidth: effectiveStrokeWidth * 1.5 (2.0 → 3.0)
- roughness: effectiveRoughness * 1.75 (0.8 → 1.4)
- seed: 100 (고정값)
- enableNoise: true (종이 질감)
- showBorder: true
- borderRadius: 0.0 (앱바는 직각)

**2nd Pass (테두리만 덧칠)**
- fillColor: Colors.transparent (배경 투명)
- borderColor: effectiveBorderColor (동일)
- strokeWidth: effectiveStrokeWidth * 1.5 (3.0)
- roughness: effectiveRoughness * 1.75 (1.4)
- seed: 150 (1st pass + 50)
- enableNoise: false
- showBorder: true
- borderRadius: 0.0

**2-Pass 효과**: seed 값 차이로 두 번째 테두리가 첫 번째와 약간 다른 경로로 그려져, 손으로 덧칠한 듯한 풍부한 테두리 질감 생성

#### 중요 사항

- **PreferredSizeWidget 인터페이스 유지 필수**: `preferredSize` getter 그대로 유지
- **statusBarHeight 처리**: `MediaQuery.of(context).padding.top`으로 노치/펀치홀 대응
- **const 생성자 유지**: SketchAppBar는 const로 선언 가능하지만, CustomPaint 내부는 런타임 렌더링
- **기존 API 100% 호환**: showSketchBorder: false일 때 기존 동작과 완전히 동일

### 2. 데모 앱 (AppBarDemo)

**파일**: `apps/mobile/apps/design_system_demo/lib/app/modules/widgets/views/demos/app_bar_demo.dart`

#### 상태 변수 추가

```dart
class _AppBarDemoState extends State<AppBarDemo> {
  bool _showShadow = true;
  bool _showSketchBorder = false; // 새로 추가

  @override
  Widget build(BuildContext context) {
    // ...
  }
}
```

#### 토글 컨트롤 업데이트

```dart
// 기존 그림자 토글 유지
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Text('그림자 표시', style: TextStyle(fontSize: SketchDesignTokens.fontSizeBase)),
    SketchSwitch(
      value: _showShadow,
      onChanged: (v) => setState(() => _showShadow = v),
    ),
  ],
),
const SizedBox(height: SketchDesignTokens.spacingMd),

// 새로운 스케치 테두리 토글
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Text('스케치 테두리', style: TextStyle(fontSize: SketchDesignTokens.fontSizeBase)),
    SketchSwitch(
      value: _showSketchBorder,
      onChanged: (v) => setState(() => _showSketchBorder = v),
    ),
  ],
),
```

#### 기존 데모 변형 업데이트

**데모 1: 기본 스케치 앱바**
```dart
const Text('기본', style: TextStyle(fontWeight: FontWeight.w500)),
const SizedBox(height: SketchDesignTokens.spacingSm),
SizedBox(
  height: 56,
  child: SketchAppBar(
    title: '홈',
    showShadow: _showShadow,
    showSketchBorder: _showSketchBorder, // 추가
    leading: const SizedBox.shrink(),
  ),
),
```

**데모 2: 액션 버튼 + 스케치**
```dart
const Text('액션 버튼 포함', style: TextStyle(fontWeight: FontWeight.w500)),
const SizedBox(height: SketchDesignTokens.spacingSm),
SizedBox(
  height: 56,
  child: SketchAppBar(
    title: '설정',
    showShadow: _showShadow,
    showSketchBorder: _showSketchBorder, // 추가
    leading: const SizedBox.shrink(),
    actions: [
      SketchIconButton(
        icon: Icons.search,
        showBorder: false,
        onPressed: () {},
      ),
      SketchIconButton(
        icon: Icons.more_vert,
        showBorder: false,
        onPressed: () {},
      ),
    ],
  ),
),
```

**데모 3: 커스텀 leading + 스케치**
```dart
const Text('커스텀 leading', style: TextStyle(fontWeight: FontWeight.w500)),
const SizedBox(height: SketchDesignTokens.spacingSm),
SizedBox(
  height: 56,
  child: SketchAppBar(
    title: '메뉴',
    showShadow: _showShadow,
    showSketchBorder: _showSketchBorder, // 추가
    leading: SketchIconButton(
      icon: Icons.menu,
      showBorder: false,
      onPressed: () {},
    ),
  ),
),
```

**데모 4: 스케치 + 그림자 동시 적용 (새 추가)**
```dart
const Text('스케치 + 그림자 조합', style: TextStyle(fontWeight: FontWeight.w500)),
const SizedBox(height: SketchDesignTokens.spacingSm),
SizedBox(
  height: 56,
  child: SketchAppBar(
    title: '조합 스타일',
    showShadow: true,           // 강제 true
    showSketchBorder: true,     // 강제 true
    leading: const SizedBox.shrink(),
  ),
),
```

**데모 5: 그림자 없음 (기존 유지)**
```dart
const Text('그림자 없음', style: TextStyle(fontWeight: FontWeight.w500)),
const SizedBox(height: SketchDesignTokens.spacingSm),
SizedBox(
  height: 56,
  child: SketchAppBar(
    title: '플랫 스타일',
    showShadow: false,
    showSketchBorder: _showSketchBorder, // 추가
    leading: const SizedBox.shrink(),
  ),
),
```

## 테마 시스템 연동

### SketchThemeExtension

**파일**: `apps/mobile/packages/design_system/lib/src/theme/sketch_theme_extension.dart`

#### 사용할 테마 속성

- **fillColor**: 앱바 배경색
  - Light: `Color(0xFFFAF8F5)` (크림색)
  - Dark: `Color(0xFF23273A)` (어두운 네이비)
- **borderColor**: 스케치 테두리 색상
  - Light: `Color(0xFF343434)` (base900)
  - Dark: `Color(0xFFFFFFFF)` (white)
- **textColor**: 제목 텍스트 색상
  - Light: `Color(0xFF343434)` (base900)
  - Dark: `Color(0xFFF5F5F5)` (textOnDark)
- **strokeWidth**: 테두리 두께 기본값
  - Default: 2.0 (SketchDesignTokens.strokeStandard)
- **roughness**: 거칠기 기본값
  - Default: 0.8 (SketchDesignTokens.roughness)
- **shadowColor**: 그림자 색상
  - Light: `Color(0x1A000000)` (black 10%)
  - Dark: `Color(0x33000000)` (black 20%)

#### 테마 접근 패턴

```dart
final theme = SketchThemeExtension.maybeOf(context);
final effectiveBorderColor = theme?.borderColor ?? SketchDesignTokens.base900;
```

## SketchDesignTokens 참고값

**파일**: `apps/mobile/packages/design_system/lib/src/theme/sketch_design_tokens.dart`

### 스케치 속성
- **strokeStandard**: 2.0
- **roughness**: 0.8
- **bowing**: 1.0
- **irregularBorderRadius**: 12.0 (앱바는 0.0 사용)
- **noiseIntensity**: 0.03
- **noiseGrainSize**: 1.5

### 스페이싱
- **spacingSm**: 8.0
- **spacingMd**: 16.0
- **spacingLg**: 24.0
- **spacing2Xl**: 32.0
- **spacingXl**: 20.0 (데모 앱 사용)

### 타이포그래피
- **fontFamilyHand**: "Nanum Pen Script"
- **fontFamilyHandFallback**: ["Gochi Hand", "Patrick Hand", "cursive"]
- **fontSizeLg**: 18.0 (앱바 제목)
- **fontSizeBase**: 14.0 (데모 레이블)

## 성능 최적화 전략

### CustomPaint 최적화
- **shouldRepaint 최소화**: SketchPainter는 파라미터 변경 시만 repaint
- **고정 seed 사용**: 매번 동일한 경로 생성으로 일관성 보장
- **2-pass 비용**: 앱바 영역이 작아 성능 영향 미미 (약 0.5ms 추가)

### const 생성자
- **SketchAppBar**: const 생성자 유지 (가능한 경우 const로 생성)
- **CustomPaint**: 런타임 렌더링이므로 const 불가
- **정적 위젯**: 앱바 내부의 SizedBox, EdgeInsets는 const 사용

### 불필요한 rebuild 방지
- **showSketchBorder 변경**: setState로 전체 위젯 리빌드 (데모 앱만 해당)
- **앱 사용 시**: 앱바는 일반적으로 정적이므로 rebuild 최소

### Stack vs Container
- **showSketchBorder: false**: 단일 Container (기존 성능 유지)
- **showSketchBorder: true**: Stack + CustomPaint (약간의 오버헤드, 시각적 효과 우선)

## 에러 처리 전략

### 테마 없을 때
- **폴백 색상 사용**: `theme?.borderColor ?? SketchDesignTokens.base900`
- **에러 메시지 없음**: 조용히 폴백 처리

### 파라미터 검증
- **height < 48**: 경고 없이 허용 (개발자 의도로 간주)
- **strokeWidth, roughness**: 음수 값 허용 안 함 (SketchPainter에서 처리)
- **seed**: 모든 정수 허용

### CustomPaint 에러
- **렌더링 실패**: SketchPainter 내부에서 try-catch 없음 (Flutter가 처리)
- **메모리 부족**: 앱바 크기가 작아 발생 가능성 낮음

## 엣지 케이스 처리

### 앱바 높이가 매우 작을 때 (height < 48)
- **대응**: strokeWidth 자동 조절 없음, 개발자 책임
- **권장**: height 최소 48dp 유지 (Material Design 가이드라인)

### 커스텀 backgroundColor 사용
- **대응**: borderColor는 테마에서 자동 선택
- **커스터마이징**: strokeWidth, roughness 파라미터로 세밀 조정

### 그림자 + 스케치 동시 사용
- **대응**: Stack 레이어 분리 (그림자 하단, 스케치 상단)
- **시각적 효과**: 입체감 제공, 충돌 없음

### 다국어 긴 제목
- **대응**: TextOverflow.ellipsis (기존 동작 유지)
- **스케치 테두리**: 텍스트 길이와 무관하게 앱바 전체 너비에 렌더링

### StatusBar 높이 변화 (노치/펀치홀)
- **대응**: MediaQuery.of(context).padding.top으로 동적 조정
- **스케치 테두리**: 전체 앱바 영역에 렌더링되므로 영향 없음

## 비즈니스 규칙

1. **스케치 테두리는 앱바 전체 영역에 표시** (상단, 하단, 좌우 모두 포함)
2. **기본값 showSketchBorder: false 유지** (기존 앱 호환성, opt-in 방식)
3. **seed 파라미터는 고정값 100 사용** (매번 다른 모양 방지, 일관성 확보)
4. **roughness는 SketchThemeExtension 기본값 사용** (0.8 → 1.4로 증폭)
5. **스케치 테두리 두께는 strokeStandard * 1.5** (2.0 → 3.0, SketchContainer와 동일)
6. **borderRadius: 0.0** (앱바는 직각, SketchContainer(12.0)와 달리 둥근 모서리 없음)

## 검증 기준

### 시각적 스타일
- [ ] showSketchBorder: true일 때 앱바 전체 영역에 손그림 스타일 테두리 렌더링
- [ ] SketchPainter의 2-pass 렌더링 기법 적용 (겹쳐진 불규칙한 선 질감)
- [ ] SketchContainer와 동일한 수준의 손그림 느낌
- [ ] 테두리는 앱바 전체 너비에 걸쳐 표시됨

### 테마 대응
- [ ] 라이트 모드: 크림색 배경(#FAF8F5) + 어두운 색상 스케치 테두리(#343434)
- [ ] 다크 모드: 어두운 배경(#23273A) + 밝은 색상 스케치 테두리(#FFFFFF)
- [ ] SketchThemeExtension의 borderColor, fillColor 자동 연동
- [ ] 시스템 테마 변경 시 즉시 반영

### 파라미터 동작
- [ ] showSketchBorder: false일 때 스케치 테두리 렌더링 안 함 (기존 BoxDecoration 방식)
- [ ] showSketchBorder: true일 때만 SketchPainter 적용
- [ ] backgroundColor, foregroundColor 파라미터 정상 동작
- [ ] strokeWidth, roughness 파라미터로 커스터마이징 가능

### 기존 API 호환성
- [ ] SketchAppBar(title, titleWidget, leading, actions, height) 기존 시그니처 유지
- [ ] Scaffold.appBar에서 정상 동작
- [ ] PreferredSizeWidget 인터페이스 유지
- [ ] 기존 사용 코드 변경 없이 동작 (showSketchBorder: false가 기본값)

### 성능
- [ ] CustomPaint 사용으로 인한 성능 저하 없음 (60fps 유지)
- [ ] 앱바 렌더링 시 버벅임 없음
- [ ] 불필요한 리빌드 최소화

### 데모 앱 검증
- [ ] design_system_demo 앱의 AppBar 데모에서 스케치 테두리 확인 가능
- [ ] 라이트/다크 모드 전환 시 테두리 색상 변경 확인
- [ ] showSketchBorder 토글로 테두리 on/off 확인
- [ ] SketchContainer와 일관성 확인

## 작업 분배 계획

### Senior Developer 작업
1. **SketchAppBar 위젯 수정**
   - showSketchBorder 파라미터 추가
   - strokeWidth, roughness, seed 파라미터 추가
   - 렌더링 로직 분기 구현 (showSketchBorder: false/true)
   - 2-pass CustomPaint 적용
   - effective 변수 계산 로직

2. **테마 연동**
   - SketchThemeExtension에서 borderColor, fillColor, strokeWidth, roughness 가져오기
   - 폴백 값 처리

3. **성능 최적화**
   - const 생성자 유지
   - 불필요한 rebuild 방지

### Junior Developer 작업
1. **데모 앱 업데이트**
   - _showSketchBorder 상태 변수 추가
   - 스케치 테두리 토글 스위치 추가
   - 기존 데모 변형에 showSketchBorder 파라미터 추가
   - 새로운 데모 변형 추가 (스케치 + 그림자 조합)

2. **레이아웃 조정**
   - 토글 컨트롤 레이아웃 조정
   - 스페이싱 일관성 유지

### 작업 의존성
- Junior는 Senior의 SketchAppBar 수정 완료 후 시작
- showSketchBorder, strokeWidth, roughness, seed 파라미터가 정확히 노출되어야 함

## 참고 자료

### 기존 구현
- **SketchContainer**: 2-pass SketchPainter 패턴의 참조 구현
  - 파일: `apps/mobile/packages/design_system/lib/src/widgets/sketch_container.dart`
  - 1st pass: 배경 + 테두리 + 노이즈 (seed)
  - 2nd pass: 테두리만 덧칠 (seed + 50)
- **SketchPainter**: RRect path metric 기반 스케치 테두리 생성 로직
  - 파일: `apps/mobile/packages/design_system/lib/src/painters/sketch_painter.dart`
  - 파라미터: fillColor, borderColor, strokeWidth, roughness, seed, enableNoise, showBorder, borderRadius
- **SketchThemeExtension**: 라이트/다크 테마별 색상 및 스케치 속성 관리
  - 파일: `apps/mobile/packages/design_system/lib/src/theme/sketch_theme_extension.dart`

### Material Design 3
- **AppBar 가이드라인**: 높이 56dp, 터치 영역 48x48dp, status bar 대응

### Frame0 스타일
- **손그림 미학**: 불규칙한 테두리, 종이 질감, 손으로 덧칠한 느낌

## 구현 완료 후 검증 사항

1. **라이트 모드에서 스케치 테두리 표시**: 어두운 테두리(#343434)가 크림 배경(#FAF8F5) 위에 명확히 표시
2. **다크 모드에서 스케치 테두리 표시**: 밝은 테두리(#FFFFFF)가 어두운 배경(#23273A) 위에 명확히 표시
3. **2-pass 효과 확인**: 테두리가 겹쳐져 손으로 덧칠한 듯한 질감
4. **그림자 + 스케치 동시 적용**: 시각적 충돌 없이 조화롭게 렌더링
5. **데모 앱 토글 동작**: showSketchBorder, showShadow 토글이 즉시 반영됨
6. **SketchContainer와 일관성**: 동일한 seed 값일 때 유사한 스케치 느낌
7. **성능 확인**: 앱바 렌더링 시 버벅임 없음, 60fps 유지
8. **기존 코드 호환성**: showSketchBorder: false일 때 기존 앱 동작 변경 없음

## CLAUDE.md 준수 사항

1. **모노레포 구조**: design_system 패키지 내부 수정, wowa 앱은 변경 없음
2. **const 최적화**: SketchAppBar는 const 생성자 유지
3. **성능**: CustomPaint 사용하지만 앱바 영역이 작아 영향 미미
4. **테마 통합**: SketchThemeExtension과 SketchDesignTokens 활용
5. **하위 호환성**: showSketchBorder: false가 기본값 (opt-in 방식)

## 출력물

- **수정된 SketchAppBar 위젯**: `apps/mobile/packages/design_system/lib/src/widgets/sketch_app_bar.dart`
- **업데이트된 데모 앱**: `apps/mobile/apps/design_system_demo/lib/app/modules/widgets/views/demos/app_bar_demo.dart`
- **위치**: 기존 파일 수정 (새 파일 생성 없음)

## 주의사항

1. **PreferredSizeWidget 인터페이스 유지**: Scaffold.appBar 호환성 필수
2. **statusBarHeight 처리**: MediaQuery.of(context).padding.top으로 동적 조정
3. **seed 고정값 사용**: seed = 100 (재현 가능한 무작위성)
4. **borderRadius: 0.0**: 앱바는 직각 (SketchContainer와 다름)
5. **기존 API 100% 호환**: showSketchBorder: false일 때 기존 동작 유지
