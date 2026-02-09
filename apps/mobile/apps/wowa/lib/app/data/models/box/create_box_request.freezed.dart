// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_box_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CreateBoxRequest _$CreateBoxRequestFromJson(Map<String, dynamic> json) {
  return _CreateBoxRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateBoxRequest {
  /// 박스 이름
  String get name => throw _privateConstructorUsedError;

  /// 박스 지역
  String get region => throw _privateConstructorUsedError;

  /// 박스 설명 (nullable)
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this CreateBoxRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateBoxRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateBoxRequestCopyWith<CreateBoxRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateBoxRequestCopyWith<$Res> {
  factory $CreateBoxRequestCopyWith(
    CreateBoxRequest value,
    $Res Function(CreateBoxRequest) then,
  ) = _$CreateBoxRequestCopyWithImpl<$Res, CreateBoxRequest>;
  @useResult
  $Res call({String name, String region, String? description});
}

/// @nodoc
class _$CreateBoxRequestCopyWithImpl<$Res, $Val extends CreateBoxRequest>
    implements $CreateBoxRequestCopyWith<$Res> {
  _$CreateBoxRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateBoxRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? region = null,
    Object? description = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            region: null == region
                ? _value.region
                : region // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateBoxRequestImplCopyWith<$Res>
    implements $CreateBoxRequestCopyWith<$Res> {
  factory _$$CreateBoxRequestImplCopyWith(
    _$CreateBoxRequestImpl value,
    $Res Function(_$CreateBoxRequestImpl) then,
  ) = __$$CreateBoxRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String region, String? description});
}

/// @nodoc
class __$$CreateBoxRequestImplCopyWithImpl<$Res>
    extends _$CreateBoxRequestCopyWithImpl<$Res, _$CreateBoxRequestImpl>
    implements _$$CreateBoxRequestImplCopyWith<$Res> {
  __$$CreateBoxRequestImplCopyWithImpl(
    _$CreateBoxRequestImpl _value,
    $Res Function(_$CreateBoxRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateBoxRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? region = null,
    Object? description = freezed,
  }) {
    return _then(
      _$CreateBoxRequestImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        region: null == region
            ? _value.region
            : region // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateBoxRequestImpl implements _CreateBoxRequest {
  const _$CreateBoxRequestImpl({
    required this.name,
    required this.region,
    this.description,
  });

  factory _$CreateBoxRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateBoxRequestImplFromJson(json);

  /// 박스 이름
  @override
  final String name;

  /// 박스 지역
  @override
  final String region;

  /// 박스 설명 (nullable)
  @override
  final String? description;

  @override
  String toString() {
    return 'CreateBoxRequest(name: $name, region: $region, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateBoxRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, region, description);

  /// Create a copy of CreateBoxRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateBoxRequestImplCopyWith<_$CreateBoxRequestImpl> get copyWith =>
      __$$CreateBoxRequestImplCopyWithImpl<_$CreateBoxRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateBoxRequestImplToJson(this);
  }
}

abstract class _CreateBoxRequest implements CreateBoxRequest {
  const factory _CreateBoxRequest({
    required final String name,
    required final String region,
    final String? description,
  }) = _$CreateBoxRequestImpl;

  factory _CreateBoxRequest.fromJson(Map<String, dynamic> json) =
      _$CreateBoxRequestImpl.fromJson;

  /// 박스 이름
  @override
  String get name;

  /// 박스 지역
  @override
  String get region;

  /// 박스 설명 (nullable)
  @override
  String? get description;

  /// Create a copy of CreateBoxRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateBoxRequestImplCopyWith<_$CreateBoxRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
