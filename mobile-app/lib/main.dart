import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kadam/firebase_options.dart';
// import 'firebase_options.dart'; // Run 'flutterfire configure' to generate this file
import 'core/config/injection.dart';
import 'core/config/router.dart';
import 'core/config/work_manager_config.dart';
import 'core/presentation/theme/app_colors.dart';
import 'features/steps/presentation/bloc/steps_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (Uncomment once firebase_options.dart is generated)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  configureDependencies();

  // Initialize and register background sync
  await WorkManagerConfig.initialize();
  await WorkManagerConfig.registerPeriodicTask();

  runApp(
    BlocProvider(
      create: (context) => getIt<StepsBloc>()..add(StepsStarted()),
      child: const KadamApp(),
    ),
  );
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
