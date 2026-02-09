// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'box_create_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BoxCreateResponseImpl _$$BoxCreateResponseImplFromJson(
  Map<String, dynamic> json,
) => _$BoxCreateResponseImpl(
  box: BoxModel.fromJson(json['box'] as Map<String, dynamic>),
  membership: MembershipModel.fromJson(
    json['membership'] as Map<String, dynamic>,
  ),
  previousBoxId: (json['previousBoxId'] as num?)?.toInt(),
);

Map<String, dynamic> _$$BoxCreateResponseImplToJson(
  _$BoxCreateResponseImpl instance,
) => <String, dynamic>{
  'box': instance.box,
  'membership': instance.membership,
  'previousBoxId': instance.previousBoxId,
};
