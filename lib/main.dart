import 'dart:io';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'screens/server_list_screen.dart';

// Παράκαμψη SSL
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const HestiaMonitorApp());
}

class HestiaMonitorApp extends StatefulWidget {
  const HestiaMonitorApp({super.key});

  @override
  State<HestiaMonitorApp> createState() => _HestiaMonitorAppState();
}

class _HestiaMonitorAppState extends State<HestiaMonitorApp> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    try {
      // Ελέγχουμε αν η συσκευή υποστηρίζει κλείδωμα
      bool isSupported = await auth.isDeviceSupported();

      if (isSupported) {
        // Η ΑΠΟΛΥΤΑ ΑΣΦΑΛΗΣ ΜΕΘΟΔΟΣ ΓΙΑ ΟΛΕΣ ΤΙΣ ΕΚΔΟΣΕΙΣ
        bool didAuthenticate = await auth.authenticate(
          localizedReason:
              'Παρακαλώ ταυτοποιηθείτε (Αποτύπωμα ή Κωδικός/Μοτίβο)',
        );

        setState(() {
          _isAuthenticated = didAuthenticate;
        });
      } else {
        setState(() => _isAuthenticated = true);
      }
    } catch (e) {
      print("Σφάλμα ταυτοποίησης: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HestiaCP Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: _isAuthenticated
          ? const ServerListScreen()
          : Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ΕΔΩ ΒΑΖΟΥΜΕ ΤΟ ΛΟΓΟΤΥΠΟ ΣΟΥ ΑΝΤΙ ΓΙΑ ΤΟ ΛΟΥΚΕΤΟ!
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        20,
                      ), // Κάνει τις γωνίες της εικόνας λίγο στρογγυλές
                      child: Image.asset(
                        'assets/icon.png',
                        width: 130, // Μέγεθος εικόνας
                        height: 130,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'HestiaCP Monitor\nby JAMP',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2, // Δίνει λίγο αέρα στα γράμματα
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: _authenticate,
                      icon: const Icon(Icons.security),
                      label: const Text('Ξεκλείδωμα Εφαρμογής'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            10,
                          ), // Πιο τετράγωνο κουμπί
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
