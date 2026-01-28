import 'package:flutter/material.dart';
import 'core/config/injection.dart';
import 'core/config/router.dart';
import 'core/presentation/theme/app_colors.dart';

void main() {
  configureDependencies();
  runApp(const KadamApp());
}

class KadamApp extends StatelessWidget {
  const KadamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kadam',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
      ),
      routerConfig: router,
    );
  }
}
