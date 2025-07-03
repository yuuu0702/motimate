// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  String get uid => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String get department => throw _privateConstructorUsedError;
  String get group => throw _privateConstructorUsedError;
  bool get profileSetup => throw _privateConstructorUsedError;
  int get latestMotivationLevel => throw _privateConstructorUsedError;
  DateTime? get latestMotivationTimestamp => throw _privateConstructorUsedError;
  String? get latestMotivationComment => throw _privateConstructorUsedError;
  List<DateTime>? get nextPlayDates => throw _privateConstructorUsedError;
  DateTime? get lastLogin => throw _privateConstructorUsedError;
  String? get fcmToken => throw _privateConstructorUsedError;
  bool get notificationsEnabled => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call({
    String uid,
    String username,
    String displayName,
    String department,
    String group,
    bool profileSetup,
    int latestMotivationLevel,
    DateTime? latestMotivationTimestamp,
    String? latestMotivationComment,
    List<DateTime>? nextPlayDates,
    DateTime? lastLogin,
    String? fcmToken,
    bool notificationsEnabled,
  });
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? username = null,
    Object? displayName = null,
    Object? department = null,
    Object? group = null,
    Object? profileSetup = null,
    Object? latestMotivationLevel = null,
    Object? latestMotivationTimestamp = freezed,
    Object? latestMotivationComment = freezed,
    Object? nextPlayDates = freezed,
    Object? lastLogin = freezed,
    Object? fcmToken = freezed,
    Object? notificationsEnabled = null,
  }) {
    return _then(
      _value.copyWith(
            uid: null == uid
                ? _value.uid
                : uid // ignore: cast_nullable_to_non_nullable
                      as String,
            username: null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String,
            displayName: null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String,
            department: null == department
                ? _value.department
                : department // ignore: cast_nullable_to_non_nullable
                      as String,
            group: null == group
                ? _value.group
                : group // ignore: cast_nullable_to_non_nullable
                      as String,
            profileSetup: null == profileSetup
                ? _value.profileSetup
                : profileSetup // ignore: cast_nullable_to_non_nullable
                      as bool,
            latestMotivationLevel: null == latestMotivationLevel
                ? _value.latestMotivationLevel
                : latestMotivationLevel // ignore: cast_nullable_to_non_nullable
                      as int,
            latestMotivationTimestamp: freezed == latestMotivationTimestamp
                ? _value.latestMotivationTimestamp
                : latestMotivationTimestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            latestMotivationComment: freezed == latestMotivationComment
                ? _value.latestMotivationComment
                : latestMotivationComment // ignore: cast_nullable_to_non_nullable
                      as String?,
            nextPlayDates: freezed == nextPlayDates
                ? _value.nextPlayDates
                : nextPlayDates // ignore: cast_nullable_to_non_nullable
                      as List<DateTime>?,
            lastLogin: freezed == lastLogin
                ? _value.lastLogin
                : lastLogin // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            fcmToken: freezed == fcmToken
                ? _value.fcmToken
                : fcmToken // ignore: cast_nullable_to_non_nullable
                      as String?,
            notificationsEnabled: null == notificationsEnabled
                ? _value.notificationsEnabled
                : notificationsEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
    _$UserModelImpl value,
    $Res Function(_$UserModelImpl) then,
  ) = __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String uid,
    String username,
    String displayName,
    String department,
    String group,
    bool profileSetup,
    int latestMotivationLevel,
    DateTime? latestMotivationTimestamp,
    String? latestMotivationComment,
    List<DateTime>? nextPlayDates,
    DateTime? lastLogin,
    String? fcmToken,
    bool notificationsEnabled,
  });
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
    _$UserModelImpl _value,
    $Res Function(_$UserModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? username = null,
    Object? displayName = null,
    Object? department = null,
    Object? group = null,
    Object? profileSetup = null,
    Object? latestMotivationLevel = null,
    Object? latestMotivationTimestamp = freezed,
    Object? latestMotivationComment = freezed,
    Object? nextPlayDates = freezed,
    Object? lastLogin = freezed,
    Object? fcmToken = freezed,
    Object? notificationsEnabled = null,
  }) {
    return _then(
      _$UserModelImpl(
        uid: null == uid
            ? _value.uid
            : uid // ignore: cast_nullable_to_non_nullable
                  as String,
        username: null == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: null == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String,
        department: null == department
            ? _value.department
            : department // ignore: cast_nullable_to_non_nullable
                  as String,
        group: null == group
            ? _value.group
            : group // ignore: cast_nullable_to_non_nullable
                  as String,
        profileSetup: null == profileSetup
            ? _value.profileSetup
            : profileSetup // ignore: cast_nullable_to_non_nullable
                  as bool,
        latestMotivationLevel: null == latestMotivationLevel
            ? _value.latestMotivationLevel
            : latestMotivationLevel // ignore: cast_nullable_to_non_nullable
                  as int,
        latestMotivationTimestamp: freezed == latestMotivationTimestamp
            ? _value.latestMotivationTimestamp
            : latestMotivationTimestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        latestMotivationComment: freezed == latestMotivationComment
            ? _value.latestMotivationComment
            : latestMotivationComment // ignore: cast_nullable_to_non_nullable
                  as String?,
        nextPlayDates: freezed == nextPlayDates
            ? _value._nextPlayDates
            : nextPlayDates // ignore: cast_nullable_to_non_nullable
                  as List<DateTime>?,
        lastLogin: freezed == lastLogin
            ? _value.lastLogin
            : lastLogin // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        fcmToken: freezed == fcmToken
            ? _value.fcmToken
            : fcmToken // ignore: cast_nullable_to_non_nullable
                  as String?,
        notificationsEnabled: null == notificationsEnabled
            ? _value.notificationsEnabled
            : notificationsEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl implements _UserModel {
  const _$UserModelImpl({
    required this.uid,
    required this.username,
    required this.displayName,
    required this.department,
    required this.group,
    this.profileSetup = false,
    this.latestMotivationLevel = 3,
    this.latestMotivationTimestamp,
    this.latestMotivationComment,
    final List<DateTime>? nextPlayDates,
    this.lastLogin,
    this.fcmToken,
    this.notificationsEnabled = false,
  }) : _nextPlayDates = nextPlayDates;

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  final String uid;
  @override
  final String username;
  @override
  final String displayName;
  @override
  final String department;
  @override
  final String group;
  @override
  @JsonKey()
  final bool profileSetup;
  @override
  @JsonKey()
  final int latestMotivationLevel;
  @override
  final DateTime? latestMotivationTimestamp;
  @override
  final String? latestMotivationComment;
  final List<DateTime>? _nextPlayDates;
  @override
  List<DateTime>? get nextPlayDates {
    final value = _nextPlayDates;
    if (value == null) return null;
    if (_nextPlayDates is EqualUnmodifiableListView) return _nextPlayDates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final DateTime? lastLogin;
  @override
  final String? fcmToken;
  @override
  @JsonKey()
  final bool notificationsEnabled;

  @override
  String toString() {
    return 'UserModel(uid: $uid, username: $username, displayName: $displayName, department: $department, group: $group, profileSetup: $profileSetup, latestMotivationLevel: $latestMotivationLevel, latestMotivationTimestamp: $latestMotivationTimestamp, latestMotivationComment: $latestMotivationComment, nextPlayDates: $nextPlayDates, lastLogin: $lastLogin, fcmToken: $fcmToken, notificationsEnabled: $notificationsEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.group, group) || other.group == group) &&
            (identical(other.profileSetup, profileSetup) ||
                other.profileSetup == profileSetup) &&
            (identical(other.latestMotivationLevel, latestMotivationLevel) ||
                other.latestMotivationLevel == latestMotivationLevel) &&
            (identical(
                  other.latestMotivationTimestamp,
                  latestMotivationTimestamp,
                ) ||
                other.latestMotivationTimestamp == latestMotivationTimestamp) &&
            (identical(
                  other.latestMotivationComment,
                  latestMotivationComment,
                ) ||
                other.latestMotivationComment == latestMotivationComment) &&
            const DeepCollectionEquality().equals(
              other._nextPlayDates,
              _nextPlayDates,
            ) &&
            (identical(other.lastLogin, lastLogin) ||
                other.lastLogin == lastLogin) &&
            (identical(other.fcmToken, fcmToken) ||
                other.fcmToken == fcmToken) &&
            (identical(other.notificationsEnabled, notificationsEnabled) ||
                other.notificationsEnabled == notificationsEnabled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    uid,
    username,
    displayName,
    department,
    group,
    profileSetup,
    latestMotivationLevel,
    latestMotivationTimestamp,
    latestMotivationComment,
    const DeepCollectionEquality().hash(_nextPlayDates),
    lastLogin,
    fcmToken,
    notificationsEnabled,
  );

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(this);
  }
}

abstract class _UserModel implements UserModel {
  const factory _UserModel({
    required final String uid,
    required final String username,
    required final String displayName,
    required final String department,
    required final String group,
    final bool profileSetup,
    final int latestMotivationLevel,
    final DateTime? latestMotivationTimestamp,
    final String? latestMotivationComment,
    final List<DateTime>? nextPlayDates,
    final DateTime? lastLogin,
    final String? fcmToken,
    final bool notificationsEnabled,
  }) = _$UserModelImpl;

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  String get uid;
  @override
  String get username;
  @override
  String get displayName;
  @override
  String get department;
  @override
  String get group;
  @override
  bool get profileSetup;
  @override
  int get latestMotivationLevel;
  @override
  DateTime? get latestMotivationTimestamp;
  @override
  String? get latestMotivationComment;
  @override
  List<DateTime>? get nextPlayDates;
  @override
  DateTime? get lastLogin;
  @override
  String? get fcmToken;
  @override
  bool get notificationsEnabled;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
