// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'circle_member_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CircleMemberModel _$CircleMemberModelFromJson(Map<String, dynamic> json) {
  return _CircleMemberModel.fromJson(json);
}

/// @nodoc
mixin _$CircleMemberModel {
  String get id => throw _privateConstructorUsedError;
  String get circleId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  MemberRole get role => throw _privateConstructorUsedError;
  MemberStatus get status => throw _privateConstructorUsedError;
  DateTime get joinedAt => throw _privateConstructorUsedError;
  DateTime? get approvedAt => throw _privateConstructorUsedError;
  String? get approvedBy => throw _privateConstructorUsedError;
  String? get joinMessage => throw _privateConstructorUsedError;
  MemberStats get stats => throw _privateConstructorUsedError;

  /// Serializes this CircleMemberModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CircleMemberModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CircleMemberModelCopyWith<CircleMemberModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CircleMemberModelCopyWith<$Res> {
  factory $CircleMemberModelCopyWith(
    CircleMemberModel value,
    $Res Function(CircleMemberModel) then,
  ) = _$CircleMemberModelCopyWithImpl<$Res, CircleMemberModel>;
  @useResult
  $Res call({
    String id,
    String circleId,
    String userId,
    MemberRole role,
    MemberStatus status,
    DateTime joinedAt,
    DateTime? approvedAt,
    String? approvedBy,
    String? joinMessage,
    MemberStats stats,
  });

  $MemberStatsCopyWith<$Res> get stats;
}

/// @nodoc
class _$CircleMemberModelCopyWithImpl<$Res, $Val extends CircleMemberModel>
    implements $CircleMemberModelCopyWith<$Res> {
  _$CircleMemberModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CircleMemberModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? circleId = null,
    Object? userId = null,
    Object? role = null,
    Object? status = null,
    Object? joinedAt = null,
    Object? approvedAt = freezed,
    Object? approvedBy = freezed,
    Object? joinMessage = freezed,
    Object? stats = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            circleId: null == circleId
                ? _value.circleId
                : circleId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as MemberRole,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as MemberStatus,
            joinedAt: null == joinedAt
                ? _value.joinedAt
                : joinedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            approvedAt: freezed == approvedAt
                ? _value.approvedAt
                : approvedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            approvedBy: freezed == approvedBy
                ? _value.approvedBy
                : approvedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            joinMessage: freezed == joinMessage
                ? _value.joinMessage
                : joinMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            stats: null == stats
                ? _value.stats
                : stats // ignore: cast_nullable_to_non_nullable
                      as MemberStats,
          )
          as $Val,
    );
  }

  /// Create a copy of CircleMemberModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MemberStatsCopyWith<$Res> get stats {
    return $MemberStatsCopyWith<$Res>(_value.stats, (value) {
      return _then(_value.copyWith(stats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CircleMemberModelImplCopyWith<$Res>
    implements $CircleMemberModelCopyWith<$Res> {
  factory _$$CircleMemberModelImplCopyWith(
    _$CircleMemberModelImpl value,
    $Res Function(_$CircleMemberModelImpl) then,
  ) = __$$CircleMemberModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String circleId,
    String userId,
    MemberRole role,
    MemberStatus status,
    DateTime joinedAt,
    DateTime? approvedAt,
    String? approvedBy,
    String? joinMessage,
    MemberStats stats,
  });

  @override
  $MemberStatsCopyWith<$Res> get stats;
}

/// @nodoc
class __$$CircleMemberModelImplCopyWithImpl<$Res>
    extends _$CircleMemberModelCopyWithImpl<$Res, _$CircleMemberModelImpl>
    implements _$$CircleMemberModelImplCopyWith<$Res> {
  __$$CircleMemberModelImplCopyWithImpl(
    _$CircleMemberModelImpl _value,
    $Res Function(_$CircleMemberModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CircleMemberModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? circleId = null,
    Object? userId = null,
    Object? role = null,
    Object? status = null,
    Object? joinedAt = null,
    Object? approvedAt = freezed,
    Object? approvedBy = freezed,
    Object? joinMessage = freezed,
    Object? stats = null,
  }) {
    return _then(
      _$CircleMemberModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        circleId: null == circleId
            ? _value.circleId
            : circleId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as MemberRole,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as MemberStatus,
        joinedAt: null == joinedAt
            ? _value.joinedAt
            : joinedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        approvedAt: freezed == approvedAt
            ? _value.approvedAt
            : approvedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        approvedBy: freezed == approvedBy
            ? _value.approvedBy
            : approvedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        joinMessage: freezed == joinMessage
            ? _value.joinMessage
            : joinMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        stats: null == stats
            ? _value.stats
            : stats // ignore: cast_nullable_to_non_nullable
                  as MemberStats,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CircleMemberModelImpl implements _CircleMemberModel {
  const _$CircleMemberModelImpl({
    required this.id,
    required this.circleId,
    required this.userId,
    required this.role,
    required this.status,
    required this.joinedAt,
    this.approvedAt,
    this.approvedBy,
    this.joinMessage,
    required this.stats,
  });

  factory _$CircleMemberModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CircleMemberModelImplFromJson(json);

  @override
  final String id;
  @override
  final String circleId;
  @override
  final String userId;
  @override
  final MemberRole role;
  @override
  final MemberStatus status;
  @override
  final DateTime joinedAt;
  @override
  final DateTime? approvedAt;
  @override
  final String? approvedBy;
  @override
  final String? joinMessage;
  @override
  final MemberStats stats;

  @override
  String toString() {
    return 'CircleMemberModel(id: $id, circleId: $circleId, userId: $userId, role: $role, status: $status, joinedAt: $joinedAt, approvedAt: $approvedAt, approvedBy: $approvedBy, joinMessage: $joinMessage, stats: $stats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CircleMemberModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.circleId, circleId) ||
                other.circleId == circleId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.approvedAt, approvedAt) ||
                other.approvedAt == approvedAt) &&
            (identical(other.approvedBy, approvedBy) ||
                other.approvedBy == approvedBy) &&
            (identical(other.joinMessage, joinMessage) ||
                other.joinMessage == joinMessage) &&
            (identical(other.stats, stats) || other.stats == stats));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    circleId,
    userId,
    role,
    status,
    joinedAt,
    approvedAt,
    approvedBy,
    joinMessage,
    stats,
  );

  /// Create a copy of CircleMemberModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CircleMemberModelImplCopyWith<_$CircleMemberModelImpl> get copyWith =>
      __$$CircleMemberModelImplCopyWithImpl<_$CircleMemberModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CircleMemberModelImplToJson(this);
  }
}

abstract class _CircleMemberModel implements CircleMemberModel {
  const factory _CircleMemberModel({
    required final String id,
    required final String circleId,
    required final String userId,
    required final MemberRole role,
    required final MemberStatus status,
    required final DateTime joinedAt,
    final DateTime? approvedAt,
    final String? approvedBy,
    final String? joinMessage,
    required final MemberStats stats,
  }) = _$CircleMemberModelImpl;

  factory _CircleMemberModel.fromJson(Map<String, dynamic> json) =
      _$CircleMemberModelImpl.fromJson;

  @override
  String get id;
  @override
  String get circleId;
  @override
  String get userId;
  @override
  MemberRole get role;
  @override
  MemberStatus get status;
  @override
  DateTime get joinedAt;
  @override
  DateTime? get approvedAt;
  @override
  String? get approvedBy;
  @override
  String? get joinMessage;
  @override
  MemberStats get stats;

  /// Create a copy of CircleMemberModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CircleMemberModelImplCopyWith<_$CircleMemberModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MemberStats _$MemberStatsFromJson(Map<String, dynamic> json) {
  return _MemberStats.fromJson(json);
}

/// @nodoc
mixin _$MemberStats {
  int get participationCount => throw _privateConstructorUsedError;
  double get motivationAverage => throw _privateConstructorUsedError;
  DateTime? get lastActiveAt => throw _privateConstructorUsedError;

  /// Serializes this MemberStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MemberStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MemberStatsCopyWith<MemberStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemberStatsCopyWith<$Res> {
  factory $MemberStatsCopyWith(
    MemberStats value,
    $Res Function(MemberStats) then,
  ) = _$MemberStatsCopyWithImpl<$Res, MemberStats>;
  @useResult
  $Res call({
    int participationCount,
    double motivationAverage,
    DateTime? lastActiveAt,
  });
}

/// @nodoc
class _$MemberStatsCopyWithImpl<$Res, $Val extends MemberStats>
    implements $MemberStatsCopyWith<$Res> {
  _$MemberStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MemberStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? participationCount = null,
    Object? motivationAverage = null,
    Object? lastActiveAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            participationCount: null == participationCount
                ? _value.participationCount
                : participationCount // ignore: cast_nullable_to_non_nullable
                      as int,
            motivationAverage: null == motivationAverage
                ? _value.motivationAverage
                : motivationAverage // ignore: cast_nullable_to_non_nullable
                      as double,
            lastActiveAt: freezed == lastActiveAt
                ? _value.lastActiveAt
                : lastActiveAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MemberStatsImplCopyWith<$Res>
    implements $MemberStatsCopyWith<$Res> {
  factory _$$MemberStatsImplCopyWith(
    _$MemberStatsImpl value,
    $Res Function(_$MemberStatsImpl) then,
  ) = __$$MemberStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int participationCount,
    double motivationAverage,
    DateTime? lastActiveAt,
  });
}

/// @nodoc
class __$$MemberStatsImplCopyWithImpl<$Res>
    extends _$MemberStatsCopyWithImpl<$Res, _$MemberStatsImpl>
    implements _$$MemberStatsImplCopyWith<$Res> {
  __$$MemberStatsImplCopyWithImpl(
    _$MemberStatsImpl _value,
    $Res Function(_$MemberStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MemberStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? participationCount = null,
    Object? motivationAverage = null,
    Object? lastActiveAt = freezed,
  }) {
    return _then(
      _$MemberStatsImpl(
        participationCount: null == participationCount
            ? _value.participationCount
            : participationCount // ignore: cast_nullable_to_non_nullable
                  as int,
        motivationAverage: null == motivationAverage
            ? _value.motivationAverage
            : motivationAverage // ignore: cast_nullable_to_non_nullable
                  as double,
        lastActiveAt: freezed == lastActiveAt
            ? _value.lastActiveAt
            : lastActiveAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MemberStatsImpl implements _MemberStats {
  const _$MemberStatsImpl({
    this.participationCount = 0,
    this.motivationAverage = 0.0,
    this.lastActiveAt,
  });

  factory _$MemberStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$MemberStatsImplFromJson(json);

  @override
  @JsonKey()
  final int participationCount;
  @override
  @JsonKey()
  final double motivationAverage;
  @override
  final DateTime? lastActiveAt;

  @override
  String toString() {
    return 'MemberStats(participationCount: $participationCount, motivationAverage: $motivationAverage, lastActiveAt: $lastActiveAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemberStatsImpl &&
            (identical(other.participationCount, participationCount) ||
                other.participationCount == participationCount) &&
            (identical(other.motivationAverage, motivationAverage) ||
                other.motivationAverage == motivationAverage) &&
            (identical(other.lastActiveAt, lastActiveAt) ||
                other.lastActiveAt == lastActiveAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    participationCount,
    motivationAverage,
    lastActiveAt,
  );

  /// Create a copy of MemberStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MemberStatsImplCopyWith<_$MemberStatsImpl> get copyWith =>
      __$$MemberStatsImplCopyWithImpl<_$MemberStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MemberStatsImplToJson(this);
  }
}

abstract class _MemberStats implements MemberStats {
  const factory _MemberStats({
    final int participationCount,
    final double motivationAverage,
    final DateTime? lastActiveAt,
  }) = _$MemberStatsImpl;

  factory _MemberStats.fromJson(Map<String, dynamic> json) =
      _$MemberStatsImpl.fromJson;

  @override
  int get participationCount;
  @override
  double get motivationAverage;
  @override
  DateTime? get lastActiveAt;

  /// Create a copy of MemberStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MemberStatsImplCopyWith<_$MemberStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
