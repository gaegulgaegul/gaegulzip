# Comments and Documentation

## 언어 정책

**이 프로젝트의 모든 주석은 한글로 작성합니다.**

- **문서화 주석 (`///`)**: 한글로 작성
- **구현 주석 (`//`)**: 한글로 작성
- **TODO, FIXME**: 한글로 작성
- **코드 자체**: 영어 (변수명, 함수명, 클래스명)

### 한글 주석 작성 원칙

- **명확한 문장으로 작성** - 첫 글자 대문자 없이, 마침표로 끝맺음
- **존댓말 사용 자제** - 간결하게 평서문 형태로 작성
- **띄어쓰기 정확히** - 가독성을 위해 올바른 띄어쓰기 사용
- **불필요한 조사 생략 가능** - 짧고 명확하게

```dart
// Good - 간결하고 명확
/// 지정된 도시의 날씨 데이터를 가져옴.

// Acceptable - 완전한 문장
/// 지정된 도시의 날씨 데이터를 가져옵니다.

// Bad - 너무 장황
/// 이 함수는 지정된 도시의 날씨 데이터를 서버로부터 가져오는 역할을 수행합니다.
```

## 주석 작성 기본 원칙

- **WHY를 설명, WHAT은 아님** - 코드는 무엇을 하는지 보여주고, 주석은 왜 그렇게 하는지 설명
- **주석은 항상 최신 상태 유지** - 오래된 주석은 없는 것보다 나쁨
- **주석 처리된 코드 삭제** - 버전 관리 시스템 사용
- **주석을 아껴서 사용** - 명확한 이름으로 자체 설명이 가능한 코드 선호

## Dart의 주석 종류

### 문서화 주석 (`///`)
공개 API, 클래스, 메서드, 속성에 사용:

```dart
/// 지정된 [city]의 날씨 데이터를 가져옴.
///
/// 현재 기상 조건이 포함된 [WeatherModel]을 반환함.
/// 요청이 실패하면 [NetworkException]을 발생시킴.
Future<WeatherModel> getWeather(String city) async {
  // 구현
}
```

### 단일 라인 주석 (`//`)
복잡한 로직이나 명확하지 않은 결정을 설명:

```dart
// 과도한 API 호출을 방지하기 위해 디바운스 사용
final debouncedSearch = Debouncer(milliseconds: 300);
```

### 블록 주석 (`/* */`)
**일반적으로 사용 금지** - 코드를 임시로 비활성화할 때만 사용.

## 문서화 주석 모범 사례

### DO: 공개 API 문서화

```dart
/// 홈 화면의 상태를 관리하는 컨트롤러.
///
/// 사용자 인증 확인, 초기 데이터 로드, 다른 화면으로의
/// 네비게이션을 처리함.
class HomeController extends GetxController {
  /// 사용자가 현재 인증되었는지 여부.
  final isAuthenticated = false.obs;

  /// 인증 상태를 확인하고 사용자 데이터를 로드함.
  ///
  /// 이 메서드는 [onInit]을 통해 컨트롤러가 초기화될 때
  /// 자동으로 호출됨.
  Future<void> checkAuth() async {
    // 구현
  }
}
```

### DO: 한 문장 요약으로 시작

```dart
/// RFC 5322 표준을 사용하여 이메일 형식을 검증함.
///
/// 이메일이 유효하면 `true`, 그렇지 않으면 `false`를 반환함.
/// 이 검증은 클라이언트 측에서만 수행되며, 보안을 위해
/// 서버 측에서 재확인해야 함.
bool isValidEmail(String email) {
  // 구현
}
```

### DO: 대괄호로 참조 표시

```dart
/// [Dio]를 사용하여 API에 연결하고 [WeatherModel]을 가져옴.
///
/// [city] 매개변수는 유효한 도시 이름이어야 함.
/// [WeatherModel]로 래핑된 날씨 데이터를 반환함.
/// 네트워크 요청이 실패하면 [DioException]을 발생시킨.
Future<WeatherModel> getWeather(String city) async {
  // 구현
}
```

### DO: 부수 효과가 있는 메서드는 3인칭 동사로 시작

```dart
// Good
/// 사용자 환경 설정을 로컬 저장소에 저장함.
void savePreferences() {}

/// 카운터를 증가시키고 UI를 업데이트함.
void increment() {}

// Bad - 명령형
/// 사용자 환경 설정을 저장하세요.
void savePreferences() {}
```

### DO: 불린 속성은 "~인지 여부" 형태 사용

```dart
// Good
/// 데이터가 현재 로딩 중인지 여부.
final isLoading = false.obs;

/// 다크 모드가 활성화되었는지 여부.
bool get isDarkMode => _darkMode;

// Bad
/// 로딩 상태.
final isLoading = false.obs;
```

### DO: 불린이 아닌 속성은 명사구 사용

```dart
// Good
/// 현재 사용자의 표시 이름.
String get userName => _userName;

/// 장바구니의 아이템 개수.
final itemCount = 0.obs;

// Bad
/// 현재 사용자의 표시 이름을 가져옴.
String get userName => _userName;
```

### AVOID: 주변 컨텍스트와 중복

```dart
// Bad - 시그니처에서 보이는 정보를 반복
/// 이 메서드는 카운터를 1씩 증가시킴.
void increment() {
  count++;
}

// Good - 시그니처에서 명확하지 않은 컨텍스트 추가
/// 카운터를 증가시키고 로컬 저장소에 저장함.
void increment() {
  count++;
  _saveToStorage();
}
```

## 구현 주석 모범 사례

### DO: 명확하지 않은 로직 설명

```dart
void processData(List<Item> items) {
  // 배치 제한에 도달해도 우선순위가 높은 아이템이 처리되도록
  // 우선순위를 기준으로 먼저 정렬
  items.sort((a, b) => b.priority.compareTo(a.priority));

  // 대용량 데이터셋(10,000개 이상)에서 메모리 문제를 방지하기 위해
  // 50개씩 배치로 처리
  for (var batch in items.chunk(50)) {
    _processBatch(batch);
  }
}
```

### DO: 임시 해결책과 TODO 문서화

```dart
// TODO: API v2가 제공되면 적절한 에러 처리로 교체
try {
  await apiCall();
} catch (e) {
  // 지금은 조용히 실패 - 레거시 API가 일관성 없는 에러 응답 반환
}

// WORKAROUND: GetX 바인딩 이슈 - 컨트롤러가 너무 빨리 해제됨
// 참고: https://github.com/jonataslaw/getx/issues/1234
Get.put(controller, permanent: true);
```

### DON'T: 명백한 코드에 주석 달기

```dart
// Bad - 주석이 명백한 내용을 설명
// 카운터 증가
count++;

// 로딩을 true로 설정
isLoading.value = true;

// Good - 주석 불필요, 코드가 자체 설명적
count++;
isLoading.value = true;
```

### DON'T: 주석 처리된 코드 남기기

```dart
// Bad
void fetchData() {
  // final oldData = _legacyFetch();
  // if (oldData != null) {
  //   return oldData;
  // }
  return _newFetch();
}

// Good - 불필요한 코드 삭제
void fetchData() {
  return _newFetch();
}
```

## GetX 관련 문서화

### 컨트롤러

```dart
/// 인증 플로우와 사용자 세션을 관리함.
///
/// 이 컨트롤러는 [AuthBinding]을 통해 싱글톤으로 등록되며
/// 앱 생명주기 동안 유지됨.
class AuthController extends GetxController {
  /// 현재 인증된 사용자, 로그인하지 않은 경우 `null`.
  final Rxn<User> currentUser = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    // 앱 시작 시 저장된 인증 정보 확인
    _checkStoredAuth();
  }

  /// [email]과 [password]로 사용자를 로그인시킴.
  ///
  /// 인증 실패 시 에러 스낵바를 표시함.
  /// 성공 시 [Routes.HOME]으로 이동함.
  Future<void> signIn(String email, String password) async {
    // 구현
  }
}
```

### 반응형 변수

```dart
/// 현재 작업이 진행 중인지 여부.
///
/// 비동기 작업 중 로딩 인디케이터를 표시하고
/// 사용자 입력을 비활성화하는 데 사용됨.
final isLoading = false.obs;

/// 활성 날씨 경보 목록.
///
/// 날씨 API로부터 새로운 경보를 받으면 자동으로 업데이트됨.
final RxList<WeatherAlert> alerts = <WeatherAlert>[].obs;
```

## 문서에 코드 샘플 포함

복잡한 API를 문서화할 때 사용 예제 포함:

```dart
/// 커스터마이징 가능한 액션을 가진 재사용 가능한 확인 대화상자.
///
/// 사용 예제:
/// ```dart
/// await showConfirmDialog(
///   title: '항목 삭제',
///   message: '이 항목을 삭제하시겠습니까?',
///   onConfirm: () => controller.deleteItem(),
/// );
/// ```
///
/// 대화상자는 네비게이션과 애니메이션을 자동으로 처리함.
Future<bool?> showConfirmDialog({
  required String title,
  required String message,
  required VoidCallback onConfirm,
}) async {
  // 구현
}
```

## 라이브러리 수준 문서화

패키지 라이브러리에 개요 문서 추가:

```dart
/// Wowa 앱을 위한 핵심 유틸리티와 기반 클래스.
///
/// 이 라이브러리는 다음을 제공:
/// - GetX를 통한 의존성 주입 설정
/// - String, DateTime 등의 공통 확장 메서드
/// - 에러 처리 유틸리티
/// - 로깅 인프라
///
/// 예제:
/// ```dart
/// import 'package:core/core.dart';
///
/// // 확장 메서드 사용
/// final formatted = DateTime.now().toFormattedString();
/// ```
library core;

export 'src/extensions/extensions.dart';
export 'src/utils/utils.dart';
```

## 빠른 참조

### 문서화 주석 (`///`)을 사용할 때
- ✅ 공개 클래스, 메서드, 속성
- ✅ 설명이 필요한 복잡한 API
- ✅ 패키지 라이브러리와 export
- ✅ 다른 개발자가 사용하는 모든 코드

### 구현 주석 (`//`)을 사용할 때
- ✅ 복잡한 알고리즘이나 로직
- ✅ 알려진 문제의 임시 해결책
- ✅ 성능이 중요한 섹션
- ✅ 명확하지 않은 비즈니스 규칙
- ✅ TODO와 FIXME

### 주석을 작성하지 말아야 할 때
- ❌ 자체 설명이 가능한 명백한 코드
- ❌ 코드가 이미 말하고 있는 것을 반복
- ❌ 코드를 비활성화하기 위해 (대신 삭제)
- ❌ 나쁜 네이밍을 설명하기 위해 (대신 이름 변경)

## 한글 주석 작성 팁

### 간결성 유지

```dart
// Bad - 너무 장황
/// 이 메서드는 사용자가 입력한 이메일 주소가 올바른 형식인지 검사하는 기능을 수행합니다.
bool validateEmail(String email) {}

// Good - 간결하고 명확
/// 이메일 주소 형식을 검증함.
bool validateEmail(String email) {}
```

### 기술 용어는 영어 그대로 사용

```dart
// Good - 널리 쓰이는 기술 용어는 영어 사용
/// API 응답을 캐시에 저장함.
/// JSON 데이터를 파싱하여 모델로 변환함.
/// HTTP 요청이 타임아웃되면 재시도함.

// Bad - 억지로 한글화
/// 에이피아이 응답을 캐쉬에 저장함.
/// 제이슨 자료를 해석하여...
```

### 자연스러운 한글 어순

```dart
// Good - 자연스러운 한글 어순
/// 사용자 인증 후 홈 화면으로 이동함.
/// 데이터 로드 중 에러가 발생하면 재시도함.

// Acceptable but less natural - 영어 어순 직역
/// 홈 화면으로 사용자 인증 후 이동함.
```

## 추가 자료

- [Effective Dart: Documentation](https://dart.dev/effective-dart/documentation)
- [Dart Comments Language Guide](https://dart.dev/language/comments)
- [Flutter Documentation Best Practices](https://medium.com/@jaitechie05/flutter-and-dart-best-practices-in-documentation-acae6bd7de9b)
