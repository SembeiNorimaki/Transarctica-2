import os
import shutil
from PIL import Image

def copy_images_64x31(input_folder, output_folder):
    os.makedirs(output_folder, exist_ok=True)

    for filename in os.listdir(input_folder):
        if not filename.lower().endswith((".png", ".jpg", ".jpeg")):
            continue

        path = os.path.join(input_folder, filename)

        try:
            with Image.open(path) as img:
                w, h = img.size
        except:
            continue  # skip unreadable files

        if w == 64 and h == 31:
            shutil.copy2(path, os.path.join(output_folder, filename))
            print("Copied:", filename)

# Example:
copy_images_64x31("C:/Users/Isaac/Documents/grfcodec-master/BRIX_Realism_Is_XXXX-0.0.3/sprites/output", 
"C:/Users/Isaac/Downloads/tiles_out")