// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'qna_submit_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

QnaSubmitRequest _$QnaSubmitRequestFromJson(Map<String, dynamic> json) {
  return _QnaSubmitRequest.fromJson(json);
}

/// @nodoc
mixin _$QnaSubmitRequest {
  /// 앱 코드 ('wowa')
  String get appCode => throw _privateConstructorUsedError;

  /// 질문 제목 (최대 256자)
  String get title => throw _privateConstructorUsedError;

  /// 질문 본문 (최대 65536자)
  String get body => throw _privateConstructorUsedError;

  /// Serializes this QnaSubmitRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QnaSubmitRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QnaSubmitRequestCopyWith<QnaSubmitRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QnaSubmitRequestCopyWith<$Res> {
  factory $QnaSubmitRequestCopyWith(
    QnaSubmitRequest value,
    $Res Function(QnaSubmitRequest) then,
  ) = _$QnaSubmitRequestCopyWithImpl<$Res, QnaSubmitRequest>;
  @useResult
  $Res call({String appCode, String title, String body});
}

/// @nodoc
class _$QnaSubmitRequestCopyWithImpl<$Res, $Val extends QnaSubmitRequest>
    implements $QnaSubmitRequestCopyWith<$Res> {
  _$QnaSubmitRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QnaSubmitRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? appCode = null,
    Object? title = null,
    Object? body = null,
  }) {
    return _then(
      _value.copyWith(
            appCode: null == appCode
                ? _value.appCode
                : appCode // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QnaSubmitRequestImplCopyWith<$Res>
    implements $QnaSubmitRequestCopyWith<$Res> {
  factory _$$QnaSubmitRequestImplCopyWith(
    _$QnaSubmitRequestImpl value,
    $Res Function(_$QnaSubmitRequestImpl) then,
  ) = __$$QnaSubmitRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String appCode, String title, String body});
}

/// @nodoc
class __$$QnaSubmitRequestImplCopyWithImpl<$Res>
    extends _$QnaSubmitRequestCopyWithImpl<$Res, _$QnaSubmitRequestImpl>
    implements _$$QnaSubmitRequestImplCopyWith<$Res> {
  __$$QnaSubmitRequestImplCopyWithImpl(
    _$QnaSubmitRequestImpl _value,
    $Res Function(_$QnaSubmitRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QnaSubmitRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? appCode = null,
    Object? title = null,
    Object? body = null,
  }) {
    return _then(
      _$QnaSubmitRequestImpl(
        appCode: null == appCode
            ? _value.appCode
            : appCode // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QnaSubmitRequestImpl implements _QnaSubmitRequest {
  const _$QnaSubmitRequestImpl({
    required this.appCode,
    required this.title,
    required this.body,
  });

  factory _$QnaSubmitRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$QnaSubmitRequestImplFromJson(json);

  /// 앱 코드 ('wowa')
  @override
  final String appCode;

  /// 질문 제목 (최대 256자)
  @override
  final String title;

  /// 질문 본문 (최대 65536자)
  @override
  final String body;

  @override
  String toString() {
    return 'QnaSubmitRequest(appCode: $appCode, title: $title, body: $body)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QnaSubmitRequestImpl &&
            (identical(other.appCode, appCode) || other.appCode == appCode) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, appCode, title, body);

  /// Create a copy of QnaSubmitRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QnaSubmitRequestImplCopyWith<_$QnaSubmitRequestImpl> get copyWith =>
      __$$QnaSubmitRequestImplCopyWithImpl<_$QnaSubmitRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$QnaSubmitRequestImplToJson(this);
  }
}

abstract class _QnaSubmitRequest implements QnaSubmitRequest {
  const factory _QnaSubmitRequest({
    required final String appCode,
    required final String title,
    required final String body,
  }) = _$QnaSubmitRequestImpl;

  factory _QnaSubmitRequest.fromJson(Map<String, dynamic> json) =
      _$QnaSubmitRequestImpl.fromJson;

  /// 앱 코드 ('wowa')
  @override
  String get appCode;

  /// 질문 제목 (최대 256자)
  @override
  String get title;

  /// 질문 본문 (최대 65536자)
  @override
  String get body;

  /// Create a copy of QnaSubmitRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QnaSubmitRequestImplCopyWith<_$QnaSubmitRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
