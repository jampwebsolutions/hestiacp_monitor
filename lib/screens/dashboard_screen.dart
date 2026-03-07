import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My VPS Servers'),
        centerTitle: true,
        elevation: 2,
      ),
      body: const Center(
        child: Text(
          'Εδώ θα μπουν οι 3 VPS μας! 🚀',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
