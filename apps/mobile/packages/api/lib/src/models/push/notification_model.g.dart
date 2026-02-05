// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationModelImpl _$$NotificationModelImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationModelImpl(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  body: json['body'] as String,
  imageUrl: json['imageUrl'] as String?,
  data: json['data'] as Map<String, dynamic>? ?? const {},
  isRead: json['isRead'] as bool,
  readAt: json['readAt'] as String?,
  receivedAt: json['receivedAt'] as String,
);

Map<String, dynamic> _$$NotificationModelImplToJson(
  _$NotificationModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'body': instance.body,
  'imageUrl': instance.imageUrl,
  'data': instance.data,
  'isRead': instance.isRead,
  'readAt': instance.readAt,
  'receivedAt': instance.receivedAt,
};
