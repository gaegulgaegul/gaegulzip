import 'package:get/get.dart';
import 'package:notice/notice.dart';

import '../controllers/mock_notice_list_controller.dart';

/// Notice 데모 화면 바인딩
///
/// MockNoticeListController를 NoticeListController 타입으로 등록합니다.
/// NoticeListView 내부의 GetView가 Mock을 자동 사용합니다.
class SdkNoticeDemoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NoticeListController>(() => MockNoticeListController());
  }
}
