import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';

/// TabController가 필요하지 않은 간단한 탭바 컴포넌트
/// 조건부 렌더링과 함께 사용하기 적합합니다.
class SimpleTabBar extends StatelessWidget {
  const SimpleTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    this.onTap,
    this.isScrollable = true,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.height,
    this.labelStyle,
    this.unselectedLabelStyle,
  });

  final List<String> tabs;
  final int selectedIndex;
  final Function(int)? onTap;
  final bool isScrollable;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final double? height;
  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 48.h,
      child: isScrollable
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildTabRow(),
            )
          : _buildTabRow(),
    );
  }

  Widget _buildTabRow() {
    return Row(
      mainAxisSize: isScrollable ? MainAxisSize.min : MainAxisSize.max,
      children: tabs.asMap().entries.map((entry) {
        final index = entry.key;
        final tab = entry.value;
        final isSelected = index == selectedIndex;

        return _buildTab(tab, index, isSelected);
      }).toList(),
    );
  }

  Widget _buildTab(String tab, int index, bool isSelected) {
    return GestureDetector(
      onTap: () => onTap?.call(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? (indicatorColor ?? AppColors.primary)
                  : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        child: Text(
          tab,
          style: isSelected
              ? (labelStyle ??
                  GlobalFontDesignSystem.m3Semi.copyWith(
                    color: labelColor ?? AppColors.primary,
                  ))
              : (unselectedLabelStyle ??
                  GlobalFontDesignSystem.m3Regular.copyWith(
                    color: unselectedLabelColor ?? AppColors.grey800,
                  )),
        ),
      ),
    );
  }
}
