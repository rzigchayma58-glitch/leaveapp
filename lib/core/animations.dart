// 🎬 SYSTÈME D'ANIMATIONS PROFESSIONNEL SAAS
import 'package:flutter/material.dart';

class AppAnimations {
  // 📱 DURÉES STANDARD POUR UN DESIGN FLUIDE
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration ultraSlow = Duration(milliseconds: 800);

  // 🎯 COURBES D'ANIMATION PROFESSIONNELLES
  static const Curve slideIn = Curves.easeOutCubic;
  static const Curve slideOut = Curves.easeInCubic;
  static const Curve bounce = Curves.elasticOut;
  static const Curve smooth = Curves.easeInOutQuart;
  static const Curve sharp = Curves.easeInExpo;
}

// 🌊 WIDGET DE TRANSITION SLIDE ÉLÉGANT
class SaaSSlideTransition extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Offset begin;
  final Offset end;
  final Curve curve;

  const SaaSSlideTransition({
    Key? key,
    required this.child,
    this.duration = AppAnimations.medium,
    this.begin = const Offset(0, 0.1),
    this.end = Offset.zero,
    this.curve = AppAnimations.smooth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Offset>(
      duration: duration,
      tween: Tween(begin: begin, end: end),
      curve: curve,
      builder: (context, offset, child) {
        return Transform.translate(
          offset: Offset(offset.dx * 100, offset.dy * 100),
          child: this.child,
        );
      },
    );
  }
}

// ✨ WIDGET DE FADE-IN PROFESSIONNEL
class FadeInAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  const FadeInAnimation({
    Key? key,
    required this.child,
    this.duration = AppAnimations.medium,
    this.delay = Duration.zero,
    this.curve = AppAnimations.smooth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: duration + delay,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: curve,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: this.child,
        );
      },
    );
  }
}

// 🚀 WIDGET SCALE ANIMATION ÉLÉGANT
class ScaleAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final double begin;
  final double end;
  final Curve curve;

  const ScaleAnimation({
    Key? key,
    required this.child,
    this.duration = AppAnimations.medium,
    this.begin = 0.8,
    this.end = 1.0,
    this.curve = AppAnimations.bounce,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: begin, end: end),
      curve: curve,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: this.child,
        );
      },
    );
  }
}

// 🌈 ANIMATION COMBINÉE SLIDE + FADE (STYLE SAAS)
class SlideAndFadeAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Offset slideBegin;
  final Curve curve;
  final int index;

  const SlideAndFadeAnimation({
    Key? key,
    required this.child,
    this.duration = AppAnimations.medium,
    this.slideBegin = const Offset(0, 0.3),
    this.curve = AppAnimations.smooth,
    this.index = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final delay = Duration(milliseconds: index * 100);
    
    return TweenAnimationBuilder<double>(
      duration: duration + delay,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: curve,
      builder: (context, progress, child) {
        return Transform.translate(
          offset: Offset(
            slideBegin.dx * (1 - progress) * 100,
            slideBegin.dy * (1 - progress) * 100,
          ),
          child: Opacity(
            opacity: progress,
            child: this.child,
          ),
        );
      },
    );
  }
}

// 💫 ANIMATION SHIMMER LOADING (STYLE MODERNE)
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerLoading({
    Key? key,
    required this.child,
    this.isLoading = true,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  }) : super(key: key);

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    
    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

// 🎪 TRANSITION DE PAGE STYLE SAAS MODERNE
class SaaSPageRoute<T> extends PageRoute<T> {
  final Widget child;
  final Duration duration;

  SaaSPageRoute({
    required this.child,
    this.duration = AppAnimations.medium,
    RouteSettings? settings,
  }) : super(settings: settings);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: AppAnimations.smooth,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return child;
  }
}

// 🎭 ANIMATIONS POUR LISTES (STAGGERED)
class StaggeredListAnimation extends StatelessWidget {
  final List<Widget> children;
  final Duration duration;
  final Duration delay;

  const StaggeredListAnimation({
    Key? key,
    required this.children,
    this.duration = AppAnimations.medium,
    this.delay = const Duration(milliseconds: 50),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        
        return SlideAndFadeAnimation(
          duration: duration,
          index: index,
          child: child,
        );
      }).toList(),
    );
  }
}

// 🌟 BOUTON ANIMÉ STYLE SAAS PREMIUM
class AnimatedSaaSButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isLoading;

  const AnimatedSaaSButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<AnimatedSaaSButton> createState() => _AnimatedSaaSButtonState();
}

class _AnimatedSaaSButtonState extends State<AnimatedSaaSButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        if (widget.onPressed != null) widget.onPressed!();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_controller.value * 0.05),
            child: AnimatedContainer(
              duration: AppAnimations.fast,
              curve: AppAnimations.smooth,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: (widget.backgroundColor ?? Theme.of(context).primaryColor)
                        .withOpacity(_isPressed ? 0.2 : 0.4),
                    blurRadius: _isPressed ? 8 : 12,
                    offset: Offset(0, _isPressed ? 2 : 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: widget.textColor ?? Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                  ],
                  if (widget.isLoading)
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: widget.textColor ?? Colors.white,
                      ),
                    )
                  else
                    Flexible(
                      child: Text(
                        widget.text,
                        style: TextStyle(
                          color: widget.textColor ?? Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}