// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notice_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NoticeModel _$NoticeModelFromJson(Map<String, dynamic> json) {
  return _NoticeModel.fromJson(json);
}

/// @nodoc
mixin _$NoticeModel {
  /// 공지사항 ID
  int get id => throw _privateConstructorUsedError;

  /// 제목
  String get title => throw _privateConstructorUsedError;

  /// 본문 (마크다운 형식, 상세 조회 시에만 포함)
  String? get content => throw _privateConstructorUsedError;

  /// 카테고리 (업데이트, 점검, 이벤트 등)
  String? get category => throw _privateConstructorUsedError;

  /// 상단 고정 여부
  bool get isPinned => throw _privateConstructorUsedError;

  /// 읽음 여부 (현재 사용자 기준)
  bool get isRead => throw _privateConstructorUsedError;

  /// 조회수
  int get viewCount => throw _privateConstructorUsedError;

  /// 작성일시 (ISO-8601 문자열)
  String get createdAt => throw _privateConstructorUsedError;

  /// 수정일시 (상세 조회 시에만 포함)
  String? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this NoticeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NoticeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NoticeModelCopyWith<NoticeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NoticeModelCopyWith<$Res> {
  factory $NoticeModelCopyWith(
    NoticeModel value,
    $Res Function(NoticeModel) then,
  ) = _$NoticeModelCopyWithImpl<$Res, NoticeModel>;
  @useResult
  $Res call({
    int id,
    String title,
    String? content,
    String? category,
    bool isPinned,
    bool isRead,
    int viewCount,
    String createdAt,
    String? updatedAt,
  });
}

/// @nodoc
class _$NoticeModelCopyWithImpl<$Res, $Val extends NoticeModel>
    implements $NoticeModelCopyWith<$Res> {
  _$NoticeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NoticeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? content = freezed,
    Object? category = freezed,
    Object? isPinned = null,
    Object? isRead = null,
    Object? viewCount = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            content: freezed == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String?,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String?,
            isPinned: null == isPinned
                ? _value.isPinned
                : isPinned // ignore: cast_nullable_to_non_nullable
                      as bool,
            isRead: null == isRead
                ? _value.isRead
                : isRead // ignore: cast_nullable_to_non_nullable
                      as bool,
            viewCount: null == viewCount
                ? _value.viewCount
                : viewCount // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NoticeModelImplCopyWith<$Res>
    implements $NoticeModelCopyWith<$Res> {
  factory _$$NoticeModelImplCopyWith(
    _$NoticeModelImpl value,
    $Res Function(_$NoticeModelImpl) then,
  ) = __$$NoticeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String title,
    String? content,
    String? category,
    bool isPinned,
    bool isRead,
    int viewCount,
    String createdAt,
    String? updatedAt,
  });
}

/// @nodoc
class __$$NoticeModelImplCopyWithImpl<$Res>
    extends _$NoticeModelCopyWithImpl<$Res, _$NoticeModelImpl>
    implements _$$NoticeModelImplCopyWith<$Res> {
  __$$NoticeModelImplCopyWithImpl(
    _$NoticeModelImpl _value,
    $Res Function(_$NoticeModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NoticeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? content = freezed,
    Object? category = freezed,
    Object? isPinned = null,
    Object? isRead = null,
    Object? viewCount = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$NoticeModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        content: freezed == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String?,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String?,
        isPinned: null == isPinned
            ? _value.isPinned
            : isPinned // ignore: cast_nullable_to_non_nullable
                  as bool,
        isRead: null == isRead
            ? _value.isRead
            : isRead // ignore: cast_nullable_to_non_nullable
                  as bool,
        viewCount: null == viewCount
            ? _value.viewCount
            : viewCount // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NoticeModelImpl implements _NoticeModel {
  const _$NoticeModelImpl({
    required this.id,
    required this.title,
    this.content,
    this.category,
    required this.isPinned,
    this.isRead = false,
    required this.viewCount,
    required this.createdAt,
    this.updatedAt,
  });

  factory _$NoticeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$NoticeModelImplFromJson(json);

  /// 공지사항 ID
  @override
  final int id;

  /// 제목
  @override
  final String title;

  /// 본문 (마크다운 형식, 상세 조회 시에만 포함)
  @override
  final String? content;

  /// 카테고리 (업데이트, 점검, 이벤트 등)
  @override
  final String? category;

  /// 상단 고정 여부
  @override
  final bool isPinned;

  /// 읽음 여부 (현재 사용자 기준)
  @override
  @JsonKey()
  final bool isRead;

  /// 조회수
  @override
  final int viewCount;

  /// 작성일시 (ISO-8601 문자열)
  @override
  final String createdAt;

  /// 수정일시 (상세 조회 시에만 포함)
  @override
  final String? updatedAt;

  @override
  String toString() {
    return 'NoticeModel(id: $id, title: $title, content: $content, category: $category, isPinned: $isPinned, isRead: $isRead, viewCount: $viewCount, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NoticeModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.isPinned, isPinned) ||
                other.isPinned == isPinned) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    content,
    category,
    isPinned,
    isRead,
    viewCount,
    createdAt,
    updatedAt,
  );

  /// Create a copy of NoticeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NoticeModelImplCopyWith<_$NoticeModelImpl> get copyWith =>
      __$$NoticeModelImplCopyWithImpl<_$NoticeModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NoticeModelImplToJson(this);
  }
}

abstract class _NoticeModel implements NoticeModel {
  const factory _NoticeModel({
    required final int id,
    required final String title,
    final String? content,
    final String? category,
    required final bool isPinned,
    final bool isRead,
    required final int viewCount,
    required final String createdAt,
    final String? updatedAt,
  }) = _$NoticeModelImpl;

  factory _NoticeModel.fromJson(Map<String, dynamic> json) =
      _$NoticeModelImpl.fromJson;

  /// 공지사항 ID
  @override
  int get id;

  /// 제목
  @override
  String get title;

  /// 본문 (마크다운 형식, 상세 조회 시에만 포함)
  @override
  String? get content;

  /// 카테고리 (업데이트, 점검, 이벤트 등)
  @override
  String? get category;

  /// 상단 고정 여부
  @override
  bool get isPinned;

  /// 읽음 여부 (현재 사용자 기준)
  @override
  bool get isRead;

  /// 조회수
  @override
  int get viewCount;

  /// 작성일시 (ISO-8601 문자열)
  @override
  String get createdAt;

  /// 수정일시 (상세 조회 시에만 포함)
  @override
  String? get updatedAt;

  /// Create a copy of NoticeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NoticeModelImplCopyWith<_$NoticeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
