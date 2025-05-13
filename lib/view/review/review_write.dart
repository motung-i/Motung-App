import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:motunge/view/component/button.dart';
import 'package:motunge/view/component/input.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';

class ReviewWrite extends StatefulWidget {
  const ReviewWrite({super.key});

  @override
  State<ReviewWrite> createState() => _ReviewWriteState();
}

class _ReviewWriteState extends State<ReviewWrite> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: double.infinity),
          SizedBox(height: 12.h),
          Text("리뷰작성", style: GlobalFontDesignSystem.m3Semi),
          SizedBox(
            height: 28.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: double.infinity),
                Text(
                  "위치",
                  style: GlobalFontDesignSystem.labelRegular
                      .copyWith(color: DiaryMainGrey.grey600),
                ),
                SizedBox(
                  height: 4.h,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: DiaryMainGrey.grey100,
                      borderRadius: BorderRadius.circular(8)),
                  height: 46.h,
                  width: 155.w,
                  alignment: Alignment.center,
                  child: Text(
                    "광주 광역시, 송정동",
                    style: GlobalFontDesignSystem.m3Regular
                        .copyWith(color: DiaryMainGrey.grey800),
                  ),
                ),
                SizedBox(
                  height: 28.h,
                ),
                Text(
                  "추천 여부",
                  style: GlobalFontDesignSystem.labelRegular
                      .copyWith(color: DiaryMainGrey.grey600),
                ),
                SizedBox(
                  height: 4.h,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: DiaryMainGrey.grey100,
                      borderRadius: BorderRadius.circular(8)),
                  height: 46.h,
                  width: 163.w,
                  alignment: Alignment.center,
                  child: Text(
                    "이 장소를 추천해요 👍",
                    style: GlobalFontDesignSystem.m3Regular
                        .copyWith(color: DiaryMainGrey.grey800),
                  ),
                ),
                SizedBox(
                  height: 16.h,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: DiaryMainGrey.grey100,
                      borderRadius: BorderRadius.circular(8)),
                  height: 46.h,
                  width: 218.w,
                  alignment: Alignment.center,
                  child: Text(
                    "이 장소를 추천하지 않아요 👎",
                    style: GlobalFontDesignSystem.m3Regular
                        .copyWith(color: DiaryMainGrey.grey800),
                  ),
                ),
                SizedBox(
                  height: 28.h,
                ),
                Text(
                  "추천 여부",
                  style: GlobalFontDesignSystem.labelRegular
                      .copyWith(color: DiaryMainGrey.grey600),
                ),
                SizedBox(
                  height: 10.h,
                ),
                InputComponent(
                    hintText: "내용을 작성해 주세요",
                    isLong: true,
                    onChanged: (text) {}),
                SizedBox(
                  height: 61.h,
                ),
                ButtonComponent(
                  isEnable: true,
                  text: "작성하기",
                ),
                SizedBox(
                  height: 16.h,
                ),
                Align(
                    alignment: Alignment.center,
                    child: Text("리뷰 건너뛰기",
                        style: GlobalFontDesignSystem.labelRegular
                            .copyWith(color: DiaryMainGrey.grey300)))
              ],
            ),
          )
        ],
      )),
    );
  }
}
