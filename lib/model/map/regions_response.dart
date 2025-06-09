import 'package:json_annotation/json_annotation.dart';

part 'regions_response.g.dart';

@JsonSerializable()
class RegionsDataResponse {
  final List<String> regions;

  const RegionsDataResponse({
    required this.regions,
  });

  factory RegionsDataResponse.fromJson(Map<String, dynamic> json) =>
      _$RegionsDataResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RegionsDataResponseToJson(this);
}
