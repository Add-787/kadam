import 'package:flutter/material.dart';
import '../../../../core/presentation/theme/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 30),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C20).withOpacity(0.9), // Slightly transparent dark
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Home Tab (Selected - Pill Shape)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.home_filled, color: Colors.black, size: 24),
                SizedBox(width: 8),
                Text(
                  'Home',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Other Tabs (Icon Only)
          _buildNavItem(Icons.group_outlined),
          _buildNavItem(Icons.calendar_today_outlined), // This will navigate to History
          _buildNavItem(Icons.settings_outlined),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
        color: Colors.black.withOpacity(0.3),
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}
