from PIL import Image
import os

W, H = 256, 191   # fixed cell size

# Offsets per image index (0..18)
OFFSETS = {
    0: (0, 0),
    1: (0, 0),
    2: (0, -16),
    3: (0, -16),
    4: (0, 0),

    5: (0, 0),
    6: (0, -16),
    7: (0, -16),
    8: (0, -16),
    9: (0, -16),
    
    10: (0, 0),
    11: (0, -32),
    12: (0, -16),
    13: (0, -16),
    14: (0, -32),
    
    15: (0, 0),
    16: (0, 0),
    17: (0, -16),
    18: (0, 16)
}

# Custom order: which image index goes into each grid cell (0..19)
# Example: ORDER[0] = 7 means "grid cell 0 uses image 7"
ORDER = [
    0,  1,  2,  8,  4,
    5,  11,  7,  13, 14,
    10, 9, 12, 3, 6,
    15, 16, 17, 18
]

def make_grid(input_folder, output_path):
    files = sorted([
        f for f in os.listdir(input_folder)
        if f.lower().endswith((".png", ".jpg", ".jpeg"))
    ])

    if len(files) != 19:
        raise ValueError("Folder must contain exactly 20 images")

    # Load all images into memory indexed by 0..19
    images = [Image.open(os.path.join(input_folder, f)).convert("RGBA") for f in files]

    # Create transparent output image
    grid = Image.new("RGBA", (5 * W, 4 * H), (0, 0, 0, 0))

    for cell_index, img_index in enumerate(ORDER):
        img = images[img_index]
        iw, ih = img.size

        # Centering offsets
        cx = (W - iw) // 2
        cy = (H - ih) // 2

        # Per-image offset
        ox, oy = OFFSETS.get(img_index, (0, 0))

        row = cell_index // 5
        col = cell_index % 5

        x = col * W + cx + ox
        y = row * H + cy + oy

        grid.paste(img, (x, y), img)

    # Save result
    grid.save(output_path + "output.png")

make_grid(r"C:/Users/Isaac/Downloads/tiles_in/", r"C:/Users/Isaac/Downloads/tiles_out/")