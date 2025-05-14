import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:motunge/view/designSystem/fonts.dart';
import 'package:motunge/view/designSystem/colors.dart';

class EmptyDataWidget extends StatelessWidget {
  final String text;

  const EmptyDataWidget({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DiaryMainGrey.grey100,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      width: 342.w,
      height: 141.h,
      child: Text(
        text,
        style: GlobalFontDesignSystem.m3Regular
            .copyWith(color: DiaryMainGrey.grey400),
      ),
    );
  }
}
