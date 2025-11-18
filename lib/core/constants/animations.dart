import 'package:flutter/material.dart';

/// Animation duration constants
class AnimationDurations {
  AnimationDurations._();

  static const Duration instant = Duration.zero;
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);

  // Specific animation durations
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration dialogAnimation = Duration(milliseconds: 250);
  static const Duration listItemAnimation = Duration(milliseconds: 200);
  static const Duration buttonAnimation = Duration(milliseconds: 150);
  static const Duration shimmer = Duration(milliseconds: 1500);
}

/// Animation curve constants
class AnimationCurves {
  AnimationCurves._();

  static const Curve standard = Curves.easeInOut;
  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve decelerate = Curves.easeOut;
  static const Curve accelerate = Curves.easeIn;
  static const Curve bounce = Curves.bounceOut;
  static const Curve elastic = Curves.elasticOut;
}

/// Custom page route transitions
class AppPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final PageTransitionType transitionType;

  AppPageRoute({
    required this.page,
    this.transitionType = PageTransitionType.fade,
    RouteSettings? settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildTransition(
              transitionType,
              animation,
              secondaryAnimation,
              child,
            );
          },
          transitionDuration: AnimationDurations.pageTransition,
          settings: settings,
        );

  static Widget _buildTransition(
    PageTransitionType type,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    switch (type) {
      case PageTransitionType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );

      case PageTransitionType.slide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: AnimationCurves.emphasized,
          )),
          child: child,
        );

      case PageTransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: AnimationCurves.emphasized,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );

      case PageTransitionType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: AnimationCurves.emphasized,
          )),
          child: child,
        );
    }
  }
}

/// Page transition types
enum PageTransitionType {
  fade,
  slide,
  scale,
  slideUp,
}

/// Staggered list animation helper
class StaggeredAnimation {
  final int itemCount;
  final Duration duration;
  final Duration delay;

  const StaggeredAnimation({
    required this.itemCount,
    this.duration = AnimationDurations.listItemAnimation,
    this.delay = const Duration(milliseconds: 50),
  });

  Duration getDelay(int index) {
    return delay * index;
  }
}

/// Animated list item wrapper
class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final int index;
  final Animation<double> animation;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: AnimationCurves.emphasized,
        )),
        child: child,
      ),
    );
  }
}

/// Pull to refresh indicator configuration
class AppRefreshIndicatorConfig {
  static const double displacement = 40.0;
  static const double edgeOffset = 0.0;
  static const double strokeWidth = 2.0;
}
