import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';

class ButtonComponent extends StatelessWidget {
  const ButtonComponent({
    super.key,
    required this.isEnable,
    required this.text,
    this.onPressed,
    this.enableColor,
    this.disabledColor,
    this.textColor,
    this.height,
  });

  final bool isEnable;
  final String text;
  final VoidCallback? onPressed;
  final Color? enableColor;
  final Color? disabledColor;
  final Color? textColor;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnable ? onPressed : null,
      child: Container(
        height: height ?? 48.h,
        decoration: BoxDecoration(
          color: isEnable
              ? (enableColor ?? AppColors.primary)
              : (disabledColor ?? AppColors.grey500),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Text(
          text,
          style: GlobalFontDesignSystem.m3Semi.copyWith(
            color: textColor ?? AppColors.white,
          ),
        ),
      ),
    );
  }
}
