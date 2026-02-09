// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_box_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateBoxRequestImpl _$$CreateBoxRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CreateBoxRequestImpl(
  name: json['name'] as String,
  region: json['region'] as String,
  description: json['description'] as String?,
);

Map<String, dynamic> _$$CreateBoxRequestImplToJson(
  _$CreateBoxRequestImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'region': instance.region,
  'description': instance.description,
};
