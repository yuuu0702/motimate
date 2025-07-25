import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/cache/cache_manager.dart';

/// 画像・アイコンキャッシュサービス
class ImageCacheService {
  ImageCacheService({required this.cacheManager});

  final CacheManager cacheManager;
  static const String _iconCachePrefix = 'icon_cache_';
  static const String _imageCachePrefix = 'image_cache_';

  /// アイコンデータをキャッシュから取得またはロード
  Future<Icon> getCachedIcon({
    required IconData iconData,
    Color? color,
    double? size,
  }) async {
    final colorHex = color != null ? '${(color.r * 255).round()}_${(color.g * 255).round()}_${(color.b * 255).round()}' : 'null';
    final cacheKey = _iconCachePrefix + iconData.codePoint.toString() + '_' + colorHex + '_' + size.toString();
    
    // キャッシュから取得を試行
    final cachedIcon = cacheManager.get<Icon>(cacheKey);
    if (cachedIcon != null) {
      return cachedIcon;
    }

    // 新しいアイコンを作成
    final icon = Icon(
      iconData,
      color: color,
      size: size,
    );

    // キャッシュに保存（1時間有効）
    cacheManager.set(cacheKey, icon, cacheType: 'icon_cache');
    
    return icon;
  }

  /// よく使用されるアイコンを事前キャッシュ
  Future<void> preloadCommonIcons() async {
    final commonIcons = [
      // ナビゲーション関連
      Icons.home,
      Icons.calendar_today,
      Icons.notifications,
      Icons.history,
      Icons.person,
      
      // アクション関連
      Icons.add,
      Icons.edit,
      Icons.delete,
      Icons.check,
      Icons.close,
      
      // 状態関連
      Icons.check_circle,
      Icons.error,
      Icons.info,
      Icons.warning,
      
      // スポーツ関連
      Icons.sports_basketball,
      Icons.people,
      Icons.event_available,
      
      // その他
      Icons.arrow_back,
      Icons.arrow_forward,
      Icons.more_vert,
      Icons.settings,
    ];

    final commonColors = [
      null, // デフォルト色
      Colors.white,
      Colors.black,
      const Color(0xFF667eea),
      const Color(0xFF10B981),
      Colors.red,
      Colors.orange,
      Colors.grey,
    ];

    final commonSizes = [null, 16.0, 20.0, 24.0, 32.0];

    // よく使用される組み合わせを事前キャッシュ
    for (final icon in commonIcons) {
      for (final color in commonColors) {
        for (final size in commonSizes) {
          await getCachedIcon(
            iconData: icon,
            color: color,
            size: size,
          );
        }
      }
    }
  }

  /// アセット画像のキャッシュ（バイナリデータ）
  Future<Uint8List> getCachedAssetImage(String assetPath) async {
    final cacheKey = '${_imageCachePrefix}asset_$assetPath';
    
    // キャッシュから取得を試行
    final cachedData = cacheManager.get<Uint8List>(cacheKey);
    if (cachedData != null) {
      return cachedData;
    }

    // アセットからロード
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();

    // キャッシュに保存（30分有効）
    cacheManager.set(cacheKey, bytes, cacheType: 'image_cache');
    
    return bytes;
  }

  /// 最適化されたImageウィジェット
  Widget getCachedImage({
    required String assetPath,
    double? width,
    double? height,
    BoxFit? fit,
    Color? color,
  }) {
    return FutureBuilder<Uint8List>(
      future: getCachedAssetImage(assetPath),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            width: width,
            height: height,
            fit: fit,
            color: color,
            // パフォーマンス最適化
            gaplessPlayback: true,
            filterQuality: FilterQuality.low,
          );
        }
        
        // ローディング中はプレースホルダー
        return SizedBox(
          width: width,
          height: height,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }

  /// CircleAvatarのキャッシュ対応版
  Widget getCachedCircleAvatar({
    required String? imageUrl,
    required double radius,
    required Widget fallbackChild,
    Color? backgroundColor,
  }) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: fallbackChild,
      );
    }

    final cacheKey = '${_imageCachePrefix}avatar_$imageUrl';
    
    return FutureBuilder<ImageProvider?>(
      future: _getCachedNetworkImage(imageUrl, cacheKey),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: backgroundColor,
            backgroundImage: snapshot.data,
          );
        }
        
        return CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor,
          child: fallbackChild,
        );
      },
    );
  }

  /// ネットワーク画像の取得（簡易版）
  Future<ImageProvider?> _getCachedNetworkImage(String url, String cacheKey) async {
    try {
      // 実際のプロダクションでは、より堅牢なネットワーク画像キャッシュを実装
      // ここでは概念実装として NetworkImage を返す
      return NetworkImage(url);
    } catch (e) {
      return null;
    }
  }

  /// パフォーマンス最適化されたContainer Decoration
  BoxDecoration getCachedBoxDecoration({
    required String cacheKey,
    Color? color,
    Gradient? gradient,
    BorderRadius? borderRadius,
    Border? border,
    List<BoxShadow>? boxShadow,
  }) {
    final fullCacheKey = '${_imageCachePrefix}decoration_$cacheKey';
    
    // キャッシュから取得を試行
    final cached = cacheManager.get<BoxDecoration>(fullCacheKey);
    if (cached != null) {
      return cached;
    }

    // 新しいDecorationを作成
    final decoration = BoxDecoration(
      color: color,
      gradient: gradient,
      borderRadius: borderRadius,
      border: border,
      boxShadow: boxShadow,
    );

    // キャッシュに保存（1時間有効）
    cacheManager.set(fullCacheKey, decoration, cacheType: 'decoration_cache');
    
    return decoration;
  }

  /// よく使用されるDecorationを事前キャッシュ
  void preloadCommonDecorations() {
    // カードスタイル
    getCachedBoxDecoration(
      cacheKey: 'card_default',
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
    
    // ボタンスタイル
    getCachedBoxDecoration(
      cacheKey: 'button_primary',
      gradient: const LinearGradient(
        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
      ),
      borderRadius: BorderRadius.circular(8),
    );
    
    // 入力フィールドスタイル
    getCachedBoxDecoration(
      cacheKey: 'input_field',
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    );

    // バッジスタイル
    getCachedBoxDecoration(
      cacheKey: 'badge_orange',
      color: Colors.orange,
      borderRadius: BorderRadius.circular(12),
    );
  }

  /// キャッシュクリア
  void clearCache() {
    cacheManager.invalidatePattern(_iconCachePrefix);
    cacheManager.invalidatePattern(_imageCachePrefix);
  }

  /// メモリ使用量の最適化
  void optimizeMemoryUsage() {
    // 古いキャッシュエントリを削除
    cacheManager.cleanup();
  }
}