import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:motunge/view/component/button.dart';
import 'package:motunge/view/designSystem/fonts.dart';
import 'package:motunge/view/designSystem/colors.dart';

class PickView extends StatelessWidget {
  final VoidCallback onDrawDestination;

  const PickView({
    super.key,
    required this.onDrawDestination,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("아직 여행지가 정해지지 않았어요!", style: GlobalFontDesignSystem.m1Semi),
        SizedBox(height: 4.h),
        Text("같이 세기의 여행을 떠나볼까요?",
            style: GlobalFontDesignSystem.m3Regular
                .copyWith(color: AppColors.grey800)),
        SizedBox(height: 20.h),
        ButtonComponent(
          isEnable: true,
          text: "여행지 뽑기",
          onPressed: onDrawDestination,
        ),
      ],
    );
  }
}
