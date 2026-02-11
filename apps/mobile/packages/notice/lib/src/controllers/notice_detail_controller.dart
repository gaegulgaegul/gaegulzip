import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/notice_model.dart';
import '../services/notice_api_service.dart';
import 'notice_list_controller.dart';

/// 공지사항 상세 화면 컨트롤러
class NoticeDetailController extends GetxController {
  /// API 서비스
  late final NoticeApiService _apiService;

  /// 앱 식별 코드 (JWT 없이 API 호출 시 사용)
  String? appCode;

  /// 공지사항 상세 데이터
  final notice = Rxn<NoticeModel>();

  /// 로딩 상태
  final isLoading = false.obs;

  /// 에러 메시지
  final errorMessage = ''.obs;

  /// 공지사항 ID (route argument)
  late final int noticeId;

  @override
  void onInit() {
    super.onInit();
    _apiService = Get.find<NoticeApiService>();

    // Get.arguments로 전달된 ID 추출 (안전한 타입 캐스팅)
    final args = Get.arguments;
    if (args == null || args is! int) {
      errorMessage.value = '잘못된 접근입니다';
      Get.back();
      return;
    }
    noticeId = args;

    fetchNoticeDetail();
  }

  /// 공지사항 상세 조회
  Future<void> fetchNoticeDetail() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _apiService.getNoticeDetail(noticeId, appCode: appCode);
      notice.value = response;

      // 목록 컨트롤러에 읽음 상태 반영 (있을 경우만)
      if (Get.isRegistered<NoticeListController>()) {
        Get.find<NoticeListController>().markAsRead(noticeId);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        errorMessage.value = '삭제되었거나 존재하지 않는 공지사항입니다';
      } else {
        errorMessage.value = e.message ?? '네트워크 오류가 발생했습니다';
      }
      Get.snackbar(
        '오류',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = '예상치 못한 오류가 발생했습니다';
      Get.snackbar(
        '오류',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
