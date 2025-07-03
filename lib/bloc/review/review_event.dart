import 'package:motunge/model/review/enum/report_reason.dart';

abstract class ReviewEvent {
  const ReviewEvent();
}

class ReviewRegionsRequested extends ReviewEvent {
  const ReviewRegionsRequested();
}

class ReviewsRequested extends ReviewEvent {
  final String region;
  final bool onlyByImage;
  final String? localAlias;
  final bool forceReload;

  const ReviewsRequested({
    required this.region,
    this.onlyByImage = false,
    this.localAlias,
    this.forceReload = false,
  });
}

class ReviewFilterChanged extends ReviewEvent {
  final bool showPhotoReviewsOnly;
  final String searchQuery;
  final String region;

  const ReviewFilterChanged({
    required this.showPhotoReviewsOnly,
    required this.searchQuery,
    required this.region,
  });
}

class ReviewTabChanged extends ReviewEvent {
  final int tabIndex;
  final String region;

  const ReviewTabChanged({
    required this.tabIndex,
    required this.region,
  });
}

class ReviewReportRequested extends ReviewEvent {
  final String reviewId;
  final List<ReportReason> reasons;

  const ReviewReportRequested({
    required this.reviewId,
    required this.reasons,
  });
}

class ReviewRefreshRequested extends ReviewEvent {
  final String region;
  final bool onlyByImage;
  final String? localAlias;

  const ReviewRefreshRequested({
    required this.region,
    this.onlyByImage = false,
    this.localAlias,
  });
}

class MyReviewsRequested extends ReviewEvent {
  const MyReviewsRequested();
}

class MyReviewsRefreshRequested extends ReviewEvent {
  const MyReviewsRefreshRequested();
}

class ReviewWriteRequested extends ReviewEvent {
  final bool isRecommend;
  final String description;
  final List<String> imagePaths;

  const ReviewWriteRequested({
    required this.isRecommend,
    required this.description,
    required this.imagePaths,
  });
}
