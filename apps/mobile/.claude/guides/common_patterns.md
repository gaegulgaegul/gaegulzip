# Common Patterns

## Importing Packages

In wowa app:
```dart
import 'package:core/core.dart';
import 'package:api/api.dart';
import 'package:design_system/design_system.dart';
```

In api or design_system packages:
```dart
import 'package:core/core.dart';
```

## State Management with GetX

### Controller Pattern
```dart
class HomeController extends GetxController {
  // Reactive state
  final count = 0.obs;
  final isLoading = false.obs;

  // Non-reactive state (when UI doesn't need to react)
  String userId = '';

  // Dependencies
  final ApiService _apiService = Get.find();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  @override
  void onClose() {
    // Clean up resources
    super.onClose();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      // API call
      final data = await _apiService.fetchData();
      count.value = data.count;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void increment() => count++;
}
```

### View Pattern
```dart
class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Obx(() => controller.isLoading.value
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Count: ${controller.count}'),
                  ElevatedButton(
                    onPressed: controller.increment,
                    child: const Text('Increment'),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}
```

### Binding Pattern
```dart
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    // Inject other dependencies
    Get.lazyPut<HomeService>(() => HomeService());
  }
}
```

## Routing Setup

In `app/routes/app_routes.dart`:
```dart
abstract class Routes {
  static const HOME = '/home';
  static const PROFILE = '/profile';
  static const SETTINGS = '/settings';
}
```

In `app/routes/app_pages.dart`:
```dart
class AppPages {
  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}
```

In `main.dart`:
```dart
void main() {
  runApp(
    GetMaterialApp(
      title: 'Wowa App',
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    ),
  );
}
```

## API Integration Pattern

In `packages/api`:
```dart
// Model with Freezed
@freezed
class WeatherModel with _$WeatherModel {
  factory WeatherModel({
    required String city,
    required double temperature,
  }) = _WeatherModel;

  factory WeatherModel.fromJson(Map<String, dynamic> json) =>
      _$WeatherModelFromJson(json);
}

// API Client
class WeatherApiClient {
  final Dio _dio = Get.find<Dio>();

  Future<WeatherModel> getWeather(String city) async {
    final response = await _dio.get('/weather',
      queryParameters: {'city': city},
    );
    return WeatherModel.fromJson(response.data);
  }
}
```

In `apps/wowa` (Repository pattern):
```dart
class WeatherRepository {
  final WeatherApiClient _apiClient = Get.find();

  Future<WeatherModel> getWeather(String city) async {
    try {
      return await _apiClient.getWeather(city);
    } catch (e) {
      // Handle errors, caching, etc.
      rethrow;
    }
  }
}
```

## Responsive Design Pattern

```dart
class ResponsiveView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return MobileLayout();
          } else if (constraints.maxWidth < 1200) {
            return TabletLayout();
          } else {
            return DesktopLayout();
          }
        },
      ),
    );
  }
}

// Or use GetX responsive helpers
class ResponsiveText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Hello',
      style: TextStyle(
        fontSize: context.isPhone ? 14 : context.isTablet ? 18 : 24,
      ),
    );
  }
}
```
