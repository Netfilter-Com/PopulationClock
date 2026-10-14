#!/bin/bash
# Mayotte is drawn in only 2-3 pixels and has no data of its own, so it is
# treated like French Guiana: part of France. This repaints its pixels with
# France's color index in each colormap image and drops it from colormap.plist.
#
# Run after colormap.sh (and add_antarctica.sh), with the generated colormap
# images and plist copied into ../../Resources. Idempotent.

set -e
cd "$(dirname "$0")/../../Resources"

YT=$(python3 -c "import plistlib; c=plistlib.load(open('colormap.plist','rb')); print(next((k for k,v in c.items() if v=='yt'), ''))")
FR=$(python3 -c "import plistlib; c=plistlib.load(open('colormap.plist','rb')); print(next(k for k,v in c.items() if v=='fr'))")

if [ -z "$YT" ]; then
    echo "colormap.plist has no 'yt' entry; nothing to do"
    exit 0
fi

for suffix in "" "@2x" "~iphone" "@2x~iphone"; do
    cm="colormap${suffix}.png"
    magick "$cm" -colorspace Gray -depth 8 -fill "gray($FR)" -opaque "gray($YT)" -depth 8 -colorspace Gray "$cm"
done

sed -i '' "s#<key>$YT</key><string>yt</string>##" colormap.plist
