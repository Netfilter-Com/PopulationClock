from os import path, sys
sys.path.append(path.abspath(path.join(path.dirname(__file__), '..')))

from shared.constants import *
from xml.dom import minidom
import csv

DATA = [
    {
        "filename": "BirthRate",
        "key": "birthRate"
    },
    {
        "filename": "BirthsPerWoman",
        "key": "birthsPerWoman"
    },
    {
        "filename": "CO2E.KT",
        "key": "co2Emissions"
    },
    {
        "filename": "DeathRate",
        "key": "deathRate"
    },
    {
        "filename": "GrowthRate",
        "key": "growthRate"
    },
    {
        "filename": "ElectricityAccess",
        "key": "electricityAccess"
    },
    {
        "filename": "ElectricityConsumption",
        "key": "electricityConsumption"
    },
    {
        "filename": "ForestAreaPercent",
        "key": "forestArea"
    },
    {
        "filename": "GDP.GROWTH",
        "key": "gdpGrowth"
    },
    {
        "filename": "GDP.PCAP",
        "key": "gdpPerCapita"
    },
    {
        "filename": "GDP",
        "key": "gdp"
    },
    {
        "filename": "HealthExpensePercentGDP",
        "key": "healthExpensePercentGDP"
    },
    {
        "filename": "LifeExpect",
        "key": "lifeExpectancy"
    },
    {
        "filename": "MobileUsersPer100",
        "key": "mobileUsersPer100"
    },
    {
        "filename": "PercentInternetUsers",
        "key": "internetUsers"
    },
    {
        "filename": "TotalPopulation",
        "key": "population",
        "needsYear": True
    }
]

processed = {}

mapCountries = []

# Entries that have no World Bank data and are not in the map, so they can't
# come from the CSVs. Antarctica has no permanent population: the figure is
# the approximate number of people wintering at research stations. The other
# entries are small territories (and Taiwan and the Holy See) that the World
# Bank does not report: rounded figures from public national statistics
# offices and encyclopedias for the year given, meant as estimates. Mayotte is
# left out on purpose because the app has no description text for it.
MANUAL_COUNTRIES = {
    "aq": {
        "birthRate": 0.0,
        "deathRate": 0.0,
        "growthRate": 0.0,
        "population": 1000,
        "populationYearValue": 2025,
    },
    "tw": {
        "birthRate": 5.8,
        "deathRate": 8.6,
        "growthRate": -0.2,
        "population": 23400000,
        "populationYearValue": 2024,
    },
    "va": {
        "birthRate": 0.0,
        "deathRate": 0.0,
        "growthRate": 0.0,
        "population": 764,
        "populationYearValue": 2023,
    },
    "gi": {
        "birthRate": 12.0,
        "deathRate": 8.0,
        "growthRate": 0.4,
        "population": 34000,
        "populationYearValue": 2024,
    },
    "je": {
        "birthRate": 8.7,
        "deathRate": 8.7,
        "growthRate": 0.8,
        "population": 103000,
        "populationYearValue": 2023,
    },
    "gg": {
        "birthRate": 8.0,
        "deathRate": 9.5,
        "growthRate": 0.1,
        "population": 64400,
        "populationYearValue": 2023,
    },
    "ck": {
        "birthRate": 13.0,
        "deathRate": 7.0,
        "growthRate": -0.5,
        "population": 15000,
        "populationYearValue": 2023,
    },
    "ai": {
        "birthRate": 11.0,
        "deathRate": 6.0,
        "growthRate": 0.9,
        "population": 15900,
        "populationYearValue": 2024,
    },
    "ms": {
        "birthRate": 13.0,
        "deathRate": 8.0,
        "growthRate": 0.0,
        "population": 4400,
        "populationYearValue": 2023,
    },
    "fk": {
        "birthRate": 11.0,
        "deathRate": 8.0,
        "growthRate": 0.4,
        "population": 3700,
        "populationYearValue": 2021,
    },
    "nr": {
        "birthRate": 24.0,
        "deathRate": 7.0,
        "growthRate": 0.6,
        "population": 12500,
        "populationYearValue": 2023,
    },
    "nu": {
        "birthRate": 11.0,
        "deathRate": 7.0,
        "growthRate": 0.0,
        "population": 1600,
        "populationYearValue": 2022,
    },
    "pm": {
        "birthRate": 8.0,
        "deathRate": 9.0,
        "growthRate": -0.5,
        "population": 5800,
        "populationYearValue": 2022,
    },
    "pn": {
        "birthRate": 0.0,
        "deathRate": 0.0,
        "growthRate": 0.0,
        "population": 47,
        "populationYearValue": 2023,
    },
    "sh": {
        "birthRate": 10.0,
        "deathRate": 11.0,
        "growthRate": -0.5,
        "population": 5600,
        "populationYearValue": 2023,
    },
    "vg": {
        "birthRate": 11.0,
        "deathRate": 5.0,
        "growthRate": 1.0,
        "population": 31000,
        "populationYearValue": 2023,
    },
    "wf": {
        "birthRate": 11.0,
        "deathRate": 6.0,
        "growthRate": -1.0,
        "population": 11500,
        "populationYearValue": 2023,
    },
    "bl": {
        "birthRate": 10.0,
        "deathRate": 5.0,
        "growthRate": 0.8,
        "population": 10900,
        "populationYearValue": 2021,
    },
}


def read_map_countries():
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

        # Add to the list
        mapCountries.append(country)


def read_csv(d):
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
            else:
                print(">>> Unknown country:", country3)
                continue

            # Ignore countries that are not in the map
            if country != "world" and country not in mapCountries:
                print(">>> Ignoring country", country, "(not in the map)")
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
            if val is None:
                print(">>> Country with no data in", d["filename"] + ":", country)
                continue

            # Add a dict for the country if we don't have one
            if country not in processed:
                processed[country] = {}

            # Add this data point
            processed[country][d["key"]] = val
            if "needsYear" in d and d["needsYear"]:
                processed[country][d["key"] + "Year"] = year


def main():
    # Read the list of countries in the map
    read_map_countries()

    # Process the CSV files
    for d in DATA:
        read_csv(d)

    # Drop any country missing total population, birth rate, death rate
    # or growth rate - the app's SimulationEngine and country list assume
    # every entry has all four (e.g. it indexes a year cache by
    # populationYear, which throws if that key is absent)
    required = ("birthRate", "deathRate", "population", "growthRate")
    for country in list(processed.keys()):
        ind = processed[country]
        missing = [f for f in required if f not in ind]
        if missing:
            print("Country with missing", ", ".join(missing) + ", dropping:", country)
            del processed[country]

    # Add the manually maintained entries
    for country, ind in MANUAL_COUNTRIES.items():
        ind = dict(ind)
        ind["populationYear"] = ind.pop("populationYearValue")
        processed[country] = ind

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
            typestr = "integer" if k == "population" or k.endswith("Year") else "real"
            if typestr == "integer":
                v = int(v)
            outd.appendChild(doc.createElementNS(None, typestr))
            outd.lastChild.appendChild(doc.createTextNode(str(v)))

    # Write the plist
    with open("data.plist", "w") as f:
        doc.writexml(f)

if __name__ == "__main__":
    main()
