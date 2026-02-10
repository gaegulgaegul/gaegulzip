// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MembershipModelImpl _$$MembershipModelImplFromJson(
  Map<String, dynamic> json,
) => _$MembershipModelImpl(
  id: (json['id'] as num).toInt(),
  boxId: (json['boxId'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  joinedAt: json['joinedAt'] as String,
);

Map<String, dynamic> _$$MembershipModelImplToJson(
  _$MembershipModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'boxId': instance.boxId,
  'userId': instance.userId,
  'joinedAt': instance.joinedAt,
};
