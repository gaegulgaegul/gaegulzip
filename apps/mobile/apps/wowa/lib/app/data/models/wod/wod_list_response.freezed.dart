// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wod_list_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WodListResponse _$WodListResponseFromJson(Map<String, dynamic> json) {
  return _WodListResponse.fromJson(json);
}

/// @nodoc
mixin _$WodListResponse {
  /// Base WOD (nullable)
  WodModel? get baseWod => throw _privateConstructorUsedError;

  /// Personal WOD 목록
  List<WodModel> get personalWods => throw _privateConstructorUsedError;

  /// Serializes this WodListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WodListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WodListResponseCopyWith<WodListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WodListResponseCopyWith<$Res> {
  factory $WodListResponseCopyWith(
    WodListResponse value,
    $Res Function(WodListResponse) then,
  ) = _$WodListResponseCopyWithImpl<$Res, WodListResponse>;
  @useResult
  $Res call({WodModel? baseWod, List<WodModel> personalWods});

  $WodModelCopyWith<$Res>? get baseWod;
}

/// @nodoc
class _$WodListResponseCopyWithImpl<$Res, $Val extends WodListResponse>
    implements $WodListResponseCopyWith<$Res> {
  _$WodListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WodListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? baseWod = freezed, Object? personalWods = null}) {
    return _then(
      _value.copyWith(
            baseWod: freezed == baseWod
                ? _value.baseWod
                : baseWod // ignore: cast_nullable_to_non_nullable
                      as WodModel?,
            personalWods: null == personalWods
                ? _value.personalWods
                : personalWods // ignore: cast_nullable_to_non_nullable
                      as List<WodModel>,
          )
          as $Val,
    );
  }

  /// Create a copy of WodListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WodModelCopyWith<$Res>? get baseWod {
    if (_value.baseWod == null) {
      return null;
    }

    return $WodModelCopyWith<$Res>(_value.baseWod!, (value) {
      return _then(_value.copyWith(baseWod: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WodListResponseImplCopyWith<$Res>
    implements $WodListResponseCopyWith<$Res> {
  factory _$$WodListResponseImplCopyWith(
    _$WodListResponseImpl value,
    $Res Function(_$WodListResponseImpl) then,
  ) = __$$WodListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({WodModel? baseWod, List<WodModel> personalWods});

  @override
  $WodModelCopyWith<$Res>? get baseWod;
}

/// @nodoc
class __$$WodListResponseImplCopyWithImpl<$Res>
    extends _$WodListResponseCopyWithImpl<$Res, _$WodListResponseImpl>
    implements _$$WodListResponseImplCopyWith<$Res> {
  __$$WodListResponseImplCopyWithImpl(
    _$WodListResponseImpl _value,
    $Res Function(_$WodListResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WodListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? baseWod = freezed, Object? personalWods = null}) {
    return _then(
      _$WodListResponseImpl(
        baseWod: freezed == baseWod
            ? _value.baseWod
            : baseWod // ignore: cast_nullable_to_non_nullable
                  as WodModel?,
        personalWods: null == personalWods
            ? _value._personalWods
            : personalWods // ignore: cast_nullable_to_non_nullable
                  as List<WodModel>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WodListResponseImpl implements _WodListResponse {
  const _$WodListResponseImpl({
    this.baseWod,
    required final List<WodModel> personalWods,
  }) : _personalWods = personalWods;

  factory _$WodListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$WodListResponseImplFromJson(json);

  /// Base WOD (nullable)
  @override
  final WodModel? baseWod;

  /// Personal WOD 목록
  final List<WodModel> _personalWods;

  /// Personal WOD 목록
  @override
  List<WodModel> get personalWods {
    if (_personalWods is EqualUnmodifiableListView) return _personalWods;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_personalWods);
  }

  @override
  String toString() {
    return 'WodListResponse(baseWod: $baseWod, personalWods: $personalWods)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WodListResponseImpl &&
            (identical(other.baseWod, baseWod) || other.baseWod == baseWod) &&
            const DeepCollectionEquality().equals(
              other._personalWods,
              _personalWods,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    baseWod,
    const DeepCollectionEquality().hash(_personalWods),
  );

  /// Create a copy of WodListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WodListResponseImplCopyWith<_$WodListResponseImpl> get copyWith =>
      __$$WodListResponseImplCopyWithImpl<_$WodListResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WodListResponseImplToJson(this);
  }
}

abstract class _WodListResponse implements WodListResponse {
  const factory _WodListResponse({
    final WodModel? baseWod,
    required final List<WodModel> personalWods,
  }) = _$WodListResponseImpl;

  factory _WodListResponse.fromJson(Map<String, dynamic> json) =
      _$WodListResponseImpl.fromJson;

  /// Base WOD (nullable)
  @override
  WodModel? get baseWod;

  /// Personal WOD 목록
  @override
  List<WodModel> get personalWods;

  /// Create a copy of WodListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WodListResponseImplCopyWith<_$WodListResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
