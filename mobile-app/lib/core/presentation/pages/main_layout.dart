import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../theme/app_colors.dart';

class MainLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({
    super.key,
    required this.navigationShell,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          widget.navigationShell,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavBar(
              currentIndex: widget.navigationShell.currentIndex,
              onTap: (index) {
                widget.navigationShell.goBranch(
                  index,
                  initialLocation: index == widget.navigationShell.currentIndex,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
