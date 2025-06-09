import 'package:json_annotation/json_annotation.dart';

part 'districts_response.g.dart';

@JsonSerializable()
class DistrictsResponse {
  final List<DistrictType> districts;

  DistrictsResponse({
    required this.districts,
  });

  factory DistrictsResponse.fromJson(Map<String, dynamic> json) =>
      _$DistrictsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DistrictsResponseToJson(this);
}

@JsonSerializable()
class DistrictType {
  final String type;
  final List<String> district;

  DistrictType({
    required this.type,
    required this.district,
  });

  factory DistrictType.fromJson(Map<String, dynamic> json) =>
      _$DistrictTypeFromJson(json);

  Map<String, dynamic> toJson() => _$DistrictTypeToJson(this);
}
