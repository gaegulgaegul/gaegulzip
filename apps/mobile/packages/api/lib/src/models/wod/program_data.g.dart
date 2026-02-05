// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProgramDataImpl _$$ProgramDataImplFromJson(Map<String, dynamic> json) =>
    _$ProgramDataImpl(
      type: json['type'] as String,
      timeCap: (json['timeCap'] as num?)?.toInt(),
      rounds: (json['rounds'] as num?)?.toInt(),
      movements: (json['movements'] as List<dynamic>)
          .map((e) => Movement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ProgramDataImplToJson(_$ProgramDataImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'timeCap': instance.timeCap,
      'rounds': instance.rounds,
      'movements': instance.movements,
    };
