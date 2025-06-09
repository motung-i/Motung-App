// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewRequest _$ReviewRequestFromJson(Map<String, dynamic> json) =>
    ReviewRequest(
      request: Request.fromJson(json['request'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReviewRequestToJson(ReviewRequest instance) =>
    <String, dynamic>{
      'request': instance.request,
    };

Request _$RequestFromJson(Map<String, dynamic> json) => Request(
      isRecommend: json['is_recommend'] as bool,
      description: json['description'] as String,
    );

Map<String, dynamic> _$RequestToJson(Request instance) => <String, dynamic>{
      'is_recommend': instance.isRecommend,
      'description': instance.description,
    };
