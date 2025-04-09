import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';

class ReviewList extends StatelessWidget {
  const ReviewList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 24.w),
              child: TextField(
                maxLines: 1,
                maxLength: 16,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  counterText: "",
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                  disabledBorder: InputBorder.none,
                  hintText: "검색어를 입력하세요",
                  hintStyle: GlobalFontDesignSystem.m3Regular
                      .copyWith(color: DiaryMainGrey.grey600),
                  filled: true,
                  fillColor: DiaryMainGrey.grey100,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: Padding(
                    padding: EdgeInsets.only(right: 16.w),
                    child: SvgPicture.asset(
                      "assets/images/search.svg",
                      width: 24.w,
                      height: 24.h,
                    ),
                  ),
                  suffixIconConstraints: BoxConstraints(
                    minWidth: 24.w,
                    minHeight: 24.h,
                  ),
                ),
              )),
          DefaultTabController(
              length: 10,
              child: Column(
                children: [
                  TabBar(
                      indicatorColor: DiaryColor.globalMainColor,
                      labelStyle: GlobalFontDesignSystem.m3Semi
                          .copyWith(color: DiaryColor.globalMainColor),
                      indicatorWeight: 1.h,
                      dividerHeight: 0,
                      tabAlignment: TabAlignment.start,
                      isScrollable: true,
                      unselectedLabelColor: DiaryMainGrey.grey800,
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: [
                        Tab(
                          text: '전북',
                          height: 40,
                        ),
                        Tab(
                          text: '전남·광주',
                          height: 40,
                        ),
                        Tab(
                          text: '경북',
                          height: 40,
                        ),
                        Tab(
                          text: '경남',
                          height: 40,
                        ),
                        Tab(
                          text: '충북',
                          height: 40,
                        ),
                        Tab(
                          text: '충남',
                          height: 40,
                        ),
                        Tab(
                          text: '인천',
                          height: 40,
                        ),
                        Tab(
                          text: '서울',
                          height: 40,
                        ),
                        Tab(
                          text: '강원',
                          height: 40,
                        ),
                        Tab(
                          text: '제주',
                          height: 40,
                        ),
                      ]),
                  Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.w, vertical: 16.h),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("총 1,200개",
                                  style: GlobalFontDesignSystem.labelRegular
                                      .copyWith(
                                    color: DiaryMainGrey.grey700,
                                  )),
                              Row(
                                children: [
                                  Text("사진리뷰",
                                      style: GlobalFontDesignSystem.m3Regular
                                          .copyWith(color: Colors.black)),
                                  SizedBox(width: 4.w),
                                  SvgPicture.asset(
                                    "assets/images/checked.svg",
                                    width: 24.w,
                                    height: 24.h,
                                  )
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Divider(
                            color: DiaryMainGrey.grey100,
                            height: 1.h,
                            thickness: 1.h,
                          ),
                          SizedBox(height: 12.h),
                        ],
                      )),
                ],
              )),
        ],
      )),
    );
  }
}
