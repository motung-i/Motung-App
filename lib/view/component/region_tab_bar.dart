import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:motunge/view/component/app_tab_bar.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';

class RegionTabBar extends StatefulWidget {
  const RegionTabBar({
    super.key,
    required this.regions,
    this.initialIndex = 0,
    this.onTabChanged,
    this.isLoading = false,
    this.height,
    this.labelColor,
    this.unselectedLabelColor,
    this.indicatorColor,
    this.children,
    this.showTabBarView = true,
  });

  final List<String> regions;
  final int initialIndex;
  final Function(int index, String region)? onTabChanged;
  final bool isLoading;
  final double? height;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final Color? indicatorColor;
  final List<Widget>? children;
  final bool showTabBarView;

  @override
  State<RegionTabBar> createState() => _RegionTabBarState();
}

class _RegionTabBarState extends State<RegionTabBar>
    with TickerProviderStateMixin
    implements RegionTabBarControllerInterface {
  TabController? _tabController;
  bool _isTabControllerReady = false;

  @override
  void initState() {
    super.initState();
    _initializeTabController();
  }

  @override
  void didUpdateWidget(RegionTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.regions.length != widget.regions.length) {
      _initializeTabController();
    }
  }

  @override
  void dispose() {
    _tabController?.removeListener(_onTabControllerChanged);
    _tabController?.dispose();
    super.dispose();
  }

  void _initializeTabController() {
    if (widget.regions.isEmpty) return;

    // 이미 같은 길이의 TabController가 있다면 재사용
    if (_tabController != null &&
        _tabController!.length == widget.regions.length) {
      return;
    }

    _tabController?.removeListener(_onTabControllerChanged);
    _tabController?.dispose();

    final safeIndex = widget.initialIndex.clamp(0, widget.regions.length - 1);

    _tabController = TabController(
      length: widget.regions.length,
      initialIndex: safeIndex,
      vsync: this,
    );

    _tabController!.addListener(_onTabControllerChanged);
    _isTabControllerReady = true;
  }

  void _onTabControllerChanged() {
    if (!_tabController!.indexIsChanging && _isTabControllerReady) {
      final index = _tabController!.index;
      if (index < widget.regions.length) {
        widget.onTabChanged?.call(index, widget.regions[index]);
      }
    }
  }

  @override
  void animateToTab(int index) {
    if (_tabController != null && index < widget.regions.length) {
      _tabController!.animateTo(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return SizedBox(
        height: widget.height ?? 48.h,
        child: Center(
          child: Text(
            '지역 정보를 불러오는 중입니다...',
            style: GlobalFontDesignSystem.m3Regular.copyWith(
              color: AppColors.grey600,
            ),
          ),
        ),
      );
    }

    if (widget.regions.isEmpty) {
      return SizedBox(
        height: widget.height ?? 48.h,
        child: Center(
          child: Text(
            '지역 정보가 없습니다.',
            style: GlobalFontDesignSystem.m3Regular.copyWith(
              color: AppColors.grey600,
            ),
          ),
        ),
      );
    }

    if (_tabController == null) {
      return SizedBox(
        height: widget.height ?? 48.h,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      children: [
        AppTabBar(
          tabs: widget.regions,
          controller: _tabController,
          onTap: (index) =>
              widget.onTabChanged?.call(index, widget.regions[index]),
          height: widget.height ?? 48.h,
          labelColor: widget.labelColor ?? AppColors.primary,
          unselectedLabelColor:
              widget.unselectedLabelColor ?? AppColors.grey800,
          indicatorColor: widget.indicatorColor ?? AppColors.primary,
        ),
        if (widget.showTabBarView && widget.children != null)
          Expanded(
            child: AppTabBarView(
              controller: _tabController,
              children: widget.children!,
            ),
          ),
      ],
    );
  }
}

// RegionTabBar의 상태를 외부에서 제어하기 위한 Controller
abstract class RegionTabBarControllerInterface {
  void animateToTab(int index);
}

class RegionTabBarController {
  RegionTabBarControllerInterface? _controller;

  void _attach(RegionTabBarControllerInterface controller) {
    _controller = controller;
  }

  void _detach() {
    _controller = null;
  }

  void animateToTab(int index) {
    _controller?.animateToTab(index);
  }
}

// Controller를 사용하는 RegionTabBar
class RegionTabBarWithController extends StatefulWidget {
  const RegionTabBarWithController({
    super.key,
    required this.regions,
    required this.controller,
    this.initialIndex = 0,
    this.onTabChanged,
    this.isLoading = false,
    this.height,
    this.labelColor,
    this.unselectedLabelColor,
    this.indicatorColor,
    this.children,
    this.showTabBarView = true,
  });

  final List<String> regions;
  final RegionTabBarController controller;
  final int initialIndex;
  final Function(int index, String region)? onTabChanged;
  final bool isLoading;
  final double? height;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final Color? indicatorColor;
  final List<Widget>? children;
  final bool showTabBarView;

  @override
  State<RegionTabBarWithController> createState() =>
      _RegionTabBarWithControllerState();
}

class _RegionTabBarWithControllerState extends State<RegionTabBarWithController>
    with TickerProviderStateMixin
    implements RegionTabBarControllerInterface {
  TabController? _tabController;
  bool _isTabControllerReady = false;

  @override
  void initState() {
    super.initState();
    widget.controller._attach(this);
    _initializeTabController();
  }

  @override
  void didUpdateWidget(RegionTabBarWithController oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller._detach();
      widget.controller._attach(this);
    }

    if (oldWidget.regions.length != widget.regions.length) {
      _initializeTabController();
    }
  }

  @override
  void dispose() {
    widget.controller._detach();
    _tabController?.removeListener(_onTabControllerChanged);
    _tabController?.dispose();
    super.dispose();
  }

  void _initializeTabController() {
    if (widget.regions.isEmpty) return;

    // 이미 같은 길이의 TabController가 있다면 재사용
    if (_tabController != null &&
        _tabController!.length == widget.regions.length) {
      return;
    }

    _tabController?.removeListener(_onTabControllerChanged);
    _tabController?.dispose();

    final safeIndex = widget.initialIndex.clamp(0, widget.regions.length - 1);

    _tabController = TabController(
      length: widget.regions.length,
      initialIndex: safeIndex,
      vsync: this,
    );

    _tabController!.addListener(_onTabControllerChanged);
    _isTabControllerReady = true;
  }

  void _onTabControllerChanged() {
    if (!_tabController!.indexIsChanging && _isTabControllerReady) {
      final index = _tabController!.index;
      if (index < widget.regions.length) {
        widget.onTabChanged?.call(index, widget.regions[index]);
      }
    }
  }

  @override
  void animateToTab(int index) {
    if (_tabController != null && index < widget.regions.length) {
      _tabController!.animateTo(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return SizedBox(
        height: widget.height ?? 48.h,
        child: Center(
          child: Text(
            '지역 정보를 불러오는 중입니다...',
            style: GlobalFontDesignSystem.m3Regular.copyWith(
              color: AppColors.grey600,
            ),
          ),
        ),
      );
    }

    if (widget.regions.isEmpty) {
      return SizedBox(
        height: widget.height ?? 48.h,
        child: Center(
          child: Text(
            '지역 정보가 없습니다.',
            style: GlobalFontDesignSystem.m3Regular.copyWith(
              color: AppColors.grey600,
            ),
          ),
        ),
      );
    }

    if (_tabController == null) {
      return SizedBox(
        height: widget.height ?? 48.h,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      children: [
        AppTabBar(
          tabs: widget.regions,
          controller: _tabController,
          onTap: (index) =>
              widget.onTabChanged?.call(index, widget.regions[index]),
          height: widget.height ?? 48.h,
          labelColor: widget.labelColor ?? AppColors.primary,
          unselectedLabelColor:
              widget.unselectedLabelColor ?? AppColors.grey800,
          indicatorColor: widget.indicatorColor ?? AppColors.primary,
        ),
        if (widget.showTabBarView && widget.children != null)
          Expanded(
            child: AppTabBarView(
              controller: _tabController,
              children: widget.children!,
            ),
          ),
      ],
    );
  }
}
