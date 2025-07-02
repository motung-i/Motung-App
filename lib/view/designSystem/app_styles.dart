import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'colors.dart';

class AppStyles {
  // 공통 BorderRadius
  static BorderRadius get defaultBorderRadius => BorderRadius.circular(8.r);
  static BorderRadius get largeBorderRadius => BorderRadius.circular(12.r);

  // 공통 EdgeInsets
  static EdgeInsets get defaultPadding =>
      EdgeInsets.symmetric(horizontal: 24.w);
  static EdgeInsets get smallPadding => EdgeInsets.symmetric(horizontal: 16.w);
  static EdgeInsets get largePadding => EdgeInsets.symmetric(horizontal: 32.w);

  // 공통 BoxDecoration
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: Colors.grey[100],
        borderRadius: largeBorderRadius,
      );

  static BoxDecoration get inputDecoration => BoxDecoration(
        color: AppColors.grey100,
        borderRadius: defaultBorderRadius,
      );

  // 공통 SizedBox
  static SizedBox get smallVerticalSpacing => SizedBox(height: 8.h);
  static SizedBox get mediumVerticalSpacing => SizedBox(height: 16.h);
  static SizedBox get largeVerticalSpacing => SizedBox(height: 24.h);
  static SizedBox get extraLargeVerticalSpacing => SizedBox(height: 32.h);

  static SizedBox get smallHorizontalSpacing => SizedBox(width: 8.w);
  static SizedBox get mediumHorizontalSpacing => SizedBox(width: 16.w);
  static SizedBox get largeHorizontalSpacing => SizedBox(width: 24.w);
}
