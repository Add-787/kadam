import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class KadamTextField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool obscureText;
  final ValueChanged<String> onChanged;

  const KadamTextField({
    super.key,
    required this.hint,
    required this.icon,
    required this.onChanged,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        obscureText: obscureText,
        onChanged: onChanged,
        style: const TextStyle(color: AppColors.text),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.hint),
          prefixIcon: Icon(icon, color: AppColors.hint),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
