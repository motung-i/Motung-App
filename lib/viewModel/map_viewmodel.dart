import 'package:geolocator/geolocator.dart';
import 'package:motunge/dataSource/map.dart';
import 'package:motunge/model/map/districts_response.dart';
import 'package:motunge/model/map/random_location_response.dart';
import 'package:motunge/model/map/regions_response.dart';
import 'package:motunge/model/map/target_info_response.dart';

class MapViewmodel {
  final _mapDataSource = MapDataSource();
  TargetInfoResponse? _targetInfo;

  Future<bool> checkServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<bool> checkPermission() async {
    return await Geolocator.checkPermission() != LocationPermission.denied;
  }

  Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition();
  }

  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  Future<RandomLocationResponse> getRandomLocation({
    List<String>? regions,
    List<String>? districts,
  }) async {
    return await _mapDataSource.getRandomLocation(
      regions: regions,
      districts: districts,
    );
  }

  Future<RegionsDataResponse> getRegions() async {
    return await _mapDataSource.getRegions();
  }

  Future<DistrictsResponse> getDistricts(String region) async {
    return await _mapDataSource.getDistricts(region);
  }

  Future<void> startTour() async {
    try {
      await _mapDataSource.startTour();
      await _updateTargetInfo();
    } catch (e) {
      print('투어 시작 실패: $e');
      rethrow;
    }
  }

  Future<RandomLocationResponse?> getOwnTourInfo() async {
    try {
      final tourInfo = await _mapDataSource.getOwnTourInfo();
      await _updateTargetInfo();
      return tourInfo;
    } catch (e) {
      print('투어 정보 조회 실패: $e');
      return null;
    }
  }

  Future<void> _updateTargetInfo() async {
    try {
      _targetInfo = await _mapDataSource.getTourTargetInfo();
    } catch (e) {
      print('타겟 정보 업데이트 실패: $e');
      _targetInfo = null;
    }
  }

  TargetInfoResponse? getTargetInfo() => _targetInfo;
}
