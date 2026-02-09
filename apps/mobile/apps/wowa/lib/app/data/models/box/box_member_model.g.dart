// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'box_member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BoxMemberModelImpl _$$BoxMemberModelImplFromJson(Map<String, dynamic> json) =>
    _$BoxMemberModelImpl(
      id: (json['id'] as num).toInt(),
      boxId: (json['boxId'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      role: json['role'] as String?,
      joinedAt: json['joinedAt'] as String,
      user: json['user'] == null
          ? null
          : UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$BoxMemberModelImplToJson(
  _$BoxMemberModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'boxId': instance.boxId,
  'userId': instance.userId,
  'role': instance.role,
  'joinedAt': instance.joinedAt,
  'user': instance.user,
};
