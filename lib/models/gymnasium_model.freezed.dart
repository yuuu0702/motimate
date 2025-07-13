// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gymnasium_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GymnasiumModel _$GymnasiumModelFromJson(Map<String, dynamic> json) {
  return _GymnasiumModel.fromJson(json);
}

/// @nodoc
mixin _$GymnasiumModel {
  /// 体育館ID
  String get id => throw _privateConstructorUsedError;

  /// 体育館名
  String get name => throw _privateConstructorUsedError;

  /// 住所
  String get address => throw _privateConstructorUsedError;

  /// 緯度経度
  LatLng get location => throw _privateConstructorUsedError;

  /// 利用可能な設備・施設
  List<String> get facilities => throw _privateConstructorUsedError;

  /// 時間帯別料金（キー: 時間帯、値: 料金）
  Map<String, int> get fees => throw _privateConstructorUsedError;

  /// 電話番号
  String? get phone => throw _privateConstructorUsedError;

  /// ウェブサイトURL
  String? get website => throw _privateConstructorUsedError;

  /// 体育館の画像URL
  List<String> get images => throw _privateConstructorUsedError;

  /// 説明・備考
  String? get description => throw _privateConstructorUsedError;

  /// 営業時間
  String? get openingHours => throw _privateConstructorUsedError;

  /// 定休日
  String? get closedDays => throw _privateConstructorUsedError;

  /// 駐車場台数
  int? get parkingSpaces => throw _privateConstructorUsedError;

  /// アクセス情報
  String? get accessInfo => throw _privateConstructorUsedError;

  /// Serializes this GymnasiumModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GymnasiumModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GymnasiumModelCopyWith<GymnasiumModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GymnasiumModelCopyWith<$Res> {
  factory $GymnasiumModelCopyWith(
    GymnasiumModel value,
    $Res Function(GymnasiumModel) then,
  ) = _$GymnasiumModelCopyWithImpl<$Res, GymnasiumModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String address,
    LatLng location,
    List<String> facilities,
    Map<String, int> fees,
    String? phone,
    String? website,
    List<String> images,
    String? description,
    String? openingHours,
    String? closedDays,
    int? parkingSpaces,
    String? accessInfo,
  });

  $LatLngCopyWith<$Res> get location;
}

/// @nodoc
class _$GymnasiumModelCopyWithImpl<$Res, $Val extends GymnasiumModel>
    implements $GymnasiumModelCopyWith<$Res> {
  _$GymnasiumModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GymnasiumModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = null,
    Object? location = null,
    Object? facilities = null,
    Object? fees = null,
    Object? phone = freezed,
    Object? website = freezed,
    Object? images = null,
    Object? description = freezed,
    Object? openingHours = freezed,
    Object? closedDays = freezed,
    Object? parkingSpaces = freezed,
    Object? accessInfo = freezed,
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
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            location: null == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as LatLng,
            facilities: null == facilities
                ? _value.facilities
                : facilities // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            fees: null == fees
                ? _value.fees
                : fees // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            website: freezed == website
                ? _value.website
                : website // ignore: cast_nullable_to_non_nullable
                      as String?,
            images: null == images
                ? _value.images
                : images // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            openingHours: freezed == openingHours
                ? _value.openingHours
                : openingHours // ignore: cast_nullable_to_non_nullable
                      as String?,
            closedDays: freezed == closedDays
                ? _value.closedDays
                : closedDays // ignore: cast_nullable_to_non_nullable
                      as String?,
            parkingSpaces: freezed == parkingSpaces
                ? _value.parkingSpaces
                : parkingSpaces // ignore: cast_nullable_to_non_nullable
                      as int?,
            accessInfo: freezed == accessInfo
                ? _value.accessInfo
                : accessInfo // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of GymnasiumModel
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
abstract class _$$GymnasiumModelImplCopyWith<$Res>
    implements $GymnasiumModelCopyWith<$Res> {
  factory _$$GymnasiumModelImplCopyWith(
    _$GymnasiumModelImpl value,
    $Res Function(_$GymnasiumModelImpl) then,
  ) = __$$GymnasiumModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String address,
    LatLng location,
    List<String> facilities,
    Map<String, int> fees,
    String? phone,
    String? website,
    List<String> images,
    String? description,
    String? openingHours,
    String? closedDays,
    int? parkingSpaces,
    String? accessInfo,
  });

  @override
  $LatLngCopyWith<$Res> get location;
}

/// @nodoc
class __$$GymnasiumModelImplCopyWithImpl<$Res>
    extends _$GymnasiumModelCopyWithImpl<$Res, _$GymnasiumModelImpl>
    implements _$$GymnasiumModelImplCopyWith<$Res> {
  __$$GymnasiumModelImplCopyWithImpl(
    _$GymnasiumModelImpl _value,
    $Res Function(_$GymnasiumModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GymnasiumModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = null,
    Object? location = null,
    Object? facilities = null,
    Object? fees = null,
    Object? phone = freezed,
    Object? website = freezed,
    Object? images = null,
    Object? description = freezed,
    Object? openingHours = freezed,
    Object? closedDays = freezed,
    Object? parkingSpaces = freezed,
    Object? accessInfo = freezed,
  }) {
    return _then(
      _$GymnasiumModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
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
        facilities: null == facilities
            ? _value._facilities
            : facilities // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        fees: null == fees
            ? _value._fees
            : fees // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        website: freezed == website
            ? _value.website
            : website // ignore: cast_nullable_to_non_nullable
                  as String?,
        images: null == images
            ? _value._images
            : images // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        openingHours: freezed == openingHours
            ? _value.openingHours
            : openingHours // ignore: cast_nullable_to_non_nullable
                  as String?,
        closedDays: freezed == closedDays
            ? _value.closedDays
            : closedDays // ignore: cast_nullable_to_non_nullable
                  as String?,
        parkingSpaces: freezed == parkingSpaces
            ? _value.parkingSpaces
            : parkingSpaces // ignore: cast_nullable_to_non_nullable
                  as int?,
        accessInfo: freezed == accessInfo
            ? _value.accessInfo
            : accessInfo // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GymnasiumModelImpl implements _GymnasiumModel {
  const _$GymnasiumModelImpl({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    final List<String> facilities = const [],
    final Map<String, int> fees = const {},
    this.phone,
    this.website,
    final List<String> images = const [],
    this.description,
    this.openingHours,
    this.closedDays,
    this.parkingSpaces,
    this.accessInfo,
  }) : _facilities = facilities,
       _fees = fees,
       _images = images;

  factory _$GymnasiumModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GymnasiumModelImplFromJson(json);

  /// 体育館ID
  @override
  final String id;

  /// 体育館名
  @override
  final String name;

  /// 住所
  @override
  final String address;

  /// 緯度経度
  @override
  final LatLng location;

  /// 利用可能な設備・施設
  final List<String> _facilities;

  /// 利用可能な設備・施設
  @override
  @JsonKey()
  List<String> get facilities {
    if (_facilities is EqualUnmodifiableListView) return _facilities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_facilities);
  }

  /// 時間帯別料金（キー: 時間帯、値: 料金）
  final Map<String, int> _fees;

  /// 時間帯別料金（キー: 時間帯、値: 料金）
  @override
  @JsonKey()
  Map<String, int> get fees {
    if (_fees is EqualUnmodifiableMapView) return _fees;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_fees);
  }

  /// 電話番号
  @override
  final String? phone;

  /// ウェブサイトURL
  @override
  final String? website;

  /// 体育館の画像URL
  final List<String> _images;

  /// 体育館の画像URL
  @override
  @JsonKey()
  List<String> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  /// 説明・備考
  @override
  final String? description;

  /// 営業時間
  @override
  final String? openingHours;

  /// 定休日
  @override
  final String? closedDays;

  /// 駐車場台数
  @override
  final int? parkingSpaces;

  /// アクセス情報
  @override
  final String? accessInfo;

  @override
  String toString() {
    return 'GymnasiumModel(id: $id, name: $name, address: $address, location: $location, facilities: $facilities, fees: $fees, phone: $phone, website: $website, images: $images, description: $description, openingHours: $openingHours, closedDays: $closedDays, parkingSpaces: $parkingSpaces, accessInfo: $accessInfo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GymnasiumModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality().equals(
              other._facilities,
              _facilities,
            ) &&
            const DeepCollectionEquality().equals(other._fees, _fees) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.website, website) || other.website == website) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.openingHours, openingHours) ||
                other.openingHours == openingHours) &&
            (identical(other.closedDays, closedDays) ||
                other.closedDays == closedDays) &&
            (identical(other.parkingSpaces, parkingSpaces) ||
                other.parkingSpaces == parkingSpaces) &&
            (identical(other.accessInfo, accessInfo) ||
                other.accessInfo == accessInfo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    address,
    location,
    const DeepCollectionEquality().hash(_facilities),
    const DeepCollectionEquality().hash(_fees),
    phone,
    website,
    const DeepCollectionEquality().hash(_images),
    description,
    openingHours,
    closedDays,
    parkingSpaces,
    accessInfo,
  );

  /// Create a copy of GymnasiumModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GymnasiumModelImplCopyWith<_$GymnasiumModelImpl> get copyWith =>
      __$$GymnasiumModelImplCopyWithImpl<_$GymnasiumModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GymnasiumModelImplToJson(this);
  }
}

abstract class _GymnasiumModel implements GymnasiumModel {
  const factory _GymnasiumModel({
    required final String id,
    required final String name,
    required final String address,
    required final LatLng location,
    final List<String> facilities,
    final Map<String, int> fees,
    final String? phone,
    final String? website,
    final List<String> images,
    final String? description,
    final String? openingHours,
    final String? closedDays,
    final int? parkingSpaces,
    final String? accessInfo,
  }) = _$GymnasiumModelImpl;

  factory _GymnasiumModel.fromJson(Map<String, dynamic> json) =
      _$GymnasiumModelImpl.fromJson;

  /// 体育館ID
  @override
  String get id;

  /// 体育館名
  @override
  String get name;

  /// 住所
  @override
  String get address;

  /// 緯度経度
  @override
  LatLng get location;

  /// 利用可能な設備・施設
  @override
  List<String> get facilities;

  /// 時間帯別料金（キー: 時間帯、値: 料金）
  @override
  Map<String, int> get fees;

  /// 電話番号
  @override
  String? get phone;

  /// ウェブサイトURL
  @override
  String? get website;

  /// 体育館の画像URL
  @override
  List<String> get images;

  /// 説明・備考
  @override
  String? get description;

  /// 営業時間
  @override
  String? get openingHours;

  /// 定休日
  @override
  String? get closedDays;

  /// 駐車場台数
  @override
  int? get parkingSpaces;

  /// アクセス情報
  @override
  String? get accessInfo;

  /// Create a copy of GymnasiumModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GymnasiumModelImplCopyWith<_$GymnasiumModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LatLng _$LatLngFromJson(Map<String, dynamic> json) {
  return _LatLng.fromJson(json);
}

/// @nodoc
mixin _$LatLng {
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;

  /// Serializes this LatLng to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LatLng
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LatLngCopyWith<LatLng> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LatLngCopyWith<$Res> {
  factory $LatLngCopyWith(LatLng value, $Res Function(LatLng) then) =
      _$LatLngCopyWithImpl<$Res, LatLng>;
  @useResult
  $Res call({double latitude, double longitude});
}

/// @nodoc
class _$LatLngCopyWithImpl<$Res, $Val extends LatLng>
    implements $LatLngCopyWith<$Res> {
  _$LatLngCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LatLng
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? latitude = null, Object? longitude = null}) {
    return _then(
      _value.copyWith(
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LatLngImplCopyWith<$Res> implements $LatLngCopyWith<$Res> {
  factory _$$LatLngImplCopyWith(
    _$LatLngImpl value,
    $Res Function(_$LatLngImpl) then,
  ) = __$$LatLngImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double latitude, double longitude});
}

/// @nodoc
class __$$LatLngImplCopyWithImpl<$Res>
    extends _$LatLngCopyWithImpl<$Res, _$LatLngImpl>
    implements _$$LatLngImplCopyWith<$Res> {
  __$$LatLngImplCopyWithImpl(
    _$LatLngImpl _value,
    $Res Function(_$LatLngImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LatLng
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? latitude = null, Object? longitude = null}) {
    return _then(
      _$LatLngImpl(
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LatLngImpl implements _LatLng {
  const _$LatLngImpl({required this.latitude, required this.longitude});

  factory _$LatLngImpl.fromJson(Map<String, dynamic> json) =>
      _$$LatLngImplFromJson(json);

  @override
  final double latitude;
  @override
  final double longitude;

  @override
  String toString() {
    return 'LatLng(latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LatLngImpl &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, latitude, longitude);

  /// Create a copy of LatLng
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LatLngImplCopyWith<_$LatLngImpl> get copyWith =>
      __$$LatLngImplCopyWithImpl<_$LatLngImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LatLngImplToJson(this);
  }
}

abstract class _LatLng implements LatLng {
  const factory _LatLng({
    required final double latitude,
    required final double longitude,
  }) = _$LatLngImpl;

  factory _LatLng.fromJson(Map<String, dynamic> json) = _$LatLngImpl.fromJson;

  @override
  double get latitude;
  @override
  double get longitude;

  /// Create a copy of LatLng
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LatLngImplCopyWith<_$LatLngImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
