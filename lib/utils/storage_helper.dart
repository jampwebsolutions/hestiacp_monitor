import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/server_model.dart';

class StorageHelper {
  static const _secureStorage = FlutterSecureStorage();
  static const String _serversKey = 'saved_servers_list';

  // 1. Αποθήκευση Λίστας Servers
  static Future<void> saveServers(List<ServerModel> servers) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> serversJson = servers.map((s) => s.toJson()).toList();
    await prefs.setStringList(_serversKey, serversJson);

    for (var server in servers) {
      // Σώζουμε τον κωδικό
      await _secureStorage.write(
        key: 'pwd_${server.id}',
        value: server.password,
      );
      // Σώζουμε το Bridge Secret ΥΠΕΡ-ΑΣΦΑΛΩΣ!
      await _secureStorage.write(
        key: 'secret_${server.id}',
        value: server.bridgeSecret,
      );
    }
  }

  // 2. Ανάγνωση Λίστας Servers
  static Future<List<ServerModel>> loadServers() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? serversJson = prefs.getStringList(_serversKey);

    if (serversJson == null) return [];

    List<ServerModel> servers = [];
    for (var jsonStr in serversJson) {
      var server = ServerModel.fromJson(jsonStr);

      server.password =
          await _secureStorage.read(key: 'pwd_${server.id}') ?? '';

      // Διαβάζουμε το Secret. Αν δεν υπάρχει (από παλιό save), βάζουμε το default!
      server.bridgeSecret =
          await _secureStorage.read(key: 'secret_${server.id}') ??
          'MySuperSecretKey_998877!';

      servers.add(server);
    }
    return servers;
  }
}
