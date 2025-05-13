import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';

class ReviewList extends StatefulWidget {
  const ReviewList({super.key});

  @override
  State<ReviewList> createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList> {
  bool _showPhotoReviewsOnly = false;
  final List<String> _regions = [
    '전북',
    '전남·광주',
    '경북',
    '경남',
    '충북',
    '충남',
    '인천',
    '서울',
    '강원',
    '제주'
  ];

  Map<String, List<ReviewData>> _reviewsByRegion = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    final Map<String, List<ReviewData>> tempData = {};
    for (String region in _regions) {
      final int reviewCount = 10 + (region.hashCode % 10);
      tempData[region] = List.generate(
        reviewCount,
        (index) => ReviewData(
          userName: '사용자${index + 1}',
          content:
              '${region}에 있는 멋진 장소입니다. 정말 추천합니다! 일정이 잘 맞아서 좋았고 날씨도 좋아서 더 좋았어요.',
          date: '2024.02.${10 + index}',
          location: '$region, 평화동',
          isRecommended: index % 3 == 0,
          images: index % 2 == 0
              ? List.generate(3, (i) => 'assets/images/review_sample.jpg')
              : [],
        ),
      );
    }

    setState(() {
      _reviewsByRegion = tempData;
      _isLoading = false;
    });
  }

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
          Expanded(
              child: DefaultTabController(
                  length: _regions.length,
                  child: Column(
                    children: [
                      // 탭바
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
                        tabs: _regions
                            .map((region) => Tab(
                                  text: region,
                                  height: 40,
                                ))
                            .toList(),
                      ),
                      Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24.w, vertical: 16.h),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "총 ${_getTotalReviewCount()}개",
                                    style: GlobalFontDesignSystem.labelRegular
                                        .copyWith(
                                      color: DiaryMainGrey.grey700,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _showPhotoReviewsOnly =
                                            !_showPhotoReviewsOnly;
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          "사진리뷰",
                                          style: GlobalFontDesignSystem
                                              .m3Regular
                                              .copyWith(color: Colors.black),
                                        ),
                                        SizedBox(width: 4.w),
                                        SvgPicture.asset(
                                          _showPhotoReviewsOnly
                                              ? "assets/images/checked.svg"
                                              : "assets/images/unchecked.svg",
                                          width: 24.w,
                                          height: 24.h,
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Divider(
                                color: DiaryMainGrey.grey100,
                                height: 1.h,
                                thickness: 1.h,
                              ),
                            ],
                          )),
                      Expanded(
                        child: TabBarView(
                          children: _regions.map((region) {
                            return _isLoading
                                ? _buildLoadingIndicator()
                                : _buildReviewListForRegion(region);
                          }).toList(),
                        ),
                      )
                    ],
                  ))),
        ],
      )),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  int _getTotalReviewCount() {
    if (_isLoading) return 0;

    int total = 0;
    for (final reviews in _reviewsByRegion.values) {
      if (_showPhotoReviewsOnly) {
        total += reviews.where((review) => review.images.isNotEmpty).length;
      } else {
        total += reviews.length;
      }
    }
    return total;
  }

  Widget _buildReviewListForRegion(String region) {
    final reviews = _reviewsByRegion[region] ?? [];
    final filteredReviews = _showPhotoReviewsOnly
        ? reviews.where((review) => review.images.isNotEmpty).toList()
        : reviews;

    return filteredReviews.isEmpty
        ? Center(
            child: Text('리뷰가 없습니다', style: GlobalFontDesignSystem.m3Regular))
        : ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            itemCount: filteredReviews.length,
            itemBuilder: (context, index) {
              return _buildReviewItem(filteredReviews[index]);
            },
          );
  }

  Widget _buildReviewItem(ReviewData review) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (review.isRecommended)
                Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: DiaryMainGrey.grey100,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    "이 장소를 추천해요 👍",
                    style: GlobalFontDesignSystem.m3Semi.copyWith(
                      color: DiaryMainGrey.grey1000,
                    ),
                  ),
                ),
              Row(
                children: [
                  Text(
                    review.location,
                    style: GlobalFontDesignSystem.m2Semi,
                  ),
                  Text(
                    " · ${review.userName}",
                    style: GlobalFontDesignSystem.labelRegular.copyWith(
                      color: DiaryMainGrey.grey700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                review.content,
                style: GlobalFontDesignSystem.m3Regular,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (review.images.isNotEmpty) ...[
                SizedBox(height: 12.h),
                SizedBox(
                  height: 120.h,
                  child: Row(
                    children: [
                      for (int i = 0; i < review.images.length; i++)
                        if (i < 3)
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(right: i < 2 ? 8.w : 0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.r),
                                image: DecorationImage(
                                  image: AssetImage(review.images[i]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 12.h),
              Row(
                children: [
                  Text(
                    review.date,
                    style: GlobalFontDesignSystem.labelRegular.copyWith(
                      color: DiaryMainGrey.grey600,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Spacer(),
                  Text(
                    "신고",
                    style: GlobalFontDesignSystem.labelRegular.copyWith(
                      color: DiaryMainGrey.grey300,
                    ),
                  ),
                ],
              ),
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
}

class ReviewData {
  final String userName;
  final String content;
  final String date;
  final String location;
  final bool isRecommended;
  final List<String> images;

  ReviewData({
    required this.userName,
    required this.content,
    required this.date,
    required this.location,
    this.isRecommended = false,
    this.images = const [],
  });
}
