import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:motunge/bloc/map/map_bloc.dart';
import 'package:motunge/bloc/map/map_event.dart';
import 'package:motunge/bloc/map/map_state.dart';
import 'package:motunge/model/map/naver_directions_response.dart';
import 'package:motunge/view/common/custom_navigation_bar.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';

class NavigationGuideView extends StatefulWidget {
  const NavigationGuideView({super.key});

  @override
  State<NavigationGuideView> createState() => _NavigationGuideViewState();
}

class _NavigationGuideViewState extends State<NavigationGuideView> {
  static const double _initialZoom = 15.0;

  final Completer<NaverMapController> _mapControllerCompleter =
      Completer<NaverMapController>();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  NaverMapController? _mapController;
  bool _isLoading = false;
  final List<NOverlay> _overlays = [];

  Position? _currentPosition;
  Direction? _selectedDirection;
  NaverDirectionsResponse? _directionsResponse;

  @override
  void initState() {
    super.initState();
    _initializeNavigation();
  }

  @override
  void dispose() {
    _clearOverlays();
    _mapController?.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  Future<void> _initializeNavigation() async {
    final mapBloc = context.read<MapBloc>();
    _currentPosition = mapBloc.currentPosition;
    _selectedDirection = mapBloc.selectedDirection as Direction?;
    _directionsResponse = mapBloc.directionsResponse;

    if (_currentPosition == null ||
        _selectedDirection == null ||
        _directionsResponse == null) {
      _showErrorSnackBar('경로 정보를 불러올 수 없습니다.');
      return;
    }

    try {
      await _updateMapCamera(
        NLatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        _initialZoom,
      );

      _drawSelectedRoute(_selectedDirection!);
    } catch (e) {
      debugPrint('Error initializing navigation: $e');
      _showErrorSnackBar('네비게이션 초기화에 실패했습니다.');
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

  void _drawSelectedRoute(Direction direction) {
    if (_mapController == null) return;

    _clearOverlays();

    final routePath =
        direction.path.map((coord) => NLatLng(coord[1], coord[0])).toList();

    final routePolyline = NPolylineOverlay(
      id: 'selected_route',
      coords: routePath,
      color: AppColors.globalMainColor,
      width: 5,
    );

    _overlays.add(routePolyline);
    _mapController!.addOverlay(routePolyline);
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

  Future<void> _refreshRoute() async {
    setState(() {
      _isLoading = true;
    });

    try {
      context.read<MapBloc>().add(const MapRouteDataRequested());
    } catch (e) {
      _showErrorSnackBar('경로 새로고침에 실패했습니다.');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getRouteTypeName() {
    if (_selectedDirection == null || _directionsResponse == null) {
      return '선택된 경로';
    }

    if (_selectedDirection == _directionsResponse!.traoptimal) {
      return '실시간 추천';
    } else if (_selectedDirection == _directionsResponse!.traavoidtoll) {
      return '무료 우선';
    }

    return '선택된 경로';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MapBloc, MapBlocState>(
      listener: (context, state) {
        if (state is MapError) {
          _showErrorSnackBar(state.message);
          setState(() {
            _isLoading = false;
          });
        } else if (state is MapRouteDataLoaded) {
          setState(() {
            _directionsResponse = state.directionsResponse;
            _currentPosition = state.currentPosition;
            _isLoading = false;
          });
          if (_selectedDirection != null) {
            _drawSelectedRoute(_selectedDirection!);
          }
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
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
            DraggableScrollableSheet(
              initialChildSize: 0.45,
              minChildSize: 0.45,
              maxChildSize: 0.8,
              controller: _sheetController,
              builder:
                  (BuildContext context, ScrollController scrollController) {
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
                          SizedBox(height: 24.h),
                          BlocBuilder<MapBloc, MapBlocState>(
                            builder: (context, state) {
                              if (_isLoading || state is MapLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.globalMainColor,
                                  ),
                                );
                              } else if (_selectedDirection != null) {
                                return Column(
                                  children: [
                                    _buildRouteHeader(),
                                    SizedBox(height: 20.h),
                                    const Divider(
                                        color: AppColors.grey100, height: 1),
                                    SizedBox(height: 20.h),
                                    _buildRouteGuideList(),
                                  ],
                                );
                              } else {
                                return Center(
                                  child: Text(
                                    '경로 정보를 불러올 수 없습니다.',
                                    style: GlobalFontDesignSystem.labelRegular
                                        .copyWith(
                                      color: AppColors.grey500,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          SizedBox(height: 100.h),
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
      ),
    );
  }

  Widget _buildRouteHeader() {
    if (_selectedDirection == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getRouteTypeName(),
              style: GlobalFontDesignSystem.labelRegular.copyWith(
                color: AppColors.black,
              ),
            ),
            GestureDetector(
              onTap: _refreshRoute,
              child: Text(
                '새로고침',
                style: GlobalFontDesignSystem.labelRegular.copyWith(
                  color: AppColors.grey400,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Text(
              _formatDuration(_selectedDirection!.duration),
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
              _formatDistance(_selectedDirection!.distance),
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
              '통행료 ${_formatPrice(_selectedDirection!.tollFare)}',
              style: GlobalFontDesignSystem.labelRegular.copyWith(
                color: AppColors.black,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              '택시비 ${_formatPrice(_selectedDirection!.taxiFare)}',
              style: GlobalFontDesignSystem.labelRegular.copyWith(
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRouteGuideList() {
    if (_selectedDirection == null) return const SizedBox();

    final guides = _selectedDirection!.guide;

    return Column(
      children: [
        for (int i = 0; i < guides.length; i++) ...[
          _buildRouteGuideItem(
            guides[i],
            isFirst: i == 0,
            isLast: i == guides.length - 1,
          ),
          if (i < guides.length - 1)
            Container(
              margin: EdgeInsets.only(left: 16.w),
              child: const Divider(
                color: AppColors.grey100,
                height: 1,
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildRouteGuideItem(String guide,
      {bool isFirst = false, bool isLast = false}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8.w,
            height: 8.h,
            margin: EdgeInsets.only(top: 6.h, right: 8.w),
            decoration: BoxDecoration(
              color: isFirst ? AppColors.globalMainColor : AppColors.grey300,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              guide,
              style: GlobalFontDesignSystem.m3Regular.copyWith(
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
