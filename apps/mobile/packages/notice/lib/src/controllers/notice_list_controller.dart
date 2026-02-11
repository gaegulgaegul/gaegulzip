import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/notice_model.dart';
import '../services/notice_api_service.dart';

/// 공지사항 목록 화면 컨트롤러
///
/// 무한 스크롤 페이지네이션을 지원합니다.
class NoticeListController extends GetxController {
  /// API 서비스
  late final NoticeApiService _apiService;

  /// 앱 식별 코드 (JWT 없이 API 호출 시 사용)
  ///
  /// NoticeBinding에서 설정합니다. null이면 JWT 인증 사용.
  String? appCode;

  /// 공지사항 목록
  final notices = <NoticeModel>[].obs;

  /// 고정 공지사항 목록 (상단 표시용)
  final pinnedNotices = <NoticeModel>[].obs;

  /// 로딩 상태
  final isLoading = false.obs;

  /// 더 많은 데이터 로딩 중 (무한 스크롤)
  final isLoadingMore = false.obs;

  /// 에러 메시지
  final errorMessage = ''.obs;

  /// 다음 페이지 존재 여부
  final hasMore = true.obs;

  /// 현재 페이지
  int _currentPage = 1;

  /// 페이지 크기
  final int _pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    _apiService = Get.find<NoticeApiService>();
    fetchNotices();
  }

  /// 공지사항 목록 조회 (초기 로드)
  Future<void> fetchNotices() async {
    isLoading.value = true;
    errorMessage.value = '';
    _currentPage = 1;

    try {
      // 고정 공지사항과 일반 공지사항을 병렬로 조회
      final results = await Future.wait([
        _apiService.getNotices(
          page: 1,
          limit: 100, // 고정 공지는 최대 100개로 제한
          pinnedOnly: true,
          appCode: appCode,
        ),
        _apiService.getNotices(
          page: _currentPage,
          limit: _pageSize,
          appCode: appCode,
        ),
      ]);

      pinnedNotices.value = results[0].items;
      final response = results[1];

      notices.value = response.items;
      hasMore.value = response.hasNext;
    } on DioException catch (e) {
      errorMessage.value = e.message ?? '네트워크 오류가 발생했습니다';
      Get.snackbar(
        '오류',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = '예상치 못한 오류가 발생했습니다';
      Get.snackbar('오류', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  /// 새로고침 (Pull to Refresh)
  Future<void> refreshNotices() async {
    _currentPage = 1;
    await fetchNotices();
  }

  /// 다음 페이지 로드 (무한 스크롤)
  Future<void> loadMoreNotices() async {
    if (isLoading.value || isLoadingMore.value || !hasMore.value) return;

    isLoadingMore.value = true;

    final nextPage = _currentPage + 1;

    try {
      final response = await _apiService.getNotices(
        page: nextPage,
        limit: _pageSize,
        appCode: appCode,
      );

      _currentPage = nextPage;
      notices.addAll(response.items);
      hasMore.value = response.hasNext;
    } on DioException catch (e) {
      Get.snackbar(
        '오류',
        e.message ?? '추가 데이터를 불러오는 중 오류가 발생했습니다',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        '오류',
        '추가 데이터를 불러오는 중 오류가 발생했습니다',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// 특정 공지사항 읽음 처리 (목록에서 UI 업데이트)
  void markAsRead(int noticeId) {
    // 일반 목록에서 업데이트
    final index = notices.indexWhere((n) => n.id == noticeId);
    if (index != -1) {
      notices[index] = notices[index].copyWith(isRead: true);
    }

    // 고정 목록에서 업데이트
    final pinnedIndex = pinnedNotices.indexWhere((n) => n.id == noticeId);
    if (pinnedIndex != -1) {
      pinnedNotices[pinnedIndex] =
          pinnedNotices[pinnedIndex].copyWith(isRead: true);
    }
  }
}
