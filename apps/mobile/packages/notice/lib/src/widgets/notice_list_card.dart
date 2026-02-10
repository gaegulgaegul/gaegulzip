import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import '../models/notice_model.dart';

/// 공지사항 목록 카드 위젯
///
/// 목록 화면에서 각 공지사항을 표시하는 재사용 가능한 위젯입니다.
class NoticeListCard extends StatelessWidget {
  /// 공지사항 데이터
  final NoticeModel notice;

  /// 탭 콜백
  final VoidCallback onTap;

  const NoticeListCard({
    super.key,
    required this.notice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SketchCard(
        elevation: notice.isRead ? 1 : 2,
        borderColor: notice.isRead
            ? SketchDesignTokens.base300
            : SketchDesignTokens.accentPrimary,
        fillColor: notice.isRead
            ? Colors.white
            : const Color(0xFFFFF9F7), // 아주 연한 오렌지
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 읽지 않음 점
              Column(
                children: [
                  if (!notice.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: SketchDesignTokens.accentPrimary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  if (notice.isRead) const SizedBox(width: 8),
                  const SizedBox(height: 24),
                ],
              ),
              const SizedBox(width: 8),

              // 콘텐츠 영역
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목 + 고정 아이콘
                    Row(
                      children: [
                        if (notice.isPinned) ...[
                          const Icon(
                            Icons.push_pin,
                            size: 16,
                            color: Color(0xFFC86947),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            notice.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  notice.isRead ? FontWeight.w500 : FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // 카테고리
                    if (notice.category != null) ...[
                      SketchChip(
                        label: notice.category!,
                        fillColor: SketchDesignTokens.base100,
                        labelColor: SketchDesignTokens.base700,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],

                    // 메타 정보 (조회수, 날짜)
                    Row(
                      children: [
                        const Icon(Icons.visibility, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${notice.viewCount}회',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(notice.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 화살표
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 날짜 포맷 (예: 2026.02.04)
  String _formatDate(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.'
          '${dateTime.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr; // 파싱 실패 시 원본 반환
    }
  }
}
