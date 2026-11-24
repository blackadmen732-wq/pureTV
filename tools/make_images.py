# Draws the white rounded shapes the app tints with blendColor (SceneGraph has no corner radius).
from pathlib import Path
from PIL import Image, ImageDraw

OUT = Path(__file__).resolve().parent.parent / "roku" / "images"

def shape(name, w, h, radius, stroke=0, pad=0):
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    box = (pad, pad, w - 1 - pad, h - 1 - pad)
    if stroke:
        ImageDraw.Draw(img).rounded_rectangle(box, radius, outline="white", width=stroke)
    else:
        ImageDraw.Draw(img).rounded_rectangle(box, radius, fill="white")
    img.save(OUT / name, optimize=True)

shape("tile.png", 332, 192, 20)
shape("tile_ring.png", 348, 208, 26, stroke=4)  # 8px clearance around the tile
shape("row.png", 1740, 64, 12)
shape("row_ring.png", 1740, 64, 12, stroke=3)
