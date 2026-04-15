import 'package:flutter/material.dart';

class ServicesTab extends StatelessWidget {
  final Map<String, dynamic> services;
  final bool isLoading;
  final Function(String) onRestart;

  const ServicesTab({
    super.key,
    required this.services,
    required this.isLoading,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (services.isEmpty) {
      return const Center(child: Text("No services found."));
    }

    List<String> names = services.keys.toList();

    return ListView.builder(
      itemCount: names.length,
      itemBuilder: (context, index) {
        String sName = names[index];
        var sData = services[sName];
        bool isRunning = sData['STATE'] == 'running';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: Icon(
              isRunning ? Icons.check_circle : Icons.error,
              color: isRunning ? Colors.green : Colors.red,
            ),
            title: Text(
              sName.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('CPU: ${sData['CPU']}% | RAM: ${sData['MEM']}MB'),
            trailing: IconButton(
              icon: const Icon(Icons.restart_alt, color: Colors.orange),
              onPressed: () => onRestart(sName),
            ),
          ),
        );
      },
    );
  }
}
