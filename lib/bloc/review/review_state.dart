import 'package:motunge/model/review/reviews_response.dart';

abstract class ReviewBlocState {
  const ReviewBlocState();
}

class ReviewInitial extends ReviewBlocState {
  const ReviewInitial();
}

class ReviewLoading extends ReviewBlocState {
  final String? region;

  const ReviewLoading({this.region});
}

class ReviewError extends ReviewBlocState {
  final String message;

  const ReviewError({required this.message});
}

class ReviewRegionsLoaded extends ReviewBlocState {
  final List<String> regions;

  const ReviewRegionsLoaded({required this.regions});
}

class ReviewsLoaded extends ReviewBlocState {
  final Map<String, List<Review>> reviewsByRegion;
  final Map<String, bool> isLoadingByRegion;
  final Map<String, bool> isInitializedByRegion;
  final List<String> regions;
  final int currentTabIndex;
  final bool showPhotoReviewsOnly;
  final String searchQuery;
  final bool showReportSuccess;

  const ReviewsLoaded({
    required this.reviewsByRegion,
    required this.isLoadingByRegion,
    required this.isInitializedByRegion,
    required this.regions,
    required this.currentTabIndex,
    required this.showPhotoReviewsOnly,
    required this.searchQuery,
    this.showReportSuccess = false,
  });

  ReviewsLoaded copyWith({
    Map<String, List<Review>>? reviewsByRegion,
    Map<String, bool>? isLoadingByRegion,
    Map<String, bool>? isInitializedByRegion,
    List<String>? regions,
    int? currentTabIndex,
    bool? showPhotoReviewsOnly,
    String? searchQuery,
    bool? showReportSuccess,
  }) {
    return ReviewsLoaded(
      reviewsByRegion: reviewsByRegion ?? this.reviewsByRegion,
      isLoadingByRegion: isLoadingByRegion ?? this.isLoadingByRegion,
      isInitializedByRegion:
          isInitializedByRegion ?? this.isInitializedByRegion,
      regions: regions ?? this.regions,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      showPhotoReviewsOnly: showPhotoReviewsOnly ?? this.showPhotoReviewsOnly,
      searchQuery: searchQuery ?? this.searchQuery,
      showReportSuccess: showReportSuccess ?? this.showReportSuccess,
    );
  }

  // Helper methods
  String get currentRegion =>
      regions.isNotEmpty ? regions[currentTabIndex] : '';

  List<Review> get currentRegionReviews => reviewsByRegion[currentRegion] ?? [];

  bool get isCurrentRegionLoading => isLoadingByRegion[currentRegion] ?? false;

  bool get isCurrentRegionInitialized =>
      isInitializedByRegion[currentRegion] ?? false;

  List<Review> get filteredReviews {
    final reviews = currentRegionReviews;
    return showPhotoReviewsOnly
        ? reviews.where((review) => review.imageUrls.isNotEmpty).toList()
        : reviews;
  }

  int get currentTabReviewCount {
    if (isCurrentRegionLoading) return 0;
    return filteredReviews.length;
  }
}

class ReviewReportSuccess extends ReviewBlocState {
  const ReviewReportSuccess();
}

class MyReviewsLoading extends ReviewBlocState {
  const MyReviewsLoading();
}

class MyReviewsLoaded extends ReviewBlocState {
  final List<Review> myReviews;

  const MyReviewsLoaded({required this.myReviews});
}

class MyReviewsError extends ReviewBlocState {
  final String message;

  const MyReviewsError({required this.message});
}

class ReviewWriteLoading extends ReviewBlocState {
  const ReviewWriteLoading();
}

class ReviewWriteSuccess extends ReviewBlocState {
  const ReviewWriteSuccess();
}

class ReviewWriteError extends ReviewBlocState {
  final String message;

  const ReviewWriteError({required this.message});
}
