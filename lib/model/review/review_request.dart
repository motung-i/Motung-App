import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

part 'review_request.g.dart';

@JsonSerializable()
class ReviewRequest {
  @JsonKey(includeFromJson: false)
  final List<File> images;

  @JsonKey(name: 'request')
  final Request request;

  ReviewRequest({
    required this.request,
    this.images = const [],
  });

  factory ReviewRequest.fromJson(Map<String, dynamic> json) =>
      _$ReviewRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewRequestToJson(this);
}

@JsonSerializable()
class Request {
  @JsonKey(name: 'is_recommend')
  final bool isRecommend;
  final String description;

  Request({
    required this.isRecommend,
    required this.description,
  });

  factory Request.fromJson(Map<String, dynamic> json) =>
      _$RequestFromJson(json);

  Map<String, dynamic> toJson() => _$RequestToJson(this);
}
