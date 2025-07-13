// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_location_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserLocationModel _$UserLocationModelFromJson(Map<String, dynamic> json) {
  return _UserLocationModel.fromJson(json);
}

/// @nodoc
mixin _$UserLocationModel {
  /// 拠点ID
  String get id => throw _privateConstructorUsedError;

  /// ユーザーID
  String get userId => throw _privateConstructorUsedError;

  /// 拠点名（例: "自宅", "職場", "実家"）
  String get name => throw _privateConstructorUsedError;

  /// 住所
  String get address => throw _privateConstructorUsedError;

  /// 緯度経度
  LatLng get location => throw _privateConstructorUsedError;

  /// 拠点タイプ
  LocationType get type => throw _privateConstructorUsedError;

  /// メイン拠点フラグ
  bool get isPrimary => throw _privateConstructorUsedError;

  /// 作成日時
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// 更新日時
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this UserLocationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserLocationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserLocationModelCopyWith<UserLocationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserLocationModelCopyWith<$Res> {
  factory $UserLocationModelCopyWith(
    UserLocationModel value,
    $Res Function(UserLocationModel) then,
  ) = _$UserLocationModelCopyWithImpl<$Res, UserLocationModel>;
  @useResult
  $Res call({
    String id,
    String userId,
    String name,
    String address,
    LatLng location,
    LocationType type,
    bool isPrimary,
    DateTime? createdAt,
    DateTime? updatedAt,
  });

  $LatLngCopyWith<$Res> get location;
}

/// @nodoc
class _$UserLocationModelCopyWithImpl<$Res, $Val extends UserLocationModel>
    implements $UserLocationModelCopyWith<$Res> {
  _$UserLocationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserLocationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? address = null,
    Object? location = null,
    Object? type = null,
    Object? isPrimary = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            location: null == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as LatLng,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as LocationType,
            isPrimary: null == isPrimary
                ? _value.isPrimary
                : isPrimary // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }

  /// Create a copy of UserLocationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LatLngCopyWith<$Res> get location {
    return $LatLngCopyWith<$Res>(_value.location, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserLocationModelImplCopyWith<$Res>
    implements $UserLocationModelCopyWith<$Res> {
  factory _$$UserLocationModelImplCopyWith(
    _$UserLocationModelImpl value,
    $Res Function(_$UserLocationModelImpl) then,
  ) = __$$UserLocationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String name,
    String address,
    LatLng location,
    LocationType type,
    bool isPrimary,
    DateTime? createdAt,
    DateTime? updatedAt,
  });

  @override
  $LatLngCopyWith<$Res> get location;
}

/// @nodoc
class __$$UserLocationModelImplCopyWithImpl<$Res>
    extends _$UserLocationModelCopyWithImpl<$Res, _$UserLocationModelImpl>
    implements _$$UserLocationModelImplCopyWith<$Res> {
  __$$UserLocationModelImplCopyWithImpl(
    _$UserLocationModelImpl _value,
    $Res Function(_$UserLocationModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserLocationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? address = null,
    Object? location = null,
    Object? type = null,
    Object? isPrimary = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$UserLocationModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        location: null == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as LatLng,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as LocationType,
        isPrimary: null == isPrimary
            ? _value.isPrimary
            : isPrimary // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserLocationModelImpl implements _UserLocationModel {
  const _$UserLocationModelImpl({
    required this.id,
    required this.userId,
    required this.name,
    required this.address,
    required this.location,
    this.type = LocationType.other,
    this.isPrimary = false,
    this.createdAt,
    this.updatedAt,
  });

  factory _$UserLocationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserLocationModelImplFromJson(json);

  /// 拠点ID
  @override
  final String id;

  /// ユーザーID
  @override
  final String userId;

  /// 拠点名（例: "自宅", "職場", "実家"）
  @override
  final String name;

  /// 住所
  @override
  final String address;

  /// 緯度経度
  @override
  final LatLng location;

  /// 拠点タイプ
  @override
  @JsonKey()
  final LocationType type;

  /// メイン拠点フラグ
  @override
  @JsonKey()
  final bool isPrimary;

  /// 作成日時
  @override
  final DateTime? createdAt;

  /// 更新日時
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'UserLocationModel(id: $id, userId: $userId, name: $name, address: $address, location: $location, type: $type, isPrimary: $isPrimary, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserLocationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.isPrimary, isPrimary) ||
                other.isPrimary == isPrimary) &&
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
    userId,
    name,
    address,
    location,
    type,
    isPrimary,
    createdAt,
    updatedAt,
  );

  /// Create a copy of UserLocationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserLocationModelImplCopyWith<_$UserLocationModelImpl> get copyWith =>
      __$$UserLocationModelImplCopyWithImpl<_$UserLocationModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserLocationModelImplToJson(this);
  }
}

abstract class _UserLocationModel implements UserLocationModel {
  const factory _UserLocationModel({
    required final String id,
    required final String userId,
    required final String name,
    required final String address,
    required final LatLng location,
    final LocationType type,
    final bool isPrimary,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$UserLocationModelImpl;

  factory _UserLocationModel.fromJson(Map<String, dynamic> json) =
      _$UserLocationModelImpl.fromJson;

  /// 拠点ID
  @override
  String get id;

  /// ユーザーID
  @override
  String get userId;

  /// 拠点名（例: "自宅", "職場", "実家"）
  @override
  String get name;

  /// 住所
  @override
  String get address;

  /// 緯度経度
  @override
  LatLng get location;

  /// 拠点タイプ
  @override
  LocationType get type;

  /// メイン拠点フラグ
  @override
  bool get isPrimary;

  /// 作成日時
  @override
  DateTime? get createdAt;

  /// 更新日時
  @override
  DateTime? get updatedAt;

  /// Create a copy of UserLocationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserLocationModelImplCopyWith<_$UserLocationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GymnasiumRecommendation _$GymnasiumRecommendationFromJson(
  Map<String, dynamic> json,
) {
  return _GymnasiumRecommendation.fromJson(json);
}

/// @nodoc
mixin _$GymnasiumRecommendation {
  /// 体育館情報
  GymnasiumModel get gymnasium => throw _privateConstructorUsedError;

  /// 推奨スコア（0-100）
  double get score => throw _privateConstructorUsedError;

  /// 参加者からの平均距離（km）
  double get averageDistance => throw _privateConstructorUsedError;

  /// 最大距離（km）
  double get maxDistance => throw _privateConstructorUsedError;

  /// 最小距離（km）
  double get minDistance => throw _privateConstructorUsedError;

  /// アクセス性評価コメント
  String? get accessibilityComment => throw _privateConstructorUsedError;

  /// 参加者の拠点情報
  List<ParticipantLocation> get participantLocations =>
      throw _privateConstructorUsedError;

  /// Serializes this GymnasiumRecommendation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GymnasiumRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GymnasiumRecommendationCopyWith<GymnasiumRecommendation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GymnasiumRecommendationCopyWith<$Res> {
  factory $GymnasiumRecommendationCopyWith(
    GymnasiumRecommendation value,
    $Res Function(GymnasiumRecommendation) then,
  ) = _$GymnasiumRecommendationCopyWithImpl<$Res, GymnasiumRecommendation>;
  @useResult
  $Res call({
    GymnasiumModel gymnasium,
    double score,
    double averageDistance,
    double maxDistance,
    double minDistance,
    String? accessibilityComment,
    List<ParticipantLocation> participantLocations,
  });

  $GymnasiumModelCopyWith<$Res> get gymnasium;
}

/// @nodoc
class _$GymnasiumRecommendationCopyWithImpl<
  $Res,
  $Val extends GymnasiumRecommendation
>
    implements $GymnasiumRecommendationCopyWith<$Res> {
  _$GymnasiumRecommendationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GymnasiumRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gymnasium = null,
    Object? score = null,
    Object? averageDistance = null,
    Object? maxDistance = null,
    Object? minDistance = null,
    Object? accessibilityComment = freezed,
    Object? participantLocations = null,
  }) {
    return _then(
      _value.copyWith(
            gymnasium: null == gymnasium
                ? _value.gymnasium
                : gymnasium // ignore: cast_nullable_to_non_nullable
                      as GymnasiumModel,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as double,
            averageDistance: null == averageDistance
                ? _value.averageDistance
                : averageDistance // ignore: cast_nullable_to_non_nullable
                      as double,
            maxDistance: null == maxDistance
                ? _value.maxDistance
                : maxDistance // ignore: cast_nullable_to_non_nullable
                      as double,
            minDistance: null == minDistance
                ? _value.minDistance
                : minDistance // ignore: cast_nullable_to_non_nullable
                      as double,
            accessibilityComment: freezed == accessibilityComment
                ? _value.accessibilityComment
                : accessibilityComment // ignore: cast_nullable_to_non_nullable
                      as String?,
            participantLocations: null == participantLocations
                ? _value.participantLocations
                : participantLocations // ignore: cast_nullable_to_non_nullable
                      as List<ParticipantLocation>,
          )
          as $Val,
    );
  }

  /// Create a copy of GymnasiumRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GymnasiumModelCopyWith<$Res> get gymnasium {
    return $GymnasiumModelCopyWith<$Res>(_value.gymnasium, (value) {
      return _then(_value.copyWith(gymnasium: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GymnasiumRecommendationImplCopyWith<$Res>
    implements $GymnasiumRecommendationCopyWith<$Res> {
  factory _$$GymnasiumRecommendationImplCopyWith(
    _$GymnasiumRecommendationImpl value,
    $Res Function(_$GymnasiumRecommendationImpl) then,
  ) = __$$GymnasiumRecommendationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    GymnasiumModel gymnasium,
    double score,
    double averageDistance,
    double maxDistance,
    double minDistance,
    String? accessibilityComment,
    List<ParticipantLocation> participantLocations,
  });

  @override
  $GymnasiumModelCopyWith<$Res> get gymnasium;
}

/// @nodoc
class __$$GymnasiumRecommendationImplCopyWithImpl<$Res>
    extends
        _$GymnasiumRecommendationCopyWithImpl<
          $Res,
          _$GymnasiumRecommendationImpl
        >
    implements _$$GymnasiumRecommendationImplCopyWith<$Res> {
  __$$GymnasiumRecommendationImplCopyWithImpl(
    _$GymnasiumRecommendationImpl _value,
    $Res Function(_$GymnasiumRecommendationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GymnasiumRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gymnasium = null,
    Object? score = null,
    Object? averageDistance = null,
    Object? maxDistance = null,
    Object? minDistance = null,
    Object? accessibilityComment = freezed,
    Object? participantLocations = null,
  }) {
    return _then(
      _$GymnasiumRecommendationImpl(
        gymnasium: null == gymnasium
            ? _value.gymnasium
            : gymnasium // ignore: cast_nullable_to_non_nullable
                  as GymnasiumModel,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as double,
        averageDistance: null == averageDistance
            ? _value.averageDistance
            : averageDistance // ignore: cast_nullable_to_non_nullable
                  as double,
        maxDistance: null == maxDistance
            ? _value.maxDistance
            : maxDistance // ignore: cast_nullable_to_non_nullable
                  as double,
        minDistance: null == minDistance
            ? _value.minDistance
            : minDistance // ignore: cast_nullable_to_non_nullable
                  as double,
        accessibilityComment: freezed == accessibilityComment
            ? _value.accessibilityComment
            : accessibilityComment // ignore: cast_nullable_to_non_nullable
                  as String?,
        participantLocations: null == participantLocations
            ? _value._participantLocations
            : participantLocations // ignore: cast_nullable_to_non_nullable
                  as List<ParticipantLocation>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GymnasiumRecommendationImpl implements _GymnasiumRecommendation {
  const _$GymnasiumRecommendationImpl({
    required this.gymnasium,
    required this.score,
    required this.averageDistance,
    required this.maxDistance,
    required this.minDistance,
    this.accessibilityComment,
    final List<ParticipantLocation> participantLocations = const [],
  }) : _participantLocations = participantLocations;

  factory _$GymnasiumRecommendationImpl.fromJson(Map<String, dynamic> json) =>
      _$$GymnasiumRecommendationImplFromJson(json);

  /// 体育館情報
  @override
  final GymnasiumModel gymnasium;

  /// 推奨スコア（0-100）
  @override
  final double score;

  /// 参加者からの平均距離（km）
  @override
  final double averageDistance;

  /// 最大距離（km）
  @override
  final double maxDistance;

  /// 最小距離（km）
  @override
  final double minDistance;

  /// アクセス性評価コメント
  @override
  final String? accessibilityComment;

  /// 参加者の拠点情報
  final List<ParticipantLocation> _participantLocations;

  /// 参加者の拠点情報
  @override
  @JsonKey()
  List<ParticipantLocation> get participantLocations {
    if (_participantLocations is EqualUnmodifiableListView)
      return _participantLocations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participantLocations);
  }

  @override
  String toString() {
    return 'GymnasiumRecommendation(gymnasium: $gymnasium, score: $score, averageDistance: $averageDistance, maxDistance: $maxDistance, minDistance: $minDistance, accessibilityComment: $accessibilityComment, participantLocations: $participantLocations)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GymnasiumRecommendationImpl &&
            (identical(other.gymnasium, gymnasium) ||
                other.gymnasium == gymnasium) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.averageDistance, averageDistance) ||
                other.averageDistance == averageDistance) &&
            (identical(other.maxDistance, maxDistance) ||
                other.maxDistance == maxDistance) &&
            (identical(other.minDistance, minDistance) ||
                other.minDistance == minDistance) &&
            (identical(other.accessibilityComment, accessibilityComment) ||
                other.accessibilityComment == accessibilityComment) &&
            const DeepCollectionEquality().equals(
              other._participantLocations,
              _participantLocations,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    gymnasium,
    score,
    averageDistance,
    maxDistance,
    minDistance,
    accessibilityComment,
    const DeepCollectionEquality().hash(_participantLocations),
  );

  /// Create a copy of GymnasiumRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GymnasiumRecommendationImplCopyWith<_$GymnasiumRecommendationImpl>
  get copyWith =>
      __$$GymnasiumRecommendationImplCopyWithImpl<
        _$GymnasiumRecommendationImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GymnasiumRecommendationImplToJson(this);
  }
}

abstract class _GymnasiumRecommendation implements GymnasiumRecommendation {
  const factory _GymnasiumRecommendation({
    required final GymnasiumModel gymnasium,
    required final double score,
    required final double averageDistance,
    required final double maxDistance,
    required final double minDistance,
    final String? accessibilityComment,
    final List<ParticipantLocation> participantLocations,
  }) = _$GymnasiumRecommendationImpl;

  factory _GymnasiumRecommendation.fromJson(Map<String, dynamic> json) =
      _$GymnasiumRecommendationImpl.fromJson;

  /// 体育館情報
  @override
  GymnasiumModel get gymnasium;

  /// 推奨スコア（0-100）
  @override
  double get score;

  /// 参加者からの平均距離（km）
  @override
  double get averageDistance;

  /// 最大距離（km）
  @override
  double get maxDistance;

  /// 最小距離（km）
  @override
  double get minDistance;

  /// アクセス性評価コメント
  @override
  String? get accessibilityComment;

  /// 参加者の拠点情報
  @override
  List<ParticipantLocation> get participantLocations;

  /// Create a copy of GymnasiumRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GymnasiumRecommendationImplCopyWith<_$GymnasiumRecommendationImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ParticipantLocation _$ParticipantLocationFromJson(Map<String, dynamic> json) {
  return _ParticipantLocation.fromJson(json);
}

/// @nodoc
mixin _$ParticipantLocation {
  /// ユーザーID
  String get userId => throw _privateConstructorUsedError;

  /// ユーザー名
  String get userName => throw _privateConstructorUsedError;

  /// 拠点情報
  UserLocationModel get location => throw _privateConstructorUsedError;

  /// 体育館までの距離（km）
  double get distanceToGymnasium => throw _privateConstructorUsedError;

  /// Serializes this ParticipantLocation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ParticipantLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParticipantLocationCopyWith<ParticipantLocation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParticipantLocationCopyWith<$Res> {
  factory $ParticipantLocationCopyWith(
    ParticipantLocation value,
    $Res Function(ParticipantLocation) then,
  ) = _$ParticipantLocationCopyWithImpl<$Res, ParticipantLocation>;
  @useResult
  $Res call({
    String userId,
    String userName,
    UserLocationModel location,
    double distanceToGymnasium,
  });

  $UserLocationModelCopyWith<$Res> get location;
}

/// @nodoc
class _$ParticipantLocationCopyWithImpl<$Res, $Val extends ParticipantLocation>
    implements $ParticipantLocationCopyWith<$Res> {
  _$ParticipantLocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ParticipantLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? location = null,
    Object? distanceToGymnasium = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            location: null == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as UserLocationModel,
            distanceToGymnasium: null == distanceToGymnasium
                ? _value.distanceToGymnasium
                : distanceToGymnasium // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }

  /// Create a copy of ParticipantLocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserLocationModelCopyWith<$Res> get location {
    return $UserLocationModelCopyWith<$Res>(_value.location, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ParticipantLocationImplCopyWith<$Res>
    implements $ParticipantLocationCopyWith<$Res> {
  factory _$$ParticipantLocationImplCopyWith(
    _$ParticipantLocationImpl value,
    $Res Function(_$ParticipantLocationImpl) then,
  ) = __$$ParticipantLocationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String userName,
    UserLocationModel location,
    double distanceToGymnasium,
  });

  @override
  $UserLocationModelCopyWith<$Res> get location;
}

/// @nodoc
class __$$ParticipantLocationImplCopyWithImpl<$Res>
    extends _$ParticipantLocationCopyWithImpl<$Res, _$ParticipantLocationImpl>
    implements _$$ParticipantLocationImplCopyWith<$Res> {
  __$$ParticipantLocationImplCopyWithImpl(
    _$ParticipantLocationImpl _value,
    $Res Function(_$ParticipantLocationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ParticipantLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? location = null,
    Object? distanceToGymnasium = null,
  }) {
    return _then(
      _$ParticipantLocationImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        location: null == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as UserLocationModel,
        distanceToGymnasium: null == distanceToGymnasium
            ? _value.distanceToGymnasium
            : distanceToGymnasium // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ParticipantLocationImpl implements _ParticipantLocation {
  const _$ParticipantLocationImpl({
    required this.userId,
    required this.userName,
    required this.location,
    required this.distanceToGymnasium,
  });

  factory _$ParticipantLocationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParticipantLocationImplFromJson(json);

  /// ユーザーID
  @override
  final String userId;

  /// ユーザー名
  @override
  final String userName;

  /// 拠点情報
  @override
  final UserLocationModel location;

  /// 体育館までの距離（km）
  @override
  final double distanceToGymnasium;

  @override
  String toString() {
    return 'ParticipantLocation(userId: $userId, userName: $userName, location: $location, distanceToGymnasium: $distanceToGymnasium)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParticipantLocationImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.distanceToGymnasium, distanceToGymnasium) ||
                other.distanceToGymnasium == distanceToGymnasium));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, userName, location, distanceToGymnasium);

  /// Create a copy of ParticipantLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParticipantLocationImplCopyWith<_$ParticipantLocationImpl> get copyWith =>
      __$$ParticipantLocationImplCopyWithImpl<_$ParticipantLocationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ParticipantLocationImplToJson(this);
  }
}

abstract class _ParticipantLocation implements ParticipantLocation {
  const factory _ParticipantLocation({
    required final String userId,
    required final String userName,
    required final UserLocationModel location,
    required final double distanceToGymnasium,
  }) = _$ParticipantLocationImpl;

  factory _ParticipantLocation.fromJson(Map<String, dynamic> json) =
      _$ParticipantLocationImpl.fromJson;

  /// ユーザーID
  @override
  String get userId;

  /// ユーザー名
  @override
  String get userName;

  /// 拠点情報
  @override
  UserLocationModel get location;

  /// 体育館までの距離（km）
  @override
  double get distanceToGymnasium;

  /// Create a copy of ParticipantLocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParticipantLocationImplCopyWith<_$ParticipantLocationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
