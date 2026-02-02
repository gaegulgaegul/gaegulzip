# GetX Best Practices

## Controllers
- **One controller per screen/feature** - avoid God controllers
- **Use reactive variables (.obs)** only when UI needs to react to changes
- **Initialize in onInit()** - not in constructor
- **Clean up in onClose()** - dispose streams, cancel timers
- **Don't reference UI elements** in controllers (no BuildContext)
- **Keep controllers testable** - avoid tight coupling with widgets

```dart
// Good
class HomeController extends GetxController {
  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  @override
  void onClose() {
    // Clean up
    super.onClose();
  }

  void increment() => count++;
}

// Bad - too much in constructor, context in controller
class BadController extends GetxController {
  BadController(BuildContext context) {
    // Don't do initialization here
  }
}
```

## Bindings
- **Use bindings for dependency injection** - don't use Get.put() in widgets
- **Lazy load controllers** - controllers created only when route is accessed
- **Bind dependencies at route level** using Binding classes

```dart
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
```

## Navigation
- **Use named routes** - more maintainable than direct navigation
- **Define routes centrally** in app_pages.dart
- **Pass arguments via Get.arguments** or route parameters

```dart
// Route definition
GetPage(
  name: Routes.HOME,
  page: () => HomeView(),
  binding: HomeBinding(),
)

// Navigation
Get.toNamed(Routes.HOME, arguments: {'id': 123});
```

## Reactive Programming
- **Choose the right reactive widget**:
  - `Obx()` - for simple reactive variables
  - `GetBuilder()` - when you need manual update control
  - `GetX<Controller>()` - combines controller injection and reactivity
- **Avoid nested Obx** - extract to separate widgets
- **Use .value for one-time reads** - don't make everything reactive

```dart
// Good - specific rebuild
Obx(() => Text('${controller.count}'))

// Bad - entire screen rebuilds
Obx(() => Scaffold(...))  // Too large
```

## Dependency Injection
- **Use Get.find() in controllers** to access other controllers/services
- **Register singletons in main.dart** for app-wide services
- **Use lazyPut for feature controllers** - created when needed

```dart
// In main.dart
Get.put(AuthService(), permanent: true);

// In controller
final authService = Get.find<AuthService>();
```

## GetX Anti-Patterns to Avoid
- ❌ **Don't use Get.context** - pass context explicitly if needed
- ❌ **Don't use Get.put() in build methods** - use bindings
- ❌ **Don't make everything reactive** - use .obs only when needed
- ❌ **Don't create controllers in widgets** - use bindings or Get.find()
- ❌ **Don't mix state management approaches** - stick to GetX patterns
