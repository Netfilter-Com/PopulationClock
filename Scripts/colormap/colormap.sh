#!/bin/bash

set -e

PYTHONPATH=../shared python colormap.py
convert \
    -background black \
    -separate -average \
    -flatten -depth 8 \
    +dither +antialias \
    -density 100 \
    colormap.svg colormap.png
rm colormap.svg
