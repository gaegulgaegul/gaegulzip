# Error Handling Patterns

## In Controllers
```dart
class MyController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Future<void> fetchData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await apiService.fetch();
      // Process data
    } on DioException catch (e) {
      errorMessage.value = e.message ?? 'Network error';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }
}
```

## In Views
```dart
Obx(() {
  if (controller.isLoading.value) {
    return const CircularProgressIndicator();
  }
  if (controller.errorMessage.value.isNotEmpty) {
    return Text('Error: ${controller.errorMessage}');
  }
  return ContentWidget();
})
```
