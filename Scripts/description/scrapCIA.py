import urllib
import constants
from bs4 import BeautifulSoup
from constants import *

url = "https://www.cia.gov/library/publications/the-world-factbook/geos/"

def main():
	for i in COUNTRY_CODES:
		data = urllib.urlopen(url + i + ".html").read()
		soup = BeautifulSoup(data)
		desc = soup.find("div", { "class" : "category_data" })
		try:
			print i,desc.text
		except:
		    print i

main()
