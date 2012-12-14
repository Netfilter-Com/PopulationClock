#!/usr/bin/python

import re
from xml.dom import minidom

def main():
    infos = []
    with open("coords.csv", "r") as f:
        while True:
            # Read a line
            line = f.readline()
            if line == "":
                break
            line = line.strip()
            if line == "":
                continue

            # Extract the info we need
            match = re.match("([A-Z]{2}); [^;]+; ([-]?\d+\.\d+); ([-]?\d+\.\d+)", line)
            if match == None:
                print ">>> Error parsing line: " + line
                continue

            # Store everything in a list
            country_code = match.group(1).lower()
            latitude = match.group(2)
            longitude = match.group(3)
            infos.append((country_code, latitude, longitude))

    # Create the plist
    doc = minidom.parseString("<plist><dict></dict></plist>")
    mydict = doc.getElementsByTagName("dict")[0]
    for info in infos:
        mydict.appendChild(doc.createElementNS(None, "key"))
        mydict.lastChild.appendChild(doc.createTextNode(info[0]))
        dict2 = doc.createElementNS(None, "dict")
        mydict.appendChild(dict2)
        dict2.appendChild(doc.createElementNS(None, "key"))
        dict2.lastChild.appendChild(doc.createTextNode("latitude"))
        dict2.appendChild(doc.createElementNS(None, "real"))
        dict2.lastChild.appendChild(doc.createTextNode(info[1]))
        dict2.appendChild(doc.createElementNS(None, "key"))
        dict2.lastChild.appendChild(doc.createTextNode("longitude"))
        dict2.appendChild(doc.createElementNS(None, "real"))
        dict2.lastChild.appendChild(doc.createTextNode(info[2]))

    # Write it to a file
    with open("coords.plist", "w") as f:
        doc.writexml(f)

if __name__ == "__main__":
    main()
