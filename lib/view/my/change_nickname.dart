import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motunge/bloc/auth/auth_bloc.dart';
import 'package:motunge/bloc/auth/auth_event.dart';
import 'package:motunge/bloc/auth/auth_state.dart';
import 'package:motunge/view/component/button.dart';
import 'package:motunge/view/component/input.dart';
import 'package:motunge/view/component/topBar.dart';
import 'package:motunge/view/designSystem/fonts.dart';

class ChangeNickname extends StatefulWidget {
  const ChangeNickname({super.key});

  @override
  State<ChangeNickname> createState() => _ChangeNicknameState();
}

class _ChangeNicknameState extends State<ChangeNickname> {
  RegExp regExp = RegExp(
    r"^(?![ㄱ-ㅎ]+$)(?![ㅏ-ㅣ]+$)[가-힣a-zA-Z0-9]+$",
    caseSensitive: false,
    multiLine: false,
  );
  String _nickname = "";

  void _onNicknameChanged(String value) {
    setState(() {
      _nickname = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthBlocState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              context.go('/home');
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('닉네임 변경에 실패했습니다: ${state.message}')),
              );
            }
          },
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
                              onChanged: _onNicknameChanged)
                        ],
                      ),
                      Spacer(),
                      BlocBuilder<AuthBloc, AuthBlocState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;

                          return ButtonComponent(
                            isEnable: !isLoading &&
                                _nickname.isNotEmpty &&
                                regExp.hasMatch(_nickname),
                            text: isLoading ? "변경 중..." : "완료",
                            onPressed: () {
                              context.read<AuthBloc>().add(
                                  AuthNicknameChangeRequested(
                                      nickname: _nickname));
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
