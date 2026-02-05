import 'package:freezed_annotation/freezed_annotation.dart';

part 'selection_model.freezed.dart';
part 'selection_model.g.dart';

/// WOD 선택 기록 모델
@freezed
class WodSelectionModel with _$WodSelectionModel {
  const factory WodSelectionModel({
    /// 선택 기록 ID
    required int id,

    /// 사용자 ID
    required int userId,

    /// 선택한 WOD ID
    required int wodId,

    /// 박스 ID
    required int boxId,

    /// 날짜 (YYYY-MM-DD 형식)
    required String date,

    /// 선택 시점의 WOD 스냅샷 (불변, JSONB 데이터)
    required Map<String, dynamic> snapshotData,

    /// 생성 시간 (ISO 8601 형식)
    required String createdAt,
  }) = _WodSelectionModel;

  factory WodSelectionModel.fromJson(Map<String, dynamic> json) =>
      _$WodSelectionModelFromJson(json);
}
