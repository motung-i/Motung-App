import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
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
  // Map Controllers
  final mapControllerCompleter = Completer<NaverMapController>();
  final DraggableScrollableController sheetController =
      DraggableScrollableController();
  NaverMapController? _mapController;

  // ViewModel
  final mapViewModel = MapViewmodel();

  // Map State
  final List<NOverlay> _overlays = [];
  MapStep _step = MapStep.pick;

  // Location Data
  String _selectedLocation = "서울시 강남구";
  String _distance = "2.5km";
  String _duration = "15분";

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    sheetController.dispose();
    super.dispose();
  }

  // Location Methods
  Future<void> _initializeLocation() async {
    try {
      final permission = await mapViewModel.checkPermission();
      if (!permission) {
        final permissionResult = await mapViewModel.requestPermission();
        if (permissionResult == LocationPermission.denied ||
            permissionResult == LocationPermission.deniedForever) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('위치 권한이 필요합니다.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
          return;
        }
      }

      final serviceEnabled = await mapViewModel.checkServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('위치 서비스를 활성화해주세요.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      final position = await mapViewModel.getCurrentLocation();
      if (_mapController != null && mounted) {
        await _mapController!.updateCamera(
          NCameraUpdate.withParams(
            target: NLatLng(position.latitude, position.longitude),
            zoom: 15,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('위치 정보를 가져오는데 실패했습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Map Drawing Methods
  void _drawPolyline() {
    if (_mapController == null) return;

    final List<NLatLng> coordinates = [
      const NLatLng(37.5665, 126.9780), // 서울시청
      const NLatLng(37.5796, 126.9770), // 경복궁
      const NLatLng(37.5715, 126.9764), // 덕수궁
      const NLatLng(37.5665, 126.9780), // 서울시청 (닫기)
    ];

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

  // Step Control Methods
  void _onDrawDestination() {
    setState(() {
      _step = MapStep.confirm;
      _selectedLocation = "서울시 강남구";
      _distance = "2.5km";
      _duration = "15분";
    });
  }

  void _onRedrawDestination() {
    setState(() {
      _step = MapStep.confirm;
    });
  }

  void _onConfirmDestination() {
    setState(() {
      _step = MapStep.navigation;
    });
  }

  void _onEndNavigation() {
    setState(() {
      _step = MapStep.pick;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        NaverMap(
          options: const NaverMapViewOptions(
            indoorEnable: true,
            locationButtonEnable: false,
            consumeSymbolTapEvents: false,
          ),
          onMapReady: (controller) async {
            _mapController = controller;
            mapControllerCompleter.complete(controller);
            await _initializeLocation();
            _drawPolyline();
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
        return PickView(
          onDrawDestination: _onDrawDestination,
        );
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
        );
    }
  }
}
