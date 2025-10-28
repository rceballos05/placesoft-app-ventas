import 'package:animated_theme_switcher/animated_theme_switcher.dart'
    hide ThemeModel, ThemeModelInheritedNotifier;
import 'package:aplicacion_ventas/core/theme/app_theme.dart';
import 'package:aplicacion_ventas/core/theme/theme_model.dart';
import 'package:aplicacion_ventas/presentation/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  final themeModel = ThemeModel();

  runApp(
    ThemeModelInheritedNotifier(
      notifier: themeModel,
      child: ThemeProvider(
        initTheme: AppTheme.lightTheme,
        builder: (context, theme) => const ProviderScope(child: MyApp()),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModel = ThemeModel.of(context);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return ThemeProvider(
          initTheme: AppTheme.lightTheme,
          builder: (context, theme) => ThemeSwitchingArea(
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Aplicación de Ventas',
              theme: theme, // <-- aquí se aplica el tema actual
              darkTheme: AppTheme.darkTheme,
              themeMode: themeModel?.themeMode ?? ThemeMode.system,
              routes: AppRouter.routes,
              initialRoute: AppRouter.initialRoute,
            ),
          ),
        );
      },
    );
  }
}
