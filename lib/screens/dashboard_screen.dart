import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../models/server_model.dart';
import 'tabs/stats_tab.dart';
import 'tabs/services_tab.dart';
import 'tabs/web_tab.dart';
import 'tabs/mail_tab.dart';

class DashboardScreen extends StatefulWidget {
  final ServerModel server;
  const DashboardScreen({super.key, required this.server});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  String uptime = "Unknown";
  String loadAverage = "Unknown";
  Map<String, dynamic> servicesList = {};
  Map<String, dynamic> webDomainsList = {};
  Map<String, dynamic> mailDomainsList = {};

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshAllData();
  }

  String _getAuthToken() {
    String secretKey = widget.server.bridgeSecret;
    // Χρησιμοποιούμε DateTime.now().toUtc() για να αποφύγουμε θέματα Timezone
    int timeWindow = (DateTime.now().toUtc().millisecondsSinceEpoch / 1000 / 30)
        .floor();

    // Ενώνουμε το κλειδί με το χρόνο
    String rawString = "$secretKey$timeWindow";
    var bytes = utf8.encode(rawString);
    return sha256.convert(bytes).toString();
  }

  // Μετατρέπει τα συνολικά λεπτά σε Μέρες, Ώρες, Λεπτά
  String _formatUptime(String minutesStr) {
    int totalMinutes = int.tryParse(minutesStr) ?? 0;
    if (totalMinutes == 0) return "$minutesStr λεπτά";

    int days = totalMinutes ~/ (24 * 60);
    int hours = (totalMinutes % (24 * 60)) ~/ 60;
    int minutes = totalMinutes % 60;

    List<String> parts = [];
    if (days > 0) parts.add('$days μέρες');
    if (hours > 0) parts.add('$hours ώρες');
    parts.add('$minutes λεπτά');

    return parts.join(', ');
  }

  // Μορφοποίηση του Load Average (Αλάνθαστη μέθοδος)
  String _formatLoadAverage(String loadStr) {
    // Ψάχνει στο κείμενο και κρατάει ΜΟΝΟ αριθμούς (π.χ. 0.15, 1.00, 2)
    Iterable<Match> matches = RegExp(r'\d+(\.\d+)?').allMatches(loadStr);
    List<String> parts = matches.map((m) => m.group(0)!).toList();

    // Αν βρήκε τουλάχιστον 3 αριθμούς, τους βάζει στη σωστή θέση
    if (parts.length >= 3) {
      return "1λ: ${parts[0]}  |  5λ: ${parts[1]}  |  15λ: ${parts[2]}";
    }

    // Αν κάτι πάει στραβά, το δείχνει όπως ήρθε
    return loadStr;
  }

  Future<void> _refreshAllData() async {
    setState(() => isLoading = true);

    // Πλέον περιμένουμε 3 πράγματα να κατέβουν!
    await fetchServerStats();
    await fetchServices();
    await fetchWebDomains(); // <-- ΝΕΟ
    await fetchMailDomains(); // <-- ΝΕΟ

    setState(() => isLoading = false);
  }

  // ... (Λήψη Στατιστικών)
  Future<void> fetchServerStats() async {
    try {
      final response = await http.post(
        Uri.parse(widget.server.url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8', // ΠΡΟΣΘΗΚΗ ΑΥΤΟΥ
        },
        body: {
          'app_token': _getAuthToken(),
          'user': widget.server.username,
          'password': widget.server.password,
          'cmd': 'v-list-sys-info',
          'arg1': 'json',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          uptime = _formatUptime(data['sysinfo']['UPTIME'].toString());
          loadAverage = _formatLoadAverage(
            data['sysinfo']['LOADAVERAGE'].toString(),
          );
        });
        print(
          "MOBILE HEX: ${hex.encode(utf8.encode(widget.server.bridgeSecret))}",
        );
      }
    } catch (e) {
      print("Stats fault: $e");
    }
  }

  // ... (Λήψη Υπηρεσιών)
  Future<void> fetchServices() async {
    try {
      final response = await http.post(
        Uri.parse(widget.server.url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8', // ΠΡΟΣΘΗΚΗ ΑΥΤΟΥ
        },
        body: {
          'app_token': _getAuthToken(),
          'user': widget.server.username,
          'password': widget.server.password,
          'cmd': 'v-list-sys-services',
          'arg1': 'json',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          servicesList = json.decode(response.body);
        });
      }
    } catch (e) {
      print("Σφάλμα Υπηρεσιών: $e");
    }
  }

  // --- ΝΕΑ ΣΥΝΑΡΤΗΣΗ: Λήψη Web Domains ---
  Future<void> fetchWebDomains() async {
    try {
      final response = await http.post(
        Uri.parse(widget.server.url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8', // ΠΡΟΣΘΗΚΗ ΑΥΤΟΥ
        },
        body: {
          'app_token': _getAuthToken(),
          'user': widget.server.username,
          'password': widget.server.password,
          'cmd': 'v-list-web-domains', // Η εντολή για τα domains
          'arg1': widget
              .server
              .username, // ΠΡΟΣΟΧΗ: Θέλουμε τα domains ΑΥΤΟΥ του χρήστη
          'arg2': 'json', // Το format που θέλουμε
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          webDomainsList = json.decode(response.body);
        });
      }
    } catch (e) {
      print("Σφάλμα Web Domains: $e");
    }
  }

  Future<void> fetchMailDomains() async {
    try {
      final response = await http.post(
        Uri.parse(widget.server.url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8', // ΠΡΟΣΘΗΚΗ ΑΥΤΟΥ
        },
        body: {
          'app_token': _getAuthToken(),
          'user': widget.server.username,
          'password': widget.server.password,
          'cmd': 'v-list-mail-domains',
          'arg1': widget.server.username,
          'arg2': 'json',
        },
      );
      if (response.statusCode == 200) {
        setState(() => mailDomainsList = json.decode(response.body));
      }
    } catch (e) {
      print(e);
    }
  }

  // ... (Επανεκκίνηση Υπηρεσίας - Παραμένει το ίδιο)
  Future<void> restartService(String serviceName) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Γίνεται επανεκκίνηση: $serviceName...'),
        duration: const Duration(seconds: 2),
      ),
    );
    try {
      final response = await http.post(
        Uri.parse(widget.server.url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8', // ΠΡΟΣΘΗΚΗ ΑΥΤΟΥ
        },
        body: {
          'app_token': _getAuthToken(),
          'user': widget.server.username,
          'password': widget.server.password,
          'cmd': 'v-restart-service',
          'arg1': serviceName,
        },
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Επιτυχία!'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshAllData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Αποτυχία επανεκκίνησης.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Σφάλμα δικτύου.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Επιλογή Καρτέλας: Τώρα έχουμε 3 επιλογές!
    Widget currentTab;
    if (_currentIndex == 0) {
      currentTab = StatsTab(
        server: widget.server,
        uptime: uptime,
        loadAverage: loadAverage,
        isLoading: isLoading,
      );
    } else if (_currentIndex == 1) {
      currentTab = ServicesTab(
        services: servicesList,
        isLoading: isLoading,
        onRestart: restartService,
      );
    } else if (_currentIndex == 2) {
      currentTab = WebTab(domains: webDomainsList, isLoading: isLoading);
    } else {
      currentTab = MailTab(mailDomains: mailDomainsList, isLoading: isLoading);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.server.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAllData,
          ),
        ],
      ),
      body: currentTab,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        // Προσθέσαμε το 3ο κουμπί!
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Στατιστικά',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_input_component),
            label: 'Υπηρεσίες',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.language), label: 'Web'),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Mail'),
        ],
      ),
    );
  }
}
