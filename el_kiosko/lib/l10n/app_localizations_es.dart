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
  String tutorialStepOf(int step, int total) {
    return 'Paso $step de $total';
  }

  @override
  String get tutorialMerge =>
      'Arrastra un producto sobre otro igual: los dos se convierten en uno mejor.';

  @override
  String get tutorialOrder =>
      'Cuando tengas lo que pide un cliente, entrégaselo y cobra.';

  @override
  String get tutorialUpgrade =>
      'Con las monedas subes el local de nivel: gana más por hora y cada tanto cambia de fachada.';

  @override
  String get skip => 'Saltar';

  @override
  String get undoSell => 'Deshacer la venta';

  @override
  String get undoSplit => 'Deshacer la separación';

  @override
  String get undoBuy => 'Deshacer la compra';

  @override
  String get undoReroll => 'Deshacer el cambio';

  @override
  String get toastUndone => 'Listo, quedó como estaba';

  @override
  String get offlineTitle => 'El almacén siguió vendiendo';

  @override
  String offlineBody(int amount) {
    return 'Mientras no estabas se juntaron $amount monedas en la caja.';
  }

  @override
  String offlineTotal(int amount) {
    return 'Con lo que tenías sin cobrar, la caja suma $amount.';
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
  String get settingsSectionLook => 'Tu local';

  @override
  String get settingsSectionPlay => 'Juego';

  @override
  String get settingsSectionAccess => 'Accesibilidad';

  @override
  String get settingsStoreName => 'Nombre del local';

  @override
  String get settingsStoreNameSub => 'Aparece en el letrero de la fachada';

  @override
  String get settingsStoreNameHint => 'Ej: El Rincón de la Tía';

  @override
  String get settingsStoreNameDefault => 'Sin nombre propio';

  @override
  String settingsStoreNameHelp(int max) {
    return 'Hasta $max caracteres. Déjalo vacío para usar el nombre del nivel.';
  }

  @override
  String get settingsAwning => 'Color del toldo';

  @override
  String get settingsAwningSub => 'Elige la tela de tu almacén';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Según el teléfono';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsTextSize => 'Tamaño del texto';

  @override
  String get settingsTextSizeSub =>
      'Se suma al tamaño que tengas en el teléfono';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get awningColorName1 => 'Teja';

  @override
  String get awningColorName2 => 'Verde';

  @override
  String get awningColorName3 => 'Azul';

  @override
  String get awningColorName4 => 'Morado';

  @override
  String get awningColorName5 => 'Rojo';

  @override
  String get awningColorName6 => 'Verde azulado';

  @override
  String get awningColorName7 => 'Mostaza';

  @override
  String get awningColorName8 => 'Pizarra';

  @override
  String get sort => 'Ordenar';

  @override
  String get sortFree => 'gratis';

  @override
  String get toastSorted => 'Mercadería acomodada';

  @override
  String get toastSortedFree => 'Mercadería acomodada, sin costo';

  @override
  String get toastAlreadySorted => 'Ya está ordenado';

  @override
  String get toastAlreadyOwned => 'Ya la tienes';

  @override
  String toastUndoneCost(int cost) {
    return 'Listo, quedó como estaba (-$cost)';
  }

  @override
  String undoCost(int cost) {
    return '$cost';
  }

  @override
  String get freeSortTitle => 'Ordenar siempre gratis';

  @override
  String get freeSortBody =>
      'Acomodar la mercadería deja de costar monedas, para siempre.';

  @override
  String freeSortBuy(int cost) {
    return 'Comprar por $cost';
  }

  @override
  String get freeSortOwned => 'Ya la compraste';

  @override
  String deliverTo(String customer) {
    return 'Para $customer';
  }

  @override
  String get deliveryThanks => '¡Gracias, vecino!';

  @override
  String get bigOrderTitle => '¡Pedido mayorista!';

  @override
  String bigOrderSub(String time) {
    return 'Se va en $time';
  }

  @override
  String get bigOrderGone => 'El mayorista se fue. Vuelve más tarde.';

  @override
  String bigOrderArrived(int reward) {
    return 'Llegó un pedido grande: paga $reward';
  }

  @override
  String get bigOrderBadge => 'MAYORISTA';

  @override
  String get toastCannotRerollBig => 'El mayorista no se puede cambiar';

  @override
  String get achievementsTitle => 'Logros';

  @override
  String achievementsSub(int done, int total) {
    return '$done de $total conseguidos';
  }

  @override
  String achievementClaim(int reward) {
    return 'Cobrar $reward';
  }

  @override
  String get achievementClaimed => 'Cobrado';

  @override
  String achievementProgress(int have, int target) {
    return '$have / $target';
  }

  @override
  String toastAchievement(int reward) {
    return '¡Logro cobrado! +$reward';
  }

  @override
  String get toastAchievementNotDone => 'Todavía no está conseguido';

  @override
  String get achMerges1 => 'Manos a la obra';

  @override
  String get achMerges2 => 'Buen ojo';

  @override
  String get achMerges3 => 'Maestro del mesón';

  @override
  String get achStreak1 => 'Cinco seguidas';

  @override
  String get achStreak2 => 'En racha';

  @override
  String get achOrders1 => 'Primeros clientes';

  @override
  String get achOrders2 => 'Cliente fiel';

  @override
  String get achOrders3 => 'El almacén del barrio';

  @override
  String get achWholesale1 => 'Trato con el mayorista';

  @override
  String get achWholesale2 => 'Proveedor de confianza';

  @override
  String get achShop3 => 'Local de verdad';

  @override
  String get achShop7 => 'Vitrina propia';

  @override
  String get achAlbum1 => 'Coleccionista';

  @override
  String get achAlbum2 => 'Media colección';

  @override
  String get achTill1 => 'Primera caja';

  @override
  String get achTill2 => 'Caja llena';

  @override
  String achMergesDesc(int n) {
    return 'Junta $n productos';
  }

  @override
  String achStreakDesc(int n) {
    return 'Junta $n veces seguidas, sin hacer otra cosa';
  }

  @override
  String achOrdersDesc(int n) {
    return 'Entrega $n pedidos';
  }

  @override
  String achWholesaleDesc(int n) {
    return 'Entrega $n pedidos mayoristas';
  }

  @override
  String achShopDesc(int n) {
    return 'Lleva tu local al nivel $n';
  }

  @override
  String achAlbumDesc(int n) {
    return 'Descubre $n productos distintos';
  }

  @override
  String achTillDesc(int n) {
    return 'Cobra $n monedas de la caja';
  }

  @override
  String toastFilled(int count) {
    return 'Entraron $count productos';
  }

  @override
  String get supplierHold => 'Mantén apretado para llenar';

  @override
  String get chainPets => 'Mascotas';

  @override
  String get pets1 => 'Sobre de comida';

  @override
  String get pets2 => 'Bolsa de croquetas';

  @override
  String get pets3 => 'Saco de alimento';

  @override
  String get pets4 => 'Pack premium';

  @override
  String get settingsPet => 'Mascota del local';

  @override
  String get settingsPetSub =>
      'Tenerla abre el rubro de alimento para mascotas, que paga mejor';

  @override
  String get petNone => 'Ninguna';

  @override
  String get petName1 => 'Gato';

  @override
  String get petName2 => 'Perro';

  @override
  String get petName3 => 'Loro';

  @override
  String get petName4 => 'Tortuga';

  @override
  String get workerTitle => 'Contratar ayuda';

  @override
  String get workerSub =>
      'Junta mercadería y pide al proveedor mientras no estás';

  @override
  String workerLevel(int level) {
    return 'Ayudante nivel $level';
  }

  @override
  String workerDetail(int hours, int max, int rate) {
    return '$hours h · junta hasta nivel $max · $rate acciones por hora';
  }

  @override
  String workerHire(int cost) {
    return 'Contratar por $cost';
  }

  @override
  String workerBusyUntil(String time) {
    return 'Trabajando: quedan $time';
  }

  @override
  String workerExtend(int cost) {
    return 'Ampliar por $cost';
  }

  @override
  String get workerLockedMsg => 'Necesitas un local más grande para contratar';

  @override
  String get workerDone => 'Se terminó el turno de tu ayudante';

  @override
  String workerReport(int merged, int bought) {
    return 'Tu ayudante juntó $merged y pidió $bought';
  }

  @override
  String workerHiredMsg(int hours) {
    return 'Ayudante contratado por $hours h';
  }

  @override
  String get notificationWorkerTitle => 'Se fue tu ayudante';

  @override
  String get notificationWorkerBody => 'Terminó su turno en el almacén.';

  @override
  String get notificationUpgradeTitle => 'Ya puedes mejorar el local';

  @override
  String get notificationUpgradeBody =>
      'Juntaste lo suficiente para el siguiente nivel.';

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

  @override
  String get marketTitle => 'Comprar mercadería';

  @override
  String get marketNote =>
      'Comprar cuesta más de lo que paga un pedido. Es un atajo cuando te falta un producto, no una forma de ganar monedas.';

  @override
  String get marketLocked => 'Sube de nivel para desbloquear';

  @override
  String buyFor(int price) {
    return 'Comprar por $price';
  }

  @override
  String itemActionsTitle(String name, int level) {
    return '$name, nivel $level';
  }

  @override
  String get splitAction => 'Separar en dos';

  @override
  String splitInto(String name, int cost) {
    return 'Separar en dos $name por $cost';
  }

  @override
  String get splitNotPossible =>
      'Los productos de nivel 1 no se pueden separar';

  @override
  String get expandTitle => 'Ampliar el mesón';

  @override
  String expandBody(int columns) {
    return 'Desbloquea una fila más de $columns casillas.';
  }

  @override
  String expandFor(int cost) {
    return 'Ampliar por $cost';
  }

  @override
  String get boardMaxSize => 'El mesón ya está en su tamaño máximo.';

  @override
  String get lockedRow => 'Fila bloqueada. Toca para ampliar.';

  @override
  String get timeBonusLab => 'x1,5';

  @override
  String timeBonusTooltip(String time) {
    return 'Entrega antes de $time y ganas bonificación';
  }

  @override
  String toastBought(int price) {
    return 'Comprado por $price';
  }

  @override
  String toastSplit(int cost) {
    return 'Separado por $cost';
  }

  @override
  String get toastExpanded => 'Mesón ampliado';

  @override
  String get toastCannotSplit => 'Ese producto no se puede separar.';

  @override
  String toastTimeBonus(int reward) {
    return '¡Entrega rápida! +$reward';
  }

  @override
  String perHourShort(int amount) {
    return '$amount/h';
  }

  @override
  String get buy => 'Comprar';

  @override
  String get chainEggs => 'Huevos';

  @override
  String get chainCleaning => 'Aseo';

  @override
  String get eggs1 => 'Huevo';

  @override
  String get eggs2 => 'Media docena';

  @override
  String get eggs3 => 'Bandeja de huevos';

  @override
  String get cleaning1 => 'Jabón';

  @override
  String get cleaning2 => 'Detergente';

  @override
  String get cleaning3 => 'Pack de limpieza';

  @override
  String get cleaning4 => 'Estante de aseo';

  @override
  String get next => 'Siguiente';

  @override
  String get deliverPartial => 'Entregar parte';

  @override
  String toastPartial(int reward) {
    return 'Entrega parcial. +$reward';
  }

  @override
  String get tillLabel => 'Caja';

  @override
  String get tillFull => 'Caja llena';

  @override
  String tillSemantics(int amount, int capacity) {
    return 'Caja: $amount de $capacity monedas. Toca para cobrar.';
  }

  @override
  String tillCollect(int amount) {
    return 'Cobrar $amount';
  }

  @override
  String get tillEmpty => 'Todavía no hay nada que cobrar';

  @override
  String get tillUpgradeTitle => 'Ampliar la caja';

  @override
  String tillUpgradeBody(int hours, int next) {
    return 'Aguanta $hours h de ganancia. Ampliada, $next h.';
  }

  @override
  String tillUpgradeFor(int cost) {
    return 'Ampliar por $cost';
  }

  @override
  String get tillAtMax => 'La caja ya está en su tamaño máximo.';

  @override
  String toastTillCollected(int amount) {
    return 'Cobraste $amount';
  }

  @override
  String get toastTillUpgraded => 'Caja ampliada';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get notificationsSub =>
      'Caja llena, fin del turno y monedas para mejorar';

  @override
  String get notificationTillFullTitle => 'Tu caja está llena';

  @override
  String get notificationTillFullBody =>
      'Tu almacén dejó de vender. Pasa a cobrar.';

  @override
  String get notificationsBlocked =>
      'Las notificaciones están apagadas en Android';

  @override
  String get bakery6 => 'Torta de cumpleaños';

  @override
  String get drinks6 => 'Caja de bebidas';

  @override
  String get snacks6 => 'Caja de golosinas';

  @override
  String get pets5 => 'Saco de alimento';

  @override
  String get cleaning5 => 'Caja de limpieza';

  @override
  String get fruit1 => 'Manzana';

  @override
  String get fruit2 => 'Bolsa de manzanas';

  @override
  String get fruit3 => 'Cajón de fruta';

  @override
  String get fruit4 => 'Pallet de fruta';

  @override
  String get dairy1 => 'Yogur';

  @override
  String get dairy2 => 'Pack de yogures';

  @override
  String get dairy3 => 'Litro de leche';

  @override
  String get dairy4 => 'Queso fresco';

  @override
  String get dairy5 => 'Rueda de queso';

  @override
  String get dairy6 => 'Caja de lácteos';

  @override
  String get dairy7 => 'Cámara de lácteos';

  @override
  String get frozen1 => 'Paleta de helado';

  @override
  String get frozen2 => 'Pote de helado';

  @override
  String get frozen3 => 'Bolsa de verdura';

  @override
  String get frozen4 => 'Pizza congelada';

  @override
  String get frozen5 => 'Caja de congelados';

  @override
  String get frozen6 => 'Pila de congelados';

  @override
  String get frozen7 => 'Congelador chico';

  @override
  String get frozen8 => 'Cámara de frío';

  @override
  String get stationery1 => 'Lápiz';

  @override
  String get stationery2 => 'Estuche';

  @override
  String get stationery3 => 'Cuaderno';

  @override
  String get stationery4 => 'Set escolar';

  @override
  String get stationery5 => 'Caja de librería';

  @override
  String get chainFruit => 'Frutas y verduras';

  @override
  String get chainDairy => 'Lácteos';

  @override
  String get chainFrozen => 'Congelados';

  @override
  String get chainStationery => 'Librería';

  @override
  String get achShop12 => 'El almacén del barrio';

  @override
  String get achShop17 => 'Minimarket';

  @override
  String get achShop22 => 'Local renovado';

  @override
  String get achShop27 => 'Imperio de barrio';

  @override
  String get achAlbum3 => 'Álbum completo';

  @override
  String get goalsTitle => 'Metas';

  @override
  String get missionsToday => 'Hoy';

  @override
  String get missionsSub =>
      'Se renuevan mañana. No pasa nada si no alcanzas: mañana hay otras tres.';

  @override
  String missionsLocked(int level) {
    return 'Las misiones diarias se abren en el nivel $level';
  }

  @override
  String get achievementsAll => 'Logros de siempre';

  @override
  String get missionDone => 'Listo';

  @override
  String get mDailyMerges => 'Junta mercadería';

  @override
  String get mDailyMergesBig => 'Día de mostrador';

  @override
  String get mDailyOrders => 'Atiende a los clientes';

  @override
  String get mDailyOrdersBig => 'Día de mucha gente';

  @override
  String get mDailyGenerate => 'Pide al proveedor';

  @override
  String get mDailyHighLevel => 'Mercadería fina';

  @override
  String get mDailyCoins => 'Haz caja';

  @override
  String get mDailyTill => 'Pasa a cobrar';

  @override
  String mDescMerges(int n) {
    return 'Junta $n pares hoy';
  }

  @override
  String mDescOrders(int n) {
    return 'Entrega $n pedidos hoy';
  }

  @override
  String mDescGenerate(int n) {
    return 'Pide $n unidades al proveedor hoy';
  }

  @override
  String mDescHighLevel(int n) {
    return 'Consigue $n productos de nivel 4 o más hoy';
  }

  @override
  String mDescCoins(int n) {
    return 'Gana $n monedas hoy';
  }

  @override
  String mDescTill(int n) {
    return 'Cobra la caja $n veces hoy';
  }

  @override
  String get toastMissionsRefreshed => 'Hay misiones nuevas';

  @override
  String get tutorialSupply =>
      'Toca la caja del proveedor para traer mercadería al mesón.';

  @override
  String get tutorialReadOrder =>
      'Cada tarjeta de arriba es un cliente. Te muestra qué producto quiere y de qué nivel.';

  @override
  String get tutorialTill =>
      'Tu local vende solo mientras no juegas. Toca la caja para cobrar lo juntado —cuando se llena, deja de juntar.';

  @override
  String get helpTitle => 'Cómo se juega';

  @override
  String get helpOpen => 'Cómo se juega';

  @override
  String get helpOpenSub => 'Repasa las reglas cuando quieras';

  @override
  String get helpLoopTitle => 'El bucle';

  @override
  String get helpLoopBody =>
      'Pides mercadería al proveedor, juntas dos iguales para conseguir una mejor, y se la entregas al cliente que la pidió. Entregar es lo único que da experiencia.';

  @override
  String get helpMergeTitle => 'Juntar';

  @override
  String get helpMergeBody =>
      'Dos productos iguales del mismo nivel se convierten en uno del nivel siguiente. Vale más que los dos por separado, así que juntar siempre conviene. Al arrastrar, la casilla de destino se pone verde si se van a juntar y roja si sólo se van a intercambiar.';

  @override
  String get helpOrdersTitle => 'Los pedidos';

  @override
  String get helpOrdersBody =>
      'Cada tarjeta muestra el producto que quiere el cliente y su nivel. Los pedidos no caducan nunca: si entregas dentro de los primeros minutos pagan más, pero pasado ese rato pagan lo normal. Nadie te castiga por guardar el teléfono.';

  @override
  String get helpTillTitle => 'La caja';

  @override
  String get helpTillBody =>
      'Tu local vende solo mientras no juegas y lo guarda en la caja. Se cobra tocándola. Tiene tope: cuando se llena deja de juntar, así que conviene pasar a cobrar. Puedes ampliarla en la tienda.';

  @override
  String get helpShopTitle => 'Subir el local';

  @override
  String helpShopBody(int max) {
    return 'Con monedas subes el local, hasta el nivel $max. Cada nivel gana más por hora, y cada cinco niveles el local estrena fachada. Las estrellas del nombre dicen cuánto llevas dentro de la fachada actual.';
  }

  @override
  String get helpGoalsTitle => 'Metas';

  @override
  String get helpGoalsBody =>
      'Cada día hay tres misiones nuevas: son lo que se puede hacer hoy. Si no alcanzas a cumplirlas no pierdes nada, mañana hay otras tres. Los logros, en cambio, son de toda la partida.';

  @override
  String get helpHelpersTitle => 'Ayudas';

  @override
  String helpHelpersBody(int worker) {
    return '\"Ordenar\" acomoda la mercadería por tipo y nivel para que veas qué se puede juntar. Manteniendo apretada la caja del proveedor se llena el mesón de una vez. Desde el nivel $worker de local puedes contratar a alguien por horas que junta y pide por ti mientras no estás.';
  }

  @override
  String get settingsSectionVoice => 'Tu opinión';

  @override
  String get feedbackSend => 'Enviar comentarios';

  @override
  String get feedbackSendSub =>
      'Cuéntanos qué te gustó y qué no. Lo leemos todo.';

  @override
  String get feedbackSubject => 'Comentarios sobre El Kiosko';

  @override
  String get feedbackIntro =>
      'Escribe aquí tu comentario, idea o el problema que encontraste:';

  @override
  String get feedbackDiagnostics =>
      'Datos técnicos (ayudan a encontrar el problema; puedes borrarlos)';

  @override
  String get feedbackRate => 'Calificar en Google Play';

  @override
  String get feedbackRateSub =>
      'Una calificación ayuda a que otros lo encuentren';

  @override
  String get feedbackNoMail => 'No se pudo abrir el correo';
}
