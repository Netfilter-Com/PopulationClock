#!/bin/bash

set -e

#python colormap.py
python colormapGrowth.py
convert \
    -background black \
    -separate -average \
    -flatten -depth 32 \
    +dither +antialias \
    -density 100 \
    colormap.svg colormap.png
rm colormap.svg
