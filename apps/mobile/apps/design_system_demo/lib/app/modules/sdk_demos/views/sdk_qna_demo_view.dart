import 'package:flutter/material.dart';
import 'package:qna/qna.dart';

/// QnA SDK 데모 화면
///
/// SDK 원본 QnaSubmitView를 직접 렌더링합니다.
/// SdkQnaDemoBinding에서 MockQnaController가 주입되므로
/// 서버 연동 없이 모의 응답으로 동작합니다.
class SdkQnaDemoView extends StatelessWidget {
  const SdkQnaDemoView({super.key});

  @override
  Widget build(BuildContext context) {
    return const QnaSubmitView();
  }
}
