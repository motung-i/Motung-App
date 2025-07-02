import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';
import 'package:motunge/dataSource/map.dart';
import 'package:motunge/model/map/districts_response.dart';

class LocationFilterPage extends StatefulWidget {
  final List<String>? initialSelectedRegions;
  final List<String>? initialSelectedDistricts;

  const LocationFilterPage({
    super.key,
    this.initialSelectedRegions,
    this.initialSelectedDistricts,
  });

  @override
  State<LocationFilterPage> createState() => _LocationFilterPageState();
}

class _LocationFilterPageState extends State<LocationFilterPage>
    with TickerProviderStateMixin {
  // Data sources and controllers
  final MapDataSource _mapDataSource = MapDataSource();
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  // State variables
  List<String> _regions = [];
  Map<String, List<String>> _districts = {};
  Set<String> _selectedRegions = {};
  Set<String> _selectedDistricts = {};
  List<String> _tabList = ['기타'];
  List<DistrictType> _districtTypes = [];
  String _selectedTab = '기타';
  bool _isLoading = true;
  final Map<String, String> _districtToRegion = {};

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ============ Initialization Methods ============

  void _initializeData() {
    _tabController = TabController(length: _tabList.length, vsync: this);
    _selectedRegions = (widget.initialSelectedRegions ?? []).toSet();
    _selectedDistricts = (widget.initialSelectedDistricts ?? []).toSet();
    _loadRegionsAndDistricts();
  }

  Future<void> _loadRegionsAndDistricts() async {
    try {
      final regionsResponse = await _mapDataSource.getRegions();

      await _processRegionsData(regionsResponse);
      _updateTabController();

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Failed to load data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _processRegionsData(regionsResponse) async {
    if (regionsResponse.regions.isEmpty) return;

    final uniqueRegions =
        regionsResponse.regions.where((region) => region != '기타').toList();
    _tabList = ['기타', ...uniqueRegions];

    for (String region in regionsResponse.regions) {
      await _loadDistrictsForRegion(region);
    }
  }

  Future<void> _loadDistrictsForRegion(String region) async {
    try {
      final districtsResponse = await _mapDataSource.getDistricts(region);

      if (region == '기타') {
        _districtTypes = districtsResponse.districts;
        _regions.addAll(
            _districtTypes.expand((districtType) => districtType.district));
      }

      _districts[region] =
          districtsResponse.districts.expand((dt) => dt.district).toList();

      for (final district in _districts[region]!) {
        _districtToRegion[district] = region;
      }
    } catch (e) {
      _districts[region] = [];
    }
  }

  void _updateTabController() {
    _tabController.dispose();
    _tabController = TabController(length: _tabList.length, vsync: this);
  }

  List<String> _getRegionsByType(String type) {
    return _districtTypes
        .where((dt) => dt.type == type)
        .expand((dt) => dt.district)
        .toList();
  }

  List<String> _getFilteredRegionsByType(String type) {
    final regions = _getRegionsByType(type);
    if (_searchController.text.isEmpty) return regions;

    final searchText = _searchController.text.toLowerCase();
    return regions
        .where((region) => region.toLowerCase().contains(searchText))
        .toList();
  }

  // ============ Event Handlers ============

  void _toggleRegionSelection(String region) {
    setState(() {
      if (_selectedRegions.contains(region)) {
        _selectedRegions.remove(region);
        _removeDistrictsForRegion(region);
      } else {
        _selectedRegions.add(region);
        _removeDistrictsForRegion(region);
      }
    });
  }

  void _removeDistrictsForRegion(String region) {
    _selectedDistricts.removeWhere(
      (district) => _districts[region]?.contains(district) ?? false,
    );
  }

  void _removeSelectedItem(String item) {
    setState(() {
      _selectedRegions.remove(item);
      _selectedDistricts.remove(item);
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedTab = _tabList[index];
    });
  }

  void _onSearchChanged(String value) {
    setState(() {});
  }

  void _applyFilter() {
    Navigator.of(context).pop({
      'regions': _selectedRegions.toList(),
      'districts': _selectedDistricts.toList(),
    });
  }

  void _toggleDistrictSelection(String district) {
    setState(() {
      if (_selectedDistricts.contains(district)) {
        _selectedDistricts.remove(district);
      } else {
        _selectedDistricts.add(district);
        final region = _districtToRegion[district];
        if (region != null && _selectedRegions.contains(region)) {
          _selectedRegions.remove(region);
        }
      }
    });
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
            _buildTabBar(),
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
        color: DiaryColor.black,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      '필터',
      style: GlobalFontDesignSystem.m3Semi.copyWith(
        color: DiaryColor.black,
      ),
    );
  }

  Widget _buildApplyButton() {
    return GestureDetector(
      onTap: _applyFilter,
      child: Text(
        '적용',
        style: GlobalFontDesignSystem.m3Semi.copyWith(
          color: DiaryColor.globalMainColor,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 20.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: DiaryMainGrey.grey100,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: GlobalFontDesignSystem.m3Regular.copyWith(
                color: DiaryMainGrey.grey600,
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
        color: DiaryMainGrey.grey600,
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
        DiaryMainGrey.grey500,
        BlendMode.srcIn,
      ),
    );
  }

  Widget _buildTabBar() {
    return SizedBox(
      height: 48.h,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: DiaryColor.globalMainColor,
        indicatorWeight: 1.0,
        labelColor: DiaryColor.globalMainColor,
        unselectedLabelColor: DiaryColor.black,
        tabAlignment: TabAlignment.start,
        labelStyle: GlobalFontDesignSystem.m3Semi,
        unselectedLabelStyle: GlobalFontDesignSystem.m3Regular,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: _tabList.map((tab) => Tab(text: tab)).toList(),
        onTap: _onTabSelected,
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

  bool _hasSelectedItems() {
    return _selectedRegions.isNotEmpty || _selectedDistricts.isNotEmpty;
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: _tabList.map(_buildTabPage).toList(),
    );
  }

  Widget _buildTabPage(String tab) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          if (tab == '기타')
            _buildOtherRegionsContent()
          else
            _buildRegionDistrictsContent(tab),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildOtherRegionsContent() {
    return Column(
      children: [
        _buildRegionTypeSection('광역시'),
        SizedBox(height: 20.h),
        _buildRegionTypeSection('특별시'),
        SizedBox(height: 20.h),
        _buildRegionTypeSection('특별자치시'),
      ],
    );
  }

  Widget _buildRegionTypeSection(String type) {
    final regions = _getFilteredRegionsByType(type);
    if (regions.isEmpty) return const SizedBox.shrink();

    return _buildRegionSection(type, regions, isDistrict: false);
  }

  Widget _buildRegionDistrictsContent(String region) {
    return FutureBuilder<DistrictsResponse>(
      future: _mapDataSource.getDistricts(region),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorWidget(region);
        }

        final districtsResponse = snapshot.data!;
        if (districtsResponse.districts.isEmpty) {
          return _buildEmptyWidget(region);
        }

        return _buildRegionDistrictListWrapper(
            region, districtsResponse.districts);
      },
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: const CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorWidget(String region) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Text(
          '$region 지역 정보를 불러올 수 없습니다.',
          style: GlobalFontDesignSystem.m3Regular.copyWith(
            color: DiaryMainGrey.grey600,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(String region) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Text(
          '$region 지역에 구/군 정보가 없습니다.',
          style: GlobalFontDesignSystem.m3Regular.copyWith(
            color: DiaryMainGrey.grey600,
          ),
        ),
      ),
    );
  }

  Widget _buildRegionDistrictListWrapper(
      String region, List<DistrictType> districts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDistrictsList(districts),
        SizedBox(height: 14.h),
        _buildEntireRegionChip(region),
      ],
    );
  }

  Widget _buildDistrictsList(List<DistrictType> districts) {
    return Column(
      children: districts
          .where((districtType) => districtType.district.isNotEmpty)
          .map((districtType) => Column(
                children: [
                  _buildRegionSection(districtType.type, districtType.district,
                      isDistrict: true),
                  SizedBox(height: 20.h),
                ],
              ))
          .toList(),
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

  List<String> _filterRegionsBySearch(List<String> regions) {
    if (_searchController.text.isEmpty) return regions;

    final searchText = _searchController.text.toLowerCase();
    return regions
        .where((region) => region.toLowerCase().contains(searchText))
        .toList();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 6.h),
      child: Text(
        title,
        style: GlobalFontDesignSystem.labelRegular.copyWith(
          color: DiaryMainGrey.grey400,
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
          color:
              isSelected ? DiaryColor.globalMainColor : DiaryMainGrey.grey100,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          item,
          style: GlobalFontDesignSystem.m3Regular.copyWith(
            color: isSelected ? Colors.white : DiaryMainGrey.grey800,
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
            color:
                isSelected ? DiaryColor.globalMainColor : DiaryMainGrey.grey100,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            '$region 전체',
            style: GlobalFontDesignSystem.m3Regular.copyWith(
              color: isSelected ? Colors.white : DiaryMainGrey.grey800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedFilters() {
    final allSelected = [..._selectedRegions, ..._selectedDistricts];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: DiaryMainGrey.grey100,
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
                children:
                    allSelected.take(4).map(_buildSelectedFilterChip).toList(),
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
        color: DiaryMainGrey.grey100,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item,
            style: GlobalFontDesignSystem.m3Regular.copyWith(
              color: DiaryMainGrey.grey600,
            ),
          ),
          SizedBox(width: 2.w),
          GestureDetector(
            onTap: () => _removeSelectedItem(item),
            child: Icon(
              Icons.close,
              size: 18.w,
              color: DiaryMainGrey.grey600,
            ),
          ),
        ],
      ),
    );
  }
}
