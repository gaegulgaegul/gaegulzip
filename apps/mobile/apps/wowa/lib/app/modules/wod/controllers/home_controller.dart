import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:api/api.dart';
import 'package:core/core.dart';
import '../../../data/repositories/box_repository.dart';
import '../../../data/repositories/wod_repository.dart';
import '../../../routes/app_routes.dart';

/// WOD 홈 화면 컨트롤러
///
/// 날짜별 WOD 목록 조회, 날짜 네비게이션, 빠른 액션을 처리합니다.
class HomeController extends GetxController {
  // ===== 반응형 상태 (.obs) =====

  /// 현재 소속 박스
  final currentBox = Rxn<BoxModel>();

  /// 선택된 날짜
  final selectedDate = DateTime.now().obs;

  /// Base WOD (첫 번째 등록자의 WOD)
  final baseWod = Rxn<WodModel>();

  /// Personal WOD 목록
  final personalWods = <WodModel>[].obs;

  /// 로딩 상태
  final isLoading = false.obs;

  /// WOD 존재 여부
  final hasWod = false.obs;

  /// 미확인 제안 수 (P1)
  final unreadCount = 0.obs;

  // ===== 비반응형 상태 (의존성) =====

  late final BoxRepository _boxRepository;
  late final WodRepository _wodRepository;

  // ===== Computed Properties =====

  /// 'yyyy.MM.dd' 형식 날짜 문자열
  String get formattedDate {
    final d = selectedDate.value;
    return '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
  }

  /// 요일 문자열 ('월', '화', '수' 등)
  String get dayOfWeek {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[selectedDate.value.weekday - 1];
  }

  /// 선택된 날짜가 오늘인지 여부
  bool get isToday {
    final now = DateTime.now();
    final d = selectedDate.value;
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  // ===== 초기화 =====

  @override
  void onInit() {
    super.onInit();
    _boxRepository = Get.find<BoxRepository>();
    _wodRepository = Get.find<WodRepository>();
    _loadInitialData();
  }

  /// 초기 데이터 로드
  Future<void> _loadInitialData() async {
    try {
      isLoading.value = true;
      final box = await _boxRepository.getCurrentBox();
      currentBox.value = box;

      if (box == null) {
        // 박스 미가입 → 박스 검색으로 이동
        Get.offAllNamed(Routes.BOX_SEARCH);
        return;
      }

      await _loadWodForDate();
    } on NetworkException catch (e) {
      Get.snackbar('오류', e.message);
    } on AuthException catch (e) {
      Get.snackbar('인증 오류', e.message);
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      Get.snackbar('오류', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ===== WOD 데이터 로드 =====

  /// 선택된 날짜의 WOD 목록 로드
  Future<void> _loadWodForDate() async {
    final box = currentBox.value;
    if (box == null) return;

    try {
      isLoading.value = true;
      final d = selectedDate.value;
      final dateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      final response = await _wodRepository.getWodsByDate(
        boxId: box.id,
        date: dateStr,
      );

      baseWod.value = response.baseWod;
      personalWods.assignAll(response.personalWods);
      hasWod.value = response.baseWod != null;
    } on NetworkException catch (e) {
      Get.snackbar('오류', e.message);
    } on AuthException catch (e) {
      Get.snackbar('인증 오류', e.message);
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      Get.snackbar('오류', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ===== 날짜 네비게이션 =====

  /// 이전 날짜로 이동
  void previousDay() {
    selectedDate.value = selectedDate.value.subtract(const Duration(days: 1));
    _loadWodForDate();
  }

  /// 다음 날짜로 이동 (오늘 이후 불가)
  void nextDay() {
    if (isToday) return;
    selectedDate.value = selectedDate.value.add(const Duration(days: 1));
    _loadWodForDate();
  }

  /// DatePicker 표시
  Future<void> openDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      selectedDate.value = picked;
      _loadWodForDate();
    }
  }

  // ===== Pull-to-Refresh =====

  /// 새로고침
  @override
  Future<void> refresh() async {
    await _loadWodForDate();
  }

  // ===== 네비게이션 =====

  /// WOD 등록 화면으로 이동
  void goToRegister() {
    final box = currentBox.value;
    if (box == null) return;
    final d = selectedDate.value;
    final dateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    Get.toNamed(Routes.WOD_REGISTER, arguments: {
      'boxId': box.id,
      'date': dateStr,
    });
  }

  /// WOD 상세 화면으로 이동
  void goToDetail(WodModel wod) {
    final box = currentBox.value;
    if (box == null) return;
    final d = selectedDate.value;
    final dateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    Get.toNamed(Routes.WOD_DETAIL, arguments: {
      'boxId': box.id,
      'date': dateStr,
    });
  }

  /// WOD 선택 화면으로 이동
  void goToSelect() {
    final box = currentBox.value;
    if (box == null) return;
    final d = selectedDate.value;
    final dateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    Get.toNamed(Routes.WOD_SELECT, arguments: {
      'boxId': box.id,
      'date': dateStr,
    });
  }
}
