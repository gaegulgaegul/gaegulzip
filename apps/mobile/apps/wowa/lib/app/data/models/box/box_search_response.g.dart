// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'box_search_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BoxSearchResponseImpl _$$BoxSearchResponseImplFromJson(
  Map<String, dynamic> json,
) => _$BoxSearchResponseImpl(
  boxes: (json['boxes'] as List<dynamic>)
      .map((e) => BoxModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$BoxSearchResponseImplToJson(
  _$BoxSearchResponseImpl instance,
) => <String, dynamic>{'boxes': instance.boxes};
