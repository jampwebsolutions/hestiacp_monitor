import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../models/server_model.dart';
import 'tabs/stats_tab.dart';
import 'tabs/services_tab.dart';
import 'tabs/web_tab.dart';
import 'tabs/mail_tab.dart';

/// The main dashboard for a specific HestiaCP server.
/// Manages navigation between different functional tabs (Stats, Services, Web, Mail) and handles data fetching.
class DashboardScreen extends StatefulWidget {
  final ServerModel server;
  const DashboardScreen({super.key, required this.server});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Tracks the currently selected tab in the BottomNavigationBar.
  int _currentIndex = 0;

  // Indicates whether network requests are currently running.
  bool isLoading = false;

  // State variables to hold fetched server data.
  String uptime = "Unknown";
  String loadAverage = "Unknown";
  Map<String, dynamic> servicesList = {};
  Map<String, dynamic> webDomainsList = {};
  Map<String, dynamic> mailDomainsList = {};

  @override
  void initState() {
    super.initState();
    _refreshAllData();
  }

  /// Generates a time-based SHA256 authentication token.
  /// Combines the bridge secret and a 30-second time window integer to securely authorize API calls.
  String _getAuthToken() {
    String secretKey = widget.server.bridgeSecret;
    int timeWindow =
        (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000) ~/ 30;
    var bytes = utf8.encode("$secretKey$timeWindow");
    return sha256.convert(bytes).toString();
  }

  /// A generic helper method to send secure POST requests to the HestiaCP API bridge.
  /// Packages the generated token, the [cmd], and optional arguments into a JSON payload.
  Future<http.Response?> _makeSecureRequest(
    String cmd, {
    String? arg1,
    String? arg2,
  }) async {
    try {
      return await http.post(
        Uri.parse(widget.server.url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'app_token': _getAuthToken(),
          'cmd': cmd,
          'arg1': arg1 ?? '',
          'arg2': arg2 ?? '',
        }),
      );
    } catch (e) {
      return null;
    }
  }

  /// Refreshes all dashboard data sequentially while showing a loading indicator.
  Future<void> _refreshAllData() async {
    setState(() => isLoading = true);

    await fetchServerStats();
    await fetchServices();
    await fetchWebDomains();
    await fetchMailDomains();

    setState(() => isLoading = false);
  }

  /// Fetches general server statistics (like uptime and load average).
  Future<void> fetchServerStats() async {
    try {
      final token = _getAuthToken();

      final response = await _makeSecureRequest(
        'v-list-sys-info',
        arg1: 'json',
      );

      if (response == null) {
        return;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          uptime = _formatUptime(data['sysinfo']['UPTIME'].toString());
          loadAverage = _formatLoadAverage(
            data['sysinfo']['LOADAVERAGE'].toString(),
          );
        });
      }
    } catch (e) {}
  }

  /// Fetches the list of system services running on the server.
  Future<void> fetchServices() async {
    final response = await _makeSecureRequest(
      'v-list-sys-services',
      arg1: 'json',
    );

    if (response?.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      final sortedKeys = decoded.keys.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      setState(() {
        servicesList = {for (var k in sortedKeys) k: decoded[k]};
      });
    }
  }

  /// Fetches the list of hosted web domains for the authenticated user.
  Future<void> fetchWebDomains() async {
    final response = await _makeSecureRequest(
      'v-list-web-domains',
      arg1: widget.server.username,
      arg2: 'json',
    );

    if (response?.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      final sortedKeys = decoded.keys.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      setState(() {
        webDomainsList = {for (var k in sortedKeys) k: decoded[k]};
      });
    }
  }

  /// Fetches the list of hosted mail domains.
  Future<void> fetchMailDomains() async {
    final response = await _makeSecureRequest(
      'v-list-mail-domains',
      arg1: widget.server.username,
      arg2: 'json',
    );
    if (response?.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response!.body);
      final sortedKeys = decoded.keys.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      setState(() {
        mailDomainsList = {for (var k in sortedKeys) k: decoded[k]};
      });
    }
  }

  /// Restarts a specific system service by its [serviceName].
  /// Shows a SnackBar providing immediate feedback to the user on success or failure.
  Future<void> restartService(String serviceName) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Restarting $serviceName...')));
    final response = await _makeSecureRequest(
      'v-restart-service',
      arg1: serviceName,
    );

    if (response?.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Success!'),
          backgroundColor: Colors.green,
        ),
      );
      _refreshAllData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to restart.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Formats raw uptime minutes into a more readable 'days, hours, minutes' format.
  String _formatUptime(String minutesStr) {
    int totalMinutes = int.tryParse(minutesStr) ?? 0;
    if (totalMinutes == 0) return "0m";
    int days = totalMinutes ~/ 1440;
    int hours = (totalMinutes % 1440) ~/ 60;
    int minutes = totalMinutes % 60;
    return "${days}d, ${hours}h, ${minutes}m";
  }

  /// Formats a raw load average string into distinct 1m, 5m, and 15m intervals.
  String _formatLoadAverage(String loadStr) {
    Iterable<Match> matches = RegExp(r'\d+(\.\d+)?').allMatches(loadStr);
    List<String> parts = matches.map((m) => m.group(0)!).toList();
    return parts.length >= 3
        ? "1m: ${parts[0]} | 5m: ${parts[1]} | 15m: ${parts[2]}"
        : loadStr;
  }

  @override
  Widget build(BuildContext context) {
    // Definition of the screens corresponding to the BottomNavigationBar items.
    final List<Widget> tabs = [
      StatsTab(
        server: widget.server,
        uptime: uptime,
        loadAverage: loadAverage,
        isLoading: isLoading,
      ),
      ServicesTab(
        services: servicesList,
        isLoading: isLoading,
        onRestart: restartService,
      ),
      WebTab(domains: webDomainsList, isLoading: isLoading),
      MailTab(mailDomains: mailDomainsList, isLoading: isLoading),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.server.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAllData,
          ),
        ],
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_input_component),
            label: 'Services (${servicesList.length})',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.language),
            label: 'Web (${webDomainsList.length})',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.mail),
            label: 'Mail (${mailDomainsList.length})',
          ),
        ],
      ),
    );
  }
}
