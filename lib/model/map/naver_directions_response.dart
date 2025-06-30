import 'package:json_annotation/json_annotation.dart';

part 'naver_directions_response.g.dart';

@JsonSerializable(explicitToJson: true)
class NaverDirectionsResponse {
  final Direction traavoidtoll;
  final Direction traoptimal;

  NaverDirectionsResponse({
    required this.traavoidtoll,
    required this.traoptimal,
  });

  factory NaverDirectionsResponse.fromJson(Map<String, dynamic> json) =>
      _$NaverDirectionsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NaverDirectionsResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Direction {
  final List<String> guide;
  final List<List<double>> path;
  @JsonKey(name: 'start_lat')
  final double startLat;
  @JsonKey(name: 'start_lon')
  final double startLon;
  @JsonKey(name: 'end_lat')
  final double endLat;
  @JsonKey(name: 'end_lon')
  final double endLon;
  final int distance;
  final int duration;
  @JsonKey(name: 'taxi_fare')
  final int taxiFare;
  @JsonKey(name: 'toll_fare')
  final int tollFare;

  Direction({
    required this.guide,
    required this.path,
    required this.startLat,
    required this.startLon,
    required this.endLat,
    required this.endLon,
    required this.distance,
    required this.duration,
    required this.taxiFare,
    required this.tollFare,
  });

  factory Direction.fromJson(Map<String, dynamic> json) =>
      _$DirectionFromJson(json);

  Map<String, dynamic> toJson() => _$DirectionToJson(this);
}
