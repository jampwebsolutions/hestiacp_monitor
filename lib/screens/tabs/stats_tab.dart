import 'package:flutter/material.dart';
import '../../models/server_model.dart';

/// A tab view that displays high-level server statistics.
/// Shows the server's name, uptime, and load average in a clean card layout.
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
    // Show a loading indicator while data is being fetched from the server.
    if (isLoading) return const Center(child: CircularProgressIndicator());

    // Render the main statistics layout once data is available.
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

  /// Helper method to construct a stylized card for individual metrics.
  /// Takes a [title] (e.g., 'Uptime'), a [value] to display, and an [icon].
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent, size: 30),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
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
