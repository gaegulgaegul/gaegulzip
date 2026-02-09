import 'package:freezed_annotation/freezed_annotation.dart';
import 'movement.dart';

part 'program_data.freezed.dart';
part 'program_data.g.dart';

/// WOD 프로그램 데이터 모델
@freezed
class ProgramData with _$ProgramData {
  const factory ProgramData({
    /// WOD 타입 (AMRAP, ForTime, EMOM, Strength, Custom)
    required String type,

    /// 시간 제한 (분, nullable)
    int? timeCap,

    /// 라운드 수 (nullable)
    int? rounds,

    /// 운동 목록
    required List<Movement> movements,
  }) = _ProgramData;

  factory ProgramData.fromJson(Map<String, dynamic> json) =>
      _$ProgramDataFromJson(json);
}
