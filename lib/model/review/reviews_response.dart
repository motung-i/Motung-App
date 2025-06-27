import 'package:json_annotation/json_annotation.dart';

part 'reviews_response.g.dart';

@JsonSerializable()
class ReviewsResponse {
  @JsonKey(name: 'reviews')
  final List<Review> reviews;

  @JsonKey(name: 'reviews_count')
  final int reviewsCount;

  ReviewsResponse({
    required this.reviews,
    required this.reviewsCount,
  });

  factory ReviewsResponse.fromJson(Map<String, dynamic> json) =>
      _$ReviewsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewsResponseToJson(this);
}

@JsonSerializable()
class Review {
  @JsonKey(name: 'review_id')
  final String reviewId;

  final String? nickname;

  @JsonKey(name: 'is_recommend')
  final bool isRecommend;

  final String local;
  final String description;

  @JsonKey(name: 'image_urls')
  final List<String> imageUrls;

  @JsonKey(name: 'created_date')
  final String createdDate;

  Review({
    required this.reviewId,
    required this.nickname,
    required this.isRecommend,
    required this.local,
    required this.description,
    required this.imageUrls,
    required this.createdDate,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}
