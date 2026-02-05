import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:api/api.dart';
import 'package:core/core.dart';
import '../../../data/repositories/wod_repository.dart';

/// 운동 동작 입력 모델
///
/// WOD 등록 시 각 운동 동작의 입력 상태를 관리합니다.
class MovementInput {
  final nameController = TextEditingController();
  final repsController = TextEditingController();
  final weightController = TextEditingController();
  final unitController = TextEditingController();

  /// 리소스 정리
  void dispose() {
    nameController.dispose();
    repsController.dispose();
    weightController.dispose();
    unitController.dispose();
  }
}

/// WOD 등록 컨트롤러
///
/// 운동 타입 선택, 동적 운동 리스트 관리, WOD 등록을 처리합니다.
class WodRegisterController extends GetxController {
  // ===== 반응형 상태 (.obs) =====

  /// 선택된 WOD 타입 ('AMRAP', 'FOR_TIME', 'EMOM', 'CUSTOM')
  final selectedType = ''.obs;

  /// 타임캡 (분 단위)
  final timeCap = RxnInt();

  /// 라운드 수
  final rounds = RxnInt();

  /// 운동 동작 입력 리스트
  final movements = <MovementInput>[].obs;

  /// 자유 텍스트 입력 (CUSTOM 타입용)
  final rawText = ''.obs;

  /// 로딩 상태
  final isLoading = false.obs;

  /// 제출 가능 여부
  final canSubmit = false.obs;

  // ===== 비반응형 상태 =====

  late final WodRepository _wodRepository;

  /// 현재 박스 ID
  late final int boxId;

  /// 등록 날짜 (YYYY-MM-DD)
  late final String date;

  // ===== 초기화 =====

  @override
  void onInit() {
    super.onInit();
    _wodRepository = Get.find<WodRepository>();

    final args = Get.arguments as Map<String, dynamic>;
    boxId = args['boxId'] as int;
    date = args['date'] as String;

    // 기본 운동 1개 추가
    addMovement();

    // 상태 변경 감시
    ever(selectedType, (_) => _validateAndUpdateCanSubmit());
    ever(rawText, (_) => _validateAndUpdateCanSubmit());
    ever(movements, (_) => _validateAndUpdateCanSubmit());
  }

  // ===== 타입 선택 =====

  /// WOD 타입 선택
  void selectType(String type) {
    selectedType.value = type;
  }

  // ===== 운동 리스트 관리 =====

  /// 운동 추가
  void addMovement() {
    movements.add(MovementInput());
  }

  /// 운동 제거 (최소 1개 유지)
  void removeMovement(int index) {
    if (movements.length <= 1) return;
    movements[index].dispose();
    movements.removeAt(index);
  }

  /// 운동 순서 변경 (드래그)
  void reorderMovements(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = movements.removeAt(oldIndex);
    movements.insert(newIndex, item);
  }

  // ===== 유효성 검증 =====

  /// 유효성 검증 및 canSubmit 업데이트
  void _validateAndUpdateCanSubmit() {
    if (selectedType.value.isEmpty) {
      canSubmit.value = false;
      return;
    }

    if (selectedType.value == 'CUSTOM') {
      // CUSTOM: rawText 필수
      canSubmit.value = rawText.value.trim().isNotEmpty;
      return;
    }

    // 비-CUSTOM: 운동 1개 이상 + 각 운동에 이름 필수
    final hasValidMovements = movements.isNotEmpty &&
        movements.every((m) => m.nameController.text.trim().isNotEmpty);
    canSubmit.value = hasValidMovements;
  }

  // ===== 등록 =====

  /// WOD 등록
  Future<void> submit() async {
    if (!canSubmit.value) return;

    try {
      isLoading.value = true;

      final ProgramData programData;
      final String rawTextValue;

      if (selectedType.value == 'CUSTOM') {
        // CUSTOM 타입: rawText만 전송
        programData = ProgramData(
          type: selectedType.value,
          movements: [],
        );
        rawTextValue = rawText.value.trim();
      } else {
        // 구조화 타입: movements 리스트 변환
        final movementList = movements.map((m) {
          return Movement(
            name: m.nameController.text.trim(),
            reps: m.repsController.text.trim().isNotEmpty
                ? int.tryParse(m.repsController.text.trim())
                : null,
            weight: m.weightController.text.trim().isNotEmpty
                ? double.tryParse(m.weightController.text.trim())
                : null,
            unit: m.unitController.text.trim().isNotEmpty
                ? m.unitController.text.trim()
                : null,
          );
        }).toList();

        programData = ProgramData(
          type: selectedType.value,
          timeCap: timeCap.value,
          rounds: rounds.value,
          movements: movementList,
        );
        // 구조화 데이터에서 rawText 생성
        rawTextValue = movementList.map((m) => m.name).join(', ');
      }

      final request = RegisterWodRequest(
        boxId: boxId,
        date: date,
        programData: programData,
        rawText: rawTextValue,
      );

      await _wodRepository.registerWod(request);
      Get.back(result: true);
      Get.snackbar('등록 완료', 'WOD가 등록되었습니다');
    } on NetworkException catch (e) {
      Get.snackbar('오류', e.message);
    } catch (e) {
      Get.snackbar('오류', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ===== 정리 =====

  @override
  void onClose() {
    for (final m in movements) {
      m.dispose();
    }
    super.onClose();
  }
}
