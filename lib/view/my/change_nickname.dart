import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:motunge/view/component/button.dart';
import 'package:motunge/view/component/input.dart';
import 'package:motunge/view/component/topBar.dart';
import 'package:motunge/view/designSystem/fonts.dart';
import 'package:motunge/viewModel/auth_viewmodel.dart';

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
                    ButtonComponent(
                        isEnable:
                            _nickname.isNotEmpty && regExp.hasMatch(_nickname),
                        text: "완료",
                        onPressed: () async {
                          await AuthViewModel().changeNickname(_nickname);
                          if (!context.mounted) return;
                          context.go('/home');
                        }),
                  ],
                )),
          )
        ],
      ),
    ));
  }
}
