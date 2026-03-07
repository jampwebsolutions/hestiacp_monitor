import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const HestiaMonitorApp());
}

class HestiaMonitorApp extends StatelessWidget {
  const HestiaMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HestiaCP Monitor',
      debugShowCheckedModeBanner: false, // Κρύβει το ενοχλητικό banner "DEBUG"
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home:
          const DashboardScreen(), // Αυτή η οθόνη δεν υπάρχει ακόμα, θα την φτιάξουμε τώρα!
    );
  }
}
