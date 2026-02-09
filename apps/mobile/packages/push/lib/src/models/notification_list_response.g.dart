// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationListResponseImpl _$$NotificationListResponseImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationListResponseImpl(
  notifications: (json['notifications'] as List<dynamic>)
      .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$$NotificationListResponseImplToJson(
  _$NotificationListResponseImpl instance,
) => <String, dynamic>{
  'notifications': instance.notifications,
  'total': instance.total,
};
