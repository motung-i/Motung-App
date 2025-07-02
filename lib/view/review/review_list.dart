import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:motunge/dataSource/map.dart';
import 'package:motunge/dataSource/review.dart';
import 'package:motunge/model/review/reviews_response.dart';
import 'package:motunge/view/component/app_tab_bar.dart';
import 'package:motunge/view/component/recommend_badge.dart';
import 'package:motunge/view/component/report_dialog.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';
import 'package:motunge/utils/error_handler.dart';
import 'package:motunge/constants/app_constants.dart';

class ReviewList extends StatefulWidget {
  const ReviewList({super.key});

  @override
  State<ReviewList> createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList> {
  // ============ Data Sources ============
  final MapDataSource _mapDataSource = MapDataSource();
  final ReviewDataSource _reviewDataSource = ReviewDataSource();

  // ============ State Variables ============
  bool _showPhotoReviewsOnly = false;
  List<String> _regions = [];
  String _searchQuery = '';
  int _currentTabIndex = 0;

  final Map<String, List<Review>> _reviewsByRegion = {};
  final Map<String, bool> _isLoadingByRegion = {};
  final Map<String, bool> _isInitializedByRegion = {};

  // ============ Lifecycle Methods ============
  @override
  void initState() {
    super.initState();
    _initializeRegions();
  }

  // ============ Data Management Methods ============
  Future<void> _initializeRegions() async {
    try {
      final regionsData = await _mapDataSource.getRegions();
      setState(() {
        _regions = regionsData.regions;
      });

      for (var region in _regions) {
        _isInitializedByRegion[region] = false;
        _isLoadingByRegion[region] = false;
      }

      if (_regions.isNotEmpty) {
        await _fetchReviewsForRegion(_regions[0]);
      }
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.showAppErrorSnackBar(
        context,
        AppError.fromException(e),
      );
    }
  }

  Future<void> _fetchReviewsForRegion(String region) async {
    if (!mounted || _isInitializedByRegion[region] == true) return;

    setState(() {
      _isLoadingByRegion[region] = true;
    });

    try {
      final response = await _reviewDataSource.getReviews(
        region: region,
        onlyByImage: _showPhotoReviewsOnly,
        localAlias: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (!mounted) return;

      setState(() {
        _reviewsByRegion[region] = response.reviews;
        _isLoadingByRegion[region] = false;
        _isInitializedByRegion[region] = true;
      });
    } catch (e) {
      if (!mounted) return;

      ErrorHandler.showAppErrorSnackBar(
        context,
        AppError.fromException(e),
      );

      setState(() {
        _isLoadingByRegion[region] = false;
      });
    }
  }

  Future<void> _refreshCurrentRegion() async {
    if (_regions.isEmpty) return;

    final currentRegion = _regions[_currentTabIndex];
    setState(() {
      _isInitializedByRegion[currentRegion] = false;
    });
    await _fetchReviewsForRegion(currentRegion);
  }

  // ============ Event Handlers ============
  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      if (_regions.isNotEmpty) {
        final currentRegion = _regions[_currentTabIndex];
        _isInitializedByRegion[currentRegion] = false;
        _fetchReviewsForRegion(currentRegion);
      }
    });
  }

  void _onPhotoFilterToggle() {
    setState(() {
      _showPhotoReviewsOnly = !_showPhotoReviewsOnly;
      if (_regions.isNotEmpty) {
        final currentRegion = _regions[_currentTabIndex];
        _isInitializedByRegion[currentRegion] = false;
      }
    });

    if (_regions.isNotEmpty) {
      _fetchReviewsForRegion(_regions[_currentTabIndex]);
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentTabIndex = index;
    });
    _fetchReviewsForRegion(_regions[index]);
  }

  Future<void> _handleReportReview(Review review) async {
    ReportDialog.show(
      context,
      onConfirm: (reasons) async {
        if (reasons.isEmpty) return;

        try {
          await _reviewDataSource.reportReview(review.reviewId, reasons);

          if (!mounted) return;
          ErrorHandler.showSuccessSnackBar(context, '신고가 접수되었습니다.');
        } catch (e) {
          if (!mounted) return;
          ErrorHandler.showAppErrorSnackBar(
            context,
            AppError.fromException(e),
          );
        }
      },
    );
  }

  // ============ Helper Methods ============
  int _getCurrentTabReviewCount() {
    if (_regions.isEmpty) return 0;

    final currentRegion = _regions[_currentTabIndex];
    final reviews = _reviewsByRegion[currentRegion] ?? [];

    if (_isLoadingByRegion[currentRegion] == true) return 0;

    return _showPhotoReviewsOnly
        ? reviews.where((review) => review.imageUrls.isNotEmpty).length
        : reviews.length;
  }

  List<Review> _getFilteredReviews(String region) {
    final reviews = _reviewsByRegion[region] ?? [];
    return _showPhotoReviewsOnly
        ? reviews.where((review) => review.imageUrls.isNotEmpty).toList()
        : reviews;
  }

  // ============ UI Building Methods ============
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchField(),
            _regions.isEmpty ? _buildLoadingRegions() : _buildTabView(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 24.w),
      child: TextField(
        maxLines: 1,
        maxLength: 16,
        textAlignVertical: TextAlignVertical.center,
        onChanged: _onSearchChanged,
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

  Widget _buildLoadingRegions() {
    return Expanded(
      child: Center(
        child: Text(
          '지역 정보를 불러오는 중입니다...',
          style: GlobalFontDesignSystem.m3Regular,
        ),
      ),
    );
  }

  Widget _buildTabView() {
    return Expanded(
      child: DefaultTabController(
        length: _regions.length,
        child: Column(
          children: [
            AppTabBar(
              tabs: _regions,
              onTap: _onTabChanged,
              height: 40.h,
            ),
            _buildFilterSection(),
            Expanded(
              child: AppTabBarView(
                children: _regions.map((region) {
                  return _isLoadingByRegion[region] == true
                      ? _buildLoadingIndicator()
                      : _buildReviewListForRegion(region);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "총 ${_getCurrentTabReviewCount()}개",
                style: GlobalFontDesignSystem.labelRegular.copyWith(
                  color: AppColors.grey700,
                ),
              ),
              _buildPhotoFilterToggle(),
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

  Widget _buildPhotoFilterToggle() {
    return GestureDetector(
      onTap: _onPhotoFilterToggle,
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
            _showPhotoReviewsOnly
                ? "assets/images/checked.svg"
                : "assets/images/unchecked.svg",
            width: 24.w,
            height: 24.h,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildReviewListForRegion(String region) {
    final filteredReviews = _getFilteredReviews(region);

    return filteredReviews.isEmpty
        ? Center(
            child: Text(
              '리뷰가 없습니다',
              style: GlobalFontDesignSystem.m3Regular,
            ),
          )
        : RefreshIndicator(
            onRefresh: _refreshCurrentRegion,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              itemCount: filteredReviews.length,
              itemBuilder: (context, index) {
                return _buildReviewItem(filteredReviews[index]);
              },
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

  Widget _buildReviewFooter(Review review) {
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
          onTap: () => _handleReportReview(review),
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
}
