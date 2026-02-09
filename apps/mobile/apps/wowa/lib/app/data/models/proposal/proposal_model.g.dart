// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proposal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProposalModelImpl _$$ProposalModelImplFromJson(Map<String, dynamic> json) =>
    _$ProposalModelImpl(
      id: (json['id'] as num).toInt(),
      baseWodId: (json['baseWodId'] as num).toInt(),
      proposedWodId: (json['proposedWodId'] as num).toInt(),
      status: json['status'] as String,
      proposedAt: json['proposedAt'] as String,
      resolvedAt: json['resolvedAt'] as String?,
      resolvedBy: (json['resolvedBy'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ProposalModelImplToJson(_$ProposalModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'baseWodId': instance.baseWodId,
      'proposedWodId': instance.proposedWodId,
      'status': instance.status,
      'proposedAt': instance.proposedAt,
      'resolvedAt': instance.resolvedAt,
      'resolvedBy': instance.resolvedBy,
    };
