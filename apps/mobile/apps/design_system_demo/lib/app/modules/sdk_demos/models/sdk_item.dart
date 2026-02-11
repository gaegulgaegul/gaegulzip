import 'package:flutter/material.dart';

/// SDK 항목 데이터 모델
class SdkItem {
  /// SDK 이름
  final String name;

  /// SDK 아이콘
  final IconData icon;

  /// 네비게이션 라우트
  final String route;

  /// SDK 설명
  final String description;

  const SdkItem({
    required this.name,
    required this.icon,
    required this.route,
    required this.description,
  });
}
