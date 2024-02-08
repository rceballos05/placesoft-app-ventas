import 'package:app_ventas/pages/home_page.dart';
import 'package:flutter/material.dart';
//import 'package:app_ventas/pages/login_page.dart';
import 'package:app_ventas/router/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Ventas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black87),
        useMaterial3: true,
      ),
      initialRoute: HomePage.id,
      routes: customRoutes,
    );
  }
}
