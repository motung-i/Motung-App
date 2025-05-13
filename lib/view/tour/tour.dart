import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:motunge/viewModel/map_viewmodel.dart';

class TourPage extends StatefulWidget {
  const TourPage({super.key});

  @override
  State<TourPage> createState() => _TourPageState();
}

class _TourPageState extends State<TourPage> {
  final mapControllerCompleter = Completer<NaverMapController>();
  final mapViewModel = MapViewmodel();
  NaverMapController? _mapController;
  final List<NOverlay> _overlays = [];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

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

  // 예시 좌표 리스트로 폴리라인 그리기
  void _drawPolyline() {
    if (_mapController == null) return;

    // 예시 좌표 리스트
    final List<NLatLng> coordinates = [
      const NLatLng(37.5665, 126.9780), // 서울시청
      const NLatLng(37.5796, 126.9770), // 경복궁
      const NLatLng(37.5715, 126.9764), // 덕수궁
      const NLatLng(37.5665, 126.9780), // 서울시청 (닫기)
    ];

    // 폴리라인 생성
    final polyline = NPolygonOverlay(
      id: 'polyline1',
      coords: coordinates,
      color: const Color(0x20125CED),
      outlineColor: const Color(0xFF125CED),
      outlineWidth: 3,
    );

    // 오버레이 추가
    _overlays.add(polyline);
    _mapController!.addOverlay(polyline);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NaverMap(
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
    );
  }
}