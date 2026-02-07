// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: (json['id'] as num).toInt(),
      provider: json['provider'] as String,
      email: json['email'] as String?,
      nickname: json['nickname'] as String?,
      profileImage: json['profileImage'] as String?,
      appCode: json['appCode'] as String,
      lastLoginAt: json['lastLoginAt'] as String,
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'provider': instance.provider,
      'email': instance.email,
      'nickname': instance.nickname,
      'profileImage': instance.profileImage,
      'appCode': instance.appCode,
      'lastLoginAt': instance.lastLoginAt,
    };
