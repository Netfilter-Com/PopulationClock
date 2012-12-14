from constants import *
from xml.dom import minidom

def main():
    # Open the base doc and get the root
    base_doc = minidom.parse("map.svg")
    root = base_doc.getElementsByTagName("svg")[0]

    # Clone the root to get a clean XML
    new_root = root.cloneNode(False)

    # The current color
    color = 1

    # A dictionary associating colors to countries
    colors = {}

    # Enumerate the groups
    groups = base_doc.getElementsByTagName("g")
    for group in groups:
        # Find the country
        country = group.getAttribute("id")
        if country not in COUNTRY_CODES:
            continue

        # Clone the group
        new_group = group.cloneNode(True)

        # Format the color as an hex string
        colorStr = hex(color + color * 256 + color * 256 * 256)[2:]
        if len(colorStr) == 5:
            colorStr = "0" + colorStr
        colorStr = "#" + colorStr

        # Find the path elements and adjust their color
        paths = new_group.getElementsByTagName("path")
        for path in paths:
            path.setAttribute("fill", colorStr)
            if path.hasAttribute("stroke"):
                path.removeAttribute("stroke")
            if path.hasAttribute("stroke-width"):
                path.removeAttribute("stroke-width")
            if path.hasAttribute("stroke-miterlimit"):
                path.removeAttribute("stroke-miterlimit")

        # Add to the new root
        new_root.appendChild(new_group)

        # Add the color to the dictionary
        colors[color] = country
        color += 1

    # Same thing for standalone paths
    paths = base_doc.getElementsByTagName("path")
    for path in paths:
        # Find the country
        country = path.getAttribute("id")
        if country not in COUNTRY_CODES:
            continue

        # Clone the path
        new_path = path.cloneNode(True)

        # Format the color as an hex string
        colorStr = hex(color + color * 256 + color * 256 * 256)[2:]
        if len(colorStr) == 5:
            colorStr = "0" + colorStr
        colorStr = "#" + colorStr

        # Adjust the color
        new_path.setAttribute("fill", colorStr)
        if new_path.hasAttribute("stroke"):
            new_path.removeAttribute("stroke")
        if new_path.hasAttribute("stroke-width"):
            new_path.removeAttribute("stroke-width")
        if new_path.hasAttribute("stroke-miterlimit"):
            new_path.removeAttribute("stroke-miterlimit")

        # Add to the new root
        new_root.appendChild(new_path)

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
