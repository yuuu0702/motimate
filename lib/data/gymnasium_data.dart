import 'dart:math';
import '../models/gymnasium_model.dart';

/// 金沢市のバスケットボール利用可能体育館データ
/// 
/// バスケットボールが利用可能な金沢市の体育館情報を基に作成
class GymnasiumData {
  /// すべてのバスケ利用可能体育館
  static final List<GymnasiumModel> gymnasiums = [
    // 金沢市総合体育館
    GymnasiumModel(
      id: 'kanazawa_sogo',
      name: '金沢市総合体育館',
      address: '石川県金沢市泉野出町3-8-1',
      location: const LatLng(latitude: 36.5384, longitude: 136.6319),
      facilities: const [
        GymnasiumFacilities.basketball,
        GymnasiumFacilities.gymnasium,
        GymnasiumFacilities.changingroom,
        GymnasiumFacilities.parking,
        GymnasiumFacilities.airconditioning,
      ],
      fees: const {
        TimeSlots.morning: 3200,
        TimeSlots.afternoon: 3200,
        TimeSlots.evening: 4000,
        TimeSlots.allDay: 9600,
      },
      phone: '076-247-9019',
      website: 'https://www.kanazawa-sports.jp/',
      description: '金沢市最大規模の総合体育館。バスケットボール正式コート2面分の広いアリーナで本格的な練習・試合が可能。',
      openingHours: '9:00-21:00',
      closedDays: '毎週月曜日（祝日の場合は翌日）、年末年始',
      parkingSpaces: 200,
      accessInfo: 'バス停「総合体育館前」から徒歩1分',
      images: const [
        'https://example.com/kanazawa_sogo_1.jpg',
        'https://example.com/kanazawa_sogo_2.jpg',
      ],
    ),


    // 金沢市西部市民体育館
    GymnasiumModel(
      id: 'seibu_taiikukan',
      name: '金沢市西部市民体育館',
      address: '石川県金沢市古府2-136',
      location: const LatLng(latitude: 36.5759, longitude: 136.6089),
      facilities: const [
        GymnasiumFacilities.basketball,
        GymnasiumFacilities.gymnasium,
        GymnasiumFacilities.changingroom,
        GymnasiumFacilities.parking,
      ],
      fees: const {
        TimeSlots.morning: 1600,
        TimeSlots.afternoon: 1600,
        TimeSlots.evening: 2000,
        TimeSlots.allDay: 4800,
      },
      phone: '076-269-9000',
      description: 'バスケットボールコート2面分の広いスペース。地域のバスケチームに人気の施設です。',
      openingHours: '9:00-21:00',
      closedDays: '毎週月曜日（祝日の場合は翌日）、年末年始',
      parkingSpaces: 80,
      accessInfo: 'バス停「古府」から徒歩5分',
    ),

    // 金沢市東部市民体育館
    GymnasiumModel(
      id: 'tobu_taiikukan',
      name: '金沢市東部市民体育館',
      address: '石川県金沢市大桑町3-82',
      location: const LatLng(latitude: 36.5452, longitude: 136.6813),
      facilities: const [
        GymnasiumFacilities.basketball,
        GymnasiumFacilities.gymnasium,
        GymnasiumFacilities.changingroom,
        GymnasiumFacilities.parking,
      ],
      fees: const {
        TimeSlots.morning: 1600,
        TimeSlots.afternoon: 1600,
        TimeSlots.evening: 2000,
        TimeSlots.allDay: 4800,
      },
      phone: '076-251-9996',
      description: '東部地区のバスケ練習拠点。フルコート利用可能でアクセスも抜群です。',
      openingHours: '9:00-21:00',
      closedDays: '毎週月曜日（祝日の場合は翌日）、年末年始',
      parkingSpaces: 100,
      accessInfo: 'バス停「大桑町」から徒歩3分',
    ),

    // 金沢市南部市民体育館
    GymnasiumModel(
      id: 'nanbu_taiikukan',
      name: '金沢市南部市民体育館',
      address: '石川県金沢市富樫3-4-25',
      location: const LatLng(latitude: 36.5183, longitude: 136.6456),
      facilities: const [
        GymnasiumFacilities.basketball,
        GymnasiumFacilities.gymnasium,
        GymnasiumFacilities.changingroom,
        GymnasiumFacilities.parking,
      ],
      fees: const {
        TimeSlots.morning: 1600,
        TimeSlots.afternoon: 1600,
        TimeSlots.evening: 2000,
        TimeSlots.allDay: 4800,
      },
      phone: '076-243-7285',
      description: '南部地区のバスケ練習場。住宅街の静かな環境でしっかりと練習に集中できます。',
      openingHours: '9:00-21:00',
      closedDays: '毎週月曜日（祝日の場合は翌日）、年末年始',
      parkingSpaces: 70,
      accessInfo: 'バス停「富樫」から徒歩5分',
    ),

    // 金沢市北部市民体育館
    GymnasiumModel(
      id: 'hokubu_taiikukan',
      name: '金沢市北部市民体育館',
      address: '石川県金沢市柳橋町甲5-5',
      location: const LatLng(latitude: 36.5892, longitude: 136.6456),
      facilities: const [
        GymnasiumFacilities.basketball,
        GymnasiumFacilities.gymnasium,
        GymnasiumFacilities.changingroom,
        GymnasiumFacilities.parking,
      ],
      fees: const {
        TimeSlots.morning: 1600,
        TimeSlots.afternoon: 1600,
        TimeSlots.evening: 2000,
        TimeSlots.allDay: 4800,
      },
      phone: '076-251-6677',
      description: '北部地区のバスケ施設。駐車場完備で車でのアクセスが便利です。',
      openingHours: '9:00-21:00',
      closedDays: '毎週月曜日（祝日の場合は翌日）、年末年始',
      parkingSpaces: 120,
      accessInfo: 'バス停「柳橋」から徒歩7分',
    ),


    // 金沢市民体育館
    GymnasiumModel(
      id: 'shimin_taiikukan',
      name: '金沢市民体育館',
      address: '石川県金沢市中央1-3-10',
      location: const LatLng(latitude: 36.5606, longitude: 136.6523),
      facilities: const [
        GymnasiumFacilities.basketball,
        GymnasiumFacilities.gymnasium,
        GymnasiumFacilities.changingroom,
        GymnasiumFacilities.parking,
      ],
      fees: const {
        TimeSlots.morning: 1800,
        TimeSlots.afternoon: 1800,
        TimeSlots.evening: 2200,
        TimeSlots.allDay: 5400,
      },
      phone: '076-262-5125',
      description: '中心部の便利なバスケ練習場。駅からのアクセスが抜群で通いやすいです。',
      openingHours: '9:00-21:00',
      closedDays: '毎週月曜日（祝日の場合は翌日）、年末年始',
      parkingSpaces: 60,
      accessInfo: 'JR金沢駅から徒歩15分、バス停「中央病院」から徒歩3分',
    ),

    // 金沢工業大学扇が丘体育館（一般開放時）
    GymnasiumModel(
      id: 'kit_ogigaoka',
      name: '金沢工業大学扇が丘体育館',
      address: '石川県金沢市扇が丘7-1',
      location: const LatLng(latitude: 36.5441, longitude: 136.6248),
      facilities: const [
        GymnasiumFacilities.basketball,
        GymnasiumFacilities.gymnasium,
        GymnasiumFacilities.changingroom,
        GymnasiumFacilities.parking,
        GymnasiumFacilities.airconditioning,
      ],
      fees: const {
        TimeSlots.morning: 2500,
        TimeSlots.afternoon: 2500,
        TimeSlots.evening: 3000,
        TimeSlots.allDay: 7500,
      },
      phone: '076-248-1100',
      website: 'https://www.kanazawa-it.ac.jp/',
      description: '大学施設の一般開放。バスケ専用コートで近代的な設備が整っています。',
      openingHours: '18:00-21:00（平日のみ一般開放）',
      closedDays: '土日祝日、大学行事日',
      parkingSpaces: 150,
      accessInfo: 'バス停「金沢工業大学前」から徒歩5分',
    ),

    // 金沢市勤労者体育センター
    GymnasiumModel(
      id: 'kinrosha_center',
      name: '金沢市勤労者体育センター',
      address: '石川県金沢市問屋町2-15',
      location: const LatLng(latitude: 36.5742, longitude: 136.6712),
      facilities: const [
        GymnasiumFacilities.basketball,
        GymnasiumFacilities.gymnasium,
        GymnasiumFacilities.changingroom,
        GymnasiumFacilities.parking,
      ],
      fees: const {
        TimeSlots.morning: 1400,
        TimeSlots.afternoon: 1400,
        TimeSlots.evening: 1800,
        TimeSlots.allDay: 4200,
      },
      phone: '076-239-0505',
      description: 'リーズナブルな料金でバスケ練習が可能。勤労者向けの使いやすい施設です。',
      openingHours: '9:00-21:00',
      closedDays: '毎週月曜日（祝日の場合は翌日）、年末年始',
      parkingSpaces: 80,
      accessInfo: 'バス停「問屋町」から徒歩3分',
    ),
  ];

  /// IDから体育館を取得
  static GymnasiumModel? getGymnasiumById(String id) {
    try {
      return gymnasiums.firstWhere((gym) => gym.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 設備でフィルタリング
  static List<GymnasiumModel> getGymnasiumsByFacility(String facility) {
    return gymnasiums
        .where((gym) => gym.facilities.contains(facility))
        .toList();
  }

  /// 料金範囲でフィルタリング
  static List<GymnasiumModel> getGymnasiumsByPriceRange(
    String timeSlot,
    int minPrice,
    int maxPrice,
  ) {
    return gymnasiums.where((gym) {
      final price = gym.fees[timeSlot];
      return price != null && price >= minPrice && price <= maxPrice;
    }).toList();
  }

  /// 距離でソート
  static List<GymnasiumModel> sortByDistance(
    List<GymnasiumModel> gymnasiums,
    LatLng userLocation,
  ) {
    final List<GymnasiumModel> sortedGymnasiums = List.from(gymnasiums);
    sortedGymnasiums.sort((a, b) {
      final distanceA = _calculateDistance(userLocation, a.location);
      final distanceB = _calculateDistance(userLocation, b.location);
      return distanceA.compareTo(distanceB);
    });
    return sortedGymnasiums;
  }

  /// 2点間の距離を計算（簡易版）
  static double _calculateDistance(LatLng point1, LatLng point2) {
    final double latDiff = point1.latitude - point2.latitude;
    final double lngDiff = point1.longitude - point2.longitude;
    return sqrt(latDiff * latDiff + lngDiff * lngDiff);
  }
}