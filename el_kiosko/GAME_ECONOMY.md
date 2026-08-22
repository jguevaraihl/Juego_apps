# GAME_ECONOMY.md

Todos los números viven en `lib/game/economy/economy_config.dart` y las
fórmulas en `lib/game/economy/economy.dart`. Nada de balance está hardcodeado
en la UI.

`EconomyConfig.version` (hoy **1**) viaja en cada evento de analytics y en el
save, para poder comparar cohortes cuando cambie el balance.

---

## 1. Fórmulas

```text
valor(nivel)        = round(3 × 2.6^(nivel-1))
venta(nivel)        = max(1, floor(valor(nivel) × 0.5))
recompensa(pedido)  = round(valor_pedido_total × 1.6)
bonus(pedido)       = recompensa × 2.0
reroll(pedido)      = max(5, round(recompensa × 0.35))
xp(pedido)          = Σ(nivel × cantidad) × 3
xp_para_nivel(n)    = round(30 × (n-1)^1.6)
nivel_máx_pedido(l) = clamp(1 + (l+1)÷2, 1, 5)
offline(t)          = floor(ingreso_hora × min(t_horas, 4))
```

---

## 2. Tabla de productos

| Nivel | Valor | Venta | Recompensa pedido (1u) | Generaciones necesarias | Costo de producir | Margen |
|---:|---:|---:|---:|---:|---:|---:|
| 1 | 3 | 1 | 5 | 1 | 3 | +2 |
| 2 | 8 | 4 | 13 | 2 | 6 | +7 |
| 3 | 20 | 10 | 32 | 4 | 12 | +20 |
| 4 | 53 | 26 | 85 | 8 | 24 | +61 |
| 5 | 137 | 68 | 219 | 16 | 48 | +171 |

Dos lecturas importantes:

1. **Fusionar siempre conviene.** `valor(n+1) > 2 × valor(n)` en toda la
   escalera. Si no fuera así, la mecánica central sería una mala jugada.
2. **Los niveles altos son mucho más rentables.** El margen pasa de +2 a +171.
   Eso es lo que hace que el jugador quiera fusionar hacia arriba en vez de
   entregar todo en nivel 1.

---

## 3. Invariantes protegidos por tests

Están en `test/economy_test.dart`. Un cambio de balance que los rompa **falla
en CI**, no en producción.

| Invariante | Por qué importa |
|---|---|
| `venta(1) < costo_generar` (1 < 3) | Si no, generar+vender es una máquina infinita de monedas |
| `venta(n) ≤ valor(n)` | Vender nunca puede pagar más de lo que vale |
| `valor(n+1) > 2 × valor(n)` | Fusionar tiene que convenir |
| `recompensa(n) > costo_producir(n)` | Un pedido nunca puede dejar pérdida |
| `levelForXp(xpForLevel(n)) == n` | La curva de nivel es consistente |
| `0 ≤ progreso ≤ 1` | La barra de XP no se desborda |
| reloj hacia atrás ⇒ offline = 0 | Cambiar la hora del teléfono no es un atajo |

---

## 4. Curva de jugador

| Nivel jugador | XP acumulada | Nivel máx. de pedido |
|---:|---:|---:|
| 1 | 0 | 2 |
| 2 | 30 | 2 |
| 3 | 91 | 3 |
| 4 | 174 | 3 |
| 5 | 276 | 4 |
| 6 | 394 | 4 |
| 7 | 527 | 5 |
| 8 | 675 | 5 |
| 10 | 1.009 | 5 |

**Nivel 2 (30 XP)** llega en unos 2–3 pedidos y desbloquea la cadena de Snacks:
es el primer momento de desbloqueo, deliberadamente temprano.

---

## 5. Parámetros de partida

| Parámetro | Valor | Nota |
|---|---:|---|
| Monedas iniciales | 60 | ~20 generaciones de colchón |
| Costo de generar | 3 | |
| Tablero | 6 × 8 = 48 | |
| Pedidos visibles | 3 | |
| Tope de ganancia offline | 4 h | |
| Mínimo para avisar ganancia offline | 5 | Bajo eso no se molesta al jugador |
| Rescate por bloqueo | 5 generaciones (15) | Gratis, sin anuncio |
| Segundos hasta sugerencia | 12 | Apagable |

---

## 6. Objetivo de calibración de los primeros 5 minutos

El brief fija: **una mejora significativa dentro de los primeros 3–5 minutos**.

Camino esperado: con 60 monedas iniciales el jugador hace ~20 generaciones,
fusiona hasta nivel 2–3 y entrega entre 6 y 10 pedidos. Con márgenes de +7 a
+20 por pedido, junta las **150** monedas del Kiosko dentro de ese rango.

⚠️ **Esto es una estimación de diseño, no un dato medido.** Es exactamente lo
que Gate A tiene que verificar con jugadores reales. Si el Kiosko llega
demasiado tarde, las palancas, en orden de preferencia:

1. subir `orderRewardMultiplier` (1.6 → 1.8);
2. bajar el costo del nivel 2 (150 → 120);
3. subir `startingCoins`.

---

## 7. Todavía no existe

Rachas, bonus diario acumulativo, misiones, eventos de temporada y desafíos
semanales están en el brief como retención de Fase 2+. No se implementaron para
no expandir el alcance antes de que el core loop sea evaluable.
