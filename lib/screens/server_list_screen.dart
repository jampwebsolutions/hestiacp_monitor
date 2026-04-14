import 'package:flutter/material.dart';
import '../models/server_model.dart';
import '../utils/storage_helper.dart';
import 'dashboard_screen.dart';

class ServerListScreen extends StatefulWidget {
  const ServerListScreen({super.key});

  @override
  State<ServerListScreen> createState() => _ServerListScreenState();
}

class _ServerListScreenState extends State<ServerListScreen> {
  List<ServerModel> servers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedServers();
  }

  Future<void> _loadSavedServers() async {
    final savedServers = await StorageHelper.loadServers();
    setState(() {
      servers = savedServers;
      isLoading = false;
    });
  }

  // Μία κοινή συνάρτηση για Προσθήκη ΚΑΙ Επεξεργασία
  void _showServerDialog({ServerModel? serverToEdit, int? index}) {
    final nameController = TextEditingController(
      text: serverToEdit?.name ?? '',
    );
    final urlController = TextEditingController(
      text: serverToEdit?.url ?? 'https://',
    );
    final usernameController = TextEditingController(
      text: serverToEdit?.username ?? 'admin',
    );
    final passwordController = TextEditingController(
      text: serverToEdit?.password ?? '',
    );
    // ΝΕΟΣ CONTROLLER
    final secretController = TextEditingController(
      text: serverToEdit?.bridgeSecret ?? 'MySuperSecretKey_998877!',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            serverToEdit == null ? 'Προσθήκη VPS' : 'Επεξεργασία VPS',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Όνομα'),
                ),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'URL (api_bridge.php)',
                  ),
                ),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password HestiaCP',
                  ),
                  obscureText: true,
                ),
                // ΝΕΟ ΠΕΔΙΟ ΣΤΗΝ ΟΘΟΝΗ
                TextField(
                  controller: secretController,
                  decoration: const InputDecoration(
                    labelText: 'API Bridge Secret Key',
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Ακύρωση'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newServer = ServerModel(
                  id:
                      serverToEdit?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  url: urlController.text.trim(),
                  username: usernameController.text.trim(),
                  password: passwordController.text.trim(),
                  bridgeSecret: secretController.text
                      .trim(), // Αποθηκεύουμε το νέο secret!
                );

                if (serverToEdit == null) {
                  servers.add(newServer);
                } else {
                  servers[index!] = newServer;
                }

                await StorageHelper.saveServers(servers);
                setState(() {});
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Αποθήκευση'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Οι VPS μου'), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: servers.length,
              itemBuilder: (context, index) {
                final server = servers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.dns, color: Colors.blueAccent),
                    title: Text(
                      server.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(server.url),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _showServerDialog(
                            serverToEdit: server,
                            index: index,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () async {
                            servers.removeAt(index);
                            await StorageHelper.saveServers(servers);
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DashboardScreen(server: server),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showServerDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
