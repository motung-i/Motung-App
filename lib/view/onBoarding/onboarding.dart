import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:motunge/view/component/button.dart';
import 'package:motunge/view/component/input.dart';
import 'package:motunge/view/component/topBar.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';

class Onboarding extends StatelessWidget {
  const Onboarding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          Topbar(isSelectable: false, isSelected: false, text: "정보 기입"),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("닉네임",
                      style: GlobalFontDesignSystem.labelRegular
                          .copyWith(color: DiaryMainGrey.grey600)),
                  SizedBox(height: 4),
                  InputComponent(
                      hintText: "닉네임을 입력해 주세요",
                      isLong: false,
                      onChanged: (text) {
                        debugPrint(text);
                      }),
                  SizedBox(
                    height: 488.h,
                  ),
                  ButtonComponent(
                    isEnable: false,
                  )
                ],
              ))
        ],
      )),
    );
  }
}
