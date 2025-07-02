import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:motunge/model/map/naver_directions_response.dart';
import 'package:motunge/view/common/custom_navigation_bar.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';
import 'package:motunge/viewModel/map_viewmodel.dart';

class RouteSelectionView extends StatefulWidget {
  const RouteSelectionView({super.key});

  @override
  State<RouteSelectionView> createState() => _RouteSelectionViewState();
}

class _RouteSelectionViewState extends State<RouteSelectionView> {
  static const double _initialZoom = 15.0;

  final Completer<NaverMapController> _mapControllerCompleter =
      Completer<NaverMapController>();
  final MapViewmodel _mapViewModel = MapViewmodel();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  NaverMapController? _mapController;
  bool _isLoading = false;
  final List<NOverlay> _overlays = [];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _clearOverlays();
    _mapController?.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final position = await _mapViewModel.initializeCurrentLocation();
      if (position == null) {
        _showErrorSnackBar('위치 정보를 가져올 수 없습니다.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      await _updateMapCamera(
        NLatLng(position.latitude, position.longitude),
        _initialZoom,
      );

      // 뷰모델을 통해 경로 정보 요청
      await _fetchRouteData();
    } catch (e) {
      debugPrint('Error initializing location: $e');
      _showErrorSnackBar('위치 정보를 가져오는데 실패했습니다.');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  Future<void> _updateMapCamera(NLatLng target, double zoom) async {
    final controller = await _mapControllerCompleter.future;
    if (mounted) {
      await controller.updateCamera(
        NCameraUpdate.withParams(target: target, zoom: zoom),
      );
    }
  }

  Future<void> _fetchRouteData() async {
    try {
      final response = await _mapViewModel.fetchAndCacheRouteData();
      if (response != null) {
        _drawRoute(response);
      } else {
        _showErrorSnackBar('경로 정보를 가져오는데 실패했습니다.');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _drawRoute(NaverDirectionsResponse response) {
    if (_mapController == null) return;

    _clearOverlays();

    // 최적 경로 그리기 (파란색)
    final optimalPath = response.traoptimal.path
        .map((coord) => NLatLng(coord[1], coord[0]))
        .toList();

    final optimalPolyline = NPolylineOverlay(
      id: 'optimal_route',
      coords: optimalPath,
      color: AppColors.globalMainColor,
      width: 5,
    );

    _overlays.add(optimalPolyline);
    _mapController!.addOverlay(optimalPolyline);

    // 무료 경로 그리기 (회색, 점선 효과)
    final tollFreePath = response.traavoidtoll.path
        .map((coord) => NLatLng(coord[1], coord[0]))
        .toList();

    final tollFreePolyline = NPolylineOverlay(
      id: 'toll_free_route',
      coords: tollFreePath,
      color: AppColors.grey600,
      width: 3,
    );

    _overlays.add(tollFreePolyline);
    _mapController!.addOverlay(tollFreePolyline);
  }

  void _clearOverlays() {
    if (_mapController != null) {
      for (var overlay in _overlays) {
        _mapController?.deleteOverlay(overlay.info);
      }
      _overlays.clear();
    }
  }

  String _formatDuration(int durationInMillis) {
    final minutes = (durationInMillis / 60000).round();
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours > 0) {
      return '$hours시간 $remainingMinutes분 예정';
    } else {
      return '$remainingMinutes분 예정';
    }
  }

  String _formatDistance(int distanceInMeters) {
    final km = (distanceInMeters / 1000).toStringAsFixed(1);
    return '${km}km';
  }

  String _formatPrice(int price) {
    final formatter = NumberFormat('#,###');
    return '${formatter.format(price)}원';
  }

  void _onStartNavigation(Direction direction) {
    // 선택된 경로를 뷰모델에 저장
    _mapViewModel.selectDirection(direction);
    // 네비게이션 가이드 뷰로 이동
    context.push('/map/navigation-guide');
  }

  @override
  Widget build(BuildContext context) {
    final directionsResponse = _mapViewModel.directionsResponse;

    return Scaffold(
      body: Stack(
        children: [
          // Naver Map
          NaverMap(
            options: const NaverMapViewOptions(
              indoorEnable: true,
              locationButtonEnable: false,
              consumeSymbolTapEvents: false,
            ),
            onMapReady: (controller) {
              _mapController = controller;
              _mapControllerCompleter.complete(controller);
            },
          ),

          // Back Button
          Positioned(
            top: 67.h,
            left: 24.w,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 32.w,
                height: 32.h,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/arrow.svg',
                    width: 16.w,
                    height: 16.h,
                  ),
                ),
              ),
            ),
          ),

          // Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.4,
            maxChildSize: 0.6,
            controller: _sheetController,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.h),
                        Center(
                          child: Container(
                            width: 91.w,
                            height: 3.h,
                            decoration: BoxDecoration(
                              color: AppColors.grey200,
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          ),
                        ),
                        SizedBox(height: 34.h),
                        if (_isLoading)
                          const Center(
                            child: CircularProgressIndicator(),
                          )
                        else if (directionsResponse != null) ...[
                          _RouteCard(
                            routeType: '실시간 추천',
                            duration: _formatDuration(
                                directionsResponse.traoptimal.duration),
                            distance: _formatDistance(
                                directionsResponse.traoptimal.distance),
                            toll: _formatPrice(
                                directionsResponse.traoptimal.tollFare),
                            taxiFare: _formatPrice(
                                directionsResponse.traoptimal.taxiFare),
                            onStartNavigation: () => _onStartNavigation(
                                directionsResponse.traoptimal),
                          ),
                          SizedBox(height: 20.h),
                          const Divider(color: AppColors.grey100, height: 1),
                          SizedBox(height: 20.h),
                          _RouteCard(
                            routeType: '무료 우선',
                            duration: _formatDuration(
                                directionsResponse.traavoidtoll.duration),
                            distance: _formatDistance(
                                directionsResponse.traavoidtoll.distance),
                            toll: _formatPrice(
                                directionsResponse.traavoidtoll.tollFare),
                            taxiFare: _formatPrice(
                                directionsResponse.traavoidtoll.taxiFare),
                            onStartNavigation: () => _onStartNavigation(
                                directionsResponse.traavoidtoll),
                          ),
                        ] else
                          Center(
                            child: Text(
                              '경로 정보를 불러올 수 없습니다.',
                              style:
                                  GlobalFontDesignSystem.labelRegular.copyWith(
                                color: AppColors.grey500,
                              ),
                            ),
                          ),
                        SizedBox(height: 100.h), // 바텀 네비게이션 바 공간
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({
    required this.routeType,
    required this.duration,
    required this.distance,
    required this.toll,
    required this.taxiFare,
    required this.onStartNavigation,
  });

  final String routeType;
  final String duration;
  final String distance;
  final String toll;
  final String taxiFare;
  final VoidCallback onStartNavigation;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                routeType,
                style: GlobalFontDesignSystem.labelRegular.copyWith(
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Text(
                    duration,
                    style: GlobalFontDesignSystem.m2Semi.copyWith(
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(width: 7.w),
                  Container(
                    width: 2,
                    height: 2,
                    decoration: const BoxDecoration(
                      color: AppColors.grey800,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 7.w),
                  Text(
                    distance,
                    style: GlobalFontDesignSystem.m3Regular.copyWith(
                      color: AppColors.grey800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Text(
                    '통행료 $toll',
                    style: GlobalFontDesignSystem.labelRegular.copyWith(
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    '택시비 $taxiFare',
                    style: GlobalFontDesignSystem.labelRegular.copyWith(
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: 16.w),
        ElevatedButton(
          onPressed: onStartNavigation,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.globalMainColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            elevation: 0,
          ),
          child: Text(
            '안내 시작',
            style: GlobalFontDesignSystem.m3Semi.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
