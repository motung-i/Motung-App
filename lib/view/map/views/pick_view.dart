import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:motunge/view/component/button.dart';
import 'package:motunge/view/designSystem/fonts.dart';
import 'package:motunge/view/designSystem/colors.dart';

class PickView extends StatelessWidget {
  final VoidCallback onDrawDestination;
  final bool isLoading;

  const PickView({
    super.key,
    required this.onDrawDestination,
    this.isLoading = false,
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
          isEnable: !isLoading,
          text: isLoading ? "여행지 찾는 중..." : "여행지 뽑기",
          onPressed: isLoading ? () {} : onDrawDestination,
        ),
      ],
    );
  }
}
