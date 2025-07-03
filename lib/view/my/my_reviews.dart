import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motunge/bloc/review/review_bloc.dart';
import 'package:motunge/bloc/review/review_event.dart';
import 'package:motunge/bloc/review/review_state.dart';
import 'package:motunge/model/review/reviews_response.dart';
import 'package:motunge/view/component/recommend_badge.dart';
import 'package:motunge/view/component/topBar.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';

class MyReviewsPage extends StatefulWidget {
  const MyReviewsPage({super.key});

  @override
  State<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends State<MyReviewsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ReviewBloc>().add(const MyReviewsRequested());
  }

  Future<void> _refreshMyReviews() async {
    context.read<ReviewBloc>().add(const MyReviewsRefreshRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<ReviewBloc, ReviewBlocState>(
          listener: (context, state) {
            if (state is MyReviewsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          buildWhen: (previous, current) {
            return current is MyReviewsLoading ||
                current is MyReviewsLoaded ||
                current is MyReviewsError;
          },
          builder: (context, state) {
            return Column(
              children: [
                const Topbar(
                  isSelectable: false,
                  isPopAble: true,
                  selectAbleText: null,
                  text: "내가 쓴 리뷰",
                ),
                Expanded(
                  child: _buildContent(state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(ReviewBlocState state) {
    if (state is MyReviewsLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.globalMainColor,
        ),
      );
    } else if (state is MyReviewsLoaded) {
      if (state.myReviews.isEmpty) {
        return Center(
          child: Text(
            '작성한 리뷰가 없습니다.',
            style: GlobalFontDesignSystem.m3Regular,
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: _refreshMyReviews,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          itemCount: state.myReviews.length,
          itemBuilder: (context, index) {
            return _buildReviewItem(state.myReviews[index]);
          },
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.globalMainColor,
        ),
      );
    }
  }

  Widget _buildReviewItem(Review review) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RecommendBadge(isRecommend: review.isRecommend),
              _buildReviewHeader(review),
              SizedBox(height: 4.h),
              _buildReviewDescription(review),
              if (review.imageUrls.isNotEmpty) _buildReviewImages(review),
              SizedBox(height: 12.h),
              _buildReviewFooter(review),
            ],
          ),
        ),
        Divider(
          color: AppColors.grey100,
          height: 1.h,
          thickness: 1.h,
        ),
      ],
    );
  }

  Widget _buildReviewHeader(Review review) {
    return Row(
      children: [
        Text(
          review.local,
          style: GlobalFontDesignSystem.m2Semi,
        ),
        Text(
          " · ${review.nickname}",
          style: GlobalFontDesignSystem.labelRegular.copyWith(
            color: AppColors.grey700,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewDescription(Review review) {
    return Text(
      review.description,
      style: GlobalFontDesignSystem.m3Regular,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildReviewImages(Review review) {
    return Column(
      children: [
        SizedBox(height: 12.h),
        SizedBox(
          height: 120.h,
          child: Row(
            children: [
              for (int i = 0; i < review.imageUrls.length && i < 3; i++)
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i < 2 ? 8.w : 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      image: DecorationImage(
                        image: NetworkImage(review.imageUrls[i]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewFooter(Review review) {
    return Row(
      children: [
        Text(
          review.createdDate,
          style: GlobalFontDesignSystem.labelRegular.copyWith(
            color: AppColors.grey600,
          ),
        ),
      ],
    );
  }
}
