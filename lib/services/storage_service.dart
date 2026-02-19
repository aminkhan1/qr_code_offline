import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/qr_item.dart';

class StorageService {
  static const _key = 'qr_history';

  Future<List<QRItem>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final List decoded = json.decode(raw);
    return decoded.map((e) => QRItem.fromJson(e)).toList();
  }

  Future<void> saveHistory(List<QRItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  Future<void> addItem(QRItem item) async {
    final items = await loadHistory();
    items.insert(0, item);
    await saveHistory(items);
  }

  Future<void> deleteItem(String id) async {
    final items = await loadHistory();
    items.removeWhere((e) => e.id == id);
    await saveHistory(items);
  }
}
