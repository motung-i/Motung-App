import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';

class Topbar extends StatelessWidget {
  const Topbar(
      {super.key,
      required this.isSelectable,
      required this.isSelected,
      required this.text});
  final String text;
  final bool isSelectable;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: SvgPicture.asset("assets/images/arrow.svg",
                    width: 24.w, height: 24.h)),
            Text("정보 기입", style: GlobalFontDesignSystem.m3Semi),
            isSelectable
                ? Text("선택",
                    style: GlobalFontDesignSystem.m3Regular.copyWith(
                        color: isSelected
                            ? DiaryColor.globalMainColor
                            : DiaryMainGrey.grey600))
                : SizedBox(width: 24.w)
          ],
        ));
  }
}
