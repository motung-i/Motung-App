import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:motunge/view/component/button.dart';
import 'package:motunge/view/component/input.dart';
import 'package:motunge/view/component/topBar.dart';
import 'package:motunge/view/designSystem/fonts.dart';

class ChangeNickname extends StatelessWidget {
  const ChangeNickname({super.key});

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
            text: "닉네임 변경",
          ),
          Expanded(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 16,
                        ),
                        Text(
                          "닉네임",
                          style: GlobalFontDesignSystem.labelRegular,
                        ),
                        SizedBox(height: 4),
                        InputComponent(
                            hintText: "닉네임을 입력하세요",
                            isLong: false,
                            onChanged: (value) {
                              debugPrint(value);
                            })
                      ],
                    ),
                    Spacer(),
                    ButtonComponent(
                        isEnable: true, text: "완료", onPressed: () {}),
                  ],
                )),
          )
        ],
      ),
    ));
  }
}
