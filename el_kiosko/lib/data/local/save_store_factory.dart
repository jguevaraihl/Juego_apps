/// Elige la implementación de almacenamiento según la plataforma en tiempo de
/// compilación: archivo en móvil/escritorio, localStorage en la web de demo.
library;

export 'save_store_io.dart' if (dart.library.js_interop) 'save_store_web.dart';
