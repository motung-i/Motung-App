import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:motunge/routes/navigation_helper.dart';
import 'package:motunge/view/designSystem/fonts.dart';
import 'package:motunge/viewModel/auth_viewmodel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthViewModel().googleLogin();
      if (response != null) {
        Navigation.toOnboarding();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 중 오류가 발생했습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.red,
          ),
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
          child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 153.h,
              width: double.infinity,
            ),
            Image.asset(
              "assets/images/logo_filled.png",
              width: 181.w,
              height: 54.h,
            ),
            SizedBox(
              height: 20.h,
            ),
            Text("대한민국 못 가본곳이 없을 때까지",
                style: GlobalFontDesignSystem.m3Semi
                    .copyWith(color: Color(0xff125CED))),
            SizedBox(
              height: 307.h,
            ),
            GestureDetector(
              onTap: _isLoading ? null : _handleGoogleLogin,
              child: Container(
                height: 52.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xffebebeb)),
                  color: _isLoading ? Colors.grey[200] : Colors.white,
                ),
                padding: EdgeInsets.symmetric(horizontal: 88.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/google.png",
                      width: 24.w,
                      height: 24.h,
                    ),
                    Text(
                      _isLoading ? "로그인 중..." : "Google로 시작하기",
                      style: GlobalFontDesignSystem.m3Semi.copyWith(
                        color: _isLoading ? Colors.grey : Colors.black,
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 15.h,
            ),
            GestureDetector(
              onTap: () async {},
              child: Container(
                height: 52.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xffebebeb)),
                ),
                padding: EdgeInsets.symmetric(horizontal: 88.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/apple.png",
                      width: 24.w,
                      height: 24.h,
                    ),
                    Text("Apple로 시작하기", style: GlobalFontDesignSystem.m3Semi)
                  ],
                ),
              ),
            )
          ],
        ),
      )),
    );
  }
}
