import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:motunge/dataSource/map.dart';
import 'package:motunge/model/map/districts_response.dart';
import 'package:motunge/view/component/app_tab_bar.dart';
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
  // ============ Data Sources ============
  final MapDataSource _mapDataSource = MapDataSource();

  // ============ Controllers ============
  final TextEditingController _searchController = TextEditingController();

  // ============ State Variables ============
  List<String> _tabList = [];
  String _selectedTab = '';
  bool _isLoading = true;

  Set<String> _selectedRegions = <String>{};
  Set<String> _selectedDistricts = <String>{};

  // Future 캐싱을 위한 Map
  final Map<String, Future<DistrictsResponse>> _districtsCache = {};

  // ============ Lifecycle Methods ============
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _districtsCache.clear(); // 캐시 정리
    super.dispose();
  }

  // ============ Data Management Methods ============
  Future<void> _initializeData() async {
    try {
      final regionsResponse = await _mapDataSource.getRegions();
      _tabList = regionsResponse.regions;

      if (_tabList.isNotEmpty) {
        _selectedTab = _tabList.first;
        // 첫 번째 탭의 데이터를 미리 로드
        _preloadTabData(_selectedTab);
      }

      _initializeSelections();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      ErrorHandler.showAppErrorSnackBar(
        context,
        AppError.fromException(e),
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initializeSelections() {
    if (widget.initialSelectedRegions != null) {
      _selectedRegions.addAll(widget.initialSelectedRegions!);
    }
    if (widget.initialSelectedDistricts != null) {
      _selectedDistricts.addAll(widget.initialSelectedDistricts!);
    }
  }

  void _preloadTabData(String region) {
    _districtsCache.putIfAbsent(
      region,
      () => _mapDataSource.getDistricts(region),
    );
  }

  // ============ Event Handlers ============
  void _onTabSelected(int index) {
    setState(() {
      _selectedTab = _tabList[index];
    });

    // 현재 탭과 인접한 탭들의 데이터를 미리 로드
    _preloadAdjacentTabs(index);
  }

  void _preloadAdjacentTabs(int currentIndex) {
    // 이전 탭 미리 로드
    if (currentIndex > 0) {
      _preloadTabData(_tabList[currentIndex - 1]);
    }

    // 다음 탭 미리 로드
    if (currentIndex < _tabList.length - 1) {
      _preloadTabData(_tabList[currentIndex + 1]);
    }
  }

  int _getCurrentTabIndex() {
    return _tabList.indexOf(_selectedTab).clamp(0, _tabList.length - 1);
  }

  void _onSearchChanged(String value) {
    setState(() {});
  }

  void _toggleRegionSelection(String region) {
    setState(() {
      if (_selectedRegions.contains(region)) {
        _selectedRegions.remove(region);
      } else {
        _selectedRegions.add(region);
        // 지역을 선택하면 해당 지역의 모든 구/군 선택 해제
        _selectedDistricts
            .removeWhere((district) => _isDistrictInRegion(district, region));
      }
    });
  }

  void _toggleDistrictSelection(String district) {
    setState(() {
      if (_selectedDistricts.contains(district)) {
        _selectedDistricts.remove(district);
      } else {
        _selectedDistricts.add(district);
        // 구/군을 선택하면 해당 지역 선택 해제
        _selectedRegions.remove(_selectedTab);
      }
    });
  }

  void _removeSelectedItem(String item) {
    setState(() {
      _selectedRegions.remove(item);
      _selectedDistricts.remove(item);
    });
  }

  void _applyFilter() {
    Navigator.of(context).pop({
      'regions': _selectedRegions.toList(),
      'districts': _selectedDistricts.toList(),
    });
  }

  // ============ Helper Methods ============
  bool _hasSelectedItems() {
    return _selectedRegions.isNotEmpty || _selectedDistricts.isNotEmpty;
  }

  bool _isDistrictInRegion(String district, String region) {
    // 실제로는 API 응답을 통해 확인해야 하지만,
    // 여기서는 단순한 로직으로 처리
    return true; // 임시 구현
  }

  List<String> _filterRegionsBySearch(List<String> regions) {
    if (_searchController.text.isEmpty) return regions;

    final searchText = _searchController.text.toLowerCase();
    return regions
        .where((region) => region.toLowerCase().contains(searchText))
        .toList();
  }

  // ============ UI Building Methods ============
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildSearchBar(),
            if (_tabList.isNotEmpty)
              DefaultTabController(
                length: _tabList.length,
                initialIndex: _getCurrentTabIndex(),
                child: AppTabBar(
                  tabs: _tabList,
                  onTap: _onTabSelected,
                  unselectedLabelColor: AppColors.black,
                  indicatorSize: TabBarIndicatorSize.label,
                ),
              ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildMainContent(),
            ),
          ],
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
    return Column(
      children: [
        Expanded(child: _buildTabContent()),
        if (_hasSelectedItems()) _buildSelectedFilters(),
      ],
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
    // 캐시에서 Future를 가져오거나 새로 생성
    final cachedFuture = _districtsCache.putIfAbsent(
      region,
      () => _mapDataSource.getDistricts(region),
    );

    return FutureBuilder<DistrictsResponse>(
      future: cachedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildEmptyWidget(region);
        }

        final districtsResponse = snapshot.data!;
        if (districtsResponse.districts.isEmpty) {
          return _buildEmptyWidget(region);
        }

        return Column(
          children: [
            // Type별로 구분된 섹션들
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
            }).toList(),

            // 전체 지역 선택 칩 (기타 탭이 아닌 경우에만)
            if (region != '기타') ...[
              SizedBox(height: 20.h),
              _buildEntireRegionChip(region),
            ],
          ],
        );
      },
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
    final bool isSelected = isDistrict
        ? _selectedDistricts.contains(item)
        : _selectedRegions.contains(item);

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
    final isSelected = _selectedRegions.contains(region);

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
    final allSelected = [..._selectedRegions, ..._selectedDistricts];
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
