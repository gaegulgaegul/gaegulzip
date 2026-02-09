// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MovementImpl _$$MovementImplFromJson(Map<String, dynamic> json) =>
    _$MovementImpl(
      name: json['name'] as String,
      reps: (json['reps'] as num?)?.toInt(),
      weight: (json['weight'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
    );

Map<String, dynamic> _$$MovementImplToJson(_$MovementImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'reps': instance.reps,
      'weight': instance.weight,
      'unit': instance.unit,
    };
