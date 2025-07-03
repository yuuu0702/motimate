// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'practice_decision_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PracticeDecisionModel _$PracticeDecisionModelFromJson(
  Map<String, dynamic> json,
) {
  return _PracticeDecisionModel.fromJson(json);
}

/// @nodoc
mixin _$PracticeDecisionModel {
  String get id => throw _privateConstructorUsedError;
  String get decidedBy => throw _privateConstructorUsedError;
  DateTime get decidedAt => throw _privateConstructorUsedError;
  DateTime get practiceDate => throw _privateConstructorUsedError;
  String get dateKey => throw _privateConstructorUsedError;
  List<String> get availableMembers => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // pending, confirmed, cancelled
  Map<String, String> get responses => throw _privateConstructorUsedError;

  /// Serializes this PracticeDecisionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PracticeDecisionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PracticeDecisionModelCopyWith<PracticeDecisionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PracticeDecisionModelCopyWith<$Res> {
  factory $PracticeDecisionModelCopyWith(
    PracticeDecisionModel value,
    $Res Function(PracticeDecisionModel) then,
  ) = _$PracticeDecisionModelCopyWithImpl<$Res, PracticeDecisionModel>;
  @useResult
  $Res call({
    String id,
    String decidedBy,
    DateTime decidedAt,
    DateTime practiceDate,
    String dateKey,
    List<String> availableMembers,
    String status,
    Map<String, String> responses,
  });
}

/// @nodoc
class _$PracticeDecisionModelCopyWithImpl<
  $Res,
  $Val extends PracticeDecisionModel
>
    implements $PracticeDecisionModelCopyWith<$Res> {
  _$PracticeDecisionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PracticeDecisionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? decidedBy = null,
    Object? decidedAt = null,
    Object? practiceDate = null,
    Object? dateKey = null,
    Object? availableMembers = null,
    Object? status = null,
    Object? responses = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            decidedBy: null == decidedBy
                ? _value.decidedBy
                : decidedBy // ignore: cast_nullable_to_non_nullable
                      as String,
            decidedAt: null == decidedAt
                ? _value.decidedAt
                : decidedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            practiceDate: null == practiceDate
                ? _value.practiceDate
                : practiceDate // ignore: cast_nullable_to_non_nullable
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PracticeDecisionModelImplCopyWith<$Res>
    implements $PracticeDecisionModelCopyWith<$Res> {
  factory _$$PracticeDecisionModelImplCopyWith(
    _$PracticeDecisionModelImpl value,
    $Res Function(_$PracticeDecisionModelImpl) then,
  ) = __$$PracticeDecisionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String decidedBy,
    DateTime decidedAt,
    DateTime practiceDate,
    String dateKey,
    List<String> availableMembers,
    String status,
    Map<String, String> responses,
  });
}

/// @nodoc
class __$$PracticeDecisionModelImplCopyWithImpl<$Res>
    extends
        _$PracticeDecisionModelCopyWithImpl<$Res, _$PracticeDecisionModelImpl>
    implements _$$PracticeDecisionModelImplCopyWith<$Res> {
  __$$PracticeDecisionModelImplCopyWithImpl(
    _$PracticeDecisionModelImpl _value,
    $Res Function(_$PracticeDecisionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PracticeDecisionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? decidedBy = null,
    Object? decidedAt = null,
    Object? practiceDate = null,
    Object? dateKey = null,
    Object? availableMembers = null,
    Object? status = null,
    Object? responses = null,
  }) {
    return _then(
      _$PracticeDecisionModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        decidedBy: null == decidedBy
            ? _value.decidedBy
            : decidedBy // ignore: cast_nullable_to_non_nullable
                  as String,
        decidedAt: null == decidedAt
            ? _value.decidedAt
            : decidedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        practiceDate: null == practiceDate
            ? _value.practiceDate
            : practiceDate // ignore: cast_nullable_to_non_nullable
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PracticeDecisionModelImpl implements _PracticeDecisionModel {
  const _$PracticeDecisionModelImpl({
    required this.id,
    required this.decidedBy,
    required this.decidedAt,
    required this.practiceDate,
    required this.dateKey,
    required final List<String> availableMembers,
    this.status = 'pending',
    final Map<String, String> responses = const <String, String>{},
  }) : _availableMembers = availableMembers,
       _responses = responses;

  factory _$PracticeDecisionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PracticeDecisionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String decidedBy;
  @override
  final DateTime decidedAt;
  @override
  final DateTime practiceDate;
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
  String toString() {
    return 'PracticeDecisionModel(id: $id, decidedBy: $decidedBy, decidedAt: $decidedAt, practiceDate: $practiceDate, dateKey: $dateKey, availableMembers: $availableMembers, status: $status, responses: $responses)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PracticeDecisionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.decidedBy, decidedBy) ||
                other.decidedBy == decidedBy) &&
            (identical(other.decidedAt, decidedAt) ||
                other.decidedAt == decidedAt) &&
            (identical(other.practiceDate, practiceDate) ||
                other.practiceDate == practiceDate) &&
            (identical(other.dateKey, dateKey) || other.dateKey == dateKey) &&
            const DeepCollectionEquality().equals(
              other._availableMembers,
              _availableMembers,
            ) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(
              other._responses,
              _responses,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    decidedBy,
    decidedAt,
    practiceDate,
    dateKey,
    const DeepCollectionEquality().hash(_availableMembers),
    status,
    const DeepCollectionEquality().hash(_responses),
  );

  /// Create a copy of PracticeDecisionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PracticeDecisionModelImplCopyWith<_$PracticeDecisionModelImpl>
  get copyWith =>
      __$$PracticeDecisionModelImplCopyWithImpl<_$PracticeDecisionModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PracticeDecisionModelImplToJson(this);
  }
}

abstract class _PracticeDecisionModel implements PracticeDecisionModel {
  const factory _PracticeDecisionModel({
    required final String id,
    required final String decidedBy,
    required final DateTime decidedAt,
    required final DateTime practiceDate,
    required final String dateKey,
    required final List<String> availableMembers,
    final String status,
    final Map<String, String> responses,
  }) = _$PracticeDecisionModelImpl;

  factory _PracticeDecisionModel.fromJson(Map<String, dynamic> json) =
      _$PracticeDecisionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get decidedBy;
  @override
  DateTime get decidedAt;
  @override
  DateTime get practiceDate;
  @override
  String get dateKey;
  @override
  List<String> get availableMembers;
  @override
  String get status; // pending, confirmed, cancelled
  @override
  Map<String, String> get responses;

  /// Create a copy of PracticeDecisionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PracticeDecisionModelImplCopyWith<_$PracticeDecisionModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
