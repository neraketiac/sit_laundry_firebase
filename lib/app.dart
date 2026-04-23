import 'package:flutter/material.dart';
import 'routes/app_router.dart';

/// Global key to allow rebuilding MyApp from anywhere (e.g. dark mode toggle)
final GlobalKey<MyAppState> myAppKey = GlobalKey<MyAppState>();

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
  Widget build(BuildContext context) {
    return MaterialApp(
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
            surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
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
    );
  }
}
