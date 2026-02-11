import 'package:flutter/material.dart';
import 'package:notice/notice.dart';

/// Notice SDK 데모 화면
///
/// SDK 원본 NoticeListView를 직접 렌더링합니다.
/// SdkNoticeDemoBinding에서 MockNoticeListController가 주입되므로
/// 서버 연동 없이 모의 데이터로 동작합니다.
class SdkNoticeDemoView extends StatelessWidget {
  const SdkNoticeDemoView({super.key});

  @override
  Widget build(BuildContext context) {
    return const NoticeListView();
  }
}
