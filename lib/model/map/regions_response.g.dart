// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'regions_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegionsDataResponse _$RegionsDataResponseFromJson(Map<String, dynamic> json) =>
    RegionsDataResponse(
      regions:
          (json['regions'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$RegionsDataResponseToJson(
        RegionsDataResponse instance) =>
    <String, dynamic>{
      'regions': instance.regions,
    };
