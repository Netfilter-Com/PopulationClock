#!/usr/bin/env python3
# coding: utf-8
"""
    Get the most recent data form worldbank.org

    API overview:
    http://data.worldbank.org/developers/api-overview?print&book_recurse
"""
import csv
import datetime
import itertools
import json
import re
import sys
from os import path
from urllib.parse import urlencode
from urllib.request import urlopen

sys.path.append(path.abspath(path.join(path.dirname(__file__), '..')))
from shared import constants


class DictObj(dict):
    def __getattr__(self, item):
        return self[item]

    def __setattr__(self, key, value):
        self[key] = value


class Report:
    file_extension = '.csv'
    dir = 'csv'
    date = (2000, datetime.datetime.now().year)
    format = 'json'
    page_limit = 10000
    url = 'http://api.worldbank.org/countries/all/indicators/{indicator}?'

    @classmethod
    def from_string(cls, string):
        args = re.search(r'^\s*([\w\.]+)\s+([\w\.]+)\s*(.*)$', string).groups()
        return cls(*args)

    def __init__(self, file, indicator, full_name, worldbank=True):
        self.full_name = full_name
        self.indicator = indicator
        self.file = file
        self.worldbank = worldbank
        self.meta = DictObj()

    @property
    def file_path(self):
        curr_path = path.abspath(path.dirname(__file__))
        return path.join(curr_path, self.dir, self.file + self.file_extension)

    def request(self):
        if self.indicator == '.':
            return []

        params = DictObj(
            format=self.format,
            date=':'.join(map(str, self.date)),
            page=1,
            per_page=self.page_limit,
        )

        data = []
        meta = DictObj()

        while True:
            url = self.url.format(indicator=self.indicator) + urlencode(params)
            with urlopen(url) as u:
                meta, curr_data = json.loads(u.read().decode(), object_hook=DictObj)

            if meta.total == 0:
                return []
            data.extend(curr_data)

            if meta.pages == params.page:
                break
            params.page += 1
            break  # TODO REMOVE THIS --- FOR TESTING ONLY

        meta.indicator = data[0].indicator
        print(len(data), meta.indicator.value)
        return data

    def generate_csv(self):
        """
            Example item:
            {
                'country': {'id': 'TV', 'value': 'Tuvalu'},
                'decimal': '0',
                'date': '2015',
                'value': '123.45'
            }
        """
        def keyfunc(x):
            return x.country.id

        def yearfunc(x):
            if x.value is None:
                return 0
            return int(x.date)

        countries = constants.CountryList.used()

        recent = []
        data = self.request()
        data.sort(key=keyfunc)
        for key, group in itertools.groupby(data, keyfunc):
            if key not in countries and key != '1W':
                # print(key, next(group).country.value)
                continue
            recent.append(max(group, key=yearfunc))

        for r in recent:
            r.pop('indicator')

        if not recent:
            print('- Nothing to do:', self.full_name)
            return

        with open(self.file_path, 'w') as file:
            writer = csv.writer(file, delimiter=';')
            writer.writerow(['Country Code', self.date[-1]])

            for el in recent:
                try:
                    code = countries[el.country.id].code(3, 'upper')
                except KeyError:
                    code = 'WLD'
                writer.writerow([code, el.value if el.value is not None else ''])


def main():
    reports = [Report.from_string(x) for x in '''
        BirthRate               SP.DYN.CBRT.IN    Birth rate, crude (per 1,000 people)
        BirthsPerWoman          SP.DYN.TFRT.IN    Fertility rate, total (births per woman)
        CO2E.KT                 EN.ATM.CO2E.KT    CO2 emissions (kt)
        DeathRate               SP.DYN.CDRT.IN    Death rate, crude (per 1,000 people)
        Description             .                 Country Description
        ElectricityAccess       EG.ELC.ACCS.ZS    Access to electricity (% of population)
        EnergyProductionKT      .                 Energy Production
        ForestAreaPercent       AG.LND.FRST.ZS    Forest area (% of land area)
        GDP                     NY.GDP.MKTP.PP.CD GDP, PPP (current international $)
        GDP.GROWTH              NY.GDP.MKTP.KD.ZG GDP growth (annual %)
        GDP.PCAP                NY.GDP.PCAP.KN    GDP per capita (constant LCU)
        GrowthRate              SP.POP.GROW       Population growth (annual %)
        HealthExpensePercentGDP SH.XPD.TOTL.ZS    Health expenditure, total (% of GDP)
        LifeExpect              SP.DYN.LE00.IN    Life expectancy at birth, total (years)
        MobileUsersPer100       IT.CEL.SETS.P2    Mobile cellular subscriptions (per 100 people)
        PassengerCarPer1000     IS.VEH.PCAR.P3    Passenger cars (per 1,000 people)
        PercentInternetUsers    IT.NET.USER.P2    Internet users (per 100 people)
        TotalPopulation         SP.POP.TOTL       Population, total
    '''.strip().splitlines()]

    for r in reports:
        r.generate_csv()


if __name__ == '__main__':
    main()
