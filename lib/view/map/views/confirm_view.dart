import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:motunge/view/component/button.dart';
import 'package:motunge/view/designSystem/fonts.dart';
import 'package:motunge/view/designSystem/colors.dart';

class ConfirmView extends StatelessWidget {
  final String selectedLocation;
  final VoidCallback onConfirmDestination;
  final VoidCallback onRedrawDestination;

  const ConfirmView({
    super.key,
    required this.selectedLocation,
    required this.onConfirmDestination,
    required this.onRedrawDestination,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(selectedLocation, style: GlobalFontDesignSystem.m1Semi),
        SizedBox(height: 4.h),
        Text("같이 세기의 여행을 떠나볼까요?",
            style: GlobalFontDesignSystem.m3Regular
                .copyWith(color: AppColors.grey800)),
        SizedBox(height: 20.h),
        ButtonComponent(
          isEnable: true,
          text: "여행지 확정",
          onPressed: onConfirmDestination,
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onRedrawDestination,
              child: Text(
                "다시 뽑기",
                style: GlobalFontDesignSystem.m3Regular.copyWith(
                  color: AppColors.grey600,
                ),
              ),
            ),
            SvgPicture.asset(
              "assets/images/arrow-return.svg",
              width: 24.w,
              height: 24.h,
            ),
          ],
        ),
      ],
    );
  }
}
