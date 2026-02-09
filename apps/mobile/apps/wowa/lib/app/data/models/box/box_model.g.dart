// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'box_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BoxModelImpl _$$BoxModelImplFromJson(Map<String, dynamic> json) =>
    _$BoxModelImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      region: json['region'] as String,
      description: json['description'] as String?,
      memberCount: (json['memberCount'] as num?)?.toInt(),
      joinedAt: json['joinedAt'] as String?,
    );

Map<String, dynamic> _$$BoxModelImplToJson(_$BoxModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'region': instance.region,
      'description': instance.description,
      'memberCount': instance.memberCount,
      'joinedAt': instance.joinedAt,
    };
