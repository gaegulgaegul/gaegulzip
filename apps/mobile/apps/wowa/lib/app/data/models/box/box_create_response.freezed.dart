// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'box_create_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BoxCreateResponse _$BoxCreateResponseFromJson(Map<String, dynamic> json) {
  return _BoxCreateResponse.fromJson(json);
}

/// @nodoc
mixin _$BoxCreateResponse {
  /// 생성된 박스
  BoxModel get box => throw _privateConstructorUsedError;

  /// 생성된 멤버십 (자동 가입)
  MembershipModel get membership => throw _privateConstructorUsedError;

  /// 이전 박스 ID (탈퇴한 박스가 있을 경우)
  int? get previousBoxId => throw _privateConstructorUsedError;

  /// Serializes this BoxCreateResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BoxCreateResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BoxCreateResponseCopyWith<BoxCreateResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BoxCreateResponseCopyWith<$Res> {
  factory $BoxCreateResponseCopyWith(
    BoxCreateResponse value,
    $Res Function(BoxCreateResponse) then,
  ) = _$BoxCreateResponseCopyWithImpl<$Res, BoxCreateResponse>;
  @useResult
  $Res call({BoxModel box, MembershipModel membership, int? previousBoxId});

  $BoxModelCopyWith<$Res> get box;
  $MembershipModelCopyWith<$Res> get membership;
}

/// @nodoc
class _$BoxCreateResponseCopyWithImpl<$Res, $Val extends BoxCreateResponse>
    implements $BoxCreateResponseCopyWith<$Res> {
  _$BoxCreateResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BoxCreateResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? box = null,
    Object? membership = null,
    Object? previousBoxId = freezed,
  }) {
    return _then(
      _value.copyWith(
            box: null == box
                ? _value.box
                : box // ignore: cast_nullable_to_non_nullable
                      as BoxModel,
            membership: null == membership
                ? _value.membership
                : membership // ignore: cast_nullable_to_non_nullable
                      as MembershipModel,
            previousBoxId: freezed == previousBoxId
                ? _value.previousBoxId
                : previousBoxId // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }

  /// Create a copy of BoxCreateResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BoxModelCopyWith<$Res> get box {
    return $BoxModelCopyWith<$Res>(_value.box, (value) {
      return _then(_value.copyWith(box: value) as $Val);
    });
  }

  /// Create a copy of BoxCreateResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MembershipModelCopyWith<$Res> get membership {
    return $MembershipModelCopyWith<$Res>(_value.membership, (value) {
      return _then(_value.copyWith(membership: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BoxCreateResponseImplCopyWith<$Res>
    implements $BoxCreateResponseCopyWith<$Res> {
  factory _$$BoxCreateResponseImplCopyWith(
    _$BoxCreateResponseImpl value,
    $Res Function(_$BoxCreateResponseImpl) then,
  ) = __$$BoxCreateResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({BoxModel box, MembershipModel membership, int? previousBoxId});

  @override
  $BoxModelCopyWith<$Res> get box;
  @override
  $MembershipModelCopyWith<$Res> get membership;
}

/// @nodoc
class __$$BoxCreateResponseImplCopyWithImpl<$Res>
    extends _$BoxCreateResponseCopyWithImpl<$Res, _$BoxCreateResponseImpl>
    implements _$$BoxCreateResponseImplCopyWith<$Res> {
  __$$BoxCreateResponseImplCopyWithImpl(
    _$BoxCreateResponseImpl _value,
    $Res Function(_$BoxCreateResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BoxCreateResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? box = null,
    Object? membership = null,
    Object? previousBoxId = freezed,
  }) {
    return _then(
      _$BoxCreateResponseImpl(
        box: null == box
            ? _value.box
            : box // ignore: cast_nullable_to_non_nullable
                  as BoxModel,
        membership: null == membership
            ? _value.membership
            : membership // ignore: cast_nullable_to_non_nullable
                  as MembershipModel,
        previousBoxId: freezed == previousBoxId
            ? _value.previousBoxId
            : previousBoxId // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BoxCreateResponseImpl implements _BoxCreateResponse {
  const _$BoxCreateResponseImpl({
    required this.box,
    required this.membership,
    this.previousBoxId,
  });

  factory _$BoxCreateResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$BoxCreateResponseImplFromJson(json);

  /// 생성된 박스
  @override
  final BoxModel box;

  /// 생성된 멤버십 (자동 가입)
  @override
  final MembershipModel membership;

  /// 이전 박스 ID (탈퇴한 박스가 있을 경우)
  @override
  final int? previousBoxId;

  @override
  String toString() {
    return 'BoxCreateResponse(box: $box, membership: $membership, previousBoxId: $previousBoxId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BoxCreateResponseImpl &&
            (identical(other.box, box) || other.box == box) &&
            (identical(other.membership, membership) ||
                other.membership == membership) &&
            (identical(other.previousBoxId, previousBoxId) ||
                other.previousBoxId == previousBoxId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, box, membership, previousBoxId);

  /// Create a copy of BoxCreateResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BoxCreateResponseImplCopyWith<_$BoxCreateResponseImpl> get copyWith =>
      __$$BoxCreateResponseImplCopyWithImpl<_$BoxCreateResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BoxCreateResponseImplToJson(this);
  }
}

abstract class _BoxCreateResponse implements BoxCreateResponse {
  const factory _BoxCreateResponse({
    required final BoxModel box,
    required final MembershipModel membership,
    final int? previousBoxId,
  }) = _$BoxCreateResponseImpl;

  factory _BoxCreateResponse.fromJson(Map<String, dynamic> json) =
      _$BoxCreateResponseImpl.fromJson;

  /// 생성된 박스
  @override
  BoxModel get box;

  /// 생성된 멤버십 (자동 가입)
  @override
  MembershipModel get membership;

  /// 이전 박스 ID (탈퇴한 박스가 있을 경우)
  @override
  int? get previousBoxId;

  /// Create a copy of BoxCreateResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BoxCreateResponseImplCopyWith<_$BoxCreateResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
