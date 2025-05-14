import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:motunge/view/component/button.dart';
import 'package:motunge/view/designSystem/fonts.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/map/components/empty_data_widget.dart';

class NavigationView extends StatelessWidget {
  final String selectedLocation;
  final String distance;
  final String duration;
  final VoidCallback onEndNavigation;

  const NavigationView({
    super.key,
    required this.selectedLocation,
    required this.distance,
    required this.duration,
    required this.onEndNavigation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(selectedLocation, style: GlobalFontDesignSystem.m1Semi),
        SizedBox(height: 4.h),
        Text("$distance • $duration 소요 예정",
            style: GlobalFontDesignSystem.m3Regular
                .copyWith(color: DiaryMainGrey.grey800)),
        SizedBox(height: 28.h),
        ButtonComponent(isEnable: true, text: "길 안내"),
        SizedBox(height: 28.h),
        Text("리뷰"),
        SizedBox(height: 4.h),
        EmptyDataWidget(text: "아직 해당 장소의 리뷰가 없어요"),
        SizedBox(height: 28.h),
        Text("AI 추천"),
        SizedBox(height: 4.h),
        EmptyDataWidget(text: "AI 추천을 가져올 수 없어요."),
        SizedBox(height: 28.h),
        Text("파노라마"),
        SizedBox(height: 4.h),
        EmptyDataWidget(text: "사진을 가져올 수 없어요."),
        SizedBox(height: 25.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onEndNavigation,
              child: Text(
                "여행종료",
                style: GlobalFontDesignSystem.m3Regular.copyWith(
                  color: Colors.red,
                ),
              ),
            ),
            SizedBox(width: 4.w),
            SvgPicture.asset(
              "assets/images/red-flag.svg",
              width: 24.w,
              height: 24.h,
            )
          ],
        ),
      ],
    );
  }
}
