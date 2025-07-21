from PIL import Image
import os
from pathlib import Path

files = os.listdir(Path())  # list of files in directory

for file in files:
    if file.endswith('.png'):  # check if file is png
        im = Image.open(file).convert("RGB")  # open file as an image object

        # save image as jpg with options
        im.save(Path("cmp") / Path(file[:-4] +
                '.jpeg'), quality=70, optimize=True)
