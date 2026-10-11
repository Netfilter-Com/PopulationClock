#!/bin/bash
# Antarctica isn't a path in shared/map.svg (the in-app map images draw it in
# white), so colormap.py can't give it a color. This paints Antarctica's white
# pixels from each map image into the matching colormap image with a new color
# index and registers it as "aq" in colormap.plist.
#
# Run from this directory after colormap.sh, with the generated colormap
# images and plist copied into ../../Resources. Idempotent.

set -e
cd "$(dirname "$0")/../../Resources"

INDEX=227

if grep -q "<key>$INDEX</key>" colormap.plist; then
    echo "colormap.plist already has index $INDEX"
fi

for suffix in "" "@2x" "~iphone" "@2x~iphone"; do
    cm="colormap${suffix}.png"
    map="map${suffix}.png"
    size=$(magick identify -format "%wx%h" "$cm")
    h=$(magick identify -format "%h" "$cm")
    # Antarctica = near-white pixels in the bottom 20% of the map
    magick "$map" -filter Triangle -resize "${size}!" -colorspace Gray -threshold 94% \
        -fill black -draw "rectangle 0,0 99999,$((h * 8 / 10))" \
        -fill "rgb($INDEX,$INDEX,$INDEX)" -opaque white -depth 8 /tmp/aq_mask.png
    magick "$cm" -colorspace Gray -depth 8 /tmp/aq_mask.png -compose Lighten -composite -depth 8 "$cm"
done

if ! grep -q "<key>$INDEX</key>" colormap.plist; then
    sed -i '' "s#</dict>#<key>$INDEX</key><string>aq</string></dict>#" colormap.plist
fi
