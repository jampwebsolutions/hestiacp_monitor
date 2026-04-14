import 'package:flutter/material.dart';
import '../../models/server_model.dart';

class StatsTab extends StatelessWidget {
  final ServerModel server;
  final String uptime;
  final String loadAverage;
  final bool isLoading;

  const StatsTab({
    super.key,
    required this.server,
    required this.uptime,
    required this.loadAverage,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.analytics, size: 80, color: Colors.blueAccent),
          const SizedBox(height: 20),
          Text(
            server.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildStatCard('Uptime', '$uptime ', Icons.timer),
          _buildStatCard('Load Average', '$loadAverage ', Icons.speed),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent, size: 30),
        // Ο Τίτλος (π.χ. Uptime) στην πάνω σειρά
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        // Η Τιμή (π.χ. 14 μέρες...) στην κάτω σειρά
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
