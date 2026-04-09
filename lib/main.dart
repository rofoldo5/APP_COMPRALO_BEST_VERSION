import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const SmartCartApp());
_initServices();
}

Future<void> _initServices() async {
  await initializeDateFormatting('es', null);
  await HiveService.init();
  await NotificationService.init();
}

class SmartCartApp extends StatelessWidget {
  const SmartCartApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compralo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF667eea),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}