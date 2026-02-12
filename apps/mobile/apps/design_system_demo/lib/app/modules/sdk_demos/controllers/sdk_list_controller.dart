import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../models/sdk_item.dart';

/// SDK 목록 컨트롤러
///
/// 데모 가능한 SDK 항목 목록을 관리합니다.
class SdkListController extends GetxController {
  /// SDK 항목 목록
  final List<SdkItem> sdkItems = const [
    SdkItem(
      name: 'QnA SDK',
      icon: Icons.question_answer,
      route: Routes.SDK_QNA_DEMO,
      description: '질문 제출 기능 테스트',
    ),
    SdkItem(
      name: 'Notice SDK',
      icon: Icons.notifications,
      route: Routes.SDK_NOTICE_DEMO,
      description: '공지사항 목록/상세 테스트',
    ),
  ];

  /// SDK 데모 화면으로 네비게이션
  void navigateToSdk(String route) {
    Get.toNamed(route);
  }
}
