// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'districts_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DistrictsResponse _$DistrictsResponseFromJson(Map<String, dynamic> json) =>
    DistrictsResponse(
      districts: (json['districts'] as List<dynamic>)
          .map((e) => DistrictType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DistrictsResponseToJson(DistrictsResponse instance) =>
    <String, dynamic>{
      'districts': instance.districts,
    };

DistrictType _$DistrictTypeFromJson(Map<String, dynamic> json) => DistrictType(
      type: json['type'] as String,
      district:
          (json['district'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$DistrictTypeToJson(DistrictType instance) =>
    <String, dynamic>{
      'type': instance.type,
      'district': instance.district,
    };
