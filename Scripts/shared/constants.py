# coding: utf-8
# Officially assigned codes ISO 3166-1: 249 (Revised Jan 2016)


class Country(object):
    def __init__(self, code_2, code_3, code_n, used, name):
        self.code_2 = code_2
        self.code_3 = code_3
        self.code_n = code_n
        self.used = bool(used)
        self.name = name

    def __repr__(self):
        return "{0.name}: {0.code_2}/{0.code_3}".format(self)

    def code(self, n=2, case='lower'):
        assert n in (2, 3)
        code = self.code_2 if n == 2 else self.code_3
        if case == 'lower':
            code = code.lower()
        return code


class CountryList(list):
    _all = None
    _used = None
    _nonused = None

    @classmethod
    def initialize(cls, data):
        data = [Country(*x) for x in data]
        cls._all = cls(data)
        cls._used = cls(x for x in data if x.used)
        cls._nonused = cls(x for x in data if not x.used)

    def __init__(self, data=()):
        super(CountryList, self).__init__(data)
        self.dict = {x.code(2): x for x in self}
        self.dict.update({x.code(3): x for x in self})

    def code(self, *args):
        return [x.code(*args) for x in self]

    def name(self):
        return [x.name for x in self]

    @classmethod
    def used(cls, value=True):
        return cls._used if value else cls._nonused

    @classmethod
    def all(cls):
        return cls._all

    def __getitem__(self, item):
        if isinstance(item, str):
            return self.dict[item.lower()]
        return super().__getitem__(item)

    def __contains__(self, item):
        if isinstance(item, str):
            return item.lower() in self.dict
        return False


DATA = [
    ['AF', 'AFG', '004', 1, "Afghanistan"],
    ['AX', 'ALA', '248', 0, "Åland Islands"],
    ['AL', 'ALB', '008', 1, "Albania"],
    ['DZ', 'DZA', '012', 1, "Algeria"],
    ['AS', 'ASM', '016', 1, "American Samoa"],
    ['AD', 'AND', '020', 1, "Andorra"],
    ['AO', 'AGO', '024', 1, "Angola"],
    ['AI', 'AIA', '660', 0, "Anguilla"],
    ['AQ', 'ATA', '010', 0, "Antarctica"],
    ['AG', 'ATG', '028', 1, "Antigua and Barbuda"],
    ['AR', 'ARG', '032', 1, "Argentina"],
    ['AM', 'ARM', '051', 1, "Armenia"],
    ['AW', 'ABW', '533', 1, "Aruba"],
    ['AU', 'AUS', '036', 1, "Australia"],
    ['AT', 'AUT', '040', 1, "Austria"],
    ['AZ', 'AZE', '031', 1, "Azerbaijan"],
    ['BS', 'BHS', '044', 1, "Bahamas"],
    ['BH', 'BHR', '048', 1, "Bahrain"],
    ['BD', 'BGD', '050', 1, "Bangladesh"],
    ['BB', 'BRB', '052', 1, "Barbados"],
    ['BY', 'BLR', '112', 1, "Belarus"],
    ['BE', 'BEL', '056', 1, "Belgium"],
    ['BZ', 'BLZ', '084', 1, "Belize"],
    ['BJ', 'BEN', '204', 1, "Benin"],
    ['BM', 'BMU', '060', 1, "Bermuda"],
    ['BT', 'BTN', '064', 1, "Bhutan"],
    ['BO', 'BOL', '068', 1, "Bolivia"],
    ['BQ', 'BES', '535', 0, "Bonaire, Sint Eustatius and Saba"],
    ['BA', 'BIH', '070', 1, "Bosnia and Herzegovina"],
    ['BW', 'BWA', '072', 1, "Botswana"],
    ['BV', 'BVT', '074', 0, "Bouvet Island"],
    ['BR', 'BRA', '076', 1, "Brazil"],
    ['IO', 'IOT', '086', 0, "British Indian Ocean Territory"],
    ['BN', 'BRN', '096', 1, "Brunei Darussalam"],
    ['BG', 'BGR', '100', 1, "Bulgaria"],
    ['BF', 'BFA', '854', 1, "Burkina Faso"],
    ['BI', 'BDI', '108', 1, "Burundi"],
    ['KH', 'KHM', '116', 1, "Cambodia"],
    ['CM', 'CMR', '120', 1, "Cameroon"],
    ['CA', 'CAN', '124', 1, "Canada"],
    ['CV', 'CPV', '132', 1, "Cabo Verde"],
    ['KY', 'CYM', '136', 1, "Cayman Islands"],
    ['CF', 'CAF', '140', 1, "Central African Republic"],
    ['TD', 'TCD', '148', 1, "Chad"],
    ['CL', 'CHL', '152', 1, "Chile"],
    ['CN', 'CHN', '156', 1, "China"],
    ['CX', 'CXR', '162', 0, "Christmas Island"],
    ['CC', 'CCK', '166', 0, "Cocos (Keeling) Islands"],
    ['CO', 'COL', '170', 1, "Colombia"],
    ['KM', 'COM', '174', 1, "Comoros"],
    ['CG', 'COG', '178', 1, "Congo"],
    ['CD', 'COD', '180', 1, "Congo, DR"],
    ['CK', 'COK', '184', 0, "Cook Islands"],
    ['CR', 'CRI', '188', 1, "Costa Rica"],
    ['CI', 'CIV', '384', 1, "Côte d'Ivoire"],
    ['HR', 'HRV', '191', 1, "Croatia"],
    ['CU', 'CUB', '192', 1, "Cuba"],
    ['CW', 'CUW', '531', 0, "Curaçao"],
    ['CY', 'CYP', '196', 1, "Cyprus"],
    ['CZ', 'CZE', '203', 1, "Czech Republic"],
    ['DK', 'DNK', '208', 1, "Denmark"],
    ['DJ', 'DJI', '262', 1, "Djibouti"],
    ['DM', 'DMA', '212', 1, "Dominica"],
    ['DO', 'DOM', '214', 1, "Dominican Republic"],
    ['EC', 'ECU', '218', 1, "Ecuador"],
    ['EG', 'EGY', '818', 1, "Egypt"],
    ['SV', 'SLV', '222', 1, "El Salvador"],
    ['GQ', 'GNQ', '226', 1, "Equatorial Guinea"],
    ['ER', 'ERI', '232', 1, "Eritrea"],
    ['EE', 'EST', '233', 1, "Estonia"],
    ['ET', 'ETH', '231', 1, "Ethiopia"],
    ['FK', 'FLK', '238', 0, "Falkland Islands (Malvinas)"],
    ['FO', 'FRO', '234', 1, "Faroe Islands"],
    ['FJ', 'FJI', '242', 1, "Fiji"],
    ['FI', 'FIN', '246', 1, "Finland"],
    ['FR', 'FRA', '250', 1, "France"],
    ['GF', 'GUF', '254', 0, "French Guiana"],
    ['PF', 'PYF', '258', 1, "French Polynesia"],
    ['TF', 'ATF', '260', 0, "French Southern Territories"],
    ['GA', 'GAB', '266', 1, "Gabon"],
    ['GM', 'GMB', '270', 1, "Gambia"],
    ['GE', 'GEO', '268', 1, "Georgia"],
    ['DE', 'DEU', '276', 1, "Germany"],
    ['GH', 'GHA', '288', 1, "Ghana"],
    ['GI', 'GIB', '292', 0, "Gibraltar"],
    ['GR', 'GRC', '300', 1, "Greece"],
    ['GL', 'GRL', '304', 1, "Greenland"],
    ['GD', 'GRD', '308', 1, "Grenada"],
    ['GP', 'GLP', '312', 0, "Guadeloupe"],
    ['GU', 'GUM', '316', 1, "Guam"],
    ['GT', 'GTM', '320', 1, "Guatemala"],
    ['GG', 'GGY', '831', 0, "Guernsey"],
    ['GN', 'GIN', '324', 1, "Guinea"],
    ['GW', 'GNB', '624', 1, "Guinea-Bissau"],
    ['GY', 'GUY', '328', 1, "Guyana"],
    ['HT', 'HTI', '332', 1, "Haiti"],
    ['HM', 'HMD', '334', 0, "Heard Island and McDonald Islands"],
    ['VA', 'VAT', '336', 1, "Holy See (Vatican State)"],
    ['HN', 'HND', '340', 1, "Honduras"],
    ['HK', 'HKG', '344', 0, "Hong Kong"],
    ['HU', 'HUN', '348', 1, "Hungary"],
    ['IS', 'ISL', '352', 1, "Iceland"],
    ['IN', 'IND', '356', 1, "India"],
    ['ID', 'IDN', '360', 1, "Indonesia"],
    ['IR', 'IRN', '364', 1, "Iran, Islamic Republic of"],
    ['IQ', 'IRQ', '368', 1, "Iraq"],
    ['IE', 'IRL', '372', 1, "Ireland"],
    ['IM', 'IMN', '833', 1, "Isle of Man"],
    ['IL', 'ISR', '376', 1, "Israel"],
    ['IT', 'ITA', '380', 1, "Italy"],
    ['JM', 'JAM', '388', 1, "Jamaica"],
    ['JP', 'JPN', '392', 1, "Japan"],
    ['JE', 'JEY', '832', 0, "Jersey"],
    ['JO', 'JOR', '400', 1, "Jordan"],
    ['KZ', 'KAZ', '398', 1, "Kazakhstan"],
    ['KE', 'KEN', '404', 1, "Kenya"],
    ['KI', 'KIR', '296', 1, "Kiribati"],
    ['KP', 'PRK', '408', 1, "Korea, DPR"],
    ['KR', 'KOR', '410', 1, "Korea, Republic of"],
    ['KW', 'KWT', '414', 1, "Kuwait"],
    ['KG', 'KGZ', '417', 1, "Kyrgyzstan"],
    ['LA', 'LAO', '418', 1, "Lao, PDR"],
    ['LV', 'LVA', '428', 1, "Latvia"],
    ['LB', 'LBN', '422', 1, "Lebanon"],
    ['LS', 'LSO', '426', 1, "Lesotho"],
    ['LR', 'LBR', '430', 1, "Liberia"],
    ['LY', 'LBY', '434', 1, "Libya"],
    ['LI', 'LIE', '438', 1, "Liechtenstein"],
    ['LT', 'LTU', '440', 1, "Lithuania"],
    ['LU', 'LUX', '442', 1, "Luxembourg"],
    ['MO', 'MAC', '446', 0, "Macao"],
    ['MK', 'MKD', '807', 1, "Macedonia, FYRO"],
    ['MG', 'MDG', '450', 1, "Madagascar"],
    ['MW', 'MWI', '454', 1, "Malawi"],
    ['MY', 'MYS', '458', 1, "Malaysia"],
    ['MV', 'MDV', '462', 1, "Maldives"],
    ['ML', 'MLI', '466', 1, "Mali"],
    ['MT', 'MLT', '470', 1, "Malta"],
    ['MH', 'MHL', '584', 1, "Marshall Islands"],
    ['MQ', 'MTQ', '474', 0, "Martinique"],
    ['MR', 'MRT', '478', 1, "Mauritania"],
    ['MU', 'MUS', '480', 1, "Mauritius"],
    ['YT', 'MYT', '175', 0, "Mayotte"],
    ['MX', 'MEX', '484', 1, "Mexico"],
    ['FM', 'FSM', '583', 1, "Micronesia, FS"],
    ['MD', 'MDA', '498', 1, "Moldova, Republic of"],
    ['MC', 'MCO', '492', 1, "Monaco"],
    ['MN', 'MNG', '496', 1, "Mongolia"],
    ['ME', 'MNE', '499', 1, "Montenegro"],
    ['MS', 'MSR', '500', 0, "Montserrat"],
    ['MA', 'MAR', '504', 1, "Morocco"],
    ['MZ', 'MOZ', '508', 1, "Mozambique"],
    ['MM', 'MMR', '104', 1, "Myanmar"],
    ['NA', 'NAM', '516', 1, "Namibia"],
    ['NR', 'NRU', '520', 0, "Nauru"],
    ['NP', 'NPL', '524', 1, "Nepal"],
    ['NL', 'NLD', '528', 1, "Netherlands"],
    ['NC', 'NCL', '540', 1, "New Caledonia"],
    ['NZ', 'NZL', '554', 1, "New Zealand"],
    ['NI', 'NIC', '558', 1, "Nicaragua"],
    ['NE', 'NER', '562', 1, "Niger"],
    ['NG', 'NGA', '566', 1, "Nigeria"],
    ['NU', 'NIU', '570', 0, "Niue"],
    ['NF', 'NFK', '574', 0, "Norfolk Island"],
    ['MP', 'MNP', '580', 1, "Northern Mariana Islands"],
    ['NO', 'NOR', '578', 1, "Norway"],
    ['OM', 'OMN', '512', 1, "Oman"],
    ['PK', 'PAK', '586', 1, "Pakistan"],
    ['PW', 'PLW', '585', 1, "Palau"],
    ['PS', 'PSE', '275', 1, "Palestine "],
    ['PA', 'PAN', '591', 1, "Panama"],
    ['PG', 'PNG', '598', 1, "Papua New Guinea"],
    ['PY', 'PRY', '600', 1, "Paraguay"],
    ['PE', 'PER', '604', 1, "Peru"],
    ['PH', 'PHL', '608', 1, "Philippines"],
    ['PN', 'PCN', '612', 0, "Pitcairn"],
    ['PL', 'POL', '616', 1, "Poland"],
    ['PT', 'PRT', '620', 1, "Portugal"],
    ['PR', 'PRI', '630', 1, "Puerto Rico"],
    ['QA', 'QAT', '634', 1, "Qatar"],
    ['RE', 'REU', '638', 0, "Réunion"],
    ['RO', 'ROU', '642', 1, "Romania"],
    ['RU', 'RUS', '643', 1, "Russian Federation"],
    ['RW', 'RWA', '646', 1, "Rwanda"],
    ['BL', 'BLM', '652', 0, "Saint Barthélemy"],
    ['SH', 'SHN', '654', 0, "Saint Helena, Ascension and Tristan da Cunha"],
    ['KN', 'KNA', '659', 1, "Saint Kitts and Nevis"],
    ['LC', 'LCA', '662', 1, "Saint Lucia"],
    ['MF', 'MAF', '663', 1, "Saint Martin (French part)"],
    ['PM', 'SPM', '666', 0, "Saint Pierre and Miquelon"],
    ['VC', 'VCT', '670', 1, "Saint Vincent and Grenadines"],
    ['WS', 'WSM', '882', 1, "Samoa"],
    ['SM', 'SMR', '674', 1, "San Marino"],
    ['ST', 'STP', '678', 1, "Sao Tome and Principe"],
    ['SA', 'SAU', '682', 1, "Saudi Arabia"],
    ['SN', 'SEN', '686', 1, "Senegal"],
    ['RS', 'SRB', '688', 1, "Serbia"],
    ['SC', 'SYC', '690', 1, "Seychelles"],
    ['SL', 'SLE', '694', 1, "Sierra Leone"],
    ['SG', 'SGP', '702', 1, "Singapore"],
    ['SX', 'SXM', '534', 0, "Sint Maarten (Dutch part)"],
    ['SK', 'SVK', '703', 1, "Slovakia"],
    ['SI', 'SVN', '705', 1, "Slovenia"],
    ['SB', 'SLB', '090', 1, "Solomon Islands"],
    ['SO', 'SOM', '706', 1, "Somalia"],
    ['ZA', 'ZAF', '710', 1, "South Africa"],
    ['GS', 'SGS', '239', 0, "South Georgia and the South Sandwich Islands"],
    ['SS', 'SSD', '728', 1, "South Sudan"],
    ['ES', 'ESP', '724', 1, "Spain"],
    ['LK', 'LKA', '144', 1, "Sri Lanka"],
    ['SD', 'SDN', '729', 1, "Sudan"],
    ['SR', 'SUR', '740', 1, "Suriname"],
    ['SJ', 'SJM', '744', 0, "Svalbard and Jan Mayen"],
    ['SZ', 'SWZ', '748', 1, "Swaziland"],
    ['SE', 'SWE', '752', 1, "Sweden"],
    ['CH', 'CHE', '756', 1, "Switzerland"],
    ['SY', 'SYR', '760', 1, "Syrian Arab Republic"],
    ['TW', 'TWN', '158', 1, "Taiwan, Province of China"],
    ['TJ', 'TJK', '762', 1, "Tajikistan"],
    ['TZ', 'TZA', '834', 1, "Tanzania, United Republic of"],
    ['TH', 'THA', '764', 1, "Thailand"],
    ['TL', 'TLS', '626', 1, "Timor-Leste"],
    ['TG', 'TGO', '768', 1, "Togo"],
    ['TK', 'TKL', '772', 0, "Tokelau"],
    ['TO', 'TON', '776', 1, "Tonga"],
    ['TT', 'TTO', '780', 1, "Trinidad and Tobago"],
    ['TN', 'TUN', '788', 1, "Tunisia"],
    ['TR', 'TUR', '792', 1, "Turkey"],
    ['TM', 'TKM', '795', 1, "Turkmenistan"],
    ['TC', 'TCA', '796', 1, "Turks and Caicos Islands"],
    ['TV', 'TUV', '798', 1, "Tuvalu"],
    ['UG', 'UGA', '800', 1, "Uganda"],
    ['UA', 'UKR', '804', 1, "Ukraine"],
    ['AE', 'ARE', '784', 1, "United Arab Emirates"],
    ['GB', 'GBR', '826', 1, "United Kingdom"],
    ['US', 'USA', '840', 1, "United States"],
    ['UM', 'UMI', '581', 0, "United States Minor Outlying Islands"],
    ['UY', 'URY', '858', 1, "Uruguay"],
    ['UZ', 'UZB', '860', 1, "Uzbekistan"],
    ['VU', 'VUT', '548', 1, "Vanuatu"],
    ['VE', 'VEN', '862', 1, "Venezuela"],
    ['VN', 'VNM', '704', 1, "Viet Nam"],
    ['VG', 'VGB', '092', 0, "Virgin Islands, British"],
    ['VI', 'VIR', '850', 1, "Virgin Islands, U.S."],
    ['WF', 'WLF', '876', 0, "Wallis and Futuna"],
    ['EH', 'ESH', '732', 0, "Western Sahara"],
    ['YE', 'YEM', '887', 1, "Yemen"],
    ['ZM', 'ZMB', '894', 1, "Zambia"],
    ['ZW', 'ZWE', '716', 1, "Zimbabwe"],
]

CountryList.initialize(DATA)
allc = CountryList.all()
COUNTRY_CODES = allc.code()
COUNTRIES_3TO2 = dict(zip(allc.code(3), allc.code(2)))
