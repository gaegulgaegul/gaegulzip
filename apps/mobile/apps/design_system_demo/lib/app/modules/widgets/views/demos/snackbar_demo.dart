import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Snackbar 데모 화면
///
/// 4가지 타입(success, info, warning, error)의 SketchSnackbar를
/// 버튼으로 표시하여 확인할 수 있는 데모.
class SnackbarDemo extends StatelessWidget {
  const SnackbarDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSnackbarButton(
            context,
            label: 'Success Snackbar',
            message: '작업이 성공적으로 완료되었습니다!',
            type: SnackbarType.success,
          ),
          const SizedBox(height: 16),
          _buildSnackbarButton(
            context,
            label: 'Info Snackbar',
            message: '새로운 업데이트가 있습니다.',
            type: SnackbarType.info,
          ),
          const SizedBox(height: 16),
          _buildSnackbarButton(
            context,
            label: 'Warning Snackbar',
            message: '입력 항목을 다시 확인해주세요.',
            type: SnackbarType.warning,
          ),
          const SizedBox(height: 16),
          _buildSnackbarButton(
            context,
            label: 'Error Snackbar',
            message: '네트워크 오류가 발생했습니다. 다시 시도해주세요.',
            type: SnackbarType.error,
          ),
          const SizedBox(height: 32),
          // 긴 메시지 테스트
          _buildSnackbarButton(
            context,
            label: 'Long Message',
            message:
                '매우 긴 메시지 텍스트입니다. 이 메시지는 3줄까지 표시되며, '
                '그 이상은 ellipsis로 생략됩니다. '
                'maxLines 속성이 정상 동작하는지 확인합니다.',
            type: SnackbarType.info,
          ),
        ],
      ),
    );
  }

  /// Snackbar 표시 버튼 생성
  Widget _buildSnackbarButton(
    BuildContext context, {
    required String label,
    required String message,
    required SnackbarType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    return SketchButton(
      text: label,
      onPressed: () {
        showSketchSnackbar(
          context,
          message: message,
          type: type,
          duration: duration,
        );
      },
    );
  }
}
