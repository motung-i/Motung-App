import 'package:flutter/material.dart';
import 'package:motunge/view/common/custom_navigation_bar.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }
} 