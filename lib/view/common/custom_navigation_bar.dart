import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFF5F6F8),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NavBarItem(
            icon: 'assets/images/home',
            label: '홈',
            isSelected: _calculateSelectedIndex(context) == 0,
            onTap: () => context.go('/home'),
          ),
          _NavBarItem(
            icon: 'assets/images/map',
            label: '지도',
            isSelected: _calculateSelectedIndex(context) == 1,
            onTap: () => context.go('/map'),
          ),
          _NavBarItem(
            icon: 'assets/images/review',
            label: '리뷰',
            isSelected: _calculateSelectedIndex(context) == 2,
            onTap: () => context.go('/review'),
          ),
          _NavBarItem(
            icon: 'assets/images/profile',
            label: '마이',
            isSelected: _calculateSelectedIndex(context) == 3,
            onTap: () => context.go('/profile'),
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String path = GoRouterState.of(context).uri.path;
    if (path.startsWith('/home')) return 0;
    if (path.startsWith('/map')) return 1;
    if (path.startsWith('/review')) return 2;
    if (path.startsWith('/profile')) return 3;
    return 0;
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              '$icon${isSelected ? '-checked' : ''}.svg',
              width: 24,
              height: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF125CED)
                    : const Color(0xFFA5A6A9),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
