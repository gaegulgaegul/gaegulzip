# User Story: SketchTabBar 디자인 리빌드

## 개요

SketchTabBar 위젯을 SketchPainter 기반의 손으로 그린 스케치 스타일로 리빌드한다.
현재 BoxDecoration 기반의 평면적 디자인에서, 각 탭이 독립적인 스케치 테두리를 가진 카드형 탭 디자인으로 변경한다.

## 사용자 스토리

**AS A** wowa 앱 사용자
**I WANT** 탭 바가 손으로 그린 스케치 스타일의 테두리와 질감을 가지길 원한다
**SO THAT** 앱 전체의 Frame0 스케치 디자인과 시각적 일관성을 유지할 수 있다

## 요구사항

### 핵심 변경사항

1. **탭 형태 변경**: 각 탭이 독립적인 스케치 스타일 카드 형태
   - 상단 모서리: 둥근 형태 (rounded top corners)
   - 하단: 직선 (하단 테두리 라인과 연결)
   - 선택된 탭: 채워진 배경 (라이트: 흰색, 다크: 어두운 색)
   - 비선택 탭: 회색 배경 (라이트: 연한 회색, 다크: 진한 회색)

2. **SketchPainter 적용**: 탭 테두리에 손으로 그린 질감 적용
   - 불규칙한 테두리 (roughness 기반 jitter)
   - 노이즈 텍스처 채우기
   - 시드 기반 재현 가능한 렌더링

3. **레이아웃 개선**: 현재 overflow 에러 해결
   - 아이콘 탭의 높이 overflow 문제 수정
   - 텍스트 전용 탭 / 아이콘 탭 모두 안정적 렌더링

4. **다크 모드 지원**: 테마에 따른 색상 자동 전환
   - 라이트: 선택 탭 흰색 배경, 비선택 탭 연한 회색, 두꺼운 검은 테두리
   - 다크: 선택 탭 어두운 배경, 비선택 탭 진한 회색, 회색 테두리

### 기존 API 호환

- `SketchTabBar` 위젯의 기존 public API 유지 (tabs, currentIndex, onTap 등)
- `SketchTab` 데이터 클래스 유지
- `SketchTabIndicatorStyle` enum은 더 이상 사용하지 않을 수 있음 (탭 형태가 카드형으로 변경)

### 데모 앱 업데이트

- `design_system_demo` 앱의 `tab_bar_demo.dart`에서 변경된 디자인 확인 가능
- 기본 탭, 아이콘 탭, 배지 포함 탭 데모 유지

## 참조 디자인

- **목표 디자인 (라이트)**: `prompt/archives/img_26.png` - 흰색 선택 탭, 연한 회색 비선택 탭
- **목표 디자인 (다크)**: `prompt/archives/img_25.png` - 검정 선택 탭, 진한 회색 비선택 탭
- **현재 구현**: `prompt/archives/img_27.png` - overflow 에러 발생, 스케치 스타일 없음

## 구현 범위

| 항목 | 경로 |
|------|------|
| 탭 바 위젯 | `apps/mobile/packages/design_system/lib/src/widgets/sketch_tab_bar.dart` |
| 탭 커스텀 페인터 (신규 가능) | `apps/mobile/packages/design_system/lib/src/painters/` |
| 데모 뷰 | `apps/mobile/apps/design_system_demo/lib/app/modules/widgets/views/demos/tab_bar_demo.dart` |
| 테마 확장 | `apps/mobile/packages/design_system/lib/src/theme/sketch_theme_extension.dart` (필요시) |

## 플랫폼

- **Mobile** (Flutter design_system 패키지)
