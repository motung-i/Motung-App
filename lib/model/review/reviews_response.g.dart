// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reviews_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewsResponse _$ReviewsResponseFromJson(Map<String, dynamic> json) =>
    ReviewsResponse(
      reviews: (json['reviews'] as List<dynamic>)
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList(),
      reviewsCount: (json['reviews_count'] as num).toInt(),
    );

Map<String, dynamic> _$ReviewsResponseToJson(ReviewsResponse instance) =>
    <String, dynamic>{
      'reviews': instance.reviews,
      'reviews_count': instance.reviewsCount,
    };

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
      reviewId: json['review_id'] as String,
      nickname: json['nickname'] as String,
      isRecommend: json['is_recommend'] as bool,
      local: json['local'] as String,
      description: json['description'] as String,
      imageUrls: (json['image_urls'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdDate: json['created_date'] as String,
    );

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
      'review_id': instance.reviewId,
      'nickname': instance.nickname,
      'is_recommend': instance.isRecommend,
      'local': instance.local,
      'description': instance.description,
      'image_urls': instance.imageUrls,
      'created_date': instance.createdDate,
    };
