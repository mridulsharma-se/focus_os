import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/memory.dart';

class StorageService {
  static const _boxName = 'memoriesBox';
  static Box<Memory>? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(MemoryAdapter());

    const secureStorage = FlutterSecureStorage();
    // if key not exists return null
    var encryptionKeyString = await secureStorage.read(key: 'key');
    if (encryptionKeyString == null) {
      final key = Hive.generateSecureKey();
      await secureStorage.write(
        key: 'key',
        value: base64UrlEncode(key),
      );
      encryptionKeyString = base64UrlEncode(key);
    }
    final encryptionKeyUint8List = base64Url.decode(encryptionKeyString);

    _box = await Hive.openBox<Memory>(
      _boxName,
      encryptionCipher: HiveAesCipher(encryptionKeyUint8List),
    );
  }

  static Future<void> saveMemory(Memory memory) async {
    await _box?.put(memory.id, memory);
  }

  static List<Memory> getAllMemories() {
    if (_box == null) return [];
    final items = _box!.values.toList();
    // sort descending by timestamp
    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items;
  }

  static List<Memory> searchMemories(String query) {
    if (_box == null) return [];
    final lowerQuery = query.toLowerCase();
    final items = _box!.values.where((m) => 
      m.content.toLowerCase().contains(lowerQuery) || 
      m.source.toLowerCase().contains(lowerQuery)
    ).toList();
    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items;
  }

  static Future<void> clearAll() async {
    await _box?.clear();
  }
  
  static int getStorageCount() {
    return _box?.length ?? 0;
  }
}
