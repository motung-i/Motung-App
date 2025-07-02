import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:motunge/view/component/button.dart';
import 'package:motunge/view/component/confirmation_dialog.dart';
import 'package:motunge/view/designSystem/fonts.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/map/components/empty_data_widget.dart';
import 'package:motunge/model/map/target_info_response.dart';

class NavigationView extends StatelessWidget {
  final String selectedLocation;
  final String distance;
  final String duration;
  final VoidCallback onEndNavigation;
  final TargetInfoResponse? targetInfo;

  const NavigationView({
    super.key,
    required this.selectedLocation,
    required this.distance,
    required this.duration,
    required this.onEndNavigation,
    this.targetInfo,
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
        ButtonComponent(
          isEnable: true,
          text: "길 안내",
          onPressed: () {
            context.push('/map/route-selection');
          },
        ),
        SizedBox(height: 28.h),
        Text("리뷰", style: GlobalFontDesignSystem.m2Semi),
        SizedBox(height: 4.h),
        EmptyDataWidget(text: "아직 해당 장소의 리뷰가 없어요"),
        SizedBox(height: 28.h),
        Text("AI 추천", style: GlobalFontDesignSystem.m2Semi),
        SizedBox(height: 4.h),
        if (targetInfo != null)
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  targetInfo!.restaurantComment,
                  style: GlobalFontDesignSystem.m3Regular
                      .copyWith(color: DiaryMainGrey.grey800),
                ),
                SizedBox(height: 8.h),
                Text(
                  targetInfo!.sightseeingSpotsComment,
                  style: GlobalFontDesignSystem.m3Regular
                      .copyWith(color: DiaryMainGrey.grey800),
                ),
                SizedBox(height: 8.h),
                Text(
                  targetInfo!.cultureComment,
                  style: GlobalFontDesignSystem.m3Regular
                      .copyWith(color: DiaryMainGrey.grey800),
                ),
              ],
            ),
          )
        else
          EmptyDataWidget(text: "AI 추천을 가져올 수 없어요."),
        SizedBox(height: 28.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                ConfirmationDialog.show(
                  context,
                  title: "정말 여행을 마칠까요?",
                  content: selectedLocation,
                  onConfirm: () {
                    context.push(
                        '/review/write?location=${Uri.encodeComponent(selectedLocation)}');
                  },
                );
              },
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
