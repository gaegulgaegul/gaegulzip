import 'package:freezed_annotation/freezed_annotation.dart';

part 'movement.freezed.dart';
part 'movement.g.dart';

/// 운동 동작 모델
@freezed
class Movement with _$Movement {
  const factory Movement({
    /// 운동 이름
    required String name,

    /// 반복 횟수 (nullable)
    int? reps,

    /// 무게 (nullable)
    double? weight,

    /// 단위 (kg, lb, bw 등, nullable)
    String? unit,
  }) = _Movement;

  factory Movement.fromJson(Map<String, dynamic> json) =>
      _$MovementFromJson(json);
}
