from __future__ import print_function
import urllib
import constants
from bs4 import BeautifulSoup
import re
from constants import *

url = "https://www.cia.gov/library/publications/the-world-factbook/geos/"

country_table = [i.rstrip().split(";") for i in open("ciaCountryCode.txt").readlines()]


def escape(text, characters):
    for character in characters:
        text = text.replace(character, '\\' + character)
    return text


def quot(st):
    return '"' + st.replace("\n", "\\n").replace("\r", "\\r") + '"'


def main():
    for i in COUNTRY_CODES:
        country_code = "error"
        for j in country_table:
            if j[2] == i.upper():
                country_code = j[1].lower()
                break
        if country_code == "error":
            continue
        data = urllib.urlopen(url + country_code + ".html").read()
        soup = BeautifulSoup(data, 'html.parser')
        desc = soup.find("div", {"class": "category_data"})
        try:
            print("%s = %s;" % (quot(i), quot(escape(desc.text, "\""))))
        except Exception:
            print(i)


main()
