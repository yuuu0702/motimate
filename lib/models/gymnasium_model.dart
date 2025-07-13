import 'package:freezed_annotation/freezed_annotation.dart';

part 'gymnasium_model.freezed.dart';
part 'gymnasium_model.g.dart';

/// 体育館情報モデル
/// 
/// 金沢市の体育館の基本情報、設備、料金情報を管理
@freezed
class GymnasiumModel with _$GymnasiumModel {
  const factory GymnasiumModel({
    /// 体育館ID
    required String id,
    /// 体育館名
    required String name,
    /// 住所
    required String address,
    /// 緯度経度
    required LatLng location,
    /// 利用可能な設備・施設
    @Default([]) List<String> facilities,
    /// 時間帯別料金（キー: 時間帯、値: 料金）
    @Default({}) Map<String, int> fees,
    /// 電話番号
    String? phone,
    /// ウェブサイトURL
    String? website,
    /// 体育館の画像URL
    @Default([]) List<String> images,
    /// 説明・備考
    String? description,
    /// 営業時間
    String? openingHours,
    /// 定休日
    String? closedDays,
    /// 駐車場台数
    int? parkingSpaces,
    /// アクセス情報
    String? accessInfo,
  }) = _GymnasiumModel;

  factory GymnasiumModel.fromJson(Map<String, dynamic> json) =>
      _$GymnasiumModelFromJson(json);
}

/// 緯度経度情報
@freezed
class LatLng with _$LatLng {
  const factory LatLng({
    required double latitude,
    required double longitude,
  }) = _LatLng;

  factory LatLng.fromJson(Map<String, dynamic> json) =>
      _$LatLngFromJson(json);
}

/// 体育館の設備タイプ
class GymnasiumFacilities {
  static const String basketball = 'バスケットボール';
  static const String volleyball = 'バレーボール';
  static const String badminton = 'バドミントン';
  static const String tabletennis = '卓球';
  static const String futsal = 'フットサル';
  static const String tennis = 'テニス';
  static const String gymnasium = '総合体育館';
  static const String swimming = 'プール';
  static const String judo = '柔道場';
  static const String kendo = '剣道場';
  static const String dancestudio = 'ダンススタジオ';
  static const String fitnessroom = 'フィットネスルーム';
  static const String changingroom = '更衣室';
  static const String shower = 'シャワー';
  static const String parking = '駐車場';
  static const String airconditioning = '空調設備';
  static const String wifi = 'Wi-Fi';

  static const List<String> allFacilities = [
    basketball,
    volleyball,
    badminton,
    tabletennis,
    futsal,
    tennis,
    gymnasium,
    swimming,
    judo,
    kendo,
    dancestudio,
    fitnessroom,
    changingroom,
    shower,
    parking,
    airconditioning,
    wifi,
  ];
}

/// 時間帯定義
class TimeSlots {
  static const String morning = '午前';
  static const String afternoon = '午後';
  static const String evening = '夜間';
  static const String allDay = '全日';

  static const List<String> allTimeSlots = [
    morning,
    afternoon,
    evening,
    allDay,
  ];
}