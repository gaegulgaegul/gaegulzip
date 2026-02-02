# Performance Optimization

## Use Const Constructors
```dart
// Good
const Text('Hello')
const SizedBox(height: 16)
const Icon(Icons.home)

// Bad - creates new instance every rebuild
Text('Hello')
SizedBox(height: 16)
```

## Minimize Obx() Scope
```dart
// Good - only Text rebuilds
Column(
  children: [
    const Text('Static'),
    Obx(() => Text('${controller.count}')),
  ],
)

// Bad - entire Column rebuilds
Obx(() => Column(
  children: [
    const Text('Static'),
    Text('${controller.count}'),
  ],
))
```

## Use GetBuilder for Complex Widgets
```dart
// When you have multiple dependencies or complex rebuild logic
GetBuilder<HomeController>(
  id: 'profile-section',
  builder: (controller) => ProfileCard(
    user: controller.user,
    stats: controller.stats,
  ),
)

// Trigger rebuild
update(['profile-section']);
```
