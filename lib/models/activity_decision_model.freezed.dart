// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_decision_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ActivityDecisionModel _$ActivityDecisionModelFromJson(
  Map<String, dynamic> json,
) {
  return _ActivityDecisionModel.fromJson(json);
}

/// @nodoc
mixin _$ActivityDecisionModel {
  String get id => throw _privateConstructorUsedError;
  String get circleId => throw _privateConstructorUsedError; // 新規追加: サークルID
  String get decidedBy => throw _privateConstructorUsedError;
  DateTime get decidedAt => throw _privateConstructorUsedError;
  DateTime get activityDate =>
      throw _privateConstructorUsedError; // practiceDate から変更
  String get dateKey => throw _privateConstructorUsedError;
  List<String> get availableMembers => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // pending, confirmed, cancelled
  Map<String, String> get responses => throw _privateConstructorUsedError;
  String? get memo => throw _privateConstructorUsedError; // 活動に関するメモ
  List<String> get actualParticipants => throw _privateConstructorUsedError;

  /// Serializes this ActivityDecisionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActivityDecisionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivityDecisionModelCopyWith<ActivityDecisionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityDecisionModelCopyWith<$Res> {
  factory $ActivityDecisionModelCopyWith(
    ActivityDecisionModel value,
    $Res Function(ActivityDecisionModel) then,
  ) = _$ActivityDecisionModelCopyWithImpl<$Res, ActivityDecisionModel>;
  @useResult
  $Res call({
    String id,
    String circleId,
    String decidedBy,
    DateTime decidedAt,
    DateTime activityDate,
    String dateKey,
    List<String> availableMembers,
    String status,
    Map<String, String> responses,
    String? memo,
    List<String> actualParticipants,
  });
}

/// @nodoc
class _$ActivityDecisionModelCopyWithImpl<
  $Res,
  $Val extends ActivityDecisionModel
>
    implements $ActivityDecisionModelCopyWith<$Res> {
  _$ActivityDecisionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActivityDecisionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? circleId = null,
    Object? decidedBy = null,
    Object? decidedAt = null,
    Object? activityDate = null,
    Object? dateKey = null,
    Object? availableMembers = null,
    Object? status = null,
    Object? responses = null,
    Object? memo = freezed,
    Object? actualParticipants = null,
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
            decidedBy: null == decidedBy
                ? _value.decidedBy
                : decidedBy // ignore: cast_nullable_to_non_nullable
                      as String,
            decidedAt: null == decidedAt
                ? _value.decidedAt
                : decidedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            activityDate: null == activityDate
                ? _value.activityDate
                : activityDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            dateKey: null == dateKey
                ? _value.dateKey
                : dateKey // ignore: cast_nullable_to_non_nullable
                      as String,
            availableMembers: null == availableMembers
                ? _value.availableMembers
                : availableMembers // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            responses: null == responses
                ? _value.responses
                : responses // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
            memo: freezed == memo
                ? _value.memo
                : memo // ignore: cast_nullable_to_non_nullable
                      as String?,
            actualParticipants: null == actualParticipants
                ? _value.actualParticipants
                : actualParticipants // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ActivityDecisionModelImplCopyWith<$Res>
    implements $ActivityDecisionModelCopyWith<$Res> {
  factory _$$ActivityDecisionModelImplCopyWith(
    _$ActivityDecisionModelImpl value,
    $Res Function(_$ActivityDecisionModelImpl) then,
  ) = __$$ActivityDecisionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String circleId,
    String decidedBy,
    DateTime decidedAt,
    DateTime activityDate,
    String dateKey,
    List<String> availableMembers,
    String status,
    Map<String, String> responses,
    String? memo,
    List<String> actualParticipants,
  });
}

/// @nodoc
class __$$ActivityDecisionModelImplCopyWithImpl<$Res>
    extends
        _$ActivityDecisionModelCopyWithImpl<$Res, _$ActivityDecisionModelImpl>
    implements _$$ActivityDecisionModelImplCopyWith<$Res> {
  __$$ActivityDecisionModelImplCopyWithImpl(
    _$ActivityDecisionModelImpl _value,
    $Res Function(_$ActivityDecisionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActivityDecisionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? circleId = null,
    Object? decidedBy = null,
    Object? decidedAt = null,
    Object? activityDate = null,
    Object? dateKey = null,
    Object? availableMembers = null,
    Object? status = null,
    Object? responses = null,
    Object? memo = freezed,
    Object? actualParticipants = null,
  }) {
    return _then(
      _$ActivityDecisionModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        circleId: null == circleId
            ? _value.circleId
            : circleId // ignore: cast_nullable_to_non_nullable
                  as String,
        decidedBy: null == decidedBy
            ? _value.decidedBy
            : decidedBy // ignore: cast_nullable_to_non_nullable
                  as String,
        decidedAt: null == decidedAt
            ? _value.decidedAt
            : decidedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        activityDate: null == activityDate
            ? _value.activityDate
            : activityDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        dateKey: null == dateKey
            ? _value.dateKey
            : dateKey // ignore: cast_nullable_to_non_nullable
                  as String,
        availableMembers: null == availableMembers
            ? _value._availableMembers
            : availableMembers // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        responses: null == responses
            ? _value._responses
            : responses // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
        memo: freezed == memo
            ? _value.memo
            : memo // ignore: cast_nullable_to_non_nullable
                  as String?,
        actualParticipants: null == actualParticipants
            ? _value._actualParticipants
            : actualParticipants // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ActivityDecisionModelImpl implements _ActivityDecisionModel {
  const _$ActivityDecisionModelImpl({
    required this.id,
    required this.circleId,
    required this.decidedBy,
    required this.decidedAt,
    required this.activityDate,
    required this.dateKey,
    required final List<String> availableMembers,
    this.status = 'pending',
    final Map<String, String> responses = const <String, String>{},
    this.memo,
    final List<String> actualParticipants = const <String>[],
  }) : _availableMembers = availableMembers,
       _responses = responses,
       _actualParticipants = actualParticipants;

  factory _$ActivityDecisionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivityDecisionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String circleId;
  // 新規追加: サークルID
  @override
  final String decidedBy;
  @override
  final DateTime decidedAt;
  @override
  final DateTime activityDate;
  // practiceDate から変更
  @override
  final String dateKey;
  final List<String> _availableMembers;
  @override
  List<String> get availableMembers {
    if (_availableMembers is EqualUnmodifiableListView)
      return _availableMembers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableMembers);
  }

  @override
  @JsonKey()
  final String status;
  // pending, confirmed, cancelled
  final Map<String, String> _responses;
  // pending, confirmed, cancelled
  @override
  @JsonKey()
  Map<String, String> get responses {
    if (_responses is EqualUnmodifiableMapView) return _responses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_responses);
  }

  @override
  final String? memo;
  // 活動に関するメモ
  final List<String> _actualParticipants;
  // 活動に関するメモ
  @override
  @JsonKey()
  List<String> get actualParticipants {
    if (_actualParticipants is EqualUnmodifiableListView)
      return _actualParticipants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_actualParticipants);
  }

  @override
  String toString() {
    return 'ActivityDecisionModel(id: $id, circleId: $circleId, decidedBy: $decidedBy, decidedAt: $decidedAt, activityDate: $activityDate, dateKey: $dateKey, availableMembers: $availableMembers, status: $status, responses: $responses, memo: $memo, actualParticipants: $actualParticipants)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivityDecisionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.circleId, circleId) ||
                other.circleId == circleId) &&
            (identical(other.decidedBy, decidedBy) ||
                other.decidedBy == decidedBy) &&
            (identical(other.decidedAt, decidedAt) ||
                other.decidedAt == decidedAt) &&
            (identical(other.activityDate, activityDate) ||
                other.activityDate == activityDate) &&
            (identical(other.dateKey, dateKey) || other.dateKey == dateKey) &&
            const DeepCollectionEquality().equals(
              other._availableMembers,
              _availableMembers,
            ) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(
              other._responses,
              _responses,
            ) &&
            (identical(other.memo, memo) || other.memo == memo) &&
            const DeepCollectionEquality().equals(
              other._actualParticipants,
              _actualParticipants,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    circleId,
    decidedBy,
    decidedAt,
    activityDate,
    dateKey,
    const DeepCollectionEquality().hash(_availableMembers),
    status,
    const DeepCollectionEquality().hash(_responses),
    memo,
    const DeepCollectionEquality().hash(_actualParticipants),
  );

  /// Create a copy of ActivityDecisionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivityDecisionModelImplCopyWith<_$ActivityDecisionModelImpl>
  get copyWith =>
      __$$ActivityDecisionModelImplCopyWithImpl<_$ActivityDecisionModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivityDecisionModelImplToJson(this);
  }
}

abstract class _ActivityDecisionModel implements ActivityDecisionModel {
  const factory _ActivityDecisionModel({
    required final String id,
    required final String circleId,
    required final String decidedBy,
    required final DateTime decidedAt,
    required final DateTime activityDate,
    required final String dateKey,
    required final List<String> availableMembers,
    final String status,
    final Map<String, String> responses,
    final String? memo,
    final List<String> actualParticipants,
  }) = _$ActivityDecisionModelImpl;

  factory _ActivityDecisionModel.fromJson(Map<String, dynamic> json) =
      _$ActivityDecisionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get circleId; // 新規追加: サークルID
  @override
  String get decidedBy;
  @override
  DateTime get decidedAt;
  @override
  DateTime get activityDate; // practiceDate から変更
  @override
  String get dateKey;
  @override
  List<String> get availableMembers;
  @override
  String get status; // pending, confirmed, cancelled
  @override
  Map<String, String> get responses;
  @override
  String? get memo; // 活動に関するメモ
  @override
  List<String> get actualParticipants;

  /// Create a copy of ActivityDecisionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivityDecisionModelImplCopyWith<_$ActivityDecisionModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
