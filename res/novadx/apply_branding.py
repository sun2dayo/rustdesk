#!/usr/bin/env python3
"""Gera os ícones NovaDX a partir de res/novadx/icon-512.png.

Corre no workflow novadx-windows.yml antes da compilação (precisa de Pillow).
Também pode ser corrido localmente a partir da raiz do repositório:
    pip install pillow && python res/novadx/apply_branding.py
"""
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / "res" / "novadx" / "icon-512.png"

ICO_SIZES = [(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
TRAY_SIZES = [(16, 16), (20, 20), (24, 24), (32, 32), (48, 48)]


def resized(img: Image.Image, size: int) -> Image.Image:
    return img.resize((size, size), Image.LANCZOS)


def main() -> None:
    img = Image.open(SRC).convert("RGBA")

    icos = {
        ROOT / "res" / "icon.ico": ICO_SIZES,
        ROOT / "flutter" / "windows" / "runner" / "resources" / "app_icon.ico": ICO_SIZES,
        ROOT / "res" / "tray-icon.ico": TRAY_SIZES,
    }
    for path, sizes in icos.items():
        img.save(path, format="ICO", sizes=sizes)
        print(f"ico  {path.relative_to(ROOT)}")

    pngs = {
        ROOT / "flutter" / "assets" / "icon.png": 256,
        ROOT / "res" / "icon.png": 512,
        ROOT / "res" / "32x32.png": 32,
        ROOT / "res" / "64x64.png": 64,
        ROOT / "res" / "128x128.png": 128,
        ROOT / "res" / "128x128@2x.png": 256,
    }
    for path, size in pngs.items():
        resized(img, size).save(path, format="PNG")
        print(f"png  {path.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
