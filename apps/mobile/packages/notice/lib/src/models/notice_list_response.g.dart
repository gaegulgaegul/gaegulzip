// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notice_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NoticeListResponseImpl _$$NoticeListResponseImplFromJson(
  Map<String, dynamic> json,
) => _$NoticeListResponseImpl(
  items: (json['items'] as List<dynamic>)
      .map((e) => NoticeModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalCount: (json['totalCount'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  hasNext: json['hasNext'] as bool,
);

Map<String, dynamic> _$$NoticeListResponseImplToJson(
  _$NoticeListResponseImpl instance,
) => <String, dynamic>{
  'items': instance.items,
  'totalCount': instance.totalCount,
  'page': instance.page,
  'limit': instance.limit,
  'hasNext': instance.hasNext,
};
