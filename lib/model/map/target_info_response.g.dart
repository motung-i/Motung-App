// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'target_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TargetInfoResponse _$TargetInfoResponseFromJson(Map<String, dynamic> json) =>
    TargetInfoResponse(
      restaurantComment: json['restaurant_comment'] as String,
      sightseeingSpotsComment: json['sightseeing_spots_comment'] as String,
      cultureComment: json['culture_comment'] as String,
    );

Map<String, dynamic> _$TargetInfoResponseToJson(TargetInfoResponse instance) =>
    <String, dynamic>{
      'restaurant_comment': instance.restaurantComment,
      'sightseeing_spots_comment': instance.sightseeingSpotsComment,
      'culture_comment': instance.cultureComment,
    };
