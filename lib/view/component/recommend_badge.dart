import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';

class RecommendBadge extends StatelessWidget {
  final bool isRecommend;

  const RecommendBadge({
    super.key,
    required this.isRecommend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        isRecommend ? "이 장소를 추천해요 👍" : "이 장소를 추천하지 않아요 👎",
        style: GlobalFontDesignSystem.m3Semi.copyWith(
          color: AppColors.grey1000,
        ),
      ),
    );
  }
}
