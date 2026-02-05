// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qna_submit_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QnaSubmitResponseImpl _$$QnaSubmitResponseImplFromJson(
  Map<String, dynamic> json,
) => _$QnaSubmitResponseImpl(
  questionId: (json['questionId'] as num).toInt(),
  issueNumber: (json['issueNumber'] as num).toInt(),
  issueUrl: json['issueUrl'] as String,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$$QnaSubmitResponseImplToJson(
  _$QnaSubmitResponseImpl instance,
) => <String, dynamic>{
  'questionId': instance.questionId,
  'issueNumber': instance.issueNumber,
  'issueUrl': instance.issueUrl,
  'createdAt': instance.createdAt,
};
