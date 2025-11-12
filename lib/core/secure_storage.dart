import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage{
  final storage=FlutterSecureStorage();
  final String _apiKey='apiKey';

  Future setapiKey(String apiKey) async{
    await storage.write(key: _apiKey, value: apiKey);
  }
  Future<String?> getapiKey() async{
    return await storage.read(key: _apiKey);
  }
}