import 'package:flutter/material.dart';
import '../../../core/constants/animations.dart';

/// Custom pull-to-refresh wrapper widget
class AppRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final double displacement;
  final double edgeOffset;

  const AppRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.displacement = AppRefreshIndicatorConfig.displacement,
    this.edgeOffset = AppRefreshIndicatorConfig.edgeOffset,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: onRefresh,
      displacement: displacement,
      edgeOffset: edgeOffset,
      strokeWidth: AppRefreshIndicatorConfig.strokeWidth,
      color: colorScheme.primary,
      backgroundColor: colorScheme.surface,
      child: child,
    );
  }
}

/// Pull-to-refresh list view
class RefreshableListView extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final Widget? separator;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  const RefreshableListView({
    super.key,
    required this.onRefresh,
    required this.itemCount,
    required this.itemBuilder,
    this.separator,
    this.padding,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return AppRefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: padding,
        physics: physics ?? const AlwaysScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        separatorBuilder: (context, index) =>
            separator ?? const SizedBox.shrink(),
      ),
    );
  }
}

/// Pull-to-refresh grid view
class RefreshableGridView extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  const RefreshableGridView({
    super.key,
    required this.onRefresh,
    required this.itemCount,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
    this.padding,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return AppRefreshIndicator(
      onRefresh: onRefresh,
      child: GridView.builder(
        padding: padding,
        physics: physics ?? const AlwaysScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      ),
    );
  }
}
