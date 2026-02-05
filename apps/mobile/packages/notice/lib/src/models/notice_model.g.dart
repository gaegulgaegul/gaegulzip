// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notice_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NoticeModelImpl _$$NoticeModelImplFromJson(Map<String, dynamic> json) =>
    _$NoticeModelImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      content: json['content'] as String?,
      category: json['category'] as String?,
      isPinned: json['isPinned'] as bool,
      isRead: json['isRead'] as bool? ?? false,
      viewCount: (json['viewCount'] as num).toInt(),
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$$NoticeModelImplToJson(_$NoticeModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'category': instance.category,
      'isPinned': instance.isPinned,
      'isRead': instance.isRead,
      'viewCount': instance.viewCount,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
