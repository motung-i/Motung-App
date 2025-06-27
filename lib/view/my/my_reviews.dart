import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:motunge/dataSource/review.dart';
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
  final ReviewDataSource _reviewDataSource = ReviewDataSource();
  List<Review> _myReviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyReviews();
  }

  Future<void> _fetchMyReviews() async {
    try {
      final response = await _reviewDataSource.getOwnReviews();
      if (mounted) {
        setState(() {
          _myReviews = response.reviews;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('내가 쓴 리뷰를 불러오는데 실패했습니다: $e')),
        );
      }
    }
  }

  Future<void> _refreshMyReviews() async {
    setState(() {
      _isLoading = true;
    });
    await _fetchMyReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Topbar(
              isSelectable: false,
              isPopAble: true,
              selectAbleText: null,
              text: "내가 쓴 리뷰",
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                      color: DiaryColor.globalMainColor,
                    ))
                  : _myReviews.isEmpty
                      ? Center(
                          child: Text(
                          '작성한 리뷰가 없습니다.',
                          style: GlobalFontDesignSystem.m3Regular,
                        ))
                      : RefreshIndicator(
                          onRefresh: _refreshMyReviews,
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            itemCount: _myReviews.length,
                            itemBuilder: (context, index) {
                              return _buildReviewItem(_myReviews[index]);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
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
          color: DiaryMainGrey.grey100,
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
          " · ${review.nickname ?? "익명"}",
          style: GlobalFontDesignSystem.labelRegular.copyWith(
            color: DiaryMainGrey.grey700,
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
            color: DiaryMainGrey.grey600,
          ),
        ),
        SizedBox(width: 8.w),
        const Spacer(),
        Text(
          "신고",
          style: GlobalFontDesignSystem.labelRegular.copyWith(
            color: DiaryMainGrey.grey300,
          ),
        ),
      ],
    );
  }
}
