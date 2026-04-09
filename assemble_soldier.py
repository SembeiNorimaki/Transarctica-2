from PIL import Image
import matplotlib.pyplot as plt

fileparts = "assets/sprites/ZSRR_RED_OPS_MALE.png"
outputfile = "redops.png"
# Load the source image into "parts"
parts = Image.open(fileparts).convert("RGBA")

# Create a transparent 32x40 image
canvas = Image.new("RGBA", (32, 40), (0, 0, 0, 0))

ix = 3
iy = 2
# head, legs, 
partids=[[3,1],[3,2],[3,15], [8+3,15]]

w=32
h=40

dx = 0
dy = 0

for ids in partids:
    region = parts.crop((ids[0]*w, ids[1]*h, (ids[0]+1)*w, (ids[1]+1)*h))
    canvas.paste(region, (dx, dy), region)

canvas.save(outputfile, format="PNG")
#plt.imshow(canvas)
#plt.axis("off")
#plt.show()
