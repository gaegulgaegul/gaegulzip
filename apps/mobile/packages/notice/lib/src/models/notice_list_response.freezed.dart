// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notice_list_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NoticeListResponse _$NoticeListResponseFromJson(Map<String, dynamic> json) {
  return _NoticeListResponse.fromJson(json);
}

/// @nodoc
mixin _$NoticeListResponse {
  /// 공지사항 목록
  List<NoticeModel> get items => throw _privateConstructorUsedError;

  /// 전체 개수
  int get totalCount => throw _privateConstructorUsedError;

  /// 현재 페이지
  int get page => throw _privateConstructorUsedError;

  /// 페이지 크기
  int get limit => throw _privateConstructorUsedError;

  /// 다음 페이지 존재 여부
  bool get hasNext => throw _privateConstructorUsedError;

  /// Serializes this NoticeListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NoticeListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NoticeListResponseCopyWith<NoticeListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NoticeListResponseCopyWith<$Res> {
  factory $NoticeListResponseCopyWith(
    NoticeListResponse value,
    $Res Function(NoticeListResponse) then,
  ) = _$NoticeListResponseCopyWithImpl<$Res, NoticeListResponse>;
  @useResult
  $Res call({
    List<NoticeModel> items,
    int totalCount,
    int page,
    int limit,
    bool hasNext,
  });
}

/// @nodoc
class _$NoticeListResponseCopyWithImpl<$Res, $Val extends NoticeListResponse>
    implements $NoticeListResponseCopyWith<$Res> {
  _$NoticeListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NoticeListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? totalCount = null,
    Object? page = null,
    Object? limit = null,
    Object? hasNext = null,
  }) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<NoticeModel>,
            totalCount: null == totalCount
                ? _value.totalCount
                : totalCount // ignore: cast_nullable_to_non_nullable
                      as int,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            limit: null == limit
                ? _value.limit
                : limit // ignore: cast_nullable_to_non_nullable
                      as int,
            hasNext: null == hasNext
                ? _value.hasNext
                : hasNext // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NoticeListResponseImplCopyWith<$Res>
    implements $NoticeListResponseCopyWith<$Res> {
  factory _$$NoticeListResponseImplCopyWith(
    _$NoticeListResponseImpl value,
    $Res Function(_$NoticeListResponseImpl) then,
  ) = __$$NoticeListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<NoticeModel> items,
    int totalCount,
    int page,
    int limit,
    bool hasNext,
  });
}

/// @nodoc
class __$$NoticeListResponseImplCopyWithImpl<$Res>
    extends _$NoticeListResponseCopyWithImpl<$Res, _$NoticeListResponseImpl>
    implements _$$NoticeListResponseImplCopyWith<$Res> {
  __$$NoticeListResponseImplCopyWithImpl(
    _$NoticeListResponseImpl _value,
    $Res Function(_$NoticeListResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NoticeListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? totalCount = null,
    Object? page = null,
    Object? limit = null,
    Object? hasNext = null,
  }) {
    return _then(
      _$NoticeListResponseImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<NoticeModel>,
        totalCount: null == totalCount
            ? _value.totalCount
            : totalCount // ignore: cast_nullable_to_non_nullable
                  as int,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        limit: null == limit
            ? _value.limit
            : limit // ignore: cast_nullable_to_non_nullable
                  as int,
        hasNext: null == hasNext
            ? _value.hasNext
            : hasNext // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NoticeListResponseImpl implements _NoticeListResponse {
  const _$NoticeListResponseImpl({
    required final List<NoticeModel> items,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.hasNext,
  }) : _items = items;

  factory _$NoticeListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$NoticeListResponseImplFromJson(json);

  /// 공지사항 목록
  final List<NoticeModel> _items;

  /// 공지사항 목록
  @override
  List<NoticeModel> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  /// 전체 개수
  @override
  final int totalCount;

  /// 현재 페이지
  @override
  final int page;

  /// 페이지 크기
  @override
  final int limit;

  /// 다음 페이지 존재 여부
  @override
  final bool hasNext;

  @override
  String toString() {
    return 'NoticeListResponse(items: $items, totalCount: $totalCount, page: $page, limit: $limit, hasNext: $hasNext)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NoticeListResponseImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.hasNext, hasNext) || other.hasNext == hasNext));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    totalCount,
    page,
    limit,
    hasNext,
  );

  /// Create a copy of NoticeListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NoticeListResponseImplCopyWith<_$NoticeListResponseImpl> get copyWith =>
      __$$NoticeListResponseImplCopyWithImpl<_$NoticeListResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NoticeListResponseImplToJson(this);
  }
}

abstract class _NoticeListResponse implements NoticeListResponse {
  const factory _NoticeListResponse({
    required final List<NoticeModel> items,
    required final int totalCount,
    required final int page,
    required final int limit,
    required final bool hasNext,
  }) = _$NoticeListResponseImpl;

  factory _NoticeListResponse.fromJson(Map<String, dynamic> json) =
      _$NoticeListResponseImpl.fromJson;

  /// 공지사항 목록
  @override
  List<NoticeModel> get items;

  /// 전체 개수
  @override
  int get totalCount;

  /// 현재 페이지
  @override
  int get page;

  /// 페이지 크기
  @override
  int get limit;

  /// 다음 페이지 존재 여부
  @override
  bool get hasNext;

  /// Create a copy of NoticeListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NoticeListResponseImplCopyWith<_$NoticeListResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
