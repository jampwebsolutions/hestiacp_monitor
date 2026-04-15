import 'package:flutter/material.dart';

class MailTab extends StatelessWidget {
  final Map<String, dynamic> mailDomains;
  final bool isLoading;

  const MailTab({
    super.key,
    required this.mailDomains,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (mailDomains.isEmpty) {
      return const Center(child: Text("No Mail Domains found."));
    }

    List<String> domains = mailDomains.keys.toList();

    return ListView.builder(
      itemCount: domains.length,
      itemBuilder: (context, index) {
        String dName = domains[index];
        var dData = mailDomains[dName];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: const Icon(
              Icons.mail,
              color: Colors.orangeAccent,
              size: 30,
            ),
            title: Text(
              dName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Accounts: ${dData['ACCOUNTS']} | Disk: ${dData['U_DISK']} MB',
            ),
            trailing: Wrap(
              spacing: 10,
              children: [
                Icon(
                  Icons.security,
                  color: dData['ANTISPAM'] == 'yes'
                      ? Colors.green
                      : Colors.grey,
                  size: 20,
                ),
                Icon(
                  Icons.bug_report,
                  color: dData['ANTIVIRUS'] == 'yes'
                      ? Colors.green
                      : Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
