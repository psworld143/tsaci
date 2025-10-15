import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../../utils/responsive.dart';

/// Universal App Scaffold Template
/// Use this as the base for all pages
class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final bool showBackButton;
  final bool centerTitle;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final bool safeArea;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  const AppScaffold({
    Key? key,
    this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.showBackButton = true,
    this.centerTitle = false,
    this.backgroundColor,
    this.padding,
    this.safeArea = true,
    this.leading,
    this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content = body;

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    if (safeArea) {
      content = SafeArea(child: content);
    }

    // Determine leading widget for AppBar
    Widget? leadingWidget = leading;
    bool autoImplyLeading = showBackButton;

    // If drawer exists and showBackButton is false, show drawer button
    if (drawer != null && !showBackButton && leading == null) {
      leadingWidget = Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
          tooltip: 'Menu',
        ),
      );
      autoImplyLeading = false;
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      appBar: title != null
          ? AppBar(
              title: Text(title!),
              centerTitle: centerTitle,
              leading: leadingWidget,
              automaticallyImplyLeading: autoImplyLeading,
              actions: actions,
              bottom: bottom,
            )
          : null,
      body: content,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
    );
  }
}

/// Scrollable App Scaffold with RefreshIndicator
class ScrollableAppScaffold extends StatelessWidget {
  final String? title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Future<void> Function()? onRefresh;
  final bool showBackButton;
  final EdgeInsetsGeometry? padding;
  final bool useResponsiveContainer;

  const ScrollableAppScaffold({
    Key? key,
    this.title,
    required this.child,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.onRefresh,
    this.showBackButton = true,
    this.padding,
    this.useResponsiveContainer = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    // Wrap in ResponsiveContainer if needed
    if (useResponsiveContainer) {
      content = ResponsiveContainer(child: content);
    }

    // Add padding
    content = Padding(
      padding:
          padding ??
          EdgeInsets.symmetric(
            horizontal: Responsive.getHorizontalPadding(context),
            vertical: AppStyles.space4,
          ),
      child: content,
    );

    // Make scrollable
    content = SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: content,
    );

    // Add refresh indicator
    if (onRefresh != null) {
      content = RefreshIndicator(onRefresh: onRefresh!, child: content);
    }

    return AppScaffold(
      title: title,
      body: content,
      actions: actions,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      showBackButton: showBackButton,
      padding: null,
      safeArea: true,
    );
  }
}

/// App Scaffold with Tab Bar
class TabbedAppScaffold extends StatelessWidget {
  final String title;
  final List<Tab> tabs;
  final List<Widget> tabViews;
  final List<Widget>? actions;
  final TabController? controller;

  const TabbedAppScaffold({
    Key? key,
    required this.title,
    required this.tabs,
    required this.tabViews,
    this.actions,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: AppScaffold(
        title: title,
        actions: actions,
        bottom: TabBar(
          tabs: tabs,
          controller: controller,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
        ),
        body: TabBarView(controller: controller, children: tabViews),
        padding: null,
      ),
    );
  }
}
