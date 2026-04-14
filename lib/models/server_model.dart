import 'dart:convert';

class ServerModel {
  String id;
  String name;
  String url;
  String username;
  String password;
  String bridgeSecret; // <-- ΝΕΟ ΠΕΔΙΟ

  ServerModel({
    required this.id,
    required this.name,
    required this.url,
    required this.username,
    required this.password,
    required this.bridgeSecret, // <-- ΝΕΟ ΠΕΔΙΟ
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'username': username,
      'password': password,
      // ΔΕΝ σώζουμε το bridgeSecret εδώ, θα το βάλουμε στο χρηματοκιβώτιο!
    };
  }

  factory ServerModel.fromMap(Map<String, dynamic> map) {
    return ServerModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      url: map['url'] ?? '',
      username: map['username'] ?? 'admin',
      password: '', // Το παίρνουμε από το StorageHelper
      bridgeSecret: '', // Το παίρνουμε από το StorageHelper
    );
  }

  String toJson() => json.encode(toMap());
  factory ServerModel.fromJson(String source) =>
      ServerModel.fromMap(json.decode(source));
}
