import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';

class ButtonComponent extends StatelessWidget {
  const ButtonComponent({super.key, required this.isEnable, required this.text});
  final bool isEnable;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: isEnable ? DiaryColor.globalMainColor : DiaryMainGrey.grey500,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Text(text,
          style: GlobalFontDesignSystem.m3Semi.copyWith(color: Colors.white)),
    );
  }
}
