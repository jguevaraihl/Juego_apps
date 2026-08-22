import 'dart:convert';

/// Dónde vive el save. Se abstrae para poder testear el repositorio sin
/// tocar disco ni depender de plugins, y para tener una implementación por
/// plataforma (archivo en móvil, localStorage en la web de demo).
abstract class SaveStore {
  Future<Map<String, dynamic>?> read();
  Future<void> write(Map<String, dynamic> data);
  Future<void> clear();
}

/// Implementación en memoria. Se usa en tests y como último recurso si la
/// plataforma no ofrece almacenamiento: es preferible jugar sin guardar que
/// no arrancar.
class MemorySaveStore implements SaveStore {
  MemorySaveStore([this._data]);

  Map<String, dynamic>? _data;
  int writeCount = 0;

  @override
  Future<Map<String, dynamic>?> read() async => _data;

  @override
  Future<void> write(Map<String, dynamic> data) async {
    // Copia profunda vía JSON: replica que el disco no comparte referencias.
    _data = Map<String, dynamic>.from(jsonDecode(jsonEncode(data)) as Map);
    writeCount++;
  }

  @override
  Future<void> clear() async {
    _data = null;
  }
}
