// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'box_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BoxModel _$BoxModelFromJson(Map<String, dynamic> json) {
  return _BoxModel.fromJson(json);
}

/// @nodoc
mixin _$BoxModel {
  /// 박스 고유 ID
  int get id => throw _privateConstructorUsedError;

  /// 박스 이름
  String get name => throw _privateConstructorUsedError;

  /// 박스 지역
  String get region => throw _privateConstructorUsedError;

  /// 박스 설명 (nullable)
  String? get description => throw _privateConstructorUsedError;

  /// 멤버 수 (nullable)
  int? get memberCount => throw _privateConstructorUsedError;

  /// 가입 시간 (ISO 8601 형식, nullable)
  String? get joinedAt => throw _privateConstructorUsedError;

  /// Serializes this BoxModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BoxModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BoxModelCopyWith<BoxModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BoxModelCopyWith<$Res> {
  factory $BoxModelCopyWith(BoxModel value, $Res Function(BoxModel) then) =
      _$BoxModelCopyWithImpl<$Res, BoxModel>;
  @useResult
  $Res call({
    int id,
    String name,
    String region,
    String? description,
    int? memberCount,
    String? joinedAt,
  });
}

/// @nodoc
class _$BoxModelCopyWithImpl<$Res, $Val extends BoxModel>
    implements $BoxModelCopyWith<$Res> {
  _$BoxModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BoxModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? region = null,
    Object? description = freezed,
    Object? memberCount = freezed,
    Object? joinedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
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
            memberCount: freezed == memberCount
                ? _value.memberCount
                : memberCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            joinedAt: freezed == joinedAt
                ? _value.joinedAt
                : joinedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BoxModelImplCopyWith<$Res>
    implements $BoxModelCopyWith<$Res> {
  factory _$$BoxModelImplCopyWith(
    _$BoxModelImpl value,
    $Res Function(_$BoxModelImpl) then,
  ) = __$$BoxModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    String region,
    String? description,
    int? memberCount,
    String? joinedAt,
  });
}

/// @nodoc
class __$$BoxModelImplCopyWithImpl<$Res>
    extends _$BoxModelCopyWithImpl<$Res, _$BoxModelImpl>
    implements _$$BoxModelImplCopyWith<$Res> {
  __$$BoxModelImplCopyWithImpl(
    _$BoxModelImpl _value,
    $Res Function(_$BoxModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BoxModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? region = null,
    Object? description = freezed,
    Object? memberCount = freezed,
    Object? joinedAt = freezed,
  }) {
    return _then(
      _$BoxModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
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
        memberCount: freezed == memberCount
            ? _value.memberCount
            : memberCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        joinedAt: freezed == joinedAt
            ? _value.joinedAt
            : joinedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BoxModelImpl implements _BoxModel {
  const _$BoxModelImpl({
    required this.id,
    required this.name,
    required this.region,
    this.description,
    this.memberCount,
    this.joinedAt,
  });

  factory _$BoxModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BoxModelImplFromJson(json);

  /// 박스 고유 ID
  @override
  final int id;

  /// 박스 이름
  @override
  final String name;

  /// 박스 지역
  @override
  final String region;

  /// 박스 설명 (nullable)
  @override
  final String? description;

  /// 멤버 수 (nullable)
  @override
  final int? memberCount;

  /// 가입 시간 (ISO 8601 형식, nullable)
  @override
  final String? joinedAt;

  @override
  String toString() {
    return 'BoxModel(id: $id, name: $name, region: $region, description: $description, memberCount: $memberCount, joinedAt: $joinedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BoxModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.memberCount, memberCount) ||
                other.memberCount == memberCount) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    region,
    description,
    memberCount,
    joinedAt,
  );

  /// Create a copy of BoxModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BoxModelImplCopyWith<_$BoxModelImpl> get copyWith =>
      __$$BoxModelImplCopyWithImpl<_$BoxModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BoxModelImplToJson(this);
  }
}

abstract class _BoxModel implements BoxModel {
  const factory _BoxModel({
    required final int id,
    required final String name,
    required final String region,
    final String? description,
    final int? memberCount,
    final String? joinedAt,
  }) = _$BoxModelImpl;

  factory _BoxModel.fromJson(Map<String, dynamic> json) =
      _$BoxModelImpl.fromJson;

  /// 박스 고유 ID
  @override
  int get id;

  /// 박스 이름
  @override
  String get name;

  /// 박스 지역
  @override
  String get region;

  /// 박스 설명 (nullable)
  @override
  String? get description;

  /// 멤버 수 (nullable)
  @override
  int? get memberCount;

  /// 가입 시간 (ISO 8601 형식, nullable)
  @override
  String? get joinedAt;

  /// Create a copy of BoxModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BoxModelImplCopyWith<_$BoxModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
