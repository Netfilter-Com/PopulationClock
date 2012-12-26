from constants import *
from xml.dom import minidom
import csv

DATA = [
    {
        "filename" : "BirthRate",
        "key" : "birthRate"
    },
    {
        "filename" : "BirthsPerWoman",
        "key" : "birthsPerWoman"
    },
    {
        "filename" : "CO2E.KT",
        "key" : "co2Emissions"
    },
    {
        "filename" : "DeathRate",
        "key" : "deathRate"
    },
    {
        "filename" : "ElectricityAccess",
        "key" : "electricityAccess"
    },
    {
        "filename" : "ForestAreaPercent",
        "key" : "forestArea"
    },
    {
        "filename" : "GDP.GROWTH",
        "key" : "gdpGrowth"
    },
    {
        "filename" : "GDP.PCAP",
        "key" : "gdpPerCapita"
    },
    {
        "filename" : "GDP",
        "key" : "gdp"
    },
    {
        "filename" : "HealthExpensePercentGDP",
        "key" : "healthExpensePercentGDP"
    },
    {
        "filename" : "LifeExpect",
        "key" : "lifeExpectancy"
    },
    {
        "filename" : "MobileUsersPer100",
        "key" : "mobileUsersPer100"
    },
    {
        "filename" : "PassengerCarPer1000",
        "key" : "passengerCarPer1000"
    },
    {
        "filename" : "PercentInternetUsers",
        "key" : "internetUsers"
    },
    {
        "filename" : "TotalPopulation",
        "key" : "population",
        "needsYear" : True
    }
]

processed = {}

mapCountries = []

def readMapCountries():
    # Open the base doc and get the root
    base_doc = minidom.parse("../shared/map.svg")
    root = base_doc.getElementsByTagName("svg")[0]

    # Clone the root to get a clean XML
    new_root = root.cloneNode(False)

    # Enumerate the paths and groups
    mapa = []
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

        # Add to the list
        mapCountries.append(country)

def readCSV(d):
    # Open the CSV and parse it
    with open("csv/" + d["filename"] + ".csv", "r") as f:
        reader = csv.reader(f, delimiter=';')
        years = None
        for row in reader:
            # Handle the header row
            if row[0] == "Country Code":
                years = row[1:]
                continue

            # Get the country code
            country3 = row[0].lower()
            if country3 in COUNTRIES_3TO2:
                country = COUNTRIES_3TO2[country3]
            elif country3 == "wld":
                country = "world"
            elif len(country3)==2:
                country = country3
            else:
                print ">>> Unknown country: " + country3
                continue

            # Ignore countries that are not in the map
            if country != "world" and country not in mapCountries:
                print ">>> Ignoring country " + country + " (not in the map)"
                continue

            # Get the most recent data
            val = None
            year = None
            for idx in range(len(row) - 1, 0, -1):
                validx = row[idx]
                if validx != "":
                    validx = validx.replace(",", ".", 1)
                    val = float(validx)
                    year = years[len(row) - 2 - idx]
                    break

            # Skip countries for which we don't have data
            if val == None:
                print ">>> Country with no data in " + d["filename"] + ": " + country
                continue

            # Add a dict for the country if we don't have one
            if not country in processed:
                processed[country] = {}

            # Add this data point
            processed[country][d["key"]] = val
            if "needsYear" in d and d["needsYear"]:
                processed[country][d["key"] + "Year"] = year

def main():
    # Read the list of countries in the map
    readMapCountries()

    # Process the CSV files
    for d in DATA:
        readCSV(d)

    # Warn if there's any country without total population,
    # birth or death rate
    for country in processed.keys():
        ind = processed[country]
        missing = []
        if not "birthRate" in ind:
            missing.append("birth rate")
        if not "deathRate" in ind:
            missing.append("death rate")
        if not "population" in ind:
            missing.append("population")
        if len(missing) > 0:
            print "Country with missing " + ", ".join(missing) + ": " + country

    # Create the plist
    doc = minidom.parseString("<plist><dict></dict></plist>")
    mydict = doc.getElementsByTagName("dict")[0]
    for country in processed.keys():
        ind = processed[country]
        mydict.appendChild(doc.createElementNS(None, "key"))
        mydict.lastChild.appendChild(doc.createTextNode(country))
        outd = doc.createElementNS(None, "dict")
        mydict.appendChild(outd)
        for k in ind.keys():
            v = ind[k]
            outd.appendChild(doc.createElementNS(None, "key"))
            outd.lastChild.appendChild(doc.createTextNode(k))
            typestr = "integer" if k == "Population" or k.endswith("Year") else "real"
            if typestr == "integer":
                v = int(v)
            outd.appendChild(doc.createElementNS(None, typestr))
            outd.lastChild.appendChild(doc.createTextNode(str(v)))

    # Write the plist
    with open("data.plist", "w") as f:
        doc.writexml(f)

if __name__ == "__main__":
    main()
