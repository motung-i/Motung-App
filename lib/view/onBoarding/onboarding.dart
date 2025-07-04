import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motunge/bloc/auth/auth_bloc.dart';
import 'package:motunge/bloc/auth/auth_event.dart';
import 'package:motunge/bloc/auth/auth_state.dart';
import 'package:motunge/routes/app_router.dart';
import 'package:motunge/view/component/button.dart';
import 'package:motunge/view/component/input.dart';
import 'package:motunge/view/component/topBar.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';

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

  void _onCompletePressed() {
    context.read<AuthBloc>().add(AuthRegisterRequested(nickname: _nickname));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthBlocState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('회원가입에 실패했습니다: ${state.message}')),
              );
            } else if (state is AuthRegisterSuccess ||
                state is AuthAuthenticated) {
              AppRouter.rootNavigatorKey.currentContext?.go('/login');
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Column(
              children: [
                Topbar(
                    isSelectable: false,
                    isPopAble: true,
                    text: "정보 기입",
                    selectAbleText: null),
                Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("닉네임",
                            style: GlobalFontDesignSystem.labelRegular
                                .copyWith(color: AppColors.grey600)),
                        SizedBox(height: 4),
                        InputComponent(
                            hintText: "닉네임을 입력해 주세요",
                            isLong: false,
                            onChanged: _onNicknameChanged),
                        SizedBox(
                          height: 488.h,
                        ),
                        ButtonComponent(
                          isEnable: !isLoading &&
                              _nickname.isNotEmpty &&
                              regExp.hasMatch(_nickname),
                          text: isLoading ? "처리 중..." : "완료",
                          onPressed: _onCompletePressed,
                        )
                      ],
                    ))
              ],
            );
          },
        ),
      ),
    );
  }
}
