// lib/main.dart
import 'package:flutter/material.dart';
import 'package:dwaya_flutter/theme/app_theme.dart';
import 'package:dwaya_flutter/router.dart';

void main() {
  runApp(const DwayaApp());
}

class DwayaApp extends StatelessWidget {
  const DwayaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dwaya.tn',
      theme: AppTheme.lightTheme, // Applique le thème défini
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
    );
  }
}
