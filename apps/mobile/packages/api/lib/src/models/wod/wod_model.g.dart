// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wod_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WodModelImpl _$$WodModelImplFromJson(Map<String, dynamic> json) =>
    _$WodModelImpl(
      id: (json['id'] as num).toInt(),
      boxId: (json['boxId'] as num).toInt(),
      date: json['date'] as String,
      programData: ProgramData.fromJson(
        json['programData'] as Map<String, dynamic>,
      ),
      rawText: json['rawText'] as String?,
      isBase: json['isBase'] as bool,
      createdBy: (json['createdBy'] as num).toInt(),
      registeredBy: json['registeredBy'] as String?,
      selectedCount: (json['selectedCount'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$$WodModelImplToJson(_$WodModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'boxId': instance.boxId,
      'date': instance.date,
      'programData': instance.programData,
      'rawText': instance.rawText,
      'isBase': instance.isBase,
      'createdBy': instance.createdBy,
      'registeredBy': instance.registeredBy,
      'selectedCount': instance.selectedCount,
      'createdAt': instance.createdAt,
    };
