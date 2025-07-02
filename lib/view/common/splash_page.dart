import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:motunge/view/designSystem/colors.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고나 앱 이름 (필요하면 추가)
            Image.asset(
              'assets/images/logo_filled.png',
              width: 120.w,
              height: 120.h,
            ),
          ],
        ),
      ),
    );
  }
}
