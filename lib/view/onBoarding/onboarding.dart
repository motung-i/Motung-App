import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:motunge/view/component/button.dart';
import 'package:motunge/view/component/input.dart';
import 'package:motunge/view/component/topBar.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';
import 'package:motunge/viewModel/auth_viewmodel.dart';
import 'package:motunge/routes/app_router.dart';
import 'package:motunge/model/auth/enum/auth_state.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  RegExp regExp = RegExp(r'^(?![ㄱ-ㅎ]+$)(?![ㅏ-ㅣ]+$)[가-힣a-zA-Z0-9]+$');
  String _nickname = "";
  bool _isLoading = false;

  void _onNicknameChanged(String value) {
    setState(() {
      _nickname = value;
    });
  }

  Future<void> _onCompletePressed() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      AuthViewModel authViewModel = AuthViewModel();
      await authViewModel.register(_nickname);

      AppRouter.authNotifier.setStatus(AuthStatus.authenticated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입에 실패했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    isEnable: !_isLoading &&
                        _nickname.isNotEmpty &&
                        regExp.hasMatch(_nickname),
                    text: _isLoading ? "처리 중..." : "완료",
                    onPressed: _onCompletePressed,
                  )
                ],
              ))
        ],
      )),
    );
  }
}
