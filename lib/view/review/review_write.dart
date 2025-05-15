import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:motunge/view/component/button.dart';
import 'package:motunge/view/component/input.dart';
import 'package:motunge/view/component/topbar.dart';
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
          Topbar(
            isSelectable: false,
            isSelected: false,
            text: "리뷰 작성",
          ),
          SizedBox(height: 28.h),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: _buildAddImage(),
            ),
          ),
        ],
      )),
    );
  }
}

Widget _buildReviewWrite() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
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
          hintText: "내용을 작성해 주세요", isLong: true, onChanged: (text) {}),
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
  );
}

Widget _buildAddImage() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "이미지 추가",
            style: GlobalFontDesignSystem.labelRegular
                .copyWith(color: DiaryMainGrey.grey600),
          ),
          SizedBox(height: 8.h),
          SvgPicture.asset(
            "assets/images/add-image.svg",
            width: 160.w,
            height: 160.h,
          ),
          SizedBox(height: 4.h),
          Text(
            "이미지는 최대 3개까지 업로드 할 수 있어요",
            style: GlobalFontDesignSystem.labelRegular
                .copyWith(color: DiaryMainGrey.grey600),
          ),
        ],
      ),
      Spacer(),
      ButtonComponent(
        isEnable: true,
        text: "작성하기",
      ),
      SizedBox(height: 20.h),
    ],
  );
}
