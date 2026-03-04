import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class KadamTextField extends StatelessWidget {
  final String hint;
  final IconData? icon; // Made optional as per new design
  final bool obscureText;
  final ValueChanged<String> onChanged;

  const KadamTextField({
    super.key,
    required this.hint,
    this.icon,
    required this.onChanged,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withOpacity(0.5), width: 1),
      ),
      child: TextField(
        obscureText: obscureText,
        onChanged: onChanged,
        style: const TextStyle(
          color: AppColors.text,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.hint),
          prefixIcon: icon != null ? Icon(icon, color: AppColors.hint) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
