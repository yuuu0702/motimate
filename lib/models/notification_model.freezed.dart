// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) {
  return _NotificationModel.fromJson(json);
}

/// @nodoc
mixin _$NotificationModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  String get type =>
      throw _privateConstructorUsedError; // 'practice_decision', 'schedule_update', 'general'
  Map<String, dynamic>? get data => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;

  /// Serializes this NotificationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationModelCopyWith<NotificationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationModelCopyWith<$Res> {
  factory $NotificationModelCopyWith(
    NotificationModel value,
    $Res Function(NotificationModel) then,
  ) = _$NotificationModelCopyWithImpl<$Res, NotificationModel>;
  @useResult
  $Res call({
    String id,
    String title,
    String body,
    String type,
    Map<String, dynamic>? data,
    DateTime createdAt,
    bool isRead,
    String? imageUrl,
  });
}

/// @nodoc
class _$NotificationModelCopyWithImpl<$Res, $Val extends NotificationModel>
    implements $NotificationModelCopyWith<$Res> {
  _$NotificationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? body = null,
    Object? type = null,
    Object? data = freezed,
    Object? createdAt = null,
    Object? isRead = null,
    Object? imageUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            data: freezed == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isRead: null == isRead
                ? _value.isRead
                : isRead // ignore: cast_nullable_to_non_nullable
                      as bool,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotificationModelImplCopyWith<$Res>
    implements $NotificationModelCopyWith<$Res> {
  factory _$$NotificationModelImplCopyWith(
    _$NotificationModelImpl value,
    $Res Function(_$NotificationModelImpl) then,
  ) = __$$NotificationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String body,
    String type,
    Map<String, dynamic>? data,
    DateTime createdAt,
    bool isRead,
    String? imageUrl,
  });
}

/// @nodoc
class __$$NotificationModelImplCopyWithImpl<$Res>
    extends _$NotificationModelCopyWithImpl<$Res, _$NotificationModelImpl>
    implements _$$NotificationModelImplCopyWith<$Res> {
  __$$NotificationModelImplCopyWithImpl(
    _$NotificationModelImpl _value,
    $Res Function(_$NotificationModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? body = null,
    Object? type = null,
    Object? data = freezed,
    Object? createdAt = null,
    Object? isRead = null,
    Object? imageUrl = freezed,
  }) {
    return _then(
      _$NotificationModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        data: freezed == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isRead: null == isRead
            ? _value.isRead
            : isRead // ignore: cast_nullable_to_non_nullable
                  as bool,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationModelImpl implements _NotificationModel {
  const _$NotificationModelImpl({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    final Map<String, dynamic>? data,
    required this.createdAt,
    this.isRead = false,
    this.imageUrl,
  }) : _data = data;

  factory _$NotificationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String body;
  @override
  final String type;
  // 'practice_decision', 'schedule_update', 'general'
  final Map<String, dynamic>? _data;
  // 'practice_decision', 'schedule_update', 'general'
  @override
  Map<String, dynamic>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final bool isRead;
  @override
  final String? imageUrl;

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, body: $body, type: $type, data: $data, createdAt: $createdAt, isRead: $isRead, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    body,
    type,
    const DeepCollectionEquality().hash(_data),
    createdAt,
    isRead,
    imageUrl,
  );

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationModelImplCopyWith<_$NotificationModelImpl> get copyWith =>
      __$$NotificationModelImplCopyWithImpl<_$NotificationModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationModelImplToJson(this);
  }
}

abstract class _NotificationModel implements NotificationModel {
  const factory _NotificationModel({
    required final String id,
    required final String title,
    required final String body,
    required final String type,
    final Map<String, dynamic>? data,
    required final DateTime createdAt,
    final bool isRead,
    final String? imageUrl,
  }) = _$NotificationModelImpl;

  factory _NotificationModel.fromJson(Map<String, dynamic> json) =
      _$NotificationModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get body;
  @override
  String get type; // 'practice_decision', 'schedule_update', 'general'
  @override
  Map<String, dynamic>? get data;
  @override
  DateTime get createdAt;
  @override
  bool get isRead;
  @override
  String? get imageUrl;

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationModelImplCopyWith<_$NotificationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
