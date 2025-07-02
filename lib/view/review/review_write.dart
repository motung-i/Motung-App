import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:motunge/view/component/button.dart';
import 'package:motunge/view/component/confirmation_dialog.dart';
import 'package:motunge/view/component/input.dart';
import 'package:motunge/view/component/location_badge.dart';
import 'package:motunge/view/component/topbar.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';
import 'package:motunge/viewModel/map_viewmodel.dart';
import 'package:motunge/utils/error_handler.dart';

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
  // ============ State Variables ============
  bool? _isRecommend;
  String _reviewText = "";

  // ============ Navigation Methods ============
  void _goToNextStep() {
    if (!_validateForm()) {
      return;
    }

    try {
      context.push(
        '/review/attach-image?location=${Uri.encodeComponent(widget.location)}&isRecommend=$_isRecommend&description=${Uri.encodeComponent(_reviewText)}',
      );
    } catch (e) {
      ErrorHandler.showAppErrorSnackBar(
        context,
        AppError.fromException(e),
      );
    }
  }

  void _handleSkipReview() {
    ConfirmationDialog.show(
      context,
      title: "정말 리뷰를 건너뛸까요?",
      content: "지금 리뷰를 건너뛰면\n다시 리뷰를 작성하실 수 없습니다.",
      confirmText: "확인",
      cancelText: "취소",
      onConfirm: () {
        try {
          MapViewmodel().endTour();
          context.go('/home');
        } catch (e) {
          ErrorHandler.showAppErrorSnackBar(
            context,
            AppError.fromException(e),
          );
        }
      },
    );
  }

  // ============ Validation Methods ============
  bool _validateForm() {
    if (_isRecommend == null) {
      ErrorHandler.showErrorSnackBar(
        context,
        '추천 여부를 선택해주세요',
        backgroundColor: AppColors.error,
      );
      return false;
    }

    if (_reviewText.trim().isEmpty) {
      ErrorHandler.showErrorSnackBar(
        context,
        '리뷰 내용을 입력해주세요',
        backgroundColor: AppColors.error,
      );
      return false;
    }

    return true;
  }

  bool _isFormValid() {
    return _isRecommend != null && _reviewText.trim().isNotEmpty;
  }

  // ============ Event Handlers ============
  void _onRecommendChanged(bool isRecommend) {
    setState(() {
      _isRecommend = isRecommend;
    });
  }

  void _onReviewTextChanged(String text) {
    setState(() {
      _reviewText = text;
    });
  }

  // ============ UI Building Methods ============
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
                    _buildLocationSection(),
                    SizedBox(height: 28.h),
                    _buildRecommendSection(),
                    SizedBox(height: 28.h),
                    _buildReviewContentSection(),
                    SizedBox(height: 61.h),
                    _buildActionButtons(),
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

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("위치"),
        SizedBox(height: 4.h),
        LocationBadge(location: widget.location),
      ],
    );
  }

  Widget _buildRecommendSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("추천 여부"),
        SizedBox(height: 4.h),
        Row(
          children: [
            _buildRecommendButton(true, "추천해요 👍"),
            SizedBox(width: 8.w),
            _buildRecommendButton(false, "추천하지 않아요 👎"),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("리뷰 내용"),
        SizedBox(height: 10.h),
        InputComponent(
          hintText: "내용을 작성해 주세요",
          isLong: true,
          onChanged: _onReviewTextChanged,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ButtonComponent(
          isEnable: _isFormValid(),
          text: "다음",
          onPressed: _goToNextStep,
        ),
        SizedBox(height: 16.h),
        _buildSkipButton(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GlobalFontDesignSystem.labelRegular.copyWith(
        color: AppColors.grey600,
      ),
    );
  }

  Widget _buildRecommendButton(bool isRecommend, String text) {
    final isSelected = _isRecommend == isRecommend;

    return GestureDetector(
      onTap: () => _onRecommendChanged(isRecommend),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.grey100,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        alignment: Alignment.center,
        child: Text(
          text,
          style: GlobalFontDesignSystem.m3Regular.copyWith(
            color: isSelected ? AppColors.white : AppColors.grey800,
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: _handleSkipReview,
        child: Text(
          "리뷰 건너뛰기",
          style: GlobalFontDesignSystem.labelRegular.copyWith(
            color: AppColors.grey300,
          ),
        ),
      ),
    );
  }
}
