from constants import *
from xml.dom import minidom

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
    # Open the base doc and get the root
    base_doc = minidom.parse("../shared/map.svg")
    root = base_doc.getElementsByTagName("svg")[0]

    # Clone the root to get a clean XML
    new_root = root.cloneNode(False)

    # The current color
    color = 1

    # A dictionary associating colors to countries
    colors = {}

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

        # Format the color as an hex string
        colorStr = hex(color + color * 256 + color * 256 * 256)[2:]
        if len(colorStr) == 5:
            colorStr = "0" + colorStr
        colorStr = "#" + colorStr

        # Apply the color
        applyColor(new_el, colorStr)

        # Add to the new root
        new_root.appendChild(new_el)

        # Add the color to the dictionary
        colors[color] = country
        color += 1

    # Write the new SVG
    with open("colormap.svg", "w") as f:
        new_root.writexml(f)

    # Create the plist
    doc = minidom.parseString("<plist><dict></dict></plist>")
    mydict = doc.getElementsByTagName("dict")[0]
    for color in colors.keys():
        country = colors[color]
        mydict.appendChild(doc.createElementNS(None, "key"))
        mydict.lastChild.appendChild(doc.createTextNode(str(color)))
        mydict.appendChild(doc.createElementNS(None, "string"))
        mydict.lastChild.appendChild(doc.createTextNode(country))

    # Write the plist
    with open("colormap.plist", "w") as f:
        doc.writexml(f)

if __name__ == "__main__":
    main()
