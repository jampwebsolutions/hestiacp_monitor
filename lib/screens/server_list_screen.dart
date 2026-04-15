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

  // A common function for Add AND Edit
  void _showServerDialog({ServerModel? serverToEdit, int? index}) {
    final nameController = TextEditingController(
      text: serverToEdit?.name ?? '',
    );
    final urlController = TextEditingController(
      text:
          serverToEdit?.url ?? 'https://<SERVER-IP>:8083/api/monitor/index.php',
    );
    final usernameController = TextEditingController(
      text: serverToEdit?.username ?? 'admin',
    );
    final passwordController = TextEditingController(
      text: serverToEdit?.password ?? '',
    );
    // NEW CONTROLLER
    final secretController = TextEditingController(
      text: serverToEdit?.bridgeSecret ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(serverToEdit == null ? 'Add Server' : 'Edit Server'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blueGrey.withOpacity(0.3)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blueAccent,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'How to get URL & Secret Key',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Run the JAMP API Addon installer on your server via SSH to generate your secure connection details. Check our GitHub for instructions.',
                        style: TextStyle(fontSize: 12, height: 1.4),
                      ),
                    ],
                  ),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
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
                // NEW FIELD ON THE SCREEN
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
              child: const Text('Cancel'),
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
                      .trim(), // Save the new secret!
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
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Servers'), centerTitle: true),
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
