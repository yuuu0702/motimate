import 'package:flutter/material.dart';

/// パフォーマンス最適化されたアニメーションウィジェット
class OptimizedAnimationWidget extends StatefulWidget {
  const OptimizedAnimationWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.animationType = AnimationType.fadeIn,
    this.delay = Duration.zero,
    this.onComplete,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final AnimationType animationType;
  final Duration delay;
  final VoidCallback? onComplete;

  @override
  State<OptimizedAnimationWidget> createState() => _OptimizedAnimationWidgetState();
}

class _OptimizedAnimationWidgetState extends State<OptimizedAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    // 遅延後にアニメーション開始
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }

    // アニメーション完了コールバック
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return _buildAnimatedWidget();
      },
    );
  }

  Widget _buildAnimatedWidget() {
    switch (widget.animationType) {
      case AnimationType.fadeIn:
        return Opacity(
          opacity: _animation.value,
          child: widget.child,
        );

      case AnimationType.slideInFromBottom:
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _animation.value)),
          child: Opacity(
            opacity: _animation.value,
            child: widget.child,
          ),
        );

      case AnimationType.slideInFromRight:
        return Transform.translate(
          offset: Offset(50 * (1 - _animation.value), 0),
          child: Opacity(
            opacity: _animation.value,
            child: widget.child,
          ),
        );

      case AnimationType.slideInFromLeft:
        return Transform.translate(
          offset: Offset(-50 * (1 - _animation.value), 0),
          child: Opacity(
            opacity: _animation.value,
            child: widget.child,
          ),
        );

      case AnimationType.scaleIn:
        return Transform.scale(
          scale: _animation.value,
          child: widget.child,
        );

      case AnimationType.scaleInWithFade:
        return Transform.scale(
          scale: 0.8 + (0.2 * _animation.value),
          child: Opacity(
            opacity: _animation.value,
            child: widget.child,
          ),
        );

      case AnimationType.bounceIn:
        final bounceValue = Curves.elasticOut.transform(_animation.value);
        return Transform.scale(
          scale: bounceValue,
          child: widget.child,
        );

      case AnimationType.rotateIn:
        return Transform.rotate(
          angle: (1 - _animation.value) * 0.5,
          child: Opacity(
            opacity: _animation.value,
            child: widget.child,
          ),
        );
    }
  }
}

/// アニメーションタイプ列挙型
enum AnimationType {
  fadeIn,
  slideInFromBottom,
  slideInFromRight,
  slideInFromLeft,
  scaleIn,
  scaleInWithFade,
  bounceIn,
  rotateIn,
}

/// パフォーマンス最適化されたリストアニメーション
class OptimizedListAnimation extends StatelessWidget {
  const OptimizedListAnimation({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.animationType = AnimationType.slideInFromBottom,
    this.duration = const Duration(milliseconds: 300),
  });

  final List<Widget> children;
  final Duration staggerDelay;
  final AnimationType animationType;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        children.length,
        (index) => OptimizedAnimationWidget(
          delay: Duration(milliseconds: staggerDelay.inMilliseconds * index),
          duration: duration,
          animationType: animationType,
          child: children[index],
        ),
      ),
    );
  }
}

/// パフォーマンス最適化されたページトランジション
class OptimizedPageTransition extends PageRouteBuilder {
  final Widget page;
  final Duration duration;
  final PageTransitionType transitionType;

  OptimizedPageTransition({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
    this.transitionType = PageTransitionType.slideRight,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildTransition(
              animation,
              secondaryAnimation,
              child,
              transitionType,
            );
          },
        );

  static Widget _buildTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    PageTransitionType type,
  ) {
    switch (type) {
      case PageTransitionType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );

      case PageTransitionType.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );

      case PageTransitionType.slideLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );

      case PageTransitionType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );

      case PageTransitionType.scale:
        return ScaleTransition(
          scale: animation,
          child: child,
        );

      case PageTransitionType.rotation:
        return RotationTransition(
          turns: animation,
          child: child,
        );
    }
  }
}

/// ページトランジションタイプ
enum PageTransitionType {
  fade,
  slideRight,
  slideLeft,
  slideUp,
  scale,
  rotation,
}

/// パフォーマンス最適化されたボタンアニメーション
class OptimizedAnimatedButton extends StatefulWidget {
  const OptimizedAnimatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor = Colors.blue,
    this.pressedColor,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.duration = const Duration(milliseconds: 150),
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Color backgroundColor;
  final Color? pressedColor;
  final double borderRadius;
  final EdgeInsets padding;
  final Duration duration;

  @override
  State<OptimizedAnimatedButton> createState() => _OptimizedAnimatedButtonState();
}

class _OptimizedAnimatedButtonState extends State<OptimizedAnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: widget.backgroundColor,
      end: widget.pressedColor ?? widget.backgroundColor.withValues(alpha: 0.8),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? _onTapDown : null,
      onTapUp: widget.onPressed != null ? _onTapUp : null,
      onTapCancel: widget.onPressed != null ? _onTapCancel : null,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                color: _colorAnimation.value,
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}