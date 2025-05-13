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
        },
      ),
    );
  }
}