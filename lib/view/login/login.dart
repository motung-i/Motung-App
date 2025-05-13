import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:motunge/routes/navigation_helper.dart';
import 'package:motunge/view/designSystem/fonts.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
              onTap: () {
                Navigation.toOnboarding();
              },
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
                      "assets/images/google.png",
                      width: 24.w,
                      height: 24.h,
                    ),
                    Text(
                      "Google로 시작하기",
                      style: GlobalFontDesignSystem.m3Semi,
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 15.h,
            ),
            GestureDetector(
              onTap: () {
                Navigation.toOnboarding();
              },
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
