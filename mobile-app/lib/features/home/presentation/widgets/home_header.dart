import 'package:flutter/material.dart';
import '../../../../core/presentation/theme/app_colors.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final String? profileImageUrl;

  const HomeHeader({super.key, required this.userName, this.profileImageUrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bolt, color: AppColors.primary, size: 32),
            const SizedBox(width: 8),
            Text(
              'Hi $userName',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.surface,
            backgroundImage: profileImageUrl != null
                ? NetworkImage(profileImageUrl!)
                : null,
            child: profileImageUrl == null
                ? const Icon(Icons.person, color: AppColors.primary)
                : null,
          ),
        ),
      ],
    );
  }
}
