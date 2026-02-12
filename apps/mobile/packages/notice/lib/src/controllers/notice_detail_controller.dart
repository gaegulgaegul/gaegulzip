import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import '../models/notice_model.dart';
import '../services/notice_api_service.dart';
import 'notice_list_controller.dart';

/// 공지사항 상세 화면 컨트롤러
class NoticeDetailController extends GetxController {
  /// API 서비스
  late final NoticeApiService _apiService;

  /// 앱 식별 코드 (JWT 없이 API 호출 시 사용)
  final String? appCode;

  /// 생성자
  ///
  /// [appCode] 앱 식별 코드 (선택, null이면 JWT 인증 사용)
  NoticeDetailController({this.appCode});

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
      Logger.warn('Notice: 상세 조회 - 잘못된 arguments: $args');
      errorMessage.value = '잘못된 접근입니다';
      return;
    }
    noticeId = args;

    fetchNoticeDetail();
  }

  /// 공지사항 상세 조회
  Future<void> fetchNoticeDetail() async {
    isLoading.value = true;
    errorMessage.value = '';

    Logger.debug('Notice: 상세 조회 시작 - id=$noticeId');

    try {
      final response = await _apiService.getNoticeDetail(noticeId, appCode: appCode);
      notice.value = response;

      Logger.debug('Notice: 상세 조회 성공 - id=$noticeId, title=${response.title}');

      // 목록 컨트롤러에 읽음 상태 반영 (있을 경우만)
      if (Get.isRegistered<NoticeListController>()) {
        Get.find<NoticeListController>().markAsRead(noticeId);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        Logger.warn('Notice: 상세 조회 - 공지 미존재 - id=$noticeId');
        errorMessage.value = '삭제되었거나 존재하지 않는 공지사항입니다';
      } else {
        Logger.error('Notice: 상세 조회 실패 - DioException', error: e);
        errorMessage.value = e.message ?? '네트워크 오류가 발생했습니다';
      }
      Get.snackbar(
        '오류',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Logger.error('Notice: 상세 조회 실패 - 예상치 못한 오류', error: e);
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
