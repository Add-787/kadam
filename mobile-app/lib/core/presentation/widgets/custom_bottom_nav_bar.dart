import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _previousIndex;

  static const _icons = [
    Icons.home_filled,
    Icons.group_outlined,
    Icons.leaderboard_outlined,
    Icons.settings_outlined,
  ];
  static const _labels = ['Home', 'Friends', 'Leaderboards', 'Settings'];

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..value = 1.0;
  }

  @override
  void didUpdateWidget(covariant CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 30),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C20).withOpacity(0.9),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: AppColors.surface, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            offset: const Offset(0, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_controller.value);
          return Row(
            children: List.generate(4, (index) {
              double flex;
              if (index == widget.currentIndex) {
                flex = 1.0 + 1.5 * t; // grows from 1.0 to 2.5
              } else if (index == _previousIndex) {
                flex = 2.5 - 1.5 * t; // shrinks from 2.5 to 1.0
              } else {
                flex = 1.0;
              }
              return Expanded(
                flex: (flex * 100).round(),
                child: _buildNavItem(index, _icons[index], _labels[index], t),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, double t) {
    final isSelected = widget.currentIndex == index;
    final wasSelected = _previousIndex == index;

    // Compute animated opacity for the label
    double labelOpacity;
    if (isSelected) {
      labelOpacity = t;
    } else if (wasSelected) {
      labelOpacity = 1.0 - t;
    } else {
      labelOpacity = 0.0;
    }

    // Compute animated colors
    final bgColor = isSelected
        ? Color.lerp(Colors.black.withOpacity(0.3), AppColors.primary, t)!
        : wasSelected
            ? Color.lerp(AppColors.primary, Colors.black.withOpacity(0.3), t)!
            : Colors.black.withOpacity(0.3);

    final iconColor = isSelected
        ? Color.lerp(Colors.white.withOpacity(0.8), Colors.black, t)!
        : wasSelected
            ? Color.lerp(Colors.black, Colors.white.withOpacity(0.8), t)!
            : Colors.white.withOpacity(0.8);

    final iconSize = isSelected
        ? 22.0 + 2.0 * t
        : wasSelected
            ? 24.0 - 2.0 * t
            : 22.0;

    return GestureDetector(
      onTap: () => widget.onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: (isSelected && t > 0.5) || (wasSelected && t < 0.5)
                ? Colors.transparent
                : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: isSelected && t > 0.3
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4 * t),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: iconSize),
            if (labelOpacity > 0)
              Flexible(
                child: Opacity(
                  opacity: labelOpacity,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
