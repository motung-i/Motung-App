import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:motunge/model/map/districts_response.dart';
import 'package:motunge/model/map/random_location_response.dart';
import 'package:motunge/model/map/regions_response.dart';
import 'package:motunge/model/map/target_info_response.dart';
import 'package:motunge/network/dio.dart';

class MapDataSource {
  final dio = AppDio.getInstance();

  Future<RandomLocationResponse> getRandomLocation({
    List<String>? regions,
    List<String>? districts,
  }) async {
    final queryParams = <String, dynamic>{
      'country': 'KOREA',
    };

    if (regions != null && regions.isNotEmpty) {
      queryParams['region'] = regions.join(',');
    }

    if (districts != null && districts.isNotEmpty) {
      queryParams['district'] = districts.join(',');
    }

    final response = await dio.post(
      '${dotenv.env['API_URL']}/tour/random',
      queryParameters: queryParams,
    );

    return RandomLocationResponse.fromJson(response.data);
  }

  Future<RegionsDataResponse> getRegions() async {
    final response = await dio
        .get('${dotenv.env['API_URL']}/tour/filter/region?country=KOREA');
    return RegionsDataResponse.fromJson(response.data);
  }

  Future<DistrictsResponse> getDistricts(String region) async {
    final response = await dio.get(
        '${dotenv.env['API_URL']}/tour/filter/district?country=KOREA&region=$region');
    return DistrictsResponse.fromJson(response.data);
  }

  Future<void> startTour() async {
    await dio.post('${dotenv.env['API_URL']}/tour');
  }

  Future<RandomLocationResponse> getOwnTourInfo() async {
    final response = await dio.get('${dotenv.env['API_URL']}/tour');
    return RandomLocationResponse.fromJson(response.data);
  }

  Future<TargetInfoResponse> getTourTargetInfo() async {
    final response = await dio.get('${dotenv.env['API_URL']}/tour/comment');
    return TargetInfoResponse.fromJson(response.data);
  }
}
