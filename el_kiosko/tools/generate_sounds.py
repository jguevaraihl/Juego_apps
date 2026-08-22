#!/usr/bin/env python3
"""Genera los efectos de sonido del juego por síntesis.

Se generan en vez de descargarse para que sean originales, con licencia
inequívoca y reproducibles (ver ASSET_LICENSES.md). Ejecutar desde el
directorio del proyecto:

    python3 tools/generate_sounds.py

Estilo: notas cortas y brillantes de una escala pentatónica mayor, que suben
de tono a medida que sube el nivel del producto. La pentatónica no tiene
intervalos disonantes, así que cualquier combinación suena bien aunque el
jugador encadene fusiones rápido.
"""

import math
import struct
import wave
from pathlib import Path

RATE = 22050
OUT = Path("assets/sounds")

# Pentatónica mayor de Do.
C5, D5, E5, G5, A5, C6, D6, E6 = 523.25, 587.33, 659.25, 783.99, 880.0, 1046.5, 1174.66, 1318.51


def envelope(i: int, total: int, attack: float, decay: float) -> float:
    """Ataque lineal muy corto y caída exponencial."""
    t = i / RATE
    a = min(1.0, t / attack) if attack > 0 else 1.0
    d = math.exp(-t / decay)
    # Rampa final para que nunca corte con un click.
    tail = min(1.0, (total - i) / (0.005 * RATE))
    return a * d * tail


def note(freq: float, seconds: float, *, decay: float = 0.18,
         harmonic: float = 0.28, glide: float = 0.0) -> list[float]:
    """Una nota: fundamental + segundo armónico, con glissando opcional."""
    total = int(RATE * seconds)
    out = []
    phase = 0.0
    for i in range(total):
        f = freq * (1.0 + glide * (i / total))
        phase += 2 * math.pi * f / RATE
        sample = math.sin(phase) + harmonic * math.sin(2 * phase)
        out.append(sample * envelope(i, total, 0.004, decay))
    return out


def sequence(notes: list[tuple[float, float]], gap: float = 0.0) -> list[float]:
    """Varias notas seguidas, con solape suave."""
    out: list[float] = []
    for freq, seconds in notes:
        piece = note(freq, seconds)
        start = max(0, len(out) - int(gap * RATE))
        for i, v in enumerate(piece):
            idx = start + i
            if idx < len(out):
                out[idx] += v
            else:
                out.append(v)
    return out


def write(name: str, samples: list[float]) -> None:
    peak = max((abs(s) for s in samples), default=1.0) or 1.0
    # Se deja headroom para que mezclar dos efectos no sature.
    scale = 0.62 / peak
    frames = b"".join(
        struct.pack("<h", max(-32768, min(32767, int(s * scale * 32767))))
        for s in samples
    )
    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / name
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(frames)
    print(f"{path}  {path.stat().st_size / 1024:.1f} KB")


def main() -> None:
    # Aparece un producto: blip corto que sube.
    write("spawn.wav", note(C5, 0.10, decay=0.05, harmonic=0.15, glide=0.35))

    # Levantar una ficha: casi un tick, no debe cansar al repetirse mucho.
    write("pick.wav", note(A5, 0.045, decay=0.02, harmonic=0.05))

    # Fusión: una nota por nivel resultante, subiendo la escala.
    for level, freq in ((2, E5), (3, G5), (4, A5), (5, C6)):
        write(f"merge_{level}.wav", note(freq, 0.18, decay=0.09, glide=0.06))

    # Nivel máximo de la cadena: acorde ascendente, se siente como un logro.
    write("max_level.wav", sequence([(G5, 0.12), (C6, 0.12), (E6, 0.26)], gap=0.05))

    # Cobrar un pedido: dos notas rápidas, el "cha-ching".
    write("coin.wav", sequence([(A5, 0.09), (D6, 0.20)], gap=0.03))

    # Mejorar el local: arpegio de tres notas.
    write("upgrade.wav", sequence([(C5, 0.11), (E5, 0.11), (G5, 0.28)], gap=0.04))

    # Vender un excedente: descendente, para distinguirlo de cobrar.
    write("sell.wav", sequence([(G5, 0.08), (D5, 0.16)], gap=0.03))


if __name__ == "__main__":
    main()
