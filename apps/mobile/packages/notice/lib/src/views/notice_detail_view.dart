import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:design_system/design_system.dart';
import '../controllers/notice_detail_controller.dart';
import '../models/notice_model.dart';

/// 공지사항 상세 화면
class NoticeDetailView extends GetView<NoticeDetailController> {
  const NoticeDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공지사항'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        // 로딩 상태
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        // 에러 상태
        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorState();
        }

        // 데이터 있음
        final notice = controller.notice.value;
        if (notice == null) {
          return const SizedBox.shrink();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(notice),
              const SizedBox(height: 24),
              _buildMetaRow(notice),
              const SizedBox(height: 16),
              const Divider(thickness: 1),
              const SizedBox(height: 16),
              _buildMarkdownBody(notice.content ?? ''),
            ],
          ),
        );
      }),
    );
  }

  /// 헤더 (고정 태그 + 제목 + 카테고리)
  Widget _buildHeader(NoticeModel notice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 고정 태그
        if (notice.isPinned)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: SketchDesignTokens.accentLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.push_pin, size: 14, color: Color(0xFFC86947)),
                SizedBox(width: 4),
                Text(
                  '고정',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFC86947),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),

        // 제목
        Text(
          notice.title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // 카테고리
        if (notice.category != null)
          SketchChip(
            label: notice.category!,
            backgroundColor: SketchDesignTokens.base100,
            textColor: SketchDesignTokens.base700,
          ),
      ],
    );
  }

  /// 메타 정보 (조회수, 작성일시)
  Widget _buildMetaRow(NoticeModel notice) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.visibility, size: 16, color: Colors.grey),
            const SizedBox(width: 6),
            Text(
              '조회 ${notice.viewCount}회',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
            const SizedBox(width: 6),
            Text(
              _formatDateTime(notice.createdAt),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  /// 마크다운 본문
  Widget _buildMarkdownBody(String content) {
    return MarkdownBody(
      data: content,
      styleSheet: MarkdownStyleSheet(
        h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        p: const TextStyle(fontSize: 16, height: 1.6),
        a: TextStyle(
          color: SketchDesignTokens.accentPrimary,
          decoration: TextDecoration.underline,
        ),
        code: const TextStyle(
          fontFamily: 'Courier',
          fontSize: 14,
          backgroundColor: Color(0xFFF7F7F7),
        ),
        codeblockDecoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFDCDCDC), width: 1),
        ),
        listBullet: TextStyle(fontSize: 16, color: SketchDesignTokens.accentPrimary),
        blockquote: const TextStyle(
          fontSize: 16,
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
        blockquoteDecoration: BoxDecoration(
          color: const Color(0xFFF7F7F7).withOpacity(0.5),
          borderRadius: BorderRadius.circular(4),
          border: const Border(
            left: BorderSide(color: Color(0xFFF19E7E), width: 4),
          ),
        ),
      ),
      onTapLink: (text, href, title) {
        if (href != null) {
          launchUrl(Uri.parse(href));
        }
      },
    );
  }

  /// 날짜/시간 포맷 (예: 2026년 2월 4일 14:30)
  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일 '
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr; // 파싱 실패 시 원본 반환
    }
  }

  /// 로딩 상태
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('공지사항을 불러오는 중...'),
        ],
      ),
    );
  }

  /// 에러 상태
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Obx(() => Text(
                  controller.errorMessage.value,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                )),
            const SizedBox(height: 24),
            SketchButton(
              text: '목록으로',
              style: SketchButtonStyle.outline,
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }
}
