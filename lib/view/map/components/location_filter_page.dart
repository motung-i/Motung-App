import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:motunge/bloc/map/map_bloc.dart';
import 'package:motunge/bloc/map/map_event.dart';
import 'package:motunge/bloc/map/map_state.dart';
import 'package:motunge/model/map/districts_response.dart';
import 'package:motunge/view/component/region_tab_bar.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';
import 'package:motunge/utils/error_handler.dart';

class LocationFilterPage extends StatefulWidget {
  const LocationFilterPage({
    super.key,
    this.initialSelectedRegions,
    this.initialSelectedDistricts,
  });

  final List<String>? initialSelectedRegions;
  final List<String>? initialSelectedDistricts;

  @override
  State<LocationFilterPage> createState() => _LocationFilterPageState();
}

class _LocationFilterPageState extends State<LocationFilterPage> {
  final TextEditingController _searchController = TextEditingController();

  List<String> _tabList = [];
  String _selectedTab = '';
  bool _isLoading = true;

  final RegionTabBarController _tabController = RegionTabBarController();
  int _currentTabIndex = 0;

  final Set<String> _selectedRegions = <String>{};
  final Map<String, String> _selectedDistricts = <String, String>{};
  final Set<String> _selectedSpecialRegions = <String>{};

  final Map<String, DistrictsResponse> _districtsCache = {};
  final Set<String> _requestingRegions = <String>{};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _initializeSelections();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapBloc>().add(const MapRegionsRequested());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _districtsCache.clear();
    super.dispose();
  }

  void _initializeSelections() {
    if (widget.initialSelectedRegions != null) {
      _selectedRegions.addAll(widget.initialSelectedRegions!);
    }
    if (widget.initialSelectedDistricts != null) {
      for (final district in widget.initialSelectedDistricts!) {
        if (widget.initialSelectedRegions != null) {
          for (final region in widget.initialSelectedRegions!) {
            if (_districtsCache.containsKey(region)) {
              final districts = _districtsCache[region]!;
              for (final districtType in districts.districts) {
                if (districtType.district.contains(district)) {
                  _selectedDistricts[district] = region;
                  break;
                }
              }
            }
          }
        }
      }
    }
  }

  void _preloadTabData(String region) {
    if (!_districtsCache.containsKey(region) &&
        !_requestingRegions.contains(region)) {
      _requestingRegions.add(region);
      context.read<MapBloc>().add(MapDistrictsRequested(region: region));
    }
  }

  void _preloadAdjacentTabs(int currentIndex) {
    if (currentIndex > 0) {
      _preloadTabData(_tabList[currentIndex - 1]);
    }

    if (currentIndex < _tabList.length - 1) {
      _preloadTabData(_tabList[currentIndex + 1]);
    }
  }

  void _onSearchChanged(String value) {
    setState(() {});
  }

  void _toggleRegionSelection(String region) {
    setState(() {
      if (_selectedTab == '기타') {
        if (_selectedSpecialRegions.contains(region)) {
          _selectedSpecialRegions.remove(region);
        } else {
          _selectedSpecialRegions.add(region);
        }
      } else {
        if (_selectedRegions.contains(region)) {
          _selectedRegions.remove(region);
        } else {
          _selectedRegions.add(region);
          _selectedDistricts.removeWhere(
              (district, districtRegion) => districtRegion == region);
        }
      }
    });
  }

  void _toggleDistrictSelection(String district) {
    setState(() {
      if (_selectedTab == '기타') {
        if (_selectedSpecialRegions.contains(district)) {
          _selectedSpecialRegions.remove(district);
        } else {
          _selectedSpecialRegions.add(district);
        }
      } else {
        if (_selectedDistricts.containsKey(district)) {
          _selectedDistricts.remove(district);
        } else {
          _selectedDistricts[district] = _selectedTab;
          _selectedRegions.remove(_selectedTab);
        }
      }
    });
  }

  void _removeSelectedItem(String item) {
    setState(() {
      _selectedRegions.remove(item);
      _selectedSpecialRegions.remove(item);
      _selectedDistricts.remove(item);
    });
  }

  void _applyFilter() {
    List<String> regions = [];
    List<String> districts = [];

    regions.addAll(_selectedRegions);
    regions.addAll(_selectedSpecialRegions);
    districts.addAll(_selectedDistricts.keys);

    Navigator.of(context).pop({
      'regions': regions,
      'districts': districts,
    });
  }

  bool _hasSelectedItems() {
    return _selectedRegions.isNotEmpty ||
        _selectedDistricts.isNotEmpty ||
        _selectedSpecialRegions.isNotEmpty;
  }

  List<String> _filterRegionsBySearch(List<String> regions) {
    if (_searchController.text.isEmpty) return regions;

    final searchText = _searchController.text.toLowerCase();
    return regions
        .where((region) => region.toLowerCase().contains(searchText))
        .toList();
  }

  void _onTabChanged(int index, String region) {
    setState(() {
      _currentTabIndex = index;
      _selectedTab = region;
    });

    _preloadAdjacentTabs(index);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MapBloc, MapBlocState>(
      listener: (context, state) {
        if (state is MapError) {
          ErrorHandler.showErrorSnackBar(context, state.message);
          setState(() {
            _isLoading = false;
          });
        } else if (state is MapRegionsLoaded) {
          setState(() {
            _tabList = state.regions.regions;
            if (_tabList.isNotEmpty) {
              _selectedTab = _tabList.first;
              _currentTabIndex = 0;
              _preloadTabData(_selectedTab);
            }
            _isLoading = false;
          });
        } else if (state is MapDistrictsLoaded) {
          _districtsCache[state.region] = state.districts;
          _requestingRegions.remove(state.region);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildSearchBar(),
              if (_tabList.isNotEmpty)
                RegionTabBarWithController(
                  regions: _tabList,
                  controller: _tabController,
                  initialIndex: _currentTabIndex,
                  onTabChanged: _onTabChanged,
                  unselectedLabelColor: AppColors.black,
                  showTabBarView: false,
                ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildMainContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBackButton(),
          _buildTitle(),
          _buildApplyButton(),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Icon(
        Icons.arrow_back_ios,
        size: 24.w,
        color: AppColors.black,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      '필터',
      style: GlobalFontDesignSystem.m3Semi.copyWith(
        color: AppColors.black,
      ),
    );
  }

  Widget _buildApplyButton() {
    return GestureDetector(
      onTap: _applyFilter,
      child: Text(
        '적용',
        style: GlobalFontDesignSystem.m3Semi.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 20.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: GlobalFontDesignSystem.m3Regular.copyWith(
                color: AppColors.grey600,
              ),
              decoration: _buildSearchInputDecoration(),
              onChanged: _onSearchChanged,
            ),
          ),
          SizedBox(width: 8.w),
          _buildSearchIcon(),
        ],
      ),
    );
  }

  InputDecoration _buildSearchInputDecoration() {
    return InputDecoration(
      hintText: '검색어를 입력하세요',
      hintStyle: GlobalFontDesignSystem.m3Regular.copyWith(
        color: AppColors.grey600,
      ),
      border: InputBorder.none,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSearchIcon() {
    return SvgPicture.asset(
      "assets/images/search.svg",
      width: 24.w,
      height: 24.h,
      colorFilter: ColorFilter.mode(
        AppColors.grey500,
        BlendMode.srcIn,
      ),
    );
  }

  Widget _buildMainContent() {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // 스와이프 속도가 일정 임계값 이상일 때만 탭 전환
        const int velocityThreshold = 200;
        if (_tabList.isEmpty) return;

        final velocity = details.primaryVelocity ?? 0;

        // 왼쪽으로 스와이프(다음 탭)
        if (velocity < -velocityThreshold &&
            _currentTabIndex < _tabList.length - 1) {
          _tabController.animateToTab(_currentTabIndex + 1);
        }

        // 오른쪽으로 스와이프(이전 탭)
        if (velocity > velocityThreshold && _currentTabIndex > 0) {
          _tabController.animateToTab(_currentTabIndex - 1);
        }
      },
      child: Column(
        children: [
          Expanded(child: _buildTabContent()),
          if (_hasSelectedItems()) _buildSelectedFilters(),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return _buildTabPage(_selectedTab);
  }

  Widget _buildTabPage(String tab) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          _buildRegionContent(tab),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildRegionContent(String region) {
    // 캐시된 데이터가 있으면 즉시 표시
    if (_districtsCache.containsKey(region)) {
      final districtsResponse = _districtsCache[region]!;
      return _buildDistrictsContent(districtsResponse, region);
    }

    // 캐시된 데이터가 없으면 로딩하고 BlocBuilder로 상태 관리
    _preloadTabData(region);

    return BlocBuilder<MapBloc, MapBlocState>(
      builder: (context, state) {
        if (state is MapLoading) {
          return _buildLoadingWidget();
        }

        if (_districtsCache.containsKey(region)) {
          final districtsResponse = _districtsCache[region]!;
          return _buildDistrictsContent(districtsResponse, region);
        }

        return _buildEmptyWidget(region);
      },
    );
  }

  Widget _buildDistrictsContent(
      DistrictsResponse districtsResponse, String region) {
    if (districtsResponse.districts.isEmpty) {
      return _buildEmptyWidget(region);
    }

    return Column(
      children: [
        ...districtsResponse.districts.asMap().entries.map((entry) {
          final index = entry.key;
          final districtType = entry.value;
          final isLast = index == districtsResponse.districts.length - 1;

          return Column(
            children: [
              _buildRegionSection(
                districtType.type,
                districtType.district,
                isDistrict: true,
              ),
              if (!isLast) SizedBox(height: 20.h),
            ],
          );
        }),
        if (region != '기타') ...[
          SizedBox(height: 20.h),
          _buildEntireRegionChip(region),
        ],
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyWidget(String region) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Text(
          '$region 지역 정보가 없습니다.',
          style: GlobalFontDesignSystem.m3Regular.copyWith(
            color: AppColors.grey600,
          ),
        ),
      ),
    );
  }

  Widget _buildRegionSection(String title, List<String> regions,
      {bool isDistrict = false}) {
    final filteredRegions = _filterRegionsBySearch(regions);
    if (filteredRegions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle(title),
        _buildRegionChips(filteredRegions, isDistrict: isDistrict),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 6.h),
      child: Text(
        title,
        style: GlobalFontDesignSystem.labelRegular.copyWith(
          color: AppColors.grey400,
        ),
      ),
    );
  }

  Widget _buildRegionChips(List<String> regions, {bool isDistrict = false}) {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children:
          regions.map((item) => _buildRegionChip(item, isDistrict)).toList(),
    );
  }

  Widget _buildRegionChip(String item, bool isDistrict) {
    bool isSelected;

    if (_selectedTab == '기타') {
      isSelected = _selectedSpecialRegions.contains(item);
    } else if (isDistrict) {
      isSelected = _selectedDistricts.containsKey(item);
    } else {
      bool hasSelectedDistricts = _selectedDistricts.values.contains(item);
      isSelected = _selectedRegions.contains(item) && !hasSelectedDistricts;
    }

    return GestureDetector(
      onTap: () => isDistrict
          ? _toggleDistrictSelection(item)
          : _toggleRegionSelection(item),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.grey100,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          item,
          style: GlobalFontDesignSystem.m3Regular.copyWith(
            color: isSelected ? Colors.white : AppColors.grey800,
          ),
        ),
      ),
    );
  }

  Widget _buildEntireRegionChip(String region) {
    bool hasSelectedDistricts = _selectedDistricts.values.contains(region);
    final isSelected =
        _selectedRegions.contains(region) && !hasSelectedDistricts;

    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => _toggleRegionSelection(region),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.grey100,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            '$region 전체',
            style: GlobalFontDesignSystem.m3Regular.copyWith(
              color: isSelected ? Colors.white : AppColors.grey800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedFilters() {
    final allSelected = [
      ..._selectedRegions,
      ..._selectedSpecialRegions,
      ..._selectedDistricts.keys
    ];
    const int maxDisplayItems = 4;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.grey100,
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: allSelected
                    .take(maxDisplayItems)
                    .map(_buildSelectedFilterChip)
                    .toList(),
              ),
            ),
          ),
          SizedBox(height: 28.h),
        ],
      ),
    );
  }

  Widget _buildSelectedFilterChip(String item) {
    return Container(
      margin: EdgeInsets.only(right: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item,
            style: GlobalFontDesignSystem.m3Regular.copyWith(
              color: AppColors.grey600,
            ),
          ),
          SizedBox(width: 2.w),
          GestureDetector(
            onTap: () => _removeSelectedItem(item),
            child: Icon(
              Icons.close,
              size: 18.w,
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
}
