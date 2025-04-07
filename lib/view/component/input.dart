import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';

class InputComponent extends StatelessWidget {
  const InputComponent(
      {super.key,
      required this.hintText,
      required this.isLong,
      required this.onChanged});
  final String hintText;
  final bool isLong;
  final Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
        onChanged: onChanged,
        maxLines: isLong ? 8 : 1,
        maxLength: isLong ? 400 : 12,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
          counterText: "",
          helperMaxLines: 94,
          contentPadding:
              EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          disabledBorder: InputBorder.none,
          hintText: hintText,
          hintStyle: GlobalFontDesignSystem.m3Regular
              .copyWith(color: DiaryMainGrey.grey600),
          filled: true,
          errorMaxLines: 10,
          fillColor: DiaryMainGrey.grey100,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8),
          ),
        ));
  }
}
