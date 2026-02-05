import 'package:freezed_annotation/freezed_annotation.dart';

part 'proposal_model.freezed.dart';
part 'proposal_model.g.dart';

/// WOD 변경 제안 모델
@freezed
class ProposalModel with _$ProposalModel {
  const factory ProposalModel({
    /// 제안 고유 ID
    required int id,

    /// 기존 Base WOD ID
    required int baseWodId,

    /// 제안된 WOD ID
    required int proposedWodId,

    /// 상태 (pending, approved, rejected)
    required String status,

    /// 제안 시간 (ISO 8601 형식)
    required String proposedAt,

    /// 처리 시간 (ISO 8601 형식, nullable)
    String? resolvedAt,

    /// 처리자 ID (nullable)
    int? resolvedBy,
  }) = _ProposalModel;

  factory ProposalModel.fromJson(Map<String, dynamic> json) =>
      _$ProposalModelFromJson(json);
}
