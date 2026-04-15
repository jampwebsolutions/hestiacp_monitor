import 'dart:convert';

/// Represents a HestiaCP server connection configuration.
/// Stores the credentials and endpoints required to securely communicate with the API bridge.
class ServerModel {
  String id;
  String name;
  String url;
  String username;
  String password;
  String bridgeSecret;

  ServerModel({
    required this.id,
    required this.name,
    required this.url,
    required this.username,
    required this.password,
    required this.bridgeSecret,
  });

  /// Converts the model into a Map for serialization (e.g., saving to local storage).
  /// Note: The `bridgeSecret` is intentionally omitted here for security or handled separately.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'username': username,
      'password': password,
    };
  }

  /// Creates a [ServerModel] instance from a Map representation.
  /// Provides fallback default values if certain keys are missing.
  factory ServerModel.fromMap(Map<String, dynamic> map) {
    return ServerModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      url: map['url'] ?? '',
      username: map['username'] ?? 'admin',
      password: '',
      bridgeSecret: '',
    );
  }

  /// Serializes the model to a JSON string.
  String toJson() => json.encode(toMap());

  /// Deserializes a JSON string into a [ServerModel] instance.
  factory ServerModel.fromJson(String source) =>
      ServerModel.fromMap(json.decode(source));
}
