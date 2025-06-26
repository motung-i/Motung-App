import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:motunge/view/component/button.dart';
import 'package:motunge/view/component/input.dart';
import 'package:motunge/view/component/location_badge.dart';
import 'package:motunge/view/component/topbar.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';
import 'package:motunge/viewModel/map_viewmodel.dart';

class ReviewWrite extends StatefulWidget {
  final String location;

  const ReviewWrite({
    super.key,
    required this.location,
  });

  @override
  State<ReviewWrite> createState() => _ReviewWriteState();
}

class _ReviewWriteState extends State<ReviewWrite> {
  bool? _isRecommend;
  String _reviewText = "";

  void _goToNextStep() {
    if (_isRecommend == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('추천 여부를 선택해주세요')),
      );
      return;
    }
    if (_reviewText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('리뷰 내용을 입력해주세요')),
      );
      return;
    }

    context.push(
        '/review/attach-image?location=${Uri.encodeComponent(widget.location)}&isRecommend=$_isRecommend&description=${Uri.encodeComponent(_reviewText)}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Topbar(
              isSelectable: false,
              isPopAble: true,
              selectAbleText: null,
              text: "리뷰 작성",
            ),
            SizedBox(height: 28.h),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "위치",
                      style: GlobalFontDesignSystem.labelRegular
                          .copyWith(color: DiaryMainGrey.grey600),
                    ),
                    SizedBox(height: 4.h),
                    LocationBadge(location: widget.location),
                    SizedBox(height: 28.h),
                    Text(
                      "추천 여부",
                      style: GlobalFontDesignSystem.labelRegular
                          .copyWith(color: DiaryMainGrey.grey600),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        _buildRecommendButton(true),
                        SizedBox(width: 8.w),
                        _buildRecommendButton(false),
                      ],
                    ),
                    SizedBox(height: 28.h),
                    Text(
                      "리뷰 내용",
                      style: GlobalFontDesignSystem.labelRegular
                          .copyWith(color: DiaryMainGrey.grey600),
                    ),
                    SizedBox(height: 10.h),
                    InputComponent(
                      hintText: "내용을 작성해 주세요",
                      isLong: true,
                      onChanged: (p0) => _reviewText = p0,
                    ),
                    SizedBox(height: 61.h),
                    ButtonComponent(
                      isEnable: true,
                      text: "다음",
                      onPressed: _goToNextStep,
                    ),
                    SizedBox(height: 16.h),
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () => _showSkipConfirmDialog(context),
                        child: Text(
                          "리뷰 건너뛰기",
                          style: GlobalFontDesignSystem.labelRegular
                              .copyWith(color: DiaryMainGrey.grey300),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSkipConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          alignment: Alignment.center,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          title: Text(
            "정말 리뷰를 건너뛸까요?",
            style: GlobalFontDesignSystem.m2Semi,
            textAlign: TextAlign.center,
          ),
          content: Text(
            "지금 리뷰를 건너뛰면\n다시 리뷰를 작성하실 수 없습니다.",
            style: GlobalFontDesignSystem.labelRegular.copyWith(
              color: DiaryMainGrey.grey800,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ButtonComponent(
                    isEnable: false,
                    text: "취소",
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: ButtonComponent(
                    isEnable: true,
                    text: "확인",
                    onPressed: () {
                      MapViewmodel().endTour();
                      Navigator.pop(dialogContext);
                      context.go('/home');
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecommendButton(bool isRecommend) {
    final isSelected = _isRecommend == isRecommend;
    return GestureDetector(
      onTap: () => setState(() => _isRecommend = isRecommend),
      child: Container(
        decoration: BoxDecoration(
          color:
              isSelected ? DiaryColor.globalMainColor : DiaryMainGrey.grey100,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        alignment: Alignment.center,
        child: Text(
          isRecommend ? "추천해요 👍" : "추천하지 않아요 👎",
          style: GlobalFontDesignSystem.m3Regular.copyWith(
            color: isSelected ? Colors.white : DiaryMainGrey.grey800,
          ),
        ),
      ),
    );
  }
}
