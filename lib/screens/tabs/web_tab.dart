import 'package:flutter/material.dart';

class WebTab extends StatelessWidget {
  final Map<String, dynamic> domains;
  final bool isLoading;

  const WebTab({super.key, required this.domains, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (domains.isEmpty) {
      return const Center(child: Text("No Web Domains found for this user."));
    }

    // HestiaCP returns the domains as dictionary "keys"
    List<String> domainNames = domains.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return ListView.builder(
      itemCount: domainNames.length,
      itemBuilder: (context, index) {
        String domainName = domainNames[index];
        var domainData = domains[domainName];

        // Check if SSL is active
        bool hasSSL = domainData['SSL'] == 'yes';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: const Icon(
              Icons.language,
              color: Colors.blueAccent,
              size: 30,
            ),
            title: Text(
              domainName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Text('IP: ${domainData['IP']}'),
                Text(
                  'Disk: ${domainData['U_DISK']} MB | Bandwidth: ${domainData['U_BANDWIDTH']} MB',
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  hasSSL ? Icons.lock : Icons.lock_open,
                  color: hasSSL ? Colors.green : Colors.red,
                ),
                Text(
                  hasSSL ? 'SSL OK' : 'No SSL',
                  style: TextStyle(
                    color: hasSSL ? Colors.green : Colors.red,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            isThreeLine: true, // Makes the card slightly taller to fit the data
          ),
        );
      },
    );
  }
}
