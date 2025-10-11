import 'package:flutter/material.dart';

/// パフォーマンス最適化された画像ウィジェット
class OptimizedImageWidget extends StatefulWidget {
  const OptimizedImageWidget({
    super.key,
    required this.imageProvider,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.memCacheWidth,
    this.memCacheHeight,
    this.semanticLabel,
  });

  final ImageProvider imageProvider;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Duration fadeInDuration;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final String? semanticLabel;

  @override
  State<OptimizedImageWidget> createState() => _OptimizedImageWidgetState();
}

class _OptimizedImageWidgetState extends State<OptimizedImageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  ImageStream? _imageStream;
  ImageInfo? _imageInfo;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: widget.fadeInDuration,
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _loadImage();
  }

  @override
  void didUpdateWidget(OptimizedImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageProvider != widget.imageProvider) {
      _disposeImageStream();
      _loadImage();
    }
  }

  @override
  void dispose() {
    _disposeImageStream();
    _fadeController.dispose();
    super.dispose();
  }

  void _loadImage() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final ImageProvider provider = widget.imageProvider;
    final ImageStream stream = provider.resolve(ImageConfiguration(
      size: widget.width != null && widget.height != null
          ? Size(widget.width!, widget.height!)
          : null,
    ));

    _imageStream = stream;
    stream.addListener(ImageStreamListener(
      _onImageLoaded,
      onError: _onImageError,
    ));
  }

  void _onImageLoaded(ImageInfo info, bool synchronousCall) {
    if (!mounted) return;

    setState(() {
      _imageInfo = info;
      _isLoading = false;
      _hasError = false;
    });

    if (!synchronousCall) {
      _fadeController.forward();
    } else {
      _fadeController.value = 1.0;
    }
  }

  void _onImageError(Object error, StackTrace? stackTrace) {
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _hasError = true;
    });
  }

  void _disposeImageStream() {
    if (_imageStream != null) {
      _imageStream!.removeListener(ImageStreamListener(
        _onImageLoaded,
        onError: _onImageError,
      ));
      _imageStream = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (_hasError) {
      child = widget.errorWidget ?? _buildDefaultErrorWidget();
    } else if (_isLoading) {
      child = widget.placeholder ?? _buildDefaultPlaceholder();
    } else if (_imageInfo != null) {
      child = _buildImage();
    } else {
      child = widget.placeholder ?? _buildDefaultPlaceholder();
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Semantics(
        label: widget.semanticLabel,
        child: child,
      ),
    );
  }

  Widget _buildImage() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: RawImage(
        image: _imageInfo!.image,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        filterQuality: FilterQuality.low, // パフォーマンス重視
      ),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[200],
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.error_outline,
          color: Colors.grey,
          size: 32,
        ),
      ),
    );
  }
}

/// メモリ効率的なCircleAvatar
class OptimizedCircleAvatar extends StatelessWidget {
  const OptimizedCircleAvatar({
    super.key,
    required this.radius,
    this.imageProvider,
    this.backgroundColor,
    this.child,
    this.semanticLabel,
  });

  final double radius;
  final ImageProvider? imageProvider;
  final Color? backgroundColor;
  final Widget? child;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    if (imageProvider != null) {
      return OptimizedImageWidget(
        imageProvider: imageProvider!,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        memCacheWidth: (radius * 2 * MediaQuery.of(context).devicePixelRatio).round(),
        memCacheHeight: (radius * 2 * MediaQuery.of(context).devicePixelRatio).round(),
        semanticLabel: semanticLabel,
        placeholder: CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor,
          child: child,
        ),
        errorWidget: CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor,
          child: child,
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: child,
    );
  }
}

/// パフォーマンス最適化されたアセット画像ウィジェット
class OptimizedAssetImage extends StatelessWidget {
  const OptimizedAssetImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.color,
    this.semanticLabel,
  });

  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      color: color,
      semanticLabel: semanticLabel,
      // パフォーマンス最適化設定
      cacheWidth: width != null
          ? (width! * MediaQuery.of(context).devicePixelRatio).round()
          : null,
      cacheHeight: height != null
          ? (height! * MediaQuery.of(context).devicePixelRatio).round()
          : null,
      filterQuality: FilterQuality.low,
      gaplessPlayback: true,
      isAntiAlias: false, // 小さい画像ではアンチエイリアスを無効化
    );
  }
}

/// ListView用の最適化されたイメージキャッシュ
class OptimizedListImageCache {
  static final Map<String, ImageProvider> _cache = {};
  static const int _maxCacheSize = 50;

  static ImageProvider getOptimizedImageProvider(
    String imageUrl, {
    int? cacheWidth,
    int? cacheHeight,
  }) {
    final cacheKey = '$imageUrl-${cacheWidth ?? 0}-${cacheHeight ?? 0}';

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    // キャッシュサイズ制限
    if (_cache.length >= _maxCacheSize) {
      _cache.remove(_cache.keys.first);
    }

    final provider = NetworkImage(imageUrl);
    _cache[cacheKey] = provider;

    return provider;
  }

  static void clearCache() {
    _cache.clear();
  }

  static void removeFromCache(String imageUrl) {
    _cache.removeWhere((key, value) => key.startsWith(imageUrl));
  }
}

/// レイジーローディング対応の画像ウィジェット
class LazyLoadImage extends StatefulWidget {
  const LazyLoadImage({
    super.key,
    required this.imageProvider,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.threshold = 200.0, // 画面端からの距離でロード開始
  });

  final ImageProvider imageProvider;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final double threshold;

  @override
  State<LazyLoadImage> createState() => _LazyLoadImageState();
}

class _LazyLoadImageState extends State<LazyLoadImage> {
  bool _shouldLoad = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey(widget.imageProvider.toString()),
      onVisibilityChanged: (visibilityInfo) {
        if (!_shouldLoad && visibilityInfo.visibleBounds != Rect.zero) {
          setState(() {
            _shouldLoad = true;
          });
        }
      },
      child: _shouldLoad
          ? OptimizedImageWidget(
              imageProvider: widget.imageProvider,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              placeholder: widget.placeholder,
              errorWidget: widget.errorWidget,
            )
          : widget.placeholder ??
              Container(
                width: widget.width,
                height: widget.height,
                color: Colors.grey[200],
              ),
    );
  }
}

/// 簡易的なVisibilityDetector実装
class VisibilityDetector extends StatefulWidget {
  const VisibilityDetector({
    super.key,
    required this.child,
    required this.onVisibilityChanged,
  });

  final Widget child;
  final Function(VisibilityInfo) onVisibilityChanged;

  @override
  State<VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<VisibilityDetector> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
  }

  void _checkVisibility() {
    // 簡易的な実装 - 実際には画面内の可視性を正確に計算する必要がある
    widget.onVisibilityChanged(VisibilityInfo(
      visibleBounds: const Rect.fromLTWH(0, 0, 100, 100),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class VisibilityInfo {
  final Rect visibleBounds;

  const VisibilityInfo({required this.visibleBounds});
}