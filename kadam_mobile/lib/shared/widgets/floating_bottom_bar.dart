import 'package:flutter/material.dart';

/// A floating bottom navigation bar with animations and shadow
///
/// Features:
/// - Primary color background
/// - Smooth animations on tap
/// - Elevated with shadow effect
/// - Responsive to theme changes
class FloatingBottomBar extends StatefulWidget {
  /// Current selected index
  final int currentIndex;

  /// Callback when an item is tapped
  final ValueChanged<int> onTap;

  const FloatingBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<FloatingBottomBar> createState() => _FloatingBottomBarState();
}

class _FloatingBottomBarState extends State<FloatingBottomBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _tappedIndex = -1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    setState(() {
      _tappedIndex = index;
    });
    _animationController.forward().then((_) {
      _animationController.reverse().then((_) {
        widget.onTap(index);
        setState(() {
          _tappedIndex = -1;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
      child: Material(
        elevation: 8,
        shadowColor: colorScheme.shadow.withOpacity(0.3),
        borderRadius: BorderRadius.circular(28),
        color: colorScheme.primary,
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_rounded,
                colorScheme: colorScheme,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.people_rounded,
                colorScheme: colorScheme,
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.emoji_events_rounded,
                colorScheme: colorScheme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required ColorScheme colorScheme,
  }) {
    final isSelected = widget.currentIndex == index;
    final isTapped = _tappedIndex == index;

    return Expanded(
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isTapped ? _scaleAnimation.value : 1.0,
            child: child,
          );
        },
        child: InkWell(
          onTap: () => _handleTap(index),
          borderRadius: BorderRadius.circular(16),
          splashColor: colorScheme.onPrimary.withOpacity(0.2),
          highlightColor: colorScheme.onPrimary.withOpacity(0.1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: EdgeInsets.all(isSelected ? 12 : 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.onPrimary.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onPrimary.withOpacity(0.6),
                  size: isSelected ? 32 : 30,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}