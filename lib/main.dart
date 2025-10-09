import 'package:aplicacion_ventas/core/theme/app_theme.dart';
import 'package:aplicacion_ventas/presentation/pages/cart_page.dart';
import 'package:aplicacion_ventas/presentation/pages/home_page.dart';
import 'package:aplicacion_ventas/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Aplicación de Ventas',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          routes: {
            LoginPage.routeName: (context) => const LoginPage(),
            HomePage.routeName: (context) => const HomePage(),
            CartPage.routeName: (context) => const CartPage(),
          },
          initialRoute: LoginPage.routeName,
        );
      },
    );
  }
}
