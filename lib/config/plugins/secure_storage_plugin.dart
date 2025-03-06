import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStoragePlugin {
  static const storage = FlutterSecureStorage();

  static Future<bool> isPasswordRegistered() async {
    return await storage.containsKey(key: 'password');
  }

  static Future<String> getPassword() async {
    return await storage.read(key: 'password') ?? '';
  }

  static Future<void> setPassword(String newPassword) async {
    await storage.write(key: 'password', value: newPassword);
  }
}
