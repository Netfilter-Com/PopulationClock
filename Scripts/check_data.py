#!/usr/bin/env python3
"""Consistency checks for the app's data and resources.

Every country in Resources/data.plist must have everything the app needs to
show it: a name, a flag (1x and 2x, added to the Xcode project), a
description, coordinates, and the numbers the simulation uses. The Brazilian
Portuguese strings must cover every string in the code.

Usage: python3 Scripts/check_data.py
Exit status is 1 when there are errors; warnings do not fail the run.
"""

import datetime
import glob
import os
import plistlib
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
errors, warnings = [], []


def path(*parts):
    return os.path.join(ROOT, *parts)


def read(*parts):
    with open(path(*parts), encoding="utf-8") as f:
        return f.read()


def load_plist(*parts):
    with open(path(*parts), "rb") as f:
        return plistlib.load(f)


def strings_keys(*parts):
    """Keys of a .strings file (the files are well-formed key = value pairs)."""
    text = read(*parts)
    return set(re.findall(r'^"((?:[^"\\]|\\.)*)"\s*=\s*"', text, re.M))


def unescape(s):
    return s.replace('\\"', '"').replace("\\n", "\n").replace("\\\\", "\\")


data = load_plist("Resources", "data.plist")
colormap = load_plist("Resources", "colormap.plist")
coords = load_plist("Resources", "coords.plist")
descriptions = strings_keys("Resources", "Description.strings")
project = read("PopulationClock.xcodeproj", "project.pbxproj")
data_manager = read("PopulationClock", "DataManager.m")
names = dict(re.findall(r'@"(\w\w)" : NSLocalizedString\(@"((?:[^"\\]|\\.)*)"', data_manager))
countries = sorted(code for code in data if code != "world")
this_year = datetime.date.today().year

# --- every country has what the app needs to show it
required_numbers = ["population", "populationYear", "birthRate", "deathRate", "growthRate"]
for code in countries:
    info = data[code]
    for key in required_numbers:
        if not isinstance(info.get(key), (int, float)):
            errors.append(f"{code}: data.plist is missing '{key}'")
    year = info.get("populationYear")
    if isinstance(year, int) and not (2000 <= year <= this_year):
        errors.append(f"{code}: populationYear {year} is not a plausible year")
    if isinstance(info.get("population"), (int, float)) and info["population"] <= 0:
        errors.append(f"{code}: population is {info['population']}")

    if code not in names:
        errors.append(f"{code}: no name in DataManager.m")
    for suffix in ("", "@2x"):
        flag = f"country_flag_{code}{suffix}.png"
        if not os.path.exists(path("Flags", flag)):
            errors.append(f"{code}: Flags/{flag} does not exist")
        elif flag not in project:
            errors.append(f"{code}: {flag} is not part of the Xcode project")
    if code not in descriptions:
        errors.append(f"{code}: no entry in Description.strings")
    if code not in coords:
        errors.append(f"{code}: no entry in coords.plist")

# --- the world entry
for key in ("population", "birthRate", "deathRate"):
    if not isinstance(data.get("world", {}).get(key), (int, float)):
        errors.append(f"world: data.plist is missing '{key}'")

# --- the map: tapping a country that has a polygon but no data does nothing
polygons = set(colormap.values())
for code in sorted(polygons - set(data)):
    warnings.append(f"{code}: has a map polygon but no data, so tapping it selects nothing")
for code in countries:
    if code not in polygons:
        warnings.append(f"{code}: has data but no polygon on the map (reachable only from the list)")

# --- loose ends
for code in sorted(set(descriptions) - set(data) - set(names)):
    warnings.append(f"{code}: in Description.strings but unknown to the app")
for code in sorted(set(names) - set(data)):
    warnings.append(f"{code}: named in DataManager.m but has no data (never listed)")

# --- Brazilian Portuguese covers every string in the code
code_keys = set()
for source in glob.glob(path("PopulationClock", "*.m")):
    with open(source, encoding="utf-8") as f:
        for key in re.findall(r'NSLocalizedString\(@"((?:[^"\\]|\\.)*)"', f.read()):
            code_keys.add(unescape(key))
pt_keys = {unescape(k) for k in strings_keys("PopulationClock", "pt-BR.lproj", "Localizable.strings")}
for key in sorted(code_keys - pt_keys):
    errors.append(f"pt-BR: no translation for \"{key[:60]}\"")
for key in sorted(pt_keys - code_keys):
    if key not in {"POPULATION:", " trillions", " billions", " millions", "Map", "Info", "List",
                   "Search", "Rotate for + info", "Share", "About", "World", "Country"}:
        warnings.append(f"pt-BR: \"{key[:60]}\" is not used by any NSLocalizedString")

for line in warnings:
    print("warning:", line)
for line in errors:
    print("error:", line)
print(f"{len(countries)} countries checked: {len(errors)} errors, {len(warnings)} warnings")
sys.exit(1 if errors else 0)
