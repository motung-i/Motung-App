import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';

class LocationBadge extends StatelessWidget {
  final String location;

  const LocationBadge({
    super.key,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: DiaryMainGrey.grey100,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        location,
        style: GlobalFontDesignSystem.m3Semi.copyWith(
          color: DiaryMainGrey.grey1000,
        ),
      ),
    );
  }
}
