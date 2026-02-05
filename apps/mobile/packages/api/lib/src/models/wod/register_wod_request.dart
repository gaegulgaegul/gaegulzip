import 'package:freezed_annotation/freezed_annotation.dart';
import 'program_data.dart';

part 'register_wod_request.freezed.dart';
part 'register_wod_request.g.dart';

/// WOD 등록 요청 모델
@freezed
class RegisterWodRequest with _$RegisterWodRequest {
  const factory RegisterWodRequest({
    /// 박스 ID
    required int boxId,

    /// 날짜 (YYYY-MM-DD 형식)
    required String date,

    /// 프로그램 데이터
    required ProgramData programData,

    /// 원본 텍스트
    required String rawText,
  }) = _RegisterWodRequest;

  factory RegisterWodRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterWodRequestFromJson(json);
}
