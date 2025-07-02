import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';

class Topbar extends StatelessWidget {
  const Topbar({
    super.key,
    required this.isPopAble,
    required this.selectAbleText,
    required this.isSelectable,
    required this.text,
  });

  final String text;
  final bool isPopAble;
  final String? selectAbleText;
  final bool isSelectable;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: Row(
        children: [
          isPopAble
              ? GestureDetector(
                  onTap: () => context.pop(),
                  child: SvgPicture.asset(
                    "assets/images/arrow.svg",
                    width: 24.w,
                    height: 24.h,
                  ),
                )
              : SizedBox(width: 24.w),
          Expanded(
            child: Center(
              child: Text(
                text,
                style: GlobalFontDesignSystem.m3Semi,
              ),
            ),
          ),
          selectAbleText != null
              ? Text(
                  selectAbleText!,
                  style: GlobalFontDesignSystem.m3Regular.copyWith(
                    color: isSelectable
                        ? AppColors.globalMainColor
                        : AppColors.grey600,
                  ),
                )
              : SizedBox(width: 24.w),
        ],
      ),
    );
  }
}
