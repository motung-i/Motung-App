import 'package:motunge/constants/app_constants.dart';
import 'package:motunge/dataSource/base_data_source.dart';
import 'package:motunge/model/map/districts_response.dart';
import 'package:motunge/model/map/naver_directions_response.dart';
import 'package:motunge/model/map/random_location_response.dart';
import 'package:motunge/model/map/regions_response.dart';
import 'package:motunge/model/map/target_info_response.dart';

class MapDataSource extends BaseDataSource {
  Future<RandomLocationResponse> getRandomLocation({
    List<String>? regions,
    List<String>? districts,
  }) async {
    final queryParams = <String, dynamic>{
      'country': AppConstants.countryKorea,
    };

    if (regions != null && regions.isNotEmpty) {
      queryParams['region'] = regions.join(',');
    }

    if (districts != null && districts.isNotEmpty) {
      queryParams['district'] = districts.join(',');
    }

    final response = await dio.post(
      getUrl('/tour/random'),
      queryParameters: queryParams,
    );

    return RandomLocationResponse.fromJson(response.data);
  }

  Future<RegionsDataResponse> getRegions() async {
    final response = await dio.get(
        getUrl('/tour/filter/region?country=${AppConstants.countryKorea}'));
    return RegionsDataResponse.fromJson(response.data);
  }

  Future<DistrictsResponse> getDistricts(String region) async {
    final response = await dio.get(getUrl(
        '/tour/filter/district?country=${AppConstants.countryKorea}&region=$region'));
    return DistrictsResponse.fromJson(response.data);
  }

  Future<void> startTour() async {
    await dio.post(getUrl('/tour'));
  }

  Future<RandomLocationResponse> getOwnTourInfo() async {
    final response = await dio.get(getUrl('/tour'));
    return RandomLocationResponse.fromJson(response.data);
  }

  Future<TargetInfoResponse> getTourTargetInfo() async {
    final response = await dio.get(getUrl('/tour/comment'));
    return TargetInfoResponse.fromJson(response.data);
  }

  Future<void> endTour() async {
    await dio.delete(getUrl('/tour'));
  }

  Future<void> requestGenerateTourInfo() async {
    await dio.post(getUrl('/tour/comment'));
  }

  Future<NaverDirectionsResponse> getTourRoute(
      double startLat, double startLon) async {
    final response = await dio
        .get(getUrl('/tour/route?startLat=$startLat&startLon=$startLon'));
    return NaverDirectionsResponse.fromJson(response.data);
  }
}
