import 'package:json_annotation/json_annotation.dart';

part 'target_info_response.g.dart';

@JsonSerializable()
class TargetInfoResponse {
  @JsonKey(name: "restaurant_comment")
  final String restaurantComment;

  @JsonKey(name: "sightseeing_spots_comment")
  final String sightseeingSpotsComment;

  @JsonKey(name: "culture_comment")
  final String cultureComment;

  TargetInfoResponse({
    required this.restaurantComment,
    required this.sightseeingSpotsComment,
    required this.cultureComment,
  });

  factory TargetInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$TargetInfoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TargetInfoResponseToJson(this);
}
