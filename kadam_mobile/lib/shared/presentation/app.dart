import 'package:flutter/material.dart';
import 'package:kadam_mobile/core/localization/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/navigation_helper.dart';
import '../../core/theme/app_theme.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';

/// The main application widget
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  String? _initialRoute;

  @override
  void initState() {
    super.initState();
    _determineInitialRoute();
  }

  Future<void> _determineInitialRoute() async {
    // Use NavigationHelper to determine initial route based on guards
    final route = await NavigationHelper.determineInitialRoute(context);

    if (mounted) {
      setState(() {
        _initialRoute = route;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while determining initial route
    if (_initialRoute == null) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return MaterialApp(
          // App configuration
          restorationScopeId: 'app',
          debugShowCheckedModeBanner: false,

          // Localization
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English
          ],
          onGenerateTitle: (context) =>
              AppLocalizations.of(context)?.appTitle ?? AppConstants.appName,

          // Theme
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settingsProvider.themeMode,

          // Routing
          onGenerateRoute: AppRoutes.onGenerateRoute,
          initialRoute: _initialRoute,
        );
      },
    );
  }
}
