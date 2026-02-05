// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'qna_submit_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

QnaSubmitResponse _$QnaSubmitResponseFromJson(Map<String, dynamic> json) {
  return _QnaSubmitResponse.fromJson(json);
}

/// @nodoc
mixin _$QnaSubmitResponse {
  /// 생성된 질문 ID
  int get questionId => throw _privateConstructorUsedError;

  /// GitHub Issue 번호
  int get issueNumber => throw _privateConstructorUsedError;

  /// GitHub Issue URL
  String get issueUrl => throw _privateConstructorUsedError;

  /// 생성 일시 (ISO 8601)
  String get createdAt => throw _privateConstructorUsedError;

  /// Serializes this QnaSubmitResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QnaSubmitResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QnaSubmitResponseCopyWith<QnaSubmitResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QnaSubmitResponseCopyWith<$Res> {
  factory $QnaSubmitResponseCopyWith(
    QnaSubmitResponse value,
    $Res Function(QnaSubmitResponse) then,
  ) = _$QnaSubmitResponseCopyWithImpl<$Res, QnaSubmitResponse>;
  @useResult
  $Res call({
    int questionId,
    int issueNumber,
    String issueUrl,
    String createdAt,
  });
}

/// @nodoc
class _$QnaSubmitResponseCopyWithImpl<$Res, $Val extends QnaSubmitResponse>
    implements $QnaSubmitResponseCopyWith<$Res> {
  _$QnaSubmitResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QnaSubmitResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionId = null,
    Object? issueNumber = null,
    Object? issueUrl = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            questionId: null == questionId
                ? _value.questionId
                : questionId // ignore: cast_nullable_to_non_nullable
                      as int,
            issueNumber: null == issueNumber
                ? _value.issueNumber
                : issueNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            issueUrl: null == issueUrl
                ? _value.issueUrl
                : issueUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QnaSubmitResponseImplCopyWith<$Res>
    implements $QnaSubmitResponseCopyWith<$Res> {
  factory _$$QnaSubmitResponseImplCopyWith(
    _$QnaSubmitResponseImpl value,
    $Res Function(_$QnaSubmitResponseImpl) then,
  ) = __$$QnaSubmitResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int questionId,
    int issueNumber,
    String issueUrl,
    String createdAt,
  });
}

/// @nodoc
class __$$QnaSubmitResponseImplCopyWithImpl<$Res>
    extends _$QnaSubmitResponseCopyWithImpl<$Res, _$QnaSubmitResponseImpl>
    implements _$$QnaSubmitResponseImplCopyWith<$Res> {
  __$$QnaSubmitResponseImplCopyWithImpl(
    _$QnaSubmitResponseImpl _value,
    $Res Function(_$QnaSubmitResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QnaSubmitResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionId = null,
    Object? issueNumber = null,
    Object? issueUrl = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$QnaSubmitResponseImpl(
        questionId: null == questionId
            ? _value.questionId
            : questionId // ignore: cast_nullable_to_non_nullable
                  as int,
        issueNumber: null == issueNumber
            ? _value.issueNumber
            : issueNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        issueUrl: null == issueUrl
            ? _value.issueUrl
            : issueUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QnaSubmitResponseImpl implements _QnaSubmitResponse {
  const _$QnaSubmitResponseImpl({
    required this.questionId,
    required this.issueNumber,
    required this.issueUrl,
    required this.createdAt,
  });

  factory _$QnaSubmitResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$QnaSubmitResponseImplFromJson(json);

  /// 생성된 질문 ID
  @override
  final int questionId;

  /// GitHub Issue 번호
  @override
  final int issueNumber;

  /// GitHub Issue URL
  @override
  final String issueUrl;

  /// 생성 일시 (ISO 8601)
  @override
  final String createdAt;

  @override
  String toString() {
    return 'QnaSubmitResponse(questionId: $questionId, issueNumber: $issueNumber, issueUrl: $issueUrl, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QnaSubmitResponseImpl &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            (identical(other.issueNumber, issueNumber) ||
                other.issueNumber == issueNumber) &&
            (identical(other.issueUrl, issueUrl) ||
                other.issueUrl == issueUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, questionId, issueNumber, issueUrl, createdAt);

  /// Create a copy of QnaSubmitResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QnaSubmitResponseImplCopyWith<_$QnaSubmitResponseImpl> get copyWith =>
      __$$QnaSubmitResponseImplCopyWithImpl<_$QnaSubmitResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$QnaSubmitResponseImplToJson(this);
  }
}

abstract class _QnaSubmitResponse implements QnaSubmitResponse {
  const factory _QnaSubmitResponse({
    required final int questionId,
    required final int issueNumber,
    required final String issueUrl,
    required final String createdAt,
  }) = _$QnaSubmitResponseImpl;

  factory _QnaSubmitResponse.fromJson(Map<String, dynamic> json) =
      _$QnaSubmitResponseImpl.fromJson;

  /// 생성된 질문 ID
  @override
  int get questionId;

  /// GitHub Issue 번호
  @override
  int get issueNumber;

  /// GitHub Issue URL
  @override
  String get issueUrl;

  /// 생성 일시 (ISO 8601)
  @override
  String get createdAt;

  /// Create a copy of QnaSubmitResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QnaSubmitResponseImplCopyWith<_$QnaSubmitResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
