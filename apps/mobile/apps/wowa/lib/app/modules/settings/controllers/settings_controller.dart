import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:auth_sdk/auth_sdk.dart';
import 'package:notice/notice.dart';
import '../../../data/repositories/box_repository.dart';
import '../../../routes/app_routes.dart';

/// 설정 화면 컨트롤러
///
/// 프로필, 박스 변경, 알림 설정, 로그아웃을 처리합니다.
class SettingsController extends GetxController {
  // ===== 반응형 상태 (.obs) =====

  /// 현재 소속 박스
  final currentBox = Rxn<BoxModel>();

  /// 로딩 상태
  final isLoading = false.obs;

  /// 읽지 않은 공지사항 개수
  final unreadCount = 0.obs;

  // ===== 비반응형 상태 =====

  late final AuthRepository _authRepository;
  late final BoxRepository _boxRepository;
  late final NoticeApiService _noticeApiService;

  // ===== 초기화 =====

  @override
  void onInit() {
    super.onInit();
    _authRepository = Get.find<AuthRepository>();
    _boxRepository = Get.find<BoxRepository>();
    _noticeApiService = Get.find<NoticeApiService>();
    _loadSettings();
    _fetchUnreadCount();
  }

  /// 설정 데이터 로드
  Future<void> _loadSettings() async {
    try {
      isLoading.value = true;
      currentBox.value = await _boxRepository.getCurrentBox();
    } on NetworkException catch (e) {
      Get.snackbar('오류', e.message);
    } catch (e) {
      Get.snackbar('오류', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ===== 읽지 않은 공지사항 개수 조회 =====

  /// 읽지 않은 공지사항 개수 조회
  Future<void> _fetchUnreadCount() async {
    try {
      final response = await _noticeApiService.getUnreadCount();
      unreadCount.value = response.unreadCount;
    } catch (e) {
      // 비치명적 오류 — 실패 시 0 유지
      debugPrint('Failed to fetch unread notice count: $e');
    }
  }

  // ===== 공지사항 =====

  /// 공지사항 목록으로 이동
  void goToNoticeList() {
    Get.toNamed(Routes.NOTICE_LIST);
  }

  // ===== 박스 변경 =====

  /// 박스 검색 화면으로 이동 (박스 변경)
  void goToBoxChange() {
    Get.toNamed(Routes.BOX_SEARCH);
  }

  // ===== 로그아웃 =====

  /// 로그아웃 확인 모달
  void logout() {
    Get.defaultDialog(
      title: '로그아웃',
      middleText: '정말 로그아웃 하시겠습니까?',
      textConfirm: '로그아웃',
      textCancel: '취소',
      onConfirm: () async {
        Get.back();
        await _performLogout();
      },
    );
  }

  /// 실제 로그아웃 처리
  Future<void> _performLogout() async {
    try {
      isLoading.value = true;
      await _authRepository.logout();
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      Get.snackbar('오류', '로그아웃 중 문제가 발생했습니다');
    } finally {
      isLoading.value = false;
    }
  }
}
