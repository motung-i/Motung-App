import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:motunge/view/component/button.dart';
import 'package:motunge/view/component/input.dart';
import 'package:motunge/view/component/topBar.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';
import 'package:motunge/viewModel/auth_viewmodel.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  RegExp regExp = RegExp(r'^(?![ㄱ-ㅎ]+$)(?![ㅏ-ㅣ]+$)[가-힣a-zA-Z0-9]+$');
  String _nickname = "";

  void _onNicknameChanged(String value) {
    setState(() {
      _nickname = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    AuthViewModel authViewModel = AuthViewModel();
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          Topbar(
              isSelectable: false,
              isPopAble: true,
              text: "정보 기입",
              selectAbleText: null),
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
                      onChanged: _onNicknameChanged),
                  SizedBox(
                    height: 488.h,
                  ),
                  ButtonComponent(
                    isEnable:
                        _nickname.isNotEmpty && regExp.hasMatch(_nickname),
                    text: "완료",
                    onPressed: () {
                      authViewModel.register(_nickname);
                      context.go("/home");
                    },
                  )
                ],
              ))
        ],
      )),
    );
  }
}
