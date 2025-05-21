import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:motunge/view/component/topBar.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';

class SystemSettingPage extends StatelessWidget {
  const SystemSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(
      children: [
        Topbar(
          isSelectable: false,
          isPopAble: true,
          selectAbleText: null,
          text: "시스템 설정",
        ),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: _buildSystemConfig()),
      ],
    )));
  }
}

Widget _buildSystemConfig() {
  return Column(
    children: [
      SizedBox(height: 36.h),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "이용약관",
            style: GlobalFontDesignSystem.m3Regular,
          ),
          SvgPicture.asset(
            "assets/images/arrow-right.svg",
            width: 24.w,
            height: 24.h,
          )
        ],
      ),
      SizedBox(
        height: 24.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "개인정보 처리방침",
            style: GlobalFontDesignSystem.m3Regular,
          ),
          SvgPicture.asset(
            "assets/images/arrow-right.svg",
            width: 24.w,
            height: 24.h,
          )
        ],
      ),
      SizedBox(
        height: 24.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "닉네임 변경",
            style: GlobalFontDesignSystem.m3Regular,
          ),
          SvgPicture.asset(
            "assets/images/arrow-right.svg",
            width: 24.w,
            height: 24.h,
          )
        ],
      ),
      SizedBox(
        height: 24.h,
      ),
      Row(
        children: [
          SvgPicture.asset(
            "assets/images/logout.svg",
            width: 24.w,
            height: 24.h,
          ),
          Text(
            "로그아웃",
            style: GlobalFontDesignSystem.m3Regular
                .copyWith(color: DiaryColor.systemErrorColor),
          ),
        ],
      ),
      SizedBox(
        height: 24.h,
      ),
      Row(
        children: [
          SvgPicture.asset(
            "assets/images/delete-profile.svg",
            width: 24.w,
            height: 24.h,
          ),
          Text(
            "회원탈퇴",
            style: GlobalFontDesignSystem.m3Regular
                .copyWith(color: DiaryColor.systemErrorColor),
          ),
        ],
      )
    ],
  );
}