import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

class StorageService {
  final FirebaseStorage? _storage;
  static const String _lastRouteKey = 'last_route';
  
  StorageService([this._storage]);

  Future<void> saveLastRoute(String route) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastRouteKey, route);
  }

  Future<String?> getLastRoute() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastRouteKey);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastRouteKey);
  }

  Future<String> uploadProductImage(File imageFile, String sellerId) async {
    if (_storage == null) throw Exception('Firebase Storage not initialized');

    final fileName = '${DateTime.now().millisecondsSinceEpoch}${p.extension(imageFile.path)}';
    final ref = _storage!.ref().child('sellers/$sellerId/products/$fileName');
    
    final uploadTask = await ref.putFile(imageFile);
    return await uploadTask.ref.getDownloadURL();
  }
}
