from constants import *
from xml.dom import minidom
import re

MIN_COLOR = (0xff, 0x32, 0x00)
MAX_COLOR = (0xff, 0xe1, 0x00)

def applyColorToPath(path, color):
    path.setAttribute("fill", color)
    if path.hasAttribute("stroke"):
        path.removeAttribute("stroke")
    if path.hasAttribute("stroke-width"):
        path.removeAttribute("stroke-width")
    if path.hasAttribute("stroke-miterlimit"):
        path.removeAttribute("stroke-miterlimit")

def applyColor(el, color):
    # If this is a path, simply apply the color to it
    if el.tagName == "path":
        applyColorToPath(el, color)

    # Otherwise it must be a group, find the paths
    # and apply the color to them
    else:
        for child in el.childNodes:
            if isinstance(child, minidom.Element) and child.tagName == "path":
                applyColorToPath(child, color)

def main():
    # Read the input from the CSV to get the colors
    min_rate = 9999
    max_rate = -9999
    rates_per_country = {}
    with open("growth_2011.csv", "r") as f:
        while True:
            # Read a line
            line = f.readline()
            if line == "":
                break
            line = line.strip()
            if line == "":
                continue

            # Parse it
            match = re.match("(\w\w\w);(-{0,1}\d+),(\d+)", line)
            if match == None:
                print ">>> Error parsing line: " + line
                continue

            # Make sure we got the country
            country3 = match.groups()[0].upper()
            if country3 in COUNTRIES_3TO2:
                country = COUNTRIES_3TO2[country3]
            else:
                print ">>> Unknown country: " + country3
                continue

            # Turn the growth rate into a floating point number
            rate = float(match.groups()[1] + "." + match.groups()[2])

            # Check if it's the minimum or maximum rate
            if rate < min_rate:
                min_rate = rate
            elif rate > max_rate:
                max_rate = rate

            # Save in the dictionary
            rates_per_country[country] = rate

    # Interpolate the colors
    colors_per_country = {}
    for country in rates_per_country:
        rate = rates_per_country[country]
        rate_rel = (rate - min_rate) / (max_rate - min_rate)
        color = "#"
        for i in range(3):
            component = int(MIN_COLOR[i] + (MAX_COLOR[i] - MIN_COLOR[i]) * rate_rel)
            component = hex(component)[2:]
            if len(component) == 1:
                component = "0" + component
            color += component
        colors_per_country[country] = color

    # Open the base doc and get the root
    base_doc = minidom.parse("../shared/map.svg")
    root = base_doc.getElementsByTagName("svg")[0]

    # Clone the root to get a clean XML
    new_root = root.cloneNode(False)

    # Enumerate the paths and groups
    for child in root.childNodes:
        # Nothing to do if this isn't even an element
        if not isinstance(child, minidom.Element):
            continue

        # Nothing to do if it isn't a path or group
        if child.tagName != "path" and child.tagName != "g":
            continue

        # Find the country
        country = child.getAttribute("id")
        if country not in COUNTRY_CODES:
            continue

        # Clone this element
        new_el = child.cloneNode(True)

        # Apply the color, if possible
        country = country.upper()
        if country in colors_per_country:
            applyColor(new_el, colors_per_country[country])

        # Add to the new root
        new_root.appendChild(new_el)

    # Write the new SVG
    with open("growth.svg", "w") as f:
        new_root.writexml(f)

if __name__ == "__main__":
    main()
