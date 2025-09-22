// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'circle_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CircleModel _$CircleModelFromJson(Map<String, dynamic> json) {
  return _CircleModel.fromJson(json);
}

/// @nodoc
mixin _$CircleModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get creatorId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  CircleSettings get settings => throw _privateConstructorUsedError;
  PrivacySettings get privacy => throw _privateConstructorUsedError;
  CircleStats get stats => throw _privateConstructorUsedError;
  String? get inviteCode => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this CircleModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CircleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CircleModelCopyWith<CircleModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CircleModelCopyWith<$Res> {
  factory $CircleModelCopyWith(
    CircleModel value,
    $Res Function(CircleModel) then,
  ) = _$CircleModelCopyWithImpl<$Res, CircleModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    String category,
    String creatorId,
    DateTime createdAt,
    DateTime updatedAt,
    CircleSettings settings,
    PrivacySettings privacy,
    CircleStats stats,
    String? inviteCode,
    bool isActive,
  });

  $CircleSettingsCopyWith<$Res> get settings;
  $PrivacySettingsCopyWith<$Res> get privacy;
  $CircleStatsCopyWith<$Res> get stats;
}

/// @nodoc
class _$CircleModelCopyWithImpl<$Res, $Val extends CircleModel>
    implements $CircleModelCopyWith<$Res> {
  _$CircleModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CircleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? category = null,
    Object? creatorId = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? settings = null,
    Object? privacy = null,
    Object? stats = null,
    Object? inviteCode = freezed,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            creatorId: null == creatorId
                ? _value.creatorId
                : creatorId // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            settings: null == settings
                ? _value.settings
                : settings // ignore: cast_nullable_to_non_nullable
                      as CircleSettings,
            privacy: null == privacy
                ? _value.privacy
                : privacy // ignore: cast_nullable_to_non_nullable
                      as PrivacySettings,
            stats: null == stats
                ? _value.stats
                : stats // ignore: cast_nullable_to_non_nullable
                      as CircleStats,
            inviteCode: freezed == inviteCode
                ? _value.inviteCode
                : inviteCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of CircleModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CircleSettingsCopyWith<$Res> get settings {
    return $CircleSettingsCopyWith<$Res>(_value.settings, (value) {
      return _then(_value.copyWith(settings: value) as $Val);
    });
  }

  /// Create a copy of CircleModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PrivacySettingsCopyWith<$Res> get privacy {
    return $PrivacySettingsCopyWith<$Res>(_value.privacy, (value) {
      return _then(_value.copyWith(privacy: value) as $Val);
    });
  }

  /// Create a copy of CircleModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CircleStatsCopyWith<$Res> get stats {
    return $CircleStatsCopyWith<$Res>(_value.stats, (value) {
      return _then(_value.copyWith(stats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CircleModelImplCopyWith<$Res>
    implements $CircleModelCopyWith<$Res> {
  factory _$$CircleModelImplCopyWith(
    _$CircleModelImpl value,
    $Res Function(_$CircleModelImpl) then,
  ) = __$$CircleModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    String category,
    String creatorId,
    DateTime createdAt,
    DateTime updatedAt,
    CircleSettings settings,
    PrivacySettings privacy,
    CircleStats stats,
    String? inviteCode,
    bool isActive,
  });

  @override
  $CircleSettingsCopyWith<$Res> get settings;
  @override
  $PrivacySettingsCopyWith<$Res> get privacy;
  @override
  $CircleStatsCopyWith<$Res> get stats;
}

/// @nodoc
class __$$CircleModelImplCopyWithImpl<$Res>
    extends _$CircleModelCopyWithImpl<$Res, _$CircleModelImpl>
    implements _$$CircleModelImplCopyWith<$Res> {
  __$$CircleModelImplCopyWithImpl(
    _$CircleModelImpl _value,
    $Res Function(_$CircleModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CircleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? category = null,
    Object? creatorId = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? settings = null,
    Object? privacy = null,
    Object? stats = null,
    Object? inviteCode = freezed,
    Object? isActive = null,
  }) {
    return _then(
      _$CircleModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        creatorId: null == creatorId
            ? _value.creatorId
            : creatorId // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        settings: null == settings
            ? _value.settings
            : settings // ignore: cast_nullable_to_non_nullable
                  as CircleSettings,
        privacy: null == privacy
            ? _value.privacy
            : privacy // ignore: cast_nullable_to_non_nullable
                  as PrivacySettings,
        stats: null == stats
            ? _value.stats
            : stats // ignore: cast_nullable_to_non_nullable
                  as CircleStats,
        inviteCode: freezed == inviteCode
            ? _value.inviteCode
            : inviteCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CircleModelImpl implements _CircleModel {
  const _$CircleModelImpl({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.creatorId,
    required this.createdAt,
    required this.updatedAt,
    required this.settings,
    required this.privacy,
    required this.stats,
    this.inviteCode,
    this.isActive = true,
  });

  factory _$CircleModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CircleModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final String category;
  @override
  final String creatorId;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final CircleSettings settings;
  @override
  final PrivacySettings privacy;
  @override
  final CircleStats stats;
  @override
  final String? inviteCode;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'CircleModel(id: $id, name: $name, description: $description, category: $category, creatorId: $creatorId, createdAt: $createdAt, updatedAt: $updatedAt, settings: $settings, privacy: $privacy, stats: $stats, inviteCode: $inviteCode, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CircleModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.settings, settings) ||
                other.settings == settings) &&
            (identical(other.privacy, privacy) || other.privacy == privacy) &&
            (identical(other.stats, stats) || other.stats == stats) &&
            (identical(other.inviteCode, inviteCode) ||
                other.inviteCode == inviteCode) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    category,
    creatorId,
    createdAt,
    updatedAt,
    settings,
    privacy,
    stats,
    inviteCode,
    isActive,
  );

  /// Create a copy of CircleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CircleModelImplCopyWith<_$CircleModelImpl> get copyWith =>
      __$$CircleModelImplCopyWithImpl<_$CircleModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CircleModelImplToJson(this);
  }
}

abstract class _CircleModel implements CircleModel {
  const factory _CircleModel({
    required final String id,
    required final String name,
    required final String description,
    required final String category,
    required final String creatorId,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    required final CircleSettings settings,
    required final PrivacySettings privacy,
    required final CircleStats stats,
    final String? inviteCode,
    final bool isActive,
  }) = _$CircleModelImpl;

  factory _CircleModel.fromJson(Map<String, dynamic> json) =
      _$CircleModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  String get category;
  @override
  String get creatorId;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  CircleSettings get settings;
  @override
  PrivacySettings get privacy;
  @override
  CircleStats get stats;
  @override
  String? get inviteCode;
  @override
  bool get isActive;

  /// Create a copy of CircleModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CircleModelImplCopyWith<_$CircleModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CircleSettings _$CircleSettingsFromJson(Map<String, dynamic> json) {
  return _CircleSettings.fromJson(json);
}

/// @nodoc
mixin _$CircleSettings {
  String get iconType => throw _privateConstructorUsedError;
  String get colorTheme => throw _privateConstructorUsedError;
  String get activityName => throw _privateConstructorUsedError;
  bool get allowInvites => throw _privateConstructorUsedError;
  bool get enableNotifications => throw _privateConstructorUsedError;
  Map<String, dynamic> get customSettings => throw _privateConstructorUsedError;

  /// Serializes this CircleSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CircleSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CircleSettingsCopyWith<CircleSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CircleSettingsCopyWith<$Res> {
  factory $CircleSettingsCopyWith(
    CircleSettings value,
    $Res Function(CircleSettings) then,
  ) = _$CircleSettingsCopyWithImpl<$Res, CircleSettings>;
  @useResult
  $Res call({
    String iconType,
    String colorTheme,
    String activityName,
    bool allowInvites,
    bool enableNotifications,
    Map<String, dynamic> customSettings,
  });
}

/// @nodoc
class _$CircleSettingsCopyWithImpl<$Res, $Val extends CircleSettings>
    implements $CircleSettingsCopyWith<$Res> {
  _$CircleSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CircleSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? iconType = null,
    Object? colorTheme = null,
    Object? activityName = null,
    Object? allowInvites = null,
    Object? enableNotifications = null,
    Object? customSettings = null,
  }) {
    return _then(
      _value.copyWith(
            iconType: null == iconType
                ? _value.iconType
                : iconType // ignore: cast_nullable_to_non_nullable
                      as String,
            colorTheme: null == colorTheme
                ? _value.colorTheme
                : colorTheme // ignore: cast_nullable_to_non_nullable
                      as String,
            activityName: null == activityName
                ? _value.activityName
                : activityName // ignore: cast_nullable_to_non_nullable
                      as String,
            allowInvites: null == allowInvites
                ? _value.allowInvites
                : allowInvites // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableNotifications: null == enableNotifications
                ? _value.enableNotifications
                : enableNotifications // ignore: cast_nullable_to_non_nullable
                      as bool,
            customSettings: null == customSettings
                ? _value.customSettings
                : customSettings // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CircleSettingsImplCopyWith<$Res>
    implements $CircleSettingsCopyWith<$Res> {
  factory _$$CircleSettingsImplCopyWith(
    _$CircleSettingsImpl value,
    $Res Function(_$CircleSettingsImpl) then,
  ) = __$$CircleSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String iconType,
    String colorTheme,
    String activityName,
    bool allowInvites,
    bool enableNotifications,
    Map<String, dynamic> customSettings,
  });
}

/// @nodoc
class __$$CircleSettingsImplCopyWithImpl<$Res>
    extends _$CircleSettingsCopyWithImpl<$Res, _$CircleSettingsImpl>
    implements _$$CircleSettingsImplCopyWith<$Res> {
  __$$CircleSettingsImplCopyWithImpl(
    _$CircleSettingsImpl _value,
    $Res Function(_$CircleSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CircleSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? iconType = null,
    Object? colorTheme = null,
    Object? activityName = null,
    Object? allowInvites = null,
    Object? enableNotifications = null,
    Object? customSettings = null,
  }) {
    return _then(
      _$CircleSettingsImpl(
        iconType: null == iconType
            ? _value.iconType
            : iconType // ignore: cast_nullable_to_non_nullable
                  as String,
        colorTheme: null == colorTheme
            ? _value.colorTheme
            : colorTheme // ignore: cast_nullable_to_non_nullable
                  as String,
        activityName: null == activityName
            ? _value.activityName
            : activityName // ignore: cast_nullable_to_non_nullable
                  as String,
        allowInvites: null == allowInvites
            ? _value.allowInvites
            : allowInvites // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableNotifications: null == enableNotifications
            ? _value.enableNotifications
            : enableNotifications // ignore: cast_nullable_to_non_nullable
                  as bool,
        customSettings: null == customSettings
            ? _value._customSettings
            : customSettings // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CircleSettingsImpl implements _CircleSettings {
  const _$CircleSettingsImpl({
    this.iconType = 'groups',
    this.colorTheme = 'blue',
    this.activityName = '活動',
    this.allowInvites = true,
    this.enableNotifications = true,
    final Map<String, dynamic> customSettings = const <String, dynamic>{},
  }) : _customSettings = customSettings;

  factory _$CircleSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CircleSettingsImplFromJson(json);

  @override
  @JsonKey()
  final String iconType;
  @override
  @JsonKey()
  final String colorTheme;
  @override
  @JsonKey()
  final String activityName;
  @override
  @JsonKey()
  final bool allowInvites;
  @override
  @JsonKey()
  final bool enableNotifications;
  final Map<String, dynamic> _customSettings;
  @override
  @JsonKey()
  Map<String, dynamic> get customSettings {
    if (_customSettings is EqualUnmodifiableMapView) return _customSettings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_customSettings);
  }

  @override
  String toString() {
    return 'CircleSettings(iconType: $iconType, colorTheme: $colorTheme, activityName: $activityName, allowInvites: $allowInvites, enableNotifications: $enableNotifications, customSettings: $customSettings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CircleSettingsImpl &&
            (identical(other.iconType, iconType) ||
                other.iconType == iconType) &&
            (identical(other.colorTheme, colorTheme) ||
                other.colorTheme == colorTheme) &&
            (identical(other.activityName, activityName) ||
                other.activityName == activityName) &&
            (identical(other.allowInvites, allowInvites) ||
                other.allowInvites == allowInvites) &&
            (identical(other.enableNotifications, enableNotifications) ||
                other.enableNotifications == enableNotifications) &&
            const DeepCollectionEquality().equals(
              other._customSettings,
              _customSettings,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    iconType,
    colorTheme,
    activityName,
    allowInvites,
    enableNotifications,
    const DeepCollectionEquality().hash(_customSettings),
  );

  /// Create a copy of CircleSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CircleSettingsImplCopyWith<_$CircleSettingsImpl> get copyWith =>
      __$$CircleSettingsImplCopyWithImpl<_$CircleSettingsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CircleSettingsImplToJson(this);
  }
}

abstract class _CircleSettings implements CircleSettings {
  const factory _CircleSettings({
    final String iconType,
    final String colorTheme,
    final String activityName,
    final bool allowInvites,
    final bool enableNotifications,
    final Map<String, dynamic> customSettings,
  }) = _$CircleSettingsImpl;

  factory _CircleSettings.fromJson(Map<String, dynamic> json) =
      _$CircleSettingsImpl.fromJson;

  @override
  String get iconType;
  @override
  String get colorTheme;
  @override
  String get activityName;
  @override
  bool get allowInvites;
  @override
  bool get enableNotifications;
  @override
  Map<String, dynamic> get customSettings;

  /// Create a copy of CircleSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CircleSettingsImplCopyWith<_$CircleSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PrivacySettings _$PrivacySettingsFromJson(Map<String, dynamic> json) {
  return _PrivacySettings.fromJson(json);
}

/// @nodoc
mixin _$PrivacySettings {
  bool get isPublic => throw _privateConstructorUsedError;
  bool get searchable => throw _privateConstructorUsedError;
  bool get requiresApproval => throw _privateConstructorUsedError;
  bool get showMemberCount => throw _privateConstructorUsedError;
  bool get showActivity => throw _privateConstructorUsedError;

  /// Serializes this PrivacySettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PrivacySettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PrivacySettingsCopyWith<PrivacySettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrivacySettingsCopyWith<$Res> {
  factory $PrivacySettingsCopyWith(
    PrivacySettings value,
    $Res Function(PrivacySettings) then,
  ) = _$PrivacySettingsCopyWithImpl<$Res, PrivacySettings>;
  @useResult
  $Res call({
    bool isPublic,
    bool searchable,
    bool requiresApproval,
    bool showMemberCount,
    bool showActivity,
  });
}

/// @nodoc
class _$PrivacySettingsCopyWithImpl<$Res, $Val extends PrivacySettings>
    implements $PrivacySettingsCopyWith<$Res> {
  _$PrivacySettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PrivacySettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPublic = null,
    Object? searchable = null,
    Object? requiresApproval = null,
    Object? showMemberCount = null,
    Object? showActivity = null,
  }) {
    return _then(
      _value.copyWith(
            isPublic: null == isPublic
                ? _value.isPublic
                : isPublic // ignore: cast_nullable_to_non_nullable
                      as bool,
            searchable: null == searchable
                ? _value.searchable
                : searchable // ignore: cast_nullable_to_non_nullable
                      as bool,
            requiresApproval: null == requiresApproval
                ? _value.requiresApproval
                : requiresApproval // ignore: cast_nullable_to_non_nullable
                      as bool,
            showMemberCount: null == showMemberCount
                ? _value.showMemberCount
                : showMemberCount // ignore: cast_nullable_to_non_nullable
                      as bool,
            showActivity: null == showActivity
                ? _value.showActivity
                : showActivity // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PrivacySettingsImplCopyWith<$Res>
    implements $PrivacySettingsCopyWith<$Res> {
  factory _$$PrivacySettingsImplCopyWith(
    _$PrivacySettingsImpl value,
    $Res Function(_$PrivacySettingsImpl) then,
  ) = __$$PrivacySettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isPublic,
    bool searchable,
    bool requiresApproval,
    bool showMemberCount,
    bool showActivity,
  });
}

/// @nodoc
class __$$PrivacySettingsImplCopyWithImpl<$Res>
    extends _$PrivacySettingsCopyWithImpl<$Res, _$PrivacySettingsImpl>
    implements _$$PrivacySettingsImplCopyWith<$Res> {
  __$$PrivacySettingsImplCopyWithImpl(
    _$PrivacySettingsImpl _value,
    $Res Function(_$PrivacySettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PrivacySettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPublic = null,
    Object? searchable = null,
    Object? requiresApproval = null,
    Object? showMemberCount = null,
    Object? showActivity = null,
  }) {
    return _then(
      _$PrivacySettingsImpl(
        isPublic: null == isPublic
            ? _value.isPublic
            : isPublic // ignore: cast_nullable_to_non_nullable
                  as bool,
        searchable: null == searchable
            ? _value.searchable
            : searchable // ignore: cast_nullable_to_non_nullable
                  as bool,
        requiresApproval: null == requiresApproval
            ? _value.requiresApproval
            : requiresApproval // ignore: cast_nullable_to_non_nullable
                  as bool,
        showMemberCount: null == showMemberCount
            ? _value.showMemberCount
            : showMemberCount // ignore: cast_nullable_to_non_nullable
                  as bool,
        showActivity: null == showActivity
            ? _value.showActivity
            : showActivity // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PrivacySettingsImpl implements _PrivacySettings {
  const _$PrivacySettingsImpl({
    this.isPublic = true,
    this.searchable = true,
    this.requiresApproval = false,
    this.showMemberCount = true,
    this.showActivity = true,
  });

  factory _$PrivacySettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PrivacySettingsImplFromJson(json);

  @override
  @JsonKey()
  final bool isPublic;
  @override
  @JsonKey()
  final bool searchable;
  @override
  @JsonKey()
  final bool requiresApproval;
  @override
  @JsonKey()
  final bool showMemberCount;
  @override
  @JsonKey()
  final bool showActivity;

  @override
  String toString() {
    return 'PrivacySettings(isPublic: $isPublic, searchable: $searchable, requiresApproval: $requiresApproval, showMemberCount: $showMemberCount, showActivity: $showActivity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrivacySettingsImpl &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            (identical(other.searchable, searchable) ||
                other.searchable == searchable) &&
            (identical(other.requiresApproval, requiresApproval) ||
                other.requiresApproval == requiresApproval) &&
            (identical(other.showMemberCount, showMemberCount) ||
                other.showMemberCount == showMemberCount) &&
            (identical(other.showActivity, showActivity) ||
                other.showActivity == showActivity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    isPublic,
    searchable,
    requiresApproval,
    showMemberCount,
    showActivity,
  );

  /// Create a copy of PrivacySettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PrivacySettingsImplCopyWith<_$PrivacySettingsImpl> get copyWith =>
      __$$PrivacySettingsImplCopyWithImpl<_$PrivacySettingsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PrivacySettingsImplToJson(this);
  }
}

abstract class _PrivacySettings implements PrivacySettings {
  const factory _PrivacySettings({
    final bool isPublic,
    final bool searchable,
    final bool requiresApproval,
    final bool showMemberCount,
    final bool showActivity,
  }) = _$PrivacySettingsImpl;

  factory _PrivacySettings.fromJson(Map<String, dynamic> json) =
      _$PrivacySettingsImpl.fromJson;

  @override
  bool get isPublic;
  @override
  bool get searchable;
  @override
  bool get requiresApproval;
  @override
  bool get showMemberCount;
  @override
  bool get showActivity;

  /// Create a copy of PrivacySettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PrivacySettingsImplCopyWith<_$PrivacySettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CircleStats _$CircleStatsFromJson(Map<String, dynamic> json) {
  return _CircleStats.fromJson(json);
}

/// @nodoc
mixin _$CircleStats {
  int get memberCount => throw _privateConstructorUsedError;
  int get activityCount => throw _privateConstructorUsedError;
  DateTime? get lastActivityAt => throw _privateConstructorUsedError;

  /// Serializes this CircleStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CircleStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CircleStatsCopyWith<CircleStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CircleStatsCopyWith<$Res> {
  factory $CircleStatsCopyWith(
    CircleStats value,
    $Res Function(CircleStats) then,
  ) = _$CircleStatsCopyWithImpl<$Res, CircleStats>;
  @useResult
  $Res call({int memberCount, int activityCount, DateTime? lastActivityAt});
}

/// @nodoc
class _$CircleStatsCopyWithImpl<$Res, $Val extends CircleStats>
    implements $CircleStatsCopyWith<$Res> {
  _$CircleStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CircleStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? memberCount = null,
    Object? activityCount = null,
    Object? lastActivityAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            memberCount: null == memberCount
                ? _value.memberCount
                : memberCount // ignore: cast_nullable_to_non_nullable
                      as int,
            activityCount: null == activityCount
                ? _value.activityCount
                : activityCount // ignore: cast_nullable_to_non_nullable
                      as int,
            lastActivityAt: freezed == lastActivityAt
                ? _value.lastActivityAt
                : lastActivityAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CircleStatsImplCopyWith<$Res>
    implements $CircleStatsCopyWith<$Res> {
  factory _$$CircleStatsImplCopyWith(
    _$CircleStatsImpl value,
    $Res Function(_$CircleStatsImpl) then,
  ) = __$$CircleStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int memberCount, int activityCount, DateTime? lastActivityAt});
}

/// @nodoc
class __$$CircleStatsImplCopyWithImpl<$Res>
    extends _$CircleStatsCopyWithImpl<$Res, _$CircleStatsImpl>
    implements _$$CircleStatsImplCopyWith<$Res> {
  __$$CircleStatsImplCopyWithImpl(
    _$CircleStatsImpl _value,
    $Res Function(_$CircleStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CircleStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? memberCount = null,
    Object? activityCount = null,
    Object? lastActivityAt = freezed,
  }) {
    return _then(
      _$CircleStatsImpl(
        memberCount: null == memberCount
            ? _value.memberCount
            : memberCount // ignore: cast_nullable_to_non_nullable
                  as int,
        activityCount: null == activityCount
            ? _value.activityCount
            : activityCount // ignore: cast_nullable_to_non_nullable
                  as int,
        lastActivityAt: freezed == lastActivityAt
            ? _value.lastActivityAt
            : lastActivityAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CircleStatsImpl implements _CircleStats {
  const _$CircleStatsImpl({
    this.memberCount = 0,
    this.activityCount = 0,
    this.lastActivityAt,
  });

  factory _$CircleStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CircleStatsImplFromJson(json);

  @override
  @JsonKey()
  final int memberCount;
  @override
  @JsonKey()
  final int activityCount;
  @override
  final DateTime? lastActivityAt;

  @override
  String toString() {
    return 'CircleStats(memberCount: $memberCount, activityCount: $activityCount, lastActivityAt: $lastActivityAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CircleStatsImpl &&
            (identical(other.memberCount, memberCount) ||
                other.memberCount == memberCount) &&
            (identical(other.activityCount, activityCount) ||
                other.activityCount == activityCount) &&
            (identical(other.lastActivityAt, lastActivityAt) ||
                other.lastActivityAt == lastActivityAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, memberCount, activityCount, lastActivityAt);

  /// Create a copy of CircleStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CircleStatsImplCopyWith<_$CircleStatsImpl> get copyWith =>
      __$$CircleStatsImplCopyWithImpl<_$CircleStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CircleStatsImplToJson(this);
  }
}

abstract class _CircleStats implements CircleStats {
  const factory _CircleStats({
    final int memberCount,
    final int activityCount,
    final DateTime? lastActivityAt,
  }) = _$CircleStatsImpl;

  factory _CircleStats.fromJson(Map<String, dynamic> json) =
      _$CircleStatsImpl.fromJson;

  @override
  int get memberCount;
  @override
  int get activityCount;
  @override
  DateTime? get lastActivityAt;

  /// Create a copy of CircleStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CircleStatsImplCopyWith<_$CircleStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
