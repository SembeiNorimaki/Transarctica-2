import tkinter as tk
from tkinter import filedialog
import cv2
import numpy as np
import os


def select_file():
    file_path = filedialog.askopenfilename()
    if file_path:
        print("Selected file:", file_path)
        extract_sprites(file_path)

def extract_sprites(selected_filename):
    rootfolder, nfo_file = os.path.split(selected_filename)
    outputfolder = rootfolder + "/outputAAA/" 
    os.makedirs(outputfolder, exist_ok=True)
    prev_filename = ""
    with open (selected_filename, "r") as fin:
        i = 0
        for line in fin:            
            if line.startswith("//"):
                continue
            line = line.split()
            try:
                if line[0] == "|":
                    pass
                else:
                    idx = int(line[0])
            
                filepath_i = line[1]
                resolution = line[2]
                x = int(line[3])
                y = int(line[4])
                w = int(line[5])
                h = int(line[6])
                offx = int(line[7])
                offy = int(line[8])
                zoom = line[9]
                #misc = line[10]
            except:
                print(f"Error in idx {idx}")
                continue
            if filepath_i == "*":
                continue
            if idx < 0:
                continue
            
            if prev_filename != filepath_i:
                prev_filename = filepath_i
                p, f = os.path.split(filepath_i) 
                img = cv2.imread(f"{rootfolder}/{f}", cv2.IMREAD_UNCHANGED)
            try:
                #if img.shape[2] == 4:
                #print(idx)
                img2 = img[y : y+h , x: x+w, :]
                cv2.imwrite(f"{outputfolder}/{idx}_{zoom}.png", img2)
            except:
                print("Error")


root = tk.Tk()
root.title("File Selector")

select_button = tk.Button(root, text="Select File", command=select_file)
select_button.pack(padx=20, pady=20)

root.mainloop()