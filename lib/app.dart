import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'routes/app_router.dart';
import 'core/widgets/version_check_overlay.dart';

/// Global key to allow rebuilding MyApp from anywhere (e.g. dark mode toggle)
final GlobalKey<MyAppState> myAppKey = GlobalKey<MyAppState>();

/// Navigator key — preserves navigation stack when MyApp rebuilds (e.g. dark mode)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  bool _isDark = false;

  void setDarkMode(bool value) {
    if (_isDark == value) return;
    setState(() => _isDark = value);
  }

  @override
  void initState() {
    super.initState();
    _disableBackGesture();
  }

  /// Disable browser back gesture (swipe back) to prevent accidental navigation
  void _disableBackGesture() {
    // Push a new history state to prevent browser back navigation
    web.window.history.pushState(null, '', web.window.location.href);

    // Listen for popstate events (back button or swipe back)
    web.window.onPopState.listen((event) {
      // Push state again to prevent going back
      web.window.history.pushState(null, '', web.window.location.href);
    });
  }

  @override
  Widget build(BuildContext context) {
    return VersionCheckOverlay(
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData(
          brightness: Brightness.light,
          colorSchemeSeed: Colors.deepPurple,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorSchemeSeed: Colors.deepPurple,
          scaffoldBackgroundColor: const Color(0xFF121212),
          cardColor: const Color(0xFF2A2A2A),
          dialogTheme: const DialogThemeData(
            backgroundColor: Color(0xFF1F1F1F),
          ),
          cardTheme: const CardThemeData(
            color: Color(0xFF2A2A2A),
            surfaceTintColor: Colors.transparent,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E1E1E),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          menuTheme: MenuThemeData(
            style: MenuStyle(
              backgroundColor: const WidgetStatePropertyAll(Color(0xFF232323)),
              surfaceTintColor:
                  const WidgetStatePropertyAll(Colors.transparent),
            ),
          ),
          menuButtonTheme: const MenuButtonThemeData(
            style: ButtonStyle(
              foregroundColor: WidgetStatePropertyAll(Colors.white),
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white70),
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: Colors.tealAccent,
          ),
        ),
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
