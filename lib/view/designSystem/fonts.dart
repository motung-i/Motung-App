import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GlobalFontDesignSystem {
  static TextStyle pretendardStyle(double size, double? height) => TextStyle(
        fontFamily: 'Pretendard',
        fontSize: size,
        height: height,
      );

  static TextStyle pretendardRegularStyle(double size, double? height) =>
      pretendardStyle(size, height).copyWith(
        fontWeight: FontWeight.w400,
      );

  static TextStyle pretendardSemiBoldStyle(double size, double? height) =>
      pretendardStyle(size, height).copyWith(
        fontWeight: FontWeight.w600,
      );

  static final TextStyle labelRegular = pretendardRegularStyle(14.sp, 1.5.h);
  static final TextStyle labelSemi = pretendardSemiBoldStyle(14.sp, 1.5.h);
  static final TextStyle m3Regular = pretendardRegularStyle(16.sp, 1.65.h);
  static final TextStyle m3Semi = pretendardSemiBoldStyle(16.sp, 1.65.h);
  static final TextStyle m2Regular = pretendardRegularStyle(18.sp, 1.5.h);
  static final TextStyle m2Semi = pretendardSemiBoldStyle(18.sp, 1.5.h);
  static final TextStyle m1Regular = pretendardRegularStyle(20.sp, 1.5.h);
  static final TextStyle m1Semi = pretendardSemiBoldStyle(20.sp, 1.5.h);
  static final TextStyle h4Regular = pretendardRegularStyle(24.sp, 1.3.h);
  static final TextStyle h4Semi = pretendardSemiBoldStyle(24.sp, 1.3.h);
  static final TextStyle h3Regular = pretendardRegularStyle(28.sp, 1.3.h);
  static final TextStyle h3Semi = pretendardSemiBoldStyle(28.sp, 1.3.h);
  static final TextStyle h2Regular = pretendardRegularStyle(32.sp, 1.2.h);
  static final TextStyle h2Semi = pretendardSemiBoldStyle(32.sp, 1.2.h);
  static final TextStyle h1Regular = pretendardRegularStyle(36.sp, 1.2.h);
  static final TextStyle h1Semi = pretendardSemiBoldStyle(36.sp, 1.2.h);
}
