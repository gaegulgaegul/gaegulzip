import 'package:flutter/material.dart';

/// 읽지 않은 공지 뱃지 위젯
///
/// 앱 메인 화면에서 읽지 않은 공지 개수를 표시합니다.
class UnreadNoticeBadge extends StatelessWidget {
  /// 읽지 않은 개수
  final int unreadCount;

  /// 뱃지를 표시할 자식 위젯
  final Widget child;

  const UnreadNoticeBadge({
    super.key,
    required this.unreadCount,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: unreadCount < 10 ? 6 : 4,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF44336), // error red
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 2),
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Center(
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
