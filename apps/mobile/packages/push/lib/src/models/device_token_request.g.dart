// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_token_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeviceTokenRequestImpl _$$DeviceTokenRequestImplFromJson(
  Map<String, dynamic> json,
) => _$DeviceTokenRequestImpl(
  token: json['token'] as String,
  platform: json['platform'] as String,
  deviceId: json['deviceId'] as String?,
);

Map<String, dynamic> _$$DeviceTokenRequestImplToJson(
  _$DeviceTokenRequestImpl instance,
) => <String, dynamic>{
  'token': instance.token,
  'platform': instance.platform,
  if (instance.deviceId case final value?) 'deviceId': value,
};
