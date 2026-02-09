import 'package:freezed_annotation/freezed_annotation.dart';
import 'wod_model.dart';

part 'wod_list_response.freezed.dart';
part 'wod_list_response.g.dart';

/// WOD 목록 응답 모델
@freezed
class WodListResponse with _$WodListResponse {
  const factory WodListResponse({
    /// Base WOD (nullable)
    WodModel? baseWod,

    /// Personal WOD 목록
    required List<WodModel> personalWods,
  }) = _WodListResponse;

  factory WodListResponse.fromJson(Map<String, dynamic> json) =>
      _$WodListResponseFromJson(json);
}
