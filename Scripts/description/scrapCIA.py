import urllib
import constants
from bs4 import BeautifulSoup
from constants import *

url = "https://www.cia.gov/library/publications/the-world-factbook/geos/"

country_table = [i.rstrip().split(";") for i in open("ciaCountryCode.txt").readlines()]
def main():
	for i in COUNTRY_CODES:
		country_code = "error"
		for j in country_table:
			if j[2]==i.upper():
				country_code = j[1].lower()
				break
		if country_code == "error":
			continue
		data = urllib.urlopen(url + country_code + ".html").read()
		soup = BeautifulSoup(data)
		desc = soup.find("div", { "class" : "category_data" })
		try:
			print i,desc.text
		except:
		    print i

main()
