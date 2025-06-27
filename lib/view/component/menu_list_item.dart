import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:motunge/view/designSystem/fonts.dart';

class MenuListItem extends StatelessWidget {
  const MenuListItem({
    super.key,
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: GlobalFontDesignSystem.m3Regular,
              ),
            ),
            SvgPicture.asset(
              "assets/images/arrow-right.svg",
              width: 24.w,
              height: 24.h,
            )
          ],
        ),
      ),
    );
  }
}
