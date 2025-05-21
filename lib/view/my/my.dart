import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 60.h),
                    Text(
                      "이지혁",
                      style: GlobalFontDesignSystem.m1Semi,
                    ),
                    SizedBox(
                      height: 60.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "내가 쓴 리뷰",
                          style: GlobalFontDesignSystem.m3Regular,
                        ),
                        SvgPicture.asset(
                          "assets/images/arrow-right.svg",
                          width: 24.w,
                          height: 24.h,
                        )
                      ],
                    ),
                    SizedBox(
                      height: 24.h,
                    ),
                    Divider(
                      color: DiaryMainGrey.grey100,
                      height: 1.h,
                    ),
                    SizedBox(
                      height: 24.h,
                    ),
                    GestureDetector(
                      onTap: () => context.go("/my/system-setting"),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "시스템",
                            style: GlobalFontDesignSystem.m3Regular,
                          ),
                          SvgPicture.asset(
                            "assets/images/arrow-right.svg",
                            width: 24.w,
                            height: 24.h,
                          )
                        ],
                      ),
                    )
                  ],
                ))));
  }
}
