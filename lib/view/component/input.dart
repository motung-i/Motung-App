import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';
import 'package:motunge/constants/app_constants.dart';

class InputComponent extends StatelessWidget {
  const InputComponent({
    super.key,
    required this.hintText,
    required this.isLong,
    required this.onChanged,
    this.controller,
    this.maxLength,
    this.maxLines,
    this.enabled = true,
  });

  final String hintText;
  final bool isLong;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final int? maxLength;
  final int? maxLines;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      onChanged: onChanged,
      maxLines: isLong ? (maxLines ?? AppConstants.reviewMaxLines) : 1,
      maxLength: isLong
          ? (maxLength ?? AppConstants.reviewMaxLength)
          : (maxLength ?? AppConstants.nicknameMaxLength),
      textAlignVertical: TextAlignVertical.top,
      decoration: InputDecoration(
        counterText: "",
        contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        disabledBorder: InputBorder.none,
        hintText: hintText,
        hintStyle: GlobalFontDesignSystem.m3Regular.copyWith(
          color: AppColors.grey600,
        ),
        filled: true,
        errorMaxLines: 10,
        fillColor: AppColors.grey100,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
