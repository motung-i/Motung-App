// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'naver_directions_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NaverDirectionsResponse _$NaverDirectionsResponseFromJson(
        Map<String, dynamic> json) =>
    NaverDirectionsResponse(
      traavoidtoll:
          Direction.fromJson(json['traavoidtoll'] as Map<String, dynamic>),
      traoptimal:
          Direction.fromJson(json['traoptimal'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NaverDirectionsResponseToJson(
        NaverDirectionsResponse instance) =>
    <String, dynamic>{
      'traavoidtoll': instance.traavoidtoll.toJson(),
      'traoptimal': instance.traoptimal.toJson(),
    };

Direction _$DirectionFromJson(Map<String, dynamic> json) => Direction(
      guide: (json['guide'] as List<dynamic>).map((e) => e as String).toList(),
      path: (json['path'] as List<dynamic>)
          .map((e) =>
              (e as List<dynamic>).map((e) => (e as num).toDouble()).toList())
          .toList(),
      startLat: (json['start_lat'] as num).toDouble(),
      startLon: (json['start_lon'] as num).toDouble(),
      endLat: (json['end_lat'] as num).toDouble(),
      endLon: (json['end_lon'] as num).toDouble(),
      distance: (json['distance'] as num).toInt(),
      duration: (json['duration'] as num).toInt(),
      taxiFare: (json['taxi_fare'] as num).toInt(),
      tollFare: (json['toll_fare'] as num).toInt(),
    );

Map<String, dynamic> _$DirectionToJson(Direction instance) => <String, dynamic>{
      'guide': instance.guide,
      'path': instance.path,
      'start_lat': instance.startLat,
      'start_lon': instance.startLon,
      'end_lat': instance.endLat,
      'end_lon': instance.endLon,
      'distance': instance.distance,
      'duration': instance.duration,
      'taxi_fare': instance.taxiFare,
      'toll_fare': instance.tollFare,
    };
