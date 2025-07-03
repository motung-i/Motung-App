import 'package:geolocator/geolocator.dart';
import 'package:motunge/model/map/districts_response.dart';
import 'package:motunge/model/map/naver_directions_response.dart';
import 'package:motunge/model/map/random_location_response.dart';
import 'package:motunge/model/map/regions_response.dart';
import 'package:motunge/model/map/target_info_response.dart';

abstract class MapBlocState {
  const MapBlocState();
}

class MapInitial extends MapBlocState {
  const MapInitial();
}

class MapLoading extends MapBlocState {
  const MapLoading();
}

class MapError extends MapBlocState {
  final String message;

  const MapError({required this.message});
}

class MapLocationServiceEnabled extends MapBlocState {
  final bool isEnabled;

  const MapLocationServiceEnabled({required this.isEnabled});
}

class MapPermissionStatus extends MapBlocState {
  final LocationPermission permission;

  const MapPermissionStatus({required this.permission});
}

class MapCurrentLocationLoaded extends MapBlocState {
  final Position position;

  const MapCurrentLocationLoaded({required this.position});
}

class MapRouteDataLoaded extends MapBlocState {
  final NaverDirectionsResponse directionsResponse;
  final Position currentPosition;

  const MapRouteDataLoaded({
    required this.directionsResponse,
    required this.currentPosition,
  });
}

class MapDirectionSelectedState extends MapBlocState {
  final Object selectedDirection;

  const MapDirectionSelectedState({required this.selectedDirection});
}

class MapRandomLocationLoaded extends MapBlocState {
  final RandomLocationResponse randomLocation;

  const MapRandomLocationLoaded({required this.randomLocation});
}

class MapRegionsLoaded extends MapBlocState {
  final RegionsDataResponse regions;

  const MapRegionsLoaded({required this.regions});
}

class MapDistrictsLoaded extends MapBlocState {
  final String region;
  final DistrictsResponse districts;

  const MapDistrictsLoaded({required this.region, required this.districts});
}

class MapTourStarted extends MapBlocState {
  final TargetInfoResponse? targetInfo;

  const MapTourStarted({this.targetInfo});
}

class MapTourInfoLoaded extends MapBlocState {
  final RandomLocationResponse? tourInfo;
  final TargetInfoResponse? targetInfo;

  const MapTourInfoLoaded({
    this.tourInfo,
    this.targetInfo,
  });
}

class MapTourEnded extends MapBlocState {
  const MapTourEnded();
}

class MapTourInfoGenerated extends MapBlocState {
  final TargetInfoResponse? targetInfo;

  const MapTourInfoGenerated({this.targetInfo});
}

class MapTourRouteLoaded extends MapBlocState {
  final NaverDirectionsResponse directionsResponse;

  const MapTourRouteLoaded({required this.directionsResponse});
}

class MapDataState extends MapBlocState {
  final Position? currentPosition;
  final NaverDirectionsResponse? directionsResponse;
  final Object? selectedDirection;
  final TargetInfoResponse? targetInfo;

  const MapDataState({
    this.currentPosition,
    this.directionsResponse,
    this.selectedDirection,
    this.targetInfo,
  });

  MapDataState copyWith({
    Position? currentPosition,
    NaverDirectionsResponse? directionsResponse,
    Object? selectedDirection,
    TargetInfoResponse? targetInfo,
  }) {
    return MapDataState(
      currentPosition: currentPosition ?? this.currentPosition,
      directionsResponse: directionsResponse ?? this.directionsResponse,
      selectedDirection: selectedDirection ?? this.selectedDirection,
      targetInfo: targetInfo ?? this.targetInfo,
    );
  }
}
