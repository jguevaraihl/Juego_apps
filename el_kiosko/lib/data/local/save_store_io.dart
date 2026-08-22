import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'save_store.dart';

/// Guardado en un archivo JSON dentro del directorio de documentos de la app.
///
/// La escritura es atómica (archivo temporal + rename): si el proceso muere a
/// mitad de camino, el save anterior queda intacto en vez de quedar truncado.
class FileSaveStore implements SaveStore {
  FileSaveStore({this.fileName = 'almacen_save.json'});

  final String fileName;
  File? _cached;

  Future<File> _file() async {
    final File? cached = _cached;
    if (cached != null) return cached;
    final Directory dir = await getApplicationDocumentsDirectory();
    return _cached = File('${dir.path}/$fileName');
  }

  @override
  Future<Map<String, dynamic>?> read() async {
    try {
      final File file = await _file();
      if (!await file.exists()) return null;
      final String contents = await file.readAsString();
      if (contents.trim().isEmpty) return null;
      final Object? decoded = jsonDecode(contents);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } on Object {
      // Archivo corrupto o ilegible: se trata como "sin partida".
      return null;
    }
  }

  @override
  Future<void> write(Map<String, dynamic> data) async {
    final File file = await _file();
    final File temp = File('${file.path}.tmp');
    await temp.writeAsString(jsonEncode(data), flush: true);
    await temp.rename(file.path);
  }

  @override
  Future<void> clear() async {
    final File file = await _file();
    if (await file.exists()) await file.delete();
  }
}

SaveStore createSaveStore() => FileSaveStore();
