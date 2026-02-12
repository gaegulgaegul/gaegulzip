import 'package:get/get.dart';
import 'package:notice/notice.dart';

/// Notice 모의 컨트롤러
///
/// NoticeListController를 상속하여 서버 연동 없이 모의 데이터로 동작합니다.
/// onInit()을 오버라이드하여 NoticeApiService 의존성을 제거합니다.
class MockNoticeListController extends NoticeListController {
  final _dataGenerator = MockNoticeDataGenerator();

  /// 현재 페이지 (부모의 _currentPage는 private이므로 별도 관리)
  int _mockCurrentPage = 1;

  @override
  // ignore: must_call_super
  void onInit() {
    // 부모의 onInit()을 호출하지 않음 (NoticeApiService Get.find 회피)
    // 초기 데이터 로드
    fetchNotices();
  }

  /// 공지사항 목록 조회 (모의 데이터)
  @override
  Future<void> fetchNotices() async {
    isLoading.value = true;
    errorMessage.value = '';
    _mockCurrentPage = 1;

    try {
      // 모의 딜레이 (500ms)
      await Future.delayed(const Duration(milliseconds: 500));

      // 고정 공지 + 일반 공지 로드
      pinnedNotices.value = _dataGenerator.generatePinnedNotices();
      notices.value = _dataGenerator.generateGeneralNotices(page: 1);
      hasMore.value = true;
    } catch (e) {
      errorMessage.value = '데이터를 불러오는 중 오류가 발생했습니다';
    } finally {
      isLoading.value = false;
    }
  }

  /// 새로고침 (Pull to Refresh)
  @override
  Future<void> refreshNotices() async {
    await fetchNotices();
  }

  /// 다음 페이지 로드 (무한 스크롤)
  @override
  Future<void> loadMoreNotices() async {
    if (isLoading.value || isLoadingMore.value || !hasMore.value) return;

    isLoadingMore.value = true;
    final nextPage = _mockCurrentPage + 1;

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final newNotices = _dataGenerator.generateGeneralNotices(
        page: nextPage,
      );
      notices.addAll(newNotices);
      _mockCurrentPage = nextPage;

      // 최대 3페이지
      hasMore.value = _mockCurrentPage < 3;
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
}

/// 모의 공지사항 데이터 생성기
class MockNoticeDataGenerator {
  /// 고정 공지 생성 (2개)
  List<NoticeModel> generatePinnedNotices() {
    return [
      NoticeModel(
        id: 1,
        title: 'v1.0.0 업데이트 안내',
        content:
            '새로운 기능이 추가되었습니다.\n\n- QnA 기능 추가\n- 디자인 시스템 개선',
        category: 'update',
        isPinned: true,
        viewCount: 150,
        createdAt: DateTime.now()
            .subtract(const Duration(days: 3))
            .toIso8601String(),
      ),
      NoticeModel(
        id: 2,
        title: '서비스 점검 안내',
        content: '2026년 2월 15일 오전 2시~5시 서비스 점검 예정입니다.',
        category: 'maintenance',
        isPinned: true,
        viewCount: 89,
        createdAt: DateTime.now()
            .subtract(const Duration(days: 5))
            .toIso8601String(),
      ),
    ];
  }

  /// 일반 공지 생성 (페이지당 10개)
  List<NoticeModel> generateGeneralNotices({required int page}) {
    return List.generate(10, (index) {
      final id = (page - 1) * 10 + index + 3;
      return NoticeModel(
        id: id,
        title: '공지사항 제목 $id',
        content:
            '공지사항 내용입니다.\n\n# 제목\n- 항목 1\n- 항목 2\n\n자세한 내용은 공지사항을 확인해주세요.',
        category: 'general',
        isPinned: false,
        viewCount: 50 - id,
        createdAt:
            DateTime.now().subtract(Duration(days: id)).toIso8601String(),
      );
    });
  }
}
