// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wod_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WodListResponseImpl _$$WodListResponseImplFromJson(
  Map<String, dynamic> json,
) => _$WodListResponseImpl(
  baseWod: json['baseWod'] == null
      ? null
      : WodModel.fromJson(json['baseWod'] as Map<String, dynamic>),
  personalWods: (json['personalWods'] as List<dynamic>)
      .map((e) => WodModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$WodListResponseImplToJson(
  _$WodListResponseImpl instance,
) => <String, dynamic>{
  'baseWod': instance.baseWod,
  'personalWods': instance.personalWods,
};
