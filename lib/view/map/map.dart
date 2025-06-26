import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:motunge/model/map/random_location_response.dart';
import 'package:motunge/viewModel/map_viewmodel.dart';
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
  final mapViewModel = MapViewmodel();
  final List<NOverlay> _overlays = [];

  NaverMapController? _mapController;
  MapStep _step = MapStep.pick;
  String _selectedLocation = "";
  String _distance = "";
  String _duration = "";

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
      final hasPermission = await _ensureLocationPermission();
      if (!hasPermission) return;

      final serviceEnabled = await mapViewModel.checkServiceEnabled();
      if (!serviceEnabled) {
        _showErrorSnackBar('위치 서비스를 활성화해주세요.');
        return;
      }

      final position = await mapViewModel.getCurrentLocation();
      await _updateMapCamera(
        NLatLng(position.latitude, position.longitude),
        _initialZoom,
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      _showErrorSnackBar('위치 정보를 가져오는데 실패했습니다.');
    }
  }

  Future<bool> _ensureLocationPermission() async {
    final permission = await mapViewModel.checkPermission();
    if (permission) return true;

    final permissionResult = await mapViewModel.requestPermission();
    if (permissionResult == LocationPermission.denied ||
        permissionResult == LocationPermission.deniedForever) {
      _showErrorSnackBar('위치 권한이 필요합니다.');
      return false;
    }
    return true;
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

    final coordinates = location.geometry.coordinates
        .expand((list) => list)
        .expand((list) => list)
        .map((coord) => NLatLng(coord[1], coord[0]))
        .toList();

    final polyline = NPolygonOverlay(
      id: 'polyline1',
      coords: coordinates,
      color: const Color(0x20125CED),
      outlineColor: const Color(0xFF125CED),
      outlineWidth: 3,
    );

    _overlays.add(polyline);
    _mapController!.addOverlay(polyline);
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
    });

    await _updateMapCamera(NLatLng(location.lat, location.lon), zoom);
    _drawPolyline(location);
  }

  Future<void> _onDrawDestination() async {
    try {
      final location = await mapViewModel.getRandomLocation();
      setState(() {
        _step = MapStep.confirm;
      });
      await _setDestination(location, _destinationZoom);
    } catch (e) {
      _showErrorSnackBar('목적지를 가져오는데 실패했습니다.');
    }
  }

  Future<void> _onRedrawDestination() async {
    try {
      final location = await mapViewModel.getRandomLocation();
      _clearOverlays();
      await _setDestination(location, _redrawZoom);
    } catch (e) {
      _showErrorSnackBar('목적지를 가져오는데 실패했습니다.');
    }
  }

  Future<void> _onConfirmDestination() async {
    try {
      await mapViewModel.startTour();
      // AI 정보 생성 요청
      mapViewModel.requestGenerateTourInfo().then((_) {
        if (!mounted) return;
        setState(() {});
      }).catchError((e) {
        debugPrint('AI 정보 생성 실패: $e');
      });

      if (!mounted) return;

      setState(() {
        _step = MapStep.navigation;
      });
    } catch (e) {
      if (!mounted) return;

      _showErrorSnackBar('투어를 시작하는데 실패했습니다.');
    }
  }

  void _onEndNavigation() {
    setState(() {
      _step = MapStep.pick;
      _selectedLocation = "";
      _distance = "";
      _duration = "";
      mapViewModel.endTour();
    });
    _clearOverlays();
  }

  Future<void> _checkCurrentTour() async {
    try {
      final tourInfo = await mapViewModel.getOwnTourInfo();
      if (!mounted) return;

      if (tourInfo != null) {
        setState(() {
          _step = MapStep.navigation;
          _selectedLocation = tourInfo.local;
          _distance = _tempDistance;
          _duration = _tempDuration;
        });
        await _setDestination(tourInfo, _destinationZoom);
      }
    } catch (e) {
      debugPrint('현재 투어 정보 확인 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        NaverMapView(
          onMapReady: (controller) async {
            _mapController = controller;
            mapControllerCompleter.complete(controller);
            await _initializeLocation();
          },
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
                          decoration: const BoxDecoration(
                            color: Color(0xffEFF0F2),
                            borderRadius: BorderRadius.all(Radius.circular(2)),
                          ),
                          height: 4,
                          width: 80,
                          margin: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.w, vertical: 28.h),
                      child: _buildStepWidget(),
                    ),
                  ),
                ],
              ),
            );
          },
        )
      ]),
    );
  }

  Widget _buildStepWidget() {
    switch (_step) {
      case MapStep.pick:
        return PickView(onDrawDestination: _onDrawDestination);
      case MapStep.confirm:
        return ConfirmView(
          selectedLocation: _selectedLocation,
          onConfirmDestination: _onConfirmDestination,
          onRedrawDestination: _onRedrawDestination,
        );
      case MapStep.navigation:
        return NavigationView(
          selectedLocation: _selectedLocation,
          distance: _distance,
          duration: _duration,
          onEndNavigation: _onEndNavigation,
          targetInfo: mapViewModel.getTargetInfo(),
        );
    }
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
