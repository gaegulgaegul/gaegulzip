// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selection_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WodSelectionModelImpl _$$WodSelectionModelImplFromJson(
  Map<String, dynamic> json,
) => _$WodSelectionModelImpl(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  wodId: (json['wodId'] as num).toInt(),
  boxId: (json['boxId'] as num).toInt(),
  date: json['date'] as String,
  snapshotData: json['snapshotData'] as Map<String, dynamic>,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$$WodSelectionModelImplToJson(
  _$WodSelectionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'wodId': instance.wodId,
  'boxId': instance.boxId,
  'date': instance.date,
  'snapshotData': instance.snapshotData,
  'createdAt': instance.createdAt,
};
