import 'package:flutter/material.dart';
import 'package:qna/qna.dart';

/// QnA SDK 데모 화면
///
/// SDK 원본 QnaSubmitView를 직접 렌더링합니다.
/// QnaBinding(appCode: 'demo')에서 QnaController가 주입되며,
/// 실서버와 연동됩니다.
class SdkQnaDemoView extends StatelessWidget {
  const SdkQnaDemoView({super.key});

  @override
  Widget build(BuildContext context) {
    return const QnaSubmitView();
  }
}
