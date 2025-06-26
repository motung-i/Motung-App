import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:motunge/constants/app_constants.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
    this.message,
    this.size = 40.0,
  });

  final String? message;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(DiaryColor.globalMainColor),
            ),
          ),
          if (message != null) ...[
            SizedBox(height: 16.h),
            Text(
              message ?? AppConstants.loadingText,
              style: GlobalFontDesignSystem.m3Regular.copyWith(
                color: DiaryMainGrey.grey600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
