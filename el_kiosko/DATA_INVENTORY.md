# DATA_INVENTORY.md

Qué datos toca la app, dónde viven y por cuánto tiempo. Este documento es la
**fuente** de la que se derivan `DATA_SAFETY.md` y `PRIVACY_POLICY_DRAFT.md`:
si algo cambia acá, hay que cambiar los otros dos.

Estado a **2026-08-22** · versión **0.1.0+1** · Fase 1.

---

## 1. Resumen ejecutivo

**La app no recolecta datos personales, no los transmite y no requiere cuenta.**
Todo lo que guarda es el progreso de la partida, en el almacenamiento privado
del propio teléfono.

---

## 2. Datos que la app escribe

Un único archivo: `almacen_save.json`, en el directorio de documentos privado
de la app (sandbox de Android; ninguna otra app puede leerlo).

| Campo | Ejemplo | ¿Es dato personal? |
|---|---|:---:|
| Estado del tablero | posiciones, cadena y nivel de cada producto | No |
| Monedas | `1234` | No |
| XP y nivel de jugador | `456`, `4` | No |
| Nivel del local | `3` | No |
| Pedidos activos | producto, cantidad, recompensa | No |
| Álbum de productos descubiertos | `["panaderia:1", ...]` | No |
| Contadores de sesión | merges y pedidos completados | No |
| Ajustes | sonido, vibración, animaciones, sugerencias, avisos, idioma | No |
| Nivel de la caja | `2` | No |
| `lastSeenAt` | marca de tiempo del último guardado | No |
| Semilla de aleatoriedad | entero | No |
| Versión de esquema y de economía | `1`, `1` | No |

`lastSeenAt` es un timestamp local usado **sólo** para calcular la ganancia
pasiva al volver. No se transmite a ningún lado.

---

## 3. Datos que la app NO toca

Ubicación · contactos · teléfono · SMS · fotos y galería · micrófono · cámara ·
calendario · nombre real · fecha de nacimiento · correo · cuenta de Google ·
Advertising ID · Android ID · IMEI · MAC · lista de apps instaladas ·
historial de navegación.

---

## 4. Transmisión

**Ninguna.** Los avisos de "caja llena" son **locales**: los programa y los
muestra el propio teléfono. No hay servidor de push, ni token, ni nada que
salga del dispositivo. La app no declara el permiso `INTERNET` en producción y no abre
sockets. Funciona íntegramente en modo avión.

---

## 5. Terceros con acceso

**Ninguno.** No hay procesadores, ni analytics, ni publicidad, ni backend.

---

## 6. Retención y borrado

Los datos viven mientras la app esté instalada. El usuario los elimina por
completo desinstalando la app, o desde Ajustes de Android →
Almacenamiento → Borrar datos. No hay copia en ningún servidor, por lo que no
existe nada que borrar del lado nuestro.

Nota: si el usuario tiene activada la copia de seguridad de Android, el sistema
puede respaldar los datos de la app en su propia cuenta de Google. Eso lo
controla el usuario en los ajustes de Android, y el respaldo queda bajo su
cuenta, no bajo la nuestra.

---

## 7. Menores de edad

La app está dirigida a **adultos**. No se hace marketing hacia niños y no se
declarará como app infantil en Play Console.

---

## 8. Ley 21.719 (Chile)

Entra en vigencia el **1 de diciembre de 2026**. Aunque el lanzamiento sería
antes, el diseño ya apunta a minimizar retrabajo:

| Principio | Cómo se cumple hoy |
|---|---|
| Finalidad | El único dato guardado es el progreso, para poder continuar la partida |
| Minimización | No se pide ningún dato que el juego no necesite |
| Seguridad | Almacenamiento privado de la app; sin transmisión |
| Transparencia | Este documento + la política de privacidad derivada de él |
| Derechos del titular | Sin datos personales tratados, no hay base de datos que consultar, rectificar ni portar |
| Control de terceros | No hay terceros |

⚠️ Esto **no** sustituye asesoría legal. Y cambia por completo en cuanto entren
Firebase o AdMob (Fase 2–3): en ese momento este documento debe reescribirse
antes de publicar.
