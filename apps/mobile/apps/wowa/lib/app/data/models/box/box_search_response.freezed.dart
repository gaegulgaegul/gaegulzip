// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'box_search_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BoxSearchResponse _$BoxSearchResponseFromJson(Map<String, dynamic> json) {
  return _BoxSearchResponse.fromJson(json);
}

/// @nodoc
mixin _$BoxSearchResponse {
  /// 검색된 박스 목록
  List<BoxModel> get boxes => throw _privateConstructorUsedError;

  /// Serializes this BoxSearchResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BoxSearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BoxSearchResponseCopyWith<BoxSearchResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BoxSearchResponseCopyWith<$Res> {
  factory $BoxSearchResponseCopyWith(
    BoxSearchResponse value,
    $Res Function(BoxSearchResponse) then,
  ) = _$BoxSearchResponseCopyWithImpl<$Res, BoxSearchResponse>;
  @useResult
  $Res call({List<BoxModel> boxes});
}

/// @nodoc
class _$BoxSearchResponseCopyWithImpl<$Res, $Val extends BoxSearchResponse>
    implements $BoxSearchResponseCopyWith<$Res> {
  _$BoxSearchResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BoxSearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? boxes = null}) {
    return _then(
      _value.copyWith(
            boxes: null == boxes
                ? _value.boxes
                : boxes // ignore: cast_nullable_to_non_nullable
                      as List<BoxModel>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BoxSearchResponseImplCopyWith<$Res>
    implements $BoxSearchResponseCopyWith<$Res> {
  factory _$$BoxSearchResponseImplCopyWith(
    _$BoxSearchResponseImpl value,
    $Res Function(_$BoxSearchResponseImpl) then,
  ) = __$$BoxSearchResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<BoxModel> boxes});
}

/// @nodoc
class __$$BoxSearchResponseImplCopyWithImpl<$Res>
    extends _$BoxSearchResponseCopyWithImpl<$Res, _$BoxSearchResponseImpl>
    implements _$$BoxSearchResponseImplCopyWith<$Res> {
  __$$BoxSearchResponseImplCopyWithImpl(
    _$BoxSearchResponseImpl _value,
    $Res Function(_$BoxSearchResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BoxSearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? boxes = null}) {
    return _then(
      _$BoxSearchResponseImpl(
        boxes: null == boxes
            ? _value._boxes
            : boxes // ignore: cast_nullable_to_non_nullable
                  as List<BoxModel>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BoxSearchResponseImpl implements _BoxSearchResponse {
  const _$BoxSearchResponseImpl({required final List<BoxModel> boxes})
    : _boxes = boxes;

  factory _$BoxSearchResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$BoxSearchResponseImplFromJson(json);

  /// 검색된 박스 목록
  final List<BoxModel> _boxes;

  /// 검색된 박스 목록
  @override
  List<BoxModel> get boxes {
    if (_boxes is EqualUnmodifiableListView) return _boxes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_boxes);
  }

  @override
  String toString() {
    return 'BoxSearchResponse(boxes: $boxes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BoxSearchResponseImpl &&
            const DeepCollectionEquality().equals(other._boxes, _boxes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_boxes));

  /// Create a copy of BoxSearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BoxSearchResponseImplCopyWith<_$BoxSearchResponseImpl> get copyWith =>
      __$$BoxSearchResponseImplCopyWithImpl<_$BoxSearchResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BoxSearchResponseImplToJson(this);
  }
}

abstract class _BoxSearchResponse implements BoxSearchResponse {
  const factory _BoxSearchResponse({required final List<BoxModel> boxes}) =
      _$BoxSearchResponseImpl;

  factory _BoxSearchResponse.fromJson(Map<String, dynamic> json) =
      _$BoxSearchResponseImpl.fromJson;

  /// 검색된 박스 목록
  @override
  List<BoxModel> get boxes;

  /// Create a copy of BoxSearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BoxSearchResponseImplCopyWith<_$BoxSearchResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
