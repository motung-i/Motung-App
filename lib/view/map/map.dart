import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:motunge/bloc/map/map_bloc.dart';
import 'package:motunge/bloc/map/map_event.dart';
import 'package:motunge/bloc/map/map_state.dart';
import 'package:motunge/model/map/random_location_response.dart';
import 'package:motunge/model/map/target_info_response.dart';
import 'package:motunge/view/map/views/pick_view.dart';
import 'package:motunge/view/map/views/confirm_view.dart';
import 'package:motunge/view/map/views/navigation_view.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

enum MapStep { pick, confirm, navigation }

class _MapPageState extends State<MapPage> {
  static const double _initialZoom = 15.0;
  static const double _destinationZoom = 11;
  static const double _redrawZoom = 11;
  static const String _tempDistance = "2.5km";
  static const String _tempDuration = "15분";

  final mapControllerCompleter = Completer<NaverMapController>();
  final DraggableScrollableController sheetController =
      DraggableScrollableController();
  final List<NOverlay> _overlays = [];

  NaverMapController? _mapController;
  MapStep _step = MapStep.pick;
  String _selectedLocation = "";
  String _distance = "";
  String _duration = "";
  // ignore: unused_field
  RandomLocationResponse? _currentLocation;
  TargetInfoResponse? _targetInfo;

  // 필터 관련 상태
  List<String> _selectedRegions = [];
  List<String> _selectedDistricts = [];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _checkCurrentTour();
  }

  @override
  void dispose() {
    _clearOverlays();
    if (_mapController != null) {
      _mapController!.dispose();
      _mapController = null;
    }
    sheetController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      context.read<MapBloc>().add(const MapPermissionChecked());
    } catch (e) {
      debugPrint('Error getting location: $e');
      _showErrorSnackBar('위치 정보 가져오기에 실패했습니다.');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _updateMapCamera(NLatLng target, double zoom) async {
    if (_mapController != null && mounted) {
      await _mapController!.updateCamera(
        NCameraUpdate.withParams(target: target, zoom: zoom),
      );
    }
  }

  void _drawPolyline(RandomLocationResponse location) {
    if (_mapController == null) return;

    // 각 폴리곤(도형)마다 별도의 오버레이를 생성
    for (int polygonIndex = 0;
        polygonIndex < location.geometry.coordinates.length;
        polygonIndex++) {
      final polygon = location.geometry.coordinates[polygonIndex];

      // 폴리곤은 여러 개의 링(외곽선, 홀)으로 구성될 수 있기 때문에 링을 모두 평탄화
      final ringPoints = polygon.expand((ring) => ring);

      final coords =
          ringPoints.map((coord) => NLatLng(coord[1], coord[0])).toList();

      final polygonOverlay = NPolygonOverlay(
        id: 'polygon_$polygonIndex',
        coords: coords,
        color: const Color(0x20125CED),
        outlineColor: const Color(0xFF125CED),
        outlineWidth: 3,
      );

      _overlays.add(polygonOverlay);
      _mapController!.addOverlay(polygonOverlay);
    }
  }

  void _clearOverlays() {
    if (_mapController != null) {
      for (var overlay in _overlays) {
        _mapController?.deleteOverlay(overlay.info);
      }
      _overlays.clear();
    }
  }

  Future<void> _setDestination(
      RandomLocationResponse location, double zoom) async {
    setState(() {
      _selectedLocation = location.local;
      _distance = _tempDistance;
      _duration = _tempDuration;
      _currentLocation = location;
    });

    await _updateMapCamera(NLatLng(location.lat, location.lon), zoom);
    _drawPolyline(location);
  }

  Future<void> _onDrawDestination() async {
    context.read<MapBloc>().add(MapRandomLocationRequested(
          regions: _selectedRegions.isNotEmpty ? _selectedRegions : null,
          districts: _selectedDistricts.isNotEmpty ? _selectedDistricts : null,
        ));
  }

  Future<void> _onRedrawDestination() async {
    context.read<MapBloc>().add(MapRandomLocationRequested(
          regions: _selectedRegions.isNotEmpty ? _selectedRegions : null,
          districts: _selectedDistricts.isNotEmpty ? _selectedDistricts : null,
        ));
  }

  Future<void> _openLocationFilter() async {
    final result = await context.pushNamed(
      'locationFilter',
      queryParameters: {
        if (_selectedRegions.isNotEmpty)
          'selectedRegions': _selectedRegions.join(','),
        if (_selectedDistricts.isNotEmpty)
          'selectedDistricts': _selectedDistricts.join(','),
      },
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _selectedRegions = List<String>.from(result['regions'] ?? []);
        _selectedDistricts = List<String>.from(result['districts'] ?? []);
      });
    }
  }

  Future<void> _onConfirmDestination() async {
    context.read<MapBloc>().add(const MapTourStartRequested());
  }

  void _onEndNavigation() {
    setState(() {
      _step = MapStep.pick;
      _selectedLocation = "";
      _distance = "";
      _duration = "";
      _currentLocation = null;
      _targetInfo = null;
    });
    _clearOverlays();
    context.read<MapBloc>().add(const MapTourEndRequested());
  }

  Future<void> _checkCurrentTour() async {
    context.read<MapBloc>().add(const MapTourInfoRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MapBloc, MapBlocState>(
      listener: (context, state) {
        if (state is MapError) {
          _showErrorSnackBar(state.message);
        } else if (state is MapPermissionStatus) {
          if (state.permission == LocationPermission.denied ||
              state.permission == LocationPermission.deniedForever) {
            context.read<MapBloc>().add(const MapPermissionRequested());
          } else {
            context.read<MapBloc>().add(const MapLocationServiceChecked());
          }
        } else if (state is MapLocationServiceEnabled) {
          if (state.isEnabled) {
            context.read<MapBloc>().add(const MapCurrentLocationRequested());
          } else {
            _showErrorSnackBar('위치 서비스를 활성화해주세요.');
          }
        } else if (state is MapCurrentLocationLoaded) {
          _updateMapCamera(
            NLatLng(state.position.latitude, state.position.longitude),
            _initialZoom,
          );
        } else if (state is MapRandomLocationLoaded) {
          if (_step == MapStep.pick) {
            setState(() {
              _step = MapStep.confirm;
            });
            _setDestination(state.randomLocation, _destinationZoom);
          } else {
            // 재뽑기의 경우
            _clearOverlays();
            _setDestination(state.randomLocation, _redrawZoom);
          }
        } else if (state is MapTourStarted) {
          setState(() {
            _step = MapStep.navigation;
            _targetInfo = state.targetInfo;
          });
          // AI 정보 생성 요청
          context.read<MapBloc>().add(const MapTourInfoGenerationRequested());
        } else if (state is MapTourInfoLoaded) {
          if (state.tourInfo != null) {
            setState(() {
              _step = MapStep.navigation;
              _selectedLocation = state.tourInfo!.local;
              _distance = _tempDistance;
              _duration = _tempDuration;
              _currentLocation = state.tourInfo;
              _targetInfo = state.targetInfo;
            });
            _setDestination(state.tourInfo!, _destinationZoom);
          }
        } else if (state is MapTourEnded) {
          // 투어 종료 후 처리는 _onEndNavigation에서 이미 처리됨
        } else if (state is MapTourInfoGenerated) {
          setState(() {
            _targetInfo = state.targetInfo;
          });
        }
      },
      child: Scaffold(
        body: Stack(children: [
          NaverMapView(
            onMapReady: (controller) async {
              _mapController = controller;
              mapControllerCompleter.complete(controller);
              await _initializeLocation();
            },
          ),
          // 필터 버튼 (pick, confirm 단계에서만 표시)
          if (_step != MapStep.navigation)
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.28,
              right: 24.w,
              child: _buildFilterButton(),
            ),
          DraggableScrollableSheet(
            initialChildSize: _step == MapStep.navigation ? 0.4 : 0.28,
            maxChildSize: _step == MapStep.navigation ? 0.6 : 0.3,
            minChildSize: _step == MapStep.navigation ? 0.4 : 0.28,
            controller: sheetController,
            builder: (BuildContext context, scrollController) {
              return Container(
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    if (_step == MapStep.navigation)
                      SliverToBoxAdapter(
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xffEFF0F2),
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                            height: 3.h,
                            width: 90.w,
                            margin: EdgeInsets.only(top: 16.h),
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.w, vertical: 28.h),
                        child: BlocBuilder<MapBloc, MapBlocState>(
                          builder: (context, state) {
                            return _buildStepWidget(state);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        ]),
      ),
    );
  }

  Widget _buildStepWidget(MapBlocState state) {
    switch (_step) {
      case MapStep.pick:
        return PickView(
          onDrawDestination: _onDrawDestination,
          isLoading: state is MapLoading,
        );
      case MapStep.confirm:
        return ConfirmView(
          selectedLocation: _selectedLocation,
          onConfirmDestination: _onConfirmDestination,
          onRedrawDestination: _onRedrawDestination,
          isLoading: state is MapLoading,
        );
      case MapStep.navigation:
        return NavigationView(
          selectedLocation: _selectedLocation,
          distance: _distance,
          duration: _duration,
          onEndNavigation: _onEndNavigation,
          targetInfo: _targetInfo,
        );
    }
  }

  Widget _buildFilterButton() {
    final double size = 48.w;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openLocationFilter,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.tune,
              size: 24.w,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class NaverMapView extends StatefulWidget {
  final Function(NaverMapController) onMapReady;

  const NaverMapView({
    super.key,
    required this.onMapReady,
  });

  @override
  State<NaverMapView> createState() => _NaverMapViewState();
}

class _NaverMapViewState extends State<NaverMapView> {
  NaverMapController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NaverMap(
      options: const NaverMapViewOptions(
        indoorEnable: true,
        locationButtonEnable: false,
        consumeSymbolTapEvents: false,
      ),
      onMapReady: (controller) {
        _controller = controller;
        widget.onMapReady(controller);
      },
    );
  }
}
