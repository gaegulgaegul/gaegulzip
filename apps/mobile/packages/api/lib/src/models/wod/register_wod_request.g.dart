// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_wod_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RegisterWodRequestImpl _$$RegisterWodRequestImplFromJson(
  Map<String, dynamic> json,
) => _$RegisterWodRequestImpl(
  boxId: (json['boxId'] as num).toInt(),
  date: json['date'] as String,
  programData: ProgramData.fromJson(
    json['programData'] as Map<String, dynamic>,
  ),
  rawText: json['rawText'] as String,
);

Map<String, dynamic> _$$RegisterWodRequestImplToJson(
  _$RegisterWodRequestImpl instance,
) => <String, dynamic>{
  'boxId': instance.boxId,
  'date': instance.date,
  'programData': instance.programData,
  'rawText': instance.rawText,
};
