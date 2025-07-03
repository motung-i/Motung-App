import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motunge/bloc/review/review_bloc.dart';
import 'package:motunge/bloc/review/review_event.dart';
import 'package:motunge/bloc/review/review_state.dart';
import 'package:motunge/model/review/reviews_response.dart';
import 'package:motunge/view/component/region_tab_bar.dart';
import 'package:motunge/view/component/recommend_badge.dart';
import 'package:motunge/view/component/report_dialog.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';
import 'package:motunge/utils/error_handler.dart';

class ReviewList extends StatefulWidget {
  const ReviewList({super.key});

  @override
  State<ReviewList> createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList> {
  // ============ State Variables ============
  final TextEditingController _searchController = TextEditingController();
  final RegionTabBarController _tabController = RegionTabBarController();

  @override
  void initState() {
    super.initState();
    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewBloc>().add(const ReviewRegionsRequested());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _syncTabController(ReviewsLoaded state) {
    final targetIndex =
        state.currentTabIndex.clamp(0, state.regions.length - 1);
    _tabController.animateToTab(targetIndex);
  }

  // ============ UI Building Methods ============
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<ReviewBloc, ReviewBlocState>(
          listener: (context, state) {
            if (state is ReviewError) {
              ErrorHandler.showAppErrorSnackBar(
                context,
                AppError.fromException(Exception(state.message)),
              );
            } else if (state is ReviewReportSuccess) {
              ErrorHandler.showSuccessSnackBar(context, '신고가 접수되었습니다.');
            } else if (state is ReviewsLoaded && state.showReportSuccess) {
              ErrorHandler.showSuccessSnackBar(context, '신고가 접수되었습니다.');
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                _buildSearchField(context, state),
                _buildContent(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context, ReviewBlocState state) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 24.w),
      child: TextField(
        controller: _searchController,
        maxLines: 1,
        maxLength: 16,
        textAlignVertical: TextAlignVertical.center,
        onChanged: (value) => _onSearchChanged(context, state, value),
        decoration: InputDecoration(
          counterText: "",
          contentPadding:
              EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          disabledBorder: InputBorder.none,
          hintText: "검색어를 입력하세요",
          hintStyle: GlobalFontDesignSystem.m3Regular.copyWith(
            color: AppColors.grey600,
          ),
          filled: true,
          fillColor: AppColors.grey100,
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
      ),
    );
  }

  Widget _buildContent(BuildContext context, ReviewBlocState state) {
    if (state is ReviewInitial || state is ReviewLoading) {
      return Expanded(
        child: Center(
          child: Text(
            '지역 정보를 불러오는 중입니다...',
            style: GlobalFontDesignSystem.m3Regular,
          ),
        ),
      );
    }

    if (state is ReviewError) {
      return Expanded(
        child: Center(
          child: Text(
            '오류가 발생했습니다: ${state.message}',
            style: GlobalFontDesignSystem.m3Regular,
          ),
        ),
      );
    }

    if (state is ReviewsLoaded) {
      return _buildTabView(context, state);
    }

    return const Expanded(child: SizedBox());
  }

  Widget _buildTabView(BuildContext context, ReviewsLoaded state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncTabController(state);
    });

    return Expanded(
      child: Column(
        children: [
          RegionTabBarWithController(
            regions: state.regions,
            controller: _tabController,
            initialIndex: state.currentTabIndex,
            onTabChanged: (index, region) =>
                _onTabChanged(context, state, index),
            height: 40.h,
            showTabBarView: false,
          ),
          _buildFilterSection(context, state),
          Expanded(
            child:
                _buildReviewListForRegion(context, state, state.currentRegion),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, ReviewsLoaded state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "총 ${state.currentTabReviewCount}개",
                style: GlobalFontDesignSystem.labelRegular.copyWith(
                  color: AppColors.grey700,
                ),
              ),
              _buildPhotoFilterToggle(context, state),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(
            color: AppColors.grey100,
            height: 1.h,
            thickness: 1.h,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoFilterToggle(BuildContext context, ReviewsLoaded state) {
    return GestureDetector(
      onTap: () => _onPhotoFilterToggle(context, state),
      child: Row(
        children: [
          Text(
            "사진리뷰",
            style: GlobalFontDesignSystem.m3Regular.copyWith(
              color: Colors.black,
            ),
          ),
          SizedBox(width: 4.w),
          SvgPicture.asset(
            state.showPhotoReviewsOnly
                ? "assets/images/checked.svg"
                : "assets/images/unchecked.svg",
            width: 24.w,
            height: 24.h,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewListForRegion(
    BuildContext context,
    ReviewsLoaded state,
    String region,
  ) {
    if (state.isCurrentRegionLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    final filteredReviews = state.filteredReviews;

    if (filteredReviews.isEmpty) {
      return Center(
        child: Text(
          '리뷰가 없습니다',
          style: GlobalFontDesignSystem.m3Regular,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _refreshCurrentRegion(context, state),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        itemCount: filteredReviews.length,
        itemBuilder: (context, index) {
          return _buildReviewItem(context, filteredReviews[index]);
        },
      ),
    );
  }

  Widget _buildReviewItem(BuildContext context, Review review) {
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
              _buildReviewFooter(context, review),
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
          " · ${review.nickname ?? "탈퇴한 유저"}",
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
    const int maxImages = 3;
    final imagesToShow = review.imageUrls.take(maxImages).toList();

    return Column(
      children: [
        SizedBox(height: 12.h),
        SizedBox(
          height: 120.h,
          child: Row(
            children: imagesToShow.asMap().entries.map((entry) {
              final index = entry.key;
              final imageUrl = entry.value;
              final isLast = index == imagesToShow.length - 1;

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: isLast ? 0 : 8.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewFooter(BuildContext context, Review review) {
    return Row(
      children: [
        Text(
          review.createdDate,
          style: GlobalFontDesignSystem.labelRegular.copyWith(
            color: AppColors.grey600,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => _handleReportReview(context, review),
          child: Text(
            "신고",
            style: GlobalFontDesignSystem.labelRegular.copyWith(
              color: AppColors.grey300,
            ),
          ),
        ),
      ],
    );
  }

  // ============ Event Handlers ============
  void _onSearchChanged(
      BuildContext context, ReviewBlocState state, String value) {
    if (state is ReviewsLoaded && state.currentRegion.isNotEmpty) {
      context.read<ReviewBloc>().add(ReviewFilterChanged(
            showPhotoReviewsOnly: state.showPhotoReviewsOnly,
            searchQuery: value,
            region: state.currentRegion,
          ));
    }
  }

  void _onPhotoFilterToggle(BuildContext context, ReviewsLoaded state) {
    if (state.currentRegion.isNotEmpty) {
      context.read<ReviewBloc>().add(ReviewFilterChanged(
            showPhotoReviewsOnly: !state.showPhotoReviewsOnly,
            searchQuery: state.searchQuery,
            region: state.currentRegion,
          ));
    }
  }

  void _onTabChanged(BuildContext context, ReviewsLoaded state, int index) {
    if (index < state.regions.length) {
      context.read<ReviewBloc>().add(ReviewTabChanged(
            tabIndex: index,
            region: state.regions[index],
          ));
    }
  }

  Future<void> _refreshCurrentRegion(
      BuildContext context, ReviewsLoaded state) async {
    if (state.currentRegion.isNotEmpty) {
      context.read<ReviewBloc>().add(ReviewRefreshRequested(
            region: state.currentRegion,
            onlyByImage: state.showPhotoReviewsOnly,
            localAlias: state.searchQuery.isNotEmpty ? state.searchQuery : null,
          ));
    }
  }

  Future<void> _handleReportReview(BuildContext context, Review review) async {
    ReportDialog.show(
      context,
      onConfirm: (reasons) async {
        if (reasons.isEmpty) return;

        context.read<ReviewBloc>().add(ReviewReportRequested(
              reviewId: review.reviewId.toString(),
              reasons: reasons,
            ));
      },
    );
  }
}
