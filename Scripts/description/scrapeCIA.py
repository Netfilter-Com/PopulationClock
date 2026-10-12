#!/usr/bin/env python3
# coding: utf-8
"""
    Scrape country descriptions and electricity consumption from the
    CIA World Factbook, via the maintained JSON mirror at
    https://github.com/factbook/factbook.json (the Factbook's own site
    has been JS-rendered and un-scrapable since the 2021 redesign).

    LEGACY: the CIA discontinued the World Factbook in February 2026, so
    there is nothing new to fetch, and Resources/Description.strings is now
    the source of truth (it has been cleaned up by hand and has one added
    note, for Antarctica, that a re-run would erase). Running this script
    overwrites those edits, so it refuses to run without --force.

    Prints the country descriptions in .strings format to stdout
    (python3 scrapeCIA.py --force > Description.strings). The electricity
    consumption it used to write is now derived from the World Bank
    (see ../data/data.py).

    factbook.json keys its files by the CIA's own two-letter GEC/FIPS
    country codes, not ISO 3166-1 alpha-2 (e.g. "gm" is Germany,
    "sp" is Spain) - ciaCountryCode.txt maps our ISO codes to those.
"""
import csv
import datetime
import json
import re
import sys
import time
import urllib.error
import urllib.request
from os import path

sys.path.append(path.abspath(path.join(path.dirname(__file__), '..')))
from shared.constants import CountryList

RAW_BASE = 'https://raw.githubusercontent.com/factbook/factbook.json/master'
API_CONTENTS = 'https://api.github.com/repos/factbook/factbook.json/contents/'
REGIONS = [
    'africa', 'antarctica', 'australia-oceania', 'central-america-n-caribbean',
    'central-asia', 'east-n-southeast-asia', 'europe', 'middle-east',
    'north-america', 'oceans', 'south-asia', 'south-america', 'world',
]

REQUEST_DELAY = 0.2


def escape(text, characters):
    for character in characters:
        text = text.replace(character, '\\' + character)
    return text


def quot(st):
    return '"' + st.replace("\n", "\\n").replace("\r", "\\r") + '"'


def load_iso_to_gec():
    """Map ISO 3166-1 alpha-2 -> the CIA's GEC/FIPS two-letter code."""
    path_ = path.join(path.dirname(__file__), 'ciaCountryCode.txt')
    mapping = {}
    with open(path_, encoding='utf-8') as f:
        for line in f:
            fields = line.rstrip('\n').split(';')
            if len(fields) < 3:
                continue
            gec, iso = fields[1], fields[2]
            if iso and iso != '-' and gec and gec != '-':
                mapping[iso.upper()] = gec.lower()
    return mapping


def build_region_index():
    """Map each GEC code (filename stem) to the region directory that holds it."""
    index = {}
    for region in REGIONS:
        req = urllib.request.Request(
            API_CONTENTS + region,
            headers={'User-Agent': 'PopulationClock-data-pipeline'},
        )
        with urllib.request.urlopen(req) as u:
            entries = json.loads(u.read().decode())
        for entry in entries:
            name = entry['name']
            if name.endswith('.json'):
                index[name[:-len('.json')]] = region
    return index


def fetch_factbook_json(region, gec):
    url = f'{RAW_BASE}/{region}/{gec}.json'
    try:
        with urllib.request.urlopen(url) as u:
            return json.loads(u.read().decode())
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return None
        raise


def parse_electricity_kwh(text):
    if not text:
        return None
    # Strip the "(YYYY est.)"-style suffix
    text = re.sub(r'\([^)]*\)', '', text).strip()
    m = re.match(r'^([\d,.]+)\s*(thousand|million|billion|trillion)?\s*kWh', text, re.IGNORECASE)
    if not m:
        return None
    number = float(m.group(1).replace(',', ''))
    multipliers = {'thousand': 1e3, 'million': 1e6, 'billion': 1e9, 'trillion': 1e12}
    multiplier = multipliers.get((m.group(2) or '').lower(), 1)
    return number * multiplier


def main():
    if '--force' not in sys.argv:
        sys.exit('The World Factbook was discontinued and Resources/Description.strings '
                 'has manual edits. Run with --force if you really want to re-fetch it.')

    iso_to_gec = load_iso_to_gec()
    region_index = build_region_index()

    countries = list(CountryList.all())

    # (iso2 key for Description.strings, gec code, ISO3 code for the CSV)
    targets = [('world', 'xx', 'WLD')]
    for country in countries:
        iso2 = country.code(2).upper()
        gec = iso_to_gec.get(iso2)
        targets.append((country.code(2), gec, country.code(3, 'upper')))

    for iso2_key, gec, iso3 in targets:
        if not gec:
            print('>>> No CIA code for:', iso2_key, file=sys.stderr)
            continue

        region = region_index.get(gec)
        if not region:
            print('>>> Not in the Factbook:', iso2_key, file=sys.stderr)
            continue

        data = fetch_factbook_json(region, gec)
        time.sleep(REQUEST_DELAY)
        if data is None:
            print('>>> 404 fetching:', iso2_key, file=sys.stderr)
            continue

        description = data.get('Introduction', {}).get('Background', {}).get('text')
        if description:
            print('%s = %s;' % (quot(iso2_key), quot(escape(description, '"'))))
        else:
            print('>>> No description for:', iso2_key, file=sys.stderr)



if __name__ == '__main__':
    main()
