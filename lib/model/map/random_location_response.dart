import 'package:json_annotation/json_annotation.dart';

part 'random_location_response.g.dart';

@JsonSerializable()
class RandomLocationResponse {
  final double lat;
  final double lon;
  final String local;
  final Geometry geometry;

  RandomLocationResponse({
    required this.lat,
    required this.lon,
    required this.local,
    required this.geometry,
  });

  factory RandomLocationResponse.fromJson(Map<String, dynamic> json) =>
      _$RandomLocationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RandomLocationResponseToJson(this);
}

@JsonSerializable()
class Geometry {
  final String type;
  final List<List<List<List<double>>>> coordinates;

  Geometry({
    required this.type,
    required this.coordinates,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) =>
      _$GeometryFromJson(json);

  Map<String, dynamic> toJson() => _$GeometryToJson(this);
}
