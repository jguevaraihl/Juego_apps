import 'dart:convert';

import 'package:web/web.dart' as web;

import 'save_store.dart';

/// Guardado en `localStorage`. Sólo se usa en la build web, que existe para
/// hacer demos rápidas en el navegador; la plataforma de release es Android.
class LocalStorageSaveStore implements SaveStore {
  LocalStorageSaveStore({this.key = 'almacen_save'});

  final String key;

  @override
  Future<Map<String, dynamic>?> read() async {
    try {
      final String? raw = web.window.localStorage.getItem(key);
      if (raw == null || raw.trim().isEmpty) return null;
      final Object? decoded = jsonDecode(raw);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } on Object {
      return null;
    }
  }

  @override
  Future<void> write(Map<String, dynamic> data) async {
    web.window.localStorage.setItem(key, jsonEncode(data));
  }

  @override
  Future<void> clear() async {
    web.window.localStorage.removeItem(key);
  }
}

SaveStore createSaveStore() => LocalStorageSaveStore();
