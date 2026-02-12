import 'package:flutter/material.dart';
import 'package:notice/notice.dart';

/// Notice SDK 데모 화면
///
/// SDK 원본 NoticeListView를 직접 렌더링합니다.
/// NoticeBinding(appCode: 'demo')에서 NoticeListController가 주입되며,
/// 실서버와 연동됩니다.
class SdkNoticeDemoView extends StatelessWidget {
  const SdkNoticeDemoView({super.key});

  @override
  Widget build(BuildContext context) {
    return const NoticeListView();
  }
}
