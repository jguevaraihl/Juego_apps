// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'El Kiosko';

  @override
  String get chainBakery => 'Panadería';

  @override
  String get chainDrinks => 'Bebidas';

  @override
  String get chainSnacks => 'Snacks';

  @override
  String get bakery1 => 'Marraqueta';

  @override
  String get bakery2 => 'Bolsa de pan';

  @override
  String get bakery3 => 'Canasto de pan';

  @override
  String get bakery4 => 'Bandeja surtida';

  @override
  String get bakery5 => 'Vitrina de pan';

  @override
  String get drinks1 => 'Vaso';

  @override
  String get drinks2 => 'Botella chica';

  @override
  String get drinks3 => 'Botella grande';

  @override
  String get drinks4 => 'Pack de bebidas';

  @override
  String get drinks5 => 'Refrigerador';

  @override
  String get snacks1 => 'Dulce';

  @override
  String get snacks2 => 'Bolsita';

  @override
  String get snacks3 => 'Paquete';

  @override
  String get snacks4 => 'Caja surtida';

  @override
  String get snacks5 => 'Estante de snacks';

  @override
  String get customer0 => 'Don Chofer';

  @override
  String get customer1 => 'La vecina del 3';

  @override
  String get customer2 => 'Estudiante de la tarde';

  @override
  String get customer3 => 'La señora del kiosko';

  @override
  String get customer4 => 'El feriante';

  @override
  String get customer5 => 'Turno de noche';

  @override
  String get customer6 => 'Repartidor';

  @override
  String get customer7 => 'Don Jubilado';

  @override
  String get customer8 => 'La profe';

  @override
  String get customer9 => 'Oficinista apurado';

  @override
  String get customer10 => 'La emprendedora';

  @override
  String get customer11 => 'El maestro albañil';

  @override
  String get shopTier1 => 'Mesón improvisado';

  @override
  String get shopTier2 => 'Kiosko';

  @override
  String get shopTier3 => 'Almacén chico';

  @override
  String get shopTier4 => 'Almacén de barrio';

  @override
  String get shopTier5 => 'Minimarket';

  @override
  String get shopTier6 => 'Local renovado';

  @override
  String get shopTier7 => 'Cadena de barrio';

  @override
  String get shopTagline1 => 'Una tabla, dos cajones y muchas ganas.';

  @override
  String get shopTagline2 => 'Ya tienes techo y una ventanilla.';

  @override
  String get shopTagline3 => 'Entra un cliente a la vez, pero entra.';

  @override
  String get shopTagline4 => 'Te saludan por el nombre.';

  @override
  String get shopTagline5 => 'Refrigerador propio y letrero iluminado.';

  @override
  String get shopTagline6 => 'Piso nuevo, vitrinas y fila en la caja.';

  @override
  String get shopTagline7 => 'El almacén más querido del sector.';

  @override
  String playerLevel(int level) {
    return 'Nivel $level';
  }

  @override
  String coinsLabel(int coins) {
    return '$coins monedas';
  }

  @override
  String get tooltipCollection => 'Álbum de productos';

  @override
  String get tooltipShop => 'Mejorar el local';

  @override
  String get tooltipSettings => 'Ajustes';

  @override
  String get shopUpgradeReady => 'Ya puedes mejorar el local';

  @override
  String get supplierBox => 'Caja del proveedor';

  @override
  String supplierCost(int cost) {
    return 'Cuesta $cost';
  }

  @override
  String get boardFull => 'Tablero lleno';

  @override
  String get notEnoughCoinsShort => 'Te faltan monedas';

  @override
  String supplierSemantics(String hint) {
    return 'Caja del proveedor. $hint';
  }

  @override
  String get sell => 'Vender';

  @override
  String get sellDone => 'Listo';

  @override
  String get deliver => 'Entregar';

  @override
  String get missing => 'Falta';

  @override
  String rerollTooltip(int cost) {
    return 'Cambiar pedido por $cost';
  }

  @override
  String orderSemantics(String customer, String status, int reward) {
    return 'Pedido de $customer. $status. Paga $reward.';
  }

  @override
  String get orderReady => 'Listo para entregar';

  @override
  String get orderNotReady => 'Faltan productos';

  @override
  String tutorialStepOf(int step) {
    return 'Paso $step de 3';
  }

  @override
  String get tutorialMerge => 'Arrastra dos productos iguales para juntarlos.';

  @override
  String get tutorialOrder => 'Ahora completa un pedido y cobra.';

  @override
  String get tutorialUpgrade => 'Usa tus monedas para mejorar el local.';

  @override
  String get skip => 'Saltar';

  @override
  String get offlineTitle => 'El almacén siguió vendiendo';

  @override
  String offlineBody(int amount) {
    return 'Mientras no estabas se juntaron $amount monedas en la caja.';
  }

  @override
  String get offlineContinue => 'Seguir atendiendo';

  @override
  String toastOrderDelivered(int reward) {
    return '¡Pedido entregado! +$reward';
  }

  @override
  String toastShopUpgraded(String name) {
    return 'Tu local ahora es $name';
  }

  @override
  String toastLevelUp(int level) {
    return 'Subiste a nivel $level';
  }

  @override
  String toastChainUnlocked(String chain) {
    return 'Nuevo producto en el almacén: $chain';
  }

  @override
  String toastSold(int value) {
    return 'Vendido por $value';
  }

  @override
  String toastRelief(int amount) {
    return 'El proveedor te fía $amount para seguir.';
  }

  @override
  String get toastNotEnoughCoins => 'Te faltan monedas.';

  @override
  String get toastBoardFull => 'El tablero está lleno. Vende o entrega.';

  @override
  String get toastOrderNotReady => 'Todavía falta mercadería.';

  @override
  String get toastMaxShopLevel => 'Ya tienes el local al máximo.';

  @override
  String get shopTitle => 'Tu local';

  @override
  String shopIncomePerHour(int amount) {
    return 'Genera $amount por hora mientras no juegas.';
  }

  @override
  String shopNext(String name) {
    return 'Siguiente: $name';
  }

  @override
  String get shopShelves => 'Estantes';

  @override
  String get shopCustomers => 'Clientes';

  @override
  String get shopIncomeLabel => 'Ganancia por hora';

  @override
  String shopUpgradeFor(int cost) {
    return 'Mejorar por $cost';
  }

  @override
  String shopMissingCoins(int amount) {
    return 'Faltan $amount monedas';
  }

  @override
  String get shopAllLevels => 'Todos los niveles';

  @override
  String get shopStartingPoint => 'Punto de partida';

  @override
  String shopCosts(int cost) {
    return 'Cuesta $cost';
  }

  @override
  String get shopMaxedOut =>
      'Llegaste al nivel máximo por ahora. Vienen más niveles en próximas actualizaciones.';

  @override
  String get collectionTitle => 'Álbum del almacén';

  @override
  String collectionProgress(int found, int total) {
    return 'Descubiertos $found de $total';
  }

  @override
  String get collectionUnknown => '???';

  @override
  String collectionLevel(int level) {
    return 'Nivel $level';
  }

  @override
  String collectionFoundSemantics(String name) {
    return '$name, descubierto';
  }

  @override
  String collectionMissingSemantics(int level) {
    return 'Producto de nivel $level, no descubierto';
  }

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSound => 'Sonido';

  @override
  String get settingsSoundSub => 'Efectos al completar acciones';

  @override
  String get settingsHaptics => 'Vibración';

  @override
  String get settingsHapticsSub => 'Respuesta táctil al juntar y cobrar';

  @override
  String get settingsReducedMotion => 'Reducir animaciones';

  @override
  String get settingsReducedMotionSub => 'Recomendado en teléfonos más lentos';

  @override
  String get settingsHints => 'Sugerencias';

  @override
  String get settingsHintsSub => 'Marcar una jugada posible si te detienes';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Idioma del sistema';

  @override
  String get settingsPremium => 'Club del Barrio';

  @override
  String get settingsPremiumSub => 'Opciones sin anuncios (próximamente)';

  @override
  String get settingsAbout => 'Sobre el juego';

  @override
  String settingsStats(int orders, int merges) {
    return 'Pedidos completados: $orders · Productos juntados: $merges';
  }

  @override
  String get settingsPrivacyNote =>
      'Esta versión funciona completamente sin conexión y no recolecta datos personales.';

  @override
  String get premiumTitle => 'Club del Barrio';

  @override
  String get premiumNotAvailable => 'Todavía no está disponible';

  @override
  String get premiumBody =>
      'Esta versión no tiene anuncios ni compras. Estamos probando el juego primero. Cuando existan opciones pagadas, van a aparecer acá con su precio real de la tienda.';

  @override
  String get premiumEvaluating => 'Lo que estamos evaluando';

  @override
  String get premiumBullet1 =>
      'Una compra única para quitar los anuncios forzados.';

  @override
  String get premiumBullet2 =>
      'Un club mensual con decoración y un bonus diario, además de cero anuncios forzados.';

  @override
  String get premiumBullet3 =>
      'Los anuncios con recompensa siempre serán voluntarios: el juego se puede terminar sin verlos.';

  @override
  String itemSemantics(String name, int level) {
    return '$name, nivel $level';
  }
}
