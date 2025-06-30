import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:motunge/dataSource/map.dart';
import 'package:motunge/model/map/districts_response.dart';
import 'package:motunge/model/map/naver_directions_response.dart';
import 'package:motunge/model/map/random_location_response.dart';
import 'package:motunge/model/map/regions_response.dart';
import 'package:motunge/model/map/target_info_response.dart';

class MapViewmodel {
  static final MapViewmodel _instance = MapViewmodel._internal();

  factory MapViewmodel() {
    return _instance;
  }

  MapViewmodel._internal();

  final _mapDataSource = MapDataSource();
  TargetInfoResponse? _targetInfo;

  // 경로 관련 상태 추가
  NaverDirectionsResponse? _directionsResponse;
  Direction? _selectedDirection;
  Position? _currentPosition;

  Future<bool> checkServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<bool> checkPermission() async {
    return await Geolocator.checkPermission() != LocationPermission.denied;
  }

  Future<Position> getCurrentLocation() async {
    _currentPosition = await Geolocator.getCurrentPosition();
    return _currentPosition!;
  }

  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  // 위치 권한 확인 공통 메서드
  Future<bool> ensureLocationPermission() async {
    final permission = await checkPermission();
    if (permission) return true;

    final permissionResult = await requestPermission();
    return permissionResult != LocationPermission.denied &&
        permissionResult != LocationPermission.deniedForever;
  }

  // 현재 위치 초기화 공통 메서드
  Future<Position?> initializeCurrentLocation() async {
    try {
      final hasPermission = await ensureLocationPermission();
      if (!hasPermission) return null;

      final serviceEnabled = await checkServiceEnabled();
      if (!serviceEnabled) return null;

      return await getCurrentLocation();
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  // 경로 데이터 가져오기
  Future<NaverDirectionsResponse?> fetchAndCacheRouteData() async {
    if (_currentPosition == null) {
      _currentPosition = await initializeCurrentLocation();
      if (_currentPosition == null) return null;
    }

    try {
      _directionsResponse = await _mapDataSource.getTourRoute(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      return _directionsResponse;
    } catch (e) {
      debugPrint('경로 정보 가져오기 실패: $e');
      return null;
    }
  }

  // 경로 선택
  void selectDirection(Direction direction) {
    _selectedDirection = direction;
  }

  // Getters
  NaverDirectionsResponse? get directionsResponse => _directionsResponse;
  Direction? get selectedDirection => _selectedDirection;
  Position? get currentPosition => _currentPosition;

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
      debugPrint('투어 시작 실패: $e');
      rethrow;
    }
  }

  Future<RandomLocationResponse?> getOwnTourInfo() async {
    try {
      final tourInfo = await _mapDataSource.getOwnTourInfo();
      await _updateTargetInfo();
      return tourInfo;
    } catch (e) {
      debugPrint('투어 정보 조회 실패: $e');
      return null;
    }
  }

  Future<void> _updateTargetInfo() async {
    try {
      _targetInfo = await _mapDataSource.getTourTargetInfo();
    } catch (e) {
      debugPrint('타겟 정보 업데이트 실패: $e');
      _targetInfo = null;
    }
  }

  TargetInfoResponse? getTargetInfo() => _targetInfo;

  Future<void> endTour() async {
    try {
      await _mapDataSource.endTour();
      _targetInfo = null;
    } catch (e) {
      debugPrint('투어 종료 실패: $e');
      rethrow;
    }
  }

  Future<void> requestGenerateTourInfo() async {
    try {
      await _mapDataSource.requestGenerateTourInfo();
      await _updateTargetInfo();
    } catch (e) {
      debugPrint('AI 정보 생성 요청 실패: $e');
      rethrow;
    }
  }

  Future<NaverDirectionsResponse> getTourRoute(
      double startLat, double startLon) async {
    return await _mapDataSource.getTourRoute(startLat, startLon);
  }
}
