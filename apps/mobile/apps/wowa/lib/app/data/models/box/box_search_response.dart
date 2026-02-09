import 'package:freezed_annotation/freezed_annotation.dart';
import 'box_model.dart';

part 'box_search_response.freezed.dart';
part 'box_search_response.g.dart';

/// 박스 검색 응답 모델
@freezed
class BoxSearchResponse with _$BoxSearchResponse {
  const factory BoxSearchResponse({
    /// 검색된 박스 목록
    required List<BoxModel> boxes,
  }) = _BoxSearchResponse;

  factory BoxSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$BoxSearchResponseFromJson(json);
}
