import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';

class AppTabBar extends StatelessWidget {
  const AppTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.onTap,
    this.isScrollable = true,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.indicatorWeight = 1.0,
    this.tabAlignment = TabAlignment.start,
    this.indicatorSize = TabBarIndicatorSize.tab,
    this.dividerColor = Colors.transparent,
    this.height,
    this.labelStyle,
    this.unselectedLabelStyle,
  });

  final List<String> tabs;
  final TabController? controller;
  final Function(int)? onTap;
  final bool isScrollable;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final double indicatorWeight;
  final TabAlignment tabAlignment;
  final TabBarIndicatorSize indicatorSize;
  final Color dividerColor;
  final double? height;
  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 48.h,
      child: TabBar(
        controller: controller,
        isScrollable: isScrollable,
        indicatorColor: indicatorColor ?? AppColors.primary,
        indicatorWeight: indicatorWeight,
        labelColor: labelColor ?? AppColors.primary,
        unselectedLabelColor: unselectedLabelColor ?? AppColors.grey800,
        tabAlignment: tabAlignment,
        indicatorSize: indicatorSize,
        dividerColor: dividerColor,
        labelStyle: labelStyle ??
            GlobalFontDesignSystem.m3Semi
                .copyWith(color: labelColor ?? AppColors.primary),
        unselectedLabelStyle: unselectedLabelStyle ??
            GlobalFontDesignSystem.m3Regular
                .copyWith(color: unselectedLabelColor ?? AppColors.grey800),
        onTap: onTap,
        tabs: tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }
}

class AppTabBarView extends StatelessWidget {
  const AppTabBarView({
    super.key,
    required this.children,
    this.controller,
  });

  final List<Widget> children;
  final TabController? controller;

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: controller,
      children: children,
    );
  }
}
