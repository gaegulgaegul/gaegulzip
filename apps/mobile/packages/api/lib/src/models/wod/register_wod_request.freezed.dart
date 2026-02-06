// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_wod_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RegisterWodRequest _$RegisterWodRequestFromJson(Map<String, dynamic> json) {
  return _RegisterWodRequest.fromJson(json);
}

/// @nodoc
mixin _$RegisterWodRequest {
  /// 박스 ID
  int get boxId => throw _privateConstructorUsedError;

  /// 날짜 (YYYY-MM-DD 형식)
  String get date => throw _privateConstructorUsedError;

  /// 프로그램 데이터
  ProgramData get programData => throw _privateConstructorUsedError;

  /// 원본 텍스트
  String get rawText => throw _privateConstructorUsedError;

  /// Serializes this RegisterWodRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RegisterWodRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RegisterWodRequestCopyWith<RegisterWodRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegisterWodRequestCopyWith<$Res> {
  factory $RegisterWodRequestCopyWith(
    RegisterWodRequest value,
    $Res Function(RegisterWodRequest) then,
  ) = _$RegisterWodRequestCopyWithImpl<$Res, RegisterWodRequest>;
  @useResult
  $Res call({int boxId, String date, ProgramData programData, String rawText});

  $ProgramDataCopyWith<$Res> get programData;
}

/// @nodoc
class _$RegisterWodRequestCopyWithImpl<$Res, $Val extends RegisterWodRequest>
    implements $RegisterWodRequestCopyWith<$Res> {
  _$RegisterWodRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RegisterWodRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? boxId = null,
    Object? date = null,
    Object? programData = null,
    Object? rawText = null,
  }) {
    return _then(
      _value.copyWith(
            boxId: null == boxId
                ? _value.boxId
                : boxId // ignore: cast_nullable_to_non_nullable
                      as int,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            programData: null == programData
                ? _value.programData
                : programData // ignore: cast_nullable_to_non_nullable
                      as ProgramData,
            rawText: null == rawText
                ? _value.rawText
                : rawText // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of RegisterWodRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProgramDataCopyWith<$Res> get programData {
    return $ProgramDataCopyWith<$Res>(_value.programData, (value) {
      return _then(_value.copyWith(programData: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RegisterWodRequestImplCopyWith<$Res>
    implements $RegisterWodRequestCopyWith<$Res> {
  factory _$$RegisterWodRequestImplCopyWith(
    _$RegisterWodRequestImpl value,
    $Res Function(_$RegisterWodRequestImpl) then,
  ) = __$$RegisterWodRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int boxId, String date, ProgramData programData, String rawText});

  @override
  $ProgramDataCopyWith<$Res> get programData;
}

/// @nodoc
class __$$RegisterWodRequestImplCopyWithImpl<$Res>
    extends _$RegisterWodRequestCopyWithImpl<$Res, _$RegisterWodRequestImpl>
    implements _$$RegisterWodRequestImplCopyWith<$Res> {
  __$$RegisterWodRequestImplCopyWithImpl(
    _$RegisterWodRequestImpl _value,
    $Res Function(_$RegisterWodRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RegisterWodRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? boxId = null,
    Object? date = null,
    Object? programData = null,
    Object? rawText = null,
  }) {
    return _then(
      _$RegisterWodRequestImpl(
        boxId: null == boxId
            ? _value.boxId
            : boxId // ignore: cast_nullable_to_non_nullable
                  as int,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        programData: null == programData
            ? _value.programData
            : programData // ignore: cast_nullable_to_non_nullable
                  as ProgramData,
        rawText: null == rawText
            ? _value.rawText
            : rawText // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RegisterWodRequestImpl implements _RegisterWodRequest {
  const _$RegisterWodRequestImpl({
    required this.boxId,
    required this.date,
    required this.programData,
    required this.rawText,
  });

  factory _$RegisterWodRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$RegisterWodRequestImplFromJson(json);

  /// 박스 ID
  @override
  final int boxId;

  /// 날짜 (YYYY-MM-DD 형식)
  @override
  final String date;

  /// 프로그램 데이터
  @override
  final ProgramData programData;

  /// 원본 텍스트
  @override
  final String rawText;

  @override
  String toString() {
    return 'RegisterWodRequest(boxId: $boxId, date: $date, programData: $programData, rawText: $rawText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterWodRequestImpl &&
            (identical(other.boxId, boxId) || other.boxId == boxId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.programData, programData) ||
                other.programData == programData) &&
            (identical(other.rawText, rawText) || other.rawText == rawText));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, boxId, date, programData, rawText);

  /// Create a copy of RegisterWodRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegisterWodRequestImplCopyWith<_$RegisterWodRequestImpl> get copyWith =>
      __$$RegisterWodRequestImplCopyWithImpl<_$RegisterWodRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RegisterWodRequestImplToJson(this);
  }
}

abstract class _RegisterWodRequest implements RegisterWodRequest {
  const factory _RegisterWodRequest({
    required final int boxId,
    required final String date,
    required final ProgramData programData,
    required final String rawText,
  }) = _$RegisterWodRequestImpl;

  factory _RegisterWodRequest.fromJson(Map<String, dynamic> json) =
      _$RegisterWodRequestImpl.fromJson;

  /// 박스 ID
  @override
  int get boxId;

  /// 날짜 (YYYY-MM-DD 형식)
  @override
  String get date;

  /// 프로그램 데이터
  @override
  ProgramData get programData;

  /// 원본 텍스트
  @override
  String get rawText;

  /// Create a copy of RegisterWodRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegisterWodRequestImplCopyWith<_$RegisterWodRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
