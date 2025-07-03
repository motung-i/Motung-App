import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';

import 'package:motunge/bloc/map/map_event.dart';
import 'package:motunge/bloc/map/map_state.dart';
import 'package:motunge/dataSource/map.dart';
import 'package:motunge/model/map/naver_directions_response.dart';
import 'package:motunge/model/map/target_info_response.dart';

class MapBloc extends Bloc<MapEvent, MapBlocState> {
  final MapDataSource _mapDataSource = MapDataSource();

  Position? _currentPosition;
  NaverDirectionsResponse? _directionsResponse;
  Object? _selectedDirection;
  TargetInfoResponse? _targetInfo;

  MapBloc() : super(const MapInitial()) {
    on<MapLocationServiceChecked>(_onLocationServiceChecked);
    on<MapPermissionChecked>(_onPermissionChecked);
    on<MapPermissionRequested>(_onPermissionRequested);
    on<MapCurrentLocationRequested>(_onCurrentLocationRequested);
    on<MapRouteDataRequested>(_onRouteDataRequested);
    on<MapDirectionSelected>(_onDirectionSelected);
    on<MapRandomLocationRequested>(_onRandomLocationRequested);
    on<MapRegionsRequested>(_onRegionsRequested);
    on<MapDistrictsRequested>(_onDistrictsRequested);
    on<MapTourStartRequested>(_onTourStartRequested);
    on<MapTourInfoRequested>(_onTourInfoRequested);
    on<MapTourEndRequested>(_onTourEndRequested);
    on<MapTourInfoGenerationRequested>(_onTourInfoGenerationRequested);
    on<MapTourRouteRequested>(_onTourRouteRequested);
  }

  Position? get currentPosition => _currentPosition;
  NaverDirectionsResponse? get directionsResponse => _directionsResponse;
  Object? get selectedDirection => _selectedDirection;
  TargetInfoResponse? get targetInfo => _targetInfo;

  Future<void> _onLocationServiceChecked(
    MapLocationServiceChecked event,
    Emitter<MapBlocState> emit,
  ) async {
    try {
      final isEnabled = await Geolocator.isLocationServiceEnabled();
      emit(MapLocationServiceEnabled(isEnabled: isEnabled));
    } catch (e) {
      emit(MapError(message: '위치 서비스 확인 중 오류가 발생했습니다'));
    }
  }

  Future<void> _onPermissionChecked(
    MapPermissionChecked event,
    Emitter<MapBlocState> emit,
  ) async {
    try {
      final permission = await Geolocator.checkPermission();
      emit(MapPermissionStatus(permission: permission));
    } catch (e) {
      emit(MapError(message: '위치 권한 확인 중 오류가 발생했습니다'));
    }
  }

  Future<void> _onPermissionRequested(
    MapPermissionRequested event,
    Emitter<MapBlocState> emit,
  ) async {
    try {
      final permission = await Geolocator.requestPermission();
      emit(MapPermissionStatus(permission: permission));
    } catch (e) {
      emit(MapError(message: '위치 권한 요청 중 오류가 발생했습니다'));
    }
  }

  Future<void> _onCurrentLocationRequested(
    MapCurrentLocationRequested event,
    Emitter<MapBlocState> emit,
  ) async {
    emit(const MapLoading());

    try {
      final hasPermission = await _ensureLocationPermission();
      if (!hasPermission) {
        emit(const MapError(message: '위치 권한이 필요합니다.'));
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(const MapError(message: '위치 서비스가 비활성화되어 있습니다.'));
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition();
      emit(MapCurrentLocationLoaded(position: _currentPosition!));
    } catch (e) {
      emit(const MapError(message: '위치 정보 가져오기에 실패했습니다.'));
    }
  }

  Future<void> _onRouteDataRequested(
    MapRouteDataRequested event,
    Emitter<MapBlocState> emit,
  ) async {
    emit(const MapLoading());

    try {
      if (_currentPosition == null) {
        final hasPermission = await _ensureLocationPermission();
        if (!hasPermission) {
          emit(const MapError(message: '위치 권한이 필요합니다.'));
          return;
        }

        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          emit(const MapError(message: '위치 서비스가 비활성화되어 있습니다.'));
          return;
        }

        _currentPosition = await Geolocator.getCurrentPosition();
      }

      _directionsResponse = await _mapDataSource.getTourRoute(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      emit(MapRouteDataLoaded(
        directionsResponse: _directionsResponse!,
        currentPosition: _currentPosition!,
      ));
    } catch (e) {
      debugPrint('경로 정보 가져오기 실패: $e');
      emit(MapError(message: '경로 정보를 가져오는 중 오류가 발생했습니다: $e'));
    }
  }

  void _onDirectionSelected(
    MapDirectionSelected event,
    Emitter<MapBlocState> emit,
  ) {
    _selectedDirection = event.direction;
    emit(MapDirectionSelectedState(selectedDirection: event.direction));
  }

  Future<void> _onRandomLocationRequested(
    MapRandomLocationRequested event,
    Emitter<MapBlocState> emit,
  ) async {
    emit(const MapLoading());

    try {
      final randomLocation = await _mapDataSource.getRandomLocation(
        regions: event.regions,
        districts: event.districts,
      );
      emit(MapRandomLocationLoaded(randomLocation: randomLocation));
    } catch (e) {
      emit(MapError(message: '랜덤 위치를 가져오는 중 오류가 발생했습니다: $e'));
    }
  }

  Future<void> _onRegionsRequested(
    MapRegionsRequested event,
    Emitter<MapBlocState> emit,
  ) async {
    emit(const MapLoading());

    try {
      final regions = await _mapDataSource.getRegions();
      emit(MapRegionsLoaded(regions: regions));
    } catch (e) {
      emit(MapError(message: '지역 정보를 가져오는 중 오류가 발생했습니다: $e'));
    }
  }

  Future<void> _onDistrictsRequested(
    MapDistrictsRequested event,
    Emitter<MapBlocState> emit,
  ) async {
    emit(const MapLoading());

    try {
      final districts = await _mapDataSource.getDistricts(event.region);
      emit(MapDistrictsLoaded(region: event.region, districts: districts));
    } catch (e) {
      emit(MapError(message: '구역 정보를 가져오는 중 오류가 발생했습니다: $e'));
    }
  }

  Future<void> _onTourStartRequested(
    MapTourStartRequested event,
    Emitter<MapBlocState> emit,
  ) async {
    emit(const MapLoading());

    try {
      await _mapDataSource.startTour();
      await _updateTargetInfo();
      emit(MapTourStarted(targetInfo: _targetInfo));
    } catch (e) {
      debugPrint('투어 시작 실패: $e');
      emit(MapError(message: '투어 시작 중 오류가 발생했습니다: $e'));
    }
  }

  Future<void> _onTourInfoRequested(
    MapTourInfoRequested event,
    Emitter<MapBlocState> emit,
  ) async {
    emit(const MapLoading());

    try {
      final tourInfo = await _mapDataSource.getOwnTourInfo();
      await _updateTargetInfo();
      emit(MapTourInfoLoaded(
        tourInfo: tourInfo,
        targetInfo: _targetInfo,
      ));
    } catch (e) {
      debugPrint('투어 정보 조회 실패: $e');

      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        if (statusCode != null && responseData != null) {
          final status = responseData['status'];
          if (status == 'NOT_ACTIVATED_TOUR') {
            emit(const MapTourInfoLoaded(tourInfo: null, targetInfo: null));
            return;
          }
        }
      }

      emit(MapError(message: '투어 정보를 가져오는 중 오류가 발생했습니다: $e'));
    }
  }

  Future<void> _onTourEndRequested(
    MapTourEndRequested event,
    Emitter<MapBlocState> emit,
  ) async {
    emit(const MapLoading());

    try {
      await _mapDataSource.endTour();
      _targetInfo = null;
      emit(const MapTourEnded());
    } catch (e) {
      debugPrint('투어 종료 실패: $e');

      if (e is DioException) {
        final statusCode = e.response?.statusCode;

        if (statusCode == 404) {
          _targetInfo = null;
          emit(const MapTourEnded());
          return;
        }
      }

      emit(MapError(message: '투어 종료 중 오류가 발생했습니다: $e'));
    }
  }

  Future<void> _onTourInfoGenerationRequested(
    MapTourInfoGenerationRequested event,
    Emitter<MapBlocState> emit,
  ) async {
    emit(const MapLoading());

    try {
      await _mapDataSource.requestGenerateTourInfo();
      await _updateTargetInfo();
      emit(MapTourInfoGenerated(targetInfo: _targetInfo));
    } catch (e) {
      debugPrint('AI 정보 생성 요청 실패: $e');
      emit(MapError(message: 'AI 정보 생성 중 오류가 발생했습니다: $e'));
    }
  }

  Future<void> _onTourRouteRequested(
    MapTourRouteRequested event,
    Emitter<MapBlocState> emit,
  ) async {
    emit(const MapLoading());

    try {
      final directionsResponse = await _mapDataSource.getTourRoute(
        event.startLat,
        event.startLon,
      );
      emit(MapTourRouteLoaded(directionsResponse: directionsResponse));
    } catch (e) {
      emit(MapError(message: '투어 경로를 가져오는 중 오류가 발생했습니다: $e'));
    }
  }

  Future<bool> _ensureLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission != LocationPermission.denied) return true;

    final permissionResult = await Geolocator.requestPermission();
    return permissionResult != LocationPermission.denied &&
        permissionResult != LocationPermission.deniedForever;
  }

  Future<void> _updateTargetInfo() async {
    try {
      _targetInfo = await _mapDataSource.getTourTargetInfo();
    } catch (e) {
      debugPrint('타겟 정보 업데이트 실패: $e');
      _targetInfo = null;
    }
  }
}
