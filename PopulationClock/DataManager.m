//
//  DataManager.m
//  PopulationClock
//
//  Created by Fernando Lemos on 21/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import "DataManager.h"

@implementation DataManager {
    NSMutableDictionary *_countryData;
}

+ (instancetype)sharedDataManager {
    static DataManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DataManager alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (!self)
        return nil;
    
    // A dictionary of country names
    NSDictionary *countryNames = @{
        @"af" : NSLocalizedString(@"Afghanistan", @""),
        @"ax" : NSLocalizedString(@"Åland Islands", @""),
        @"al" : NSLocalizedString(@"Albania", @""),
        @"dz" : NSLocalizedString(@"Algeria", @""),
        @"as" : NSLocalizedString(@"American Samoa", @""),
        @"ad" : NSLocalizedString(@"Andorra", @""),
        @"ao" : NSLocalizedString(@"Angola", @""),
        @"ai" : NSLocalizedString(@"Anguilla", @""),
        @"aq" : NSLocalizedString(@"Antarctica", @""),
        @"ag" : NSLocalizedString(@"Antigua and Barbuda", @""),
        @"ar" : NSLocalizedString(@"Argentina", @""),
        @"am" : NSLocalizedString(@"Armenia", @""),
        @"aw" : NSLocalizedString(@"Aruba", @""),
        @"au" : NSLocalizedString(@"Australia", @""),
        @"at" : NSLocalizedString(@"Austria", @""),
        @"az" : NSLocalizedString(@"Azerbaijan", @""),
        @"bs" : NSLocalizedString(@"Bahamas", @""),
        @"bh" : NSLocalizedString(@"Bahrain", @""),
        @"bd" : NSLocalizedString(@"Bangladesh", @""),
        @"bb" : NSLocalizedString(@"Barbados", @""),
        @"by" : NSLocalizedString(@"Belarus", @""),
        @"be" : NSLocalizedString(@"Belgium", @""),
        @"bz" : NSLocalizedString(@"Belize", @""),
        @"bj" : NSLocalizedString(@"Benin", @""),
        @"bm" : NSLocalizedString(@"Bermuda", @""),
        @"bt" : NSLocalizedString(@"Bhutan", @""),
        @"bo" : NSLocalizedString(@"Bolivia, Plurinational State of", @""),
        @"bq" : NSLocalizedString(@"Bonaire, Sint Eustatius and Saba", @""),
        @"ba" : NSLocalizedString(@"Bosnia and Herzegovina", @""),
        @"bw" : NSLocalizedString(@"Botswana", @""),
        @"bv" : NSLocalizedString(@"Bouvet Island", @""),
        @"br" : NSLocalizedString(@"Brazil", @""),
        @"io" : NSLocalizedString(@"British Indian Ocean Territory", @""),
        @"bn" : NSLocalizedString(@"Brunei Darussalam", @""),
        @"bg" : NSLocalizedString(@"Bulgaria", @""),
        @"bf" : NSLocalizedString(@"Burkina Faso", @""),
        @"bi" : NSLocalizedString(@"Burundi", @""),
        @"kh" : NSLocalizedString(@"Cambodia", @""),
        @"cm" : NSLocalizedString(@"Cameroon", @""),
        @"ca" : NSLocalizedString(@"Canada", @""),
        @"cv" : NSLocalizedString(@"Cape Verde", @""),
        @"ky" : NSLocalizedString(@"Cayman Islands", @""),
        @"cf" : NSLocalizedString(@"Central African Republic", @""),
        @"td" : NSLocalizedString(@"Chad", @""),
        @"cl" : NSLocalizedString(@"Chile", @""),
        @"cn" : NSLocalizedString(@"China", @""),
        @"cx" : NSLocalizedString(@"Christmas Island", @""),
        @"cc" : NSLocalizedString(@"Cocos (Keeling) Islands", @""),
        @"co" : NSLocalizedString(@"Colombia", @""),
        @"km" : NSLocalizedString(@"Comoros", @""),
        @"cg" : NSLocalizedString(@"Congo", @""),
        @"cd" : NSLocalizedString(@"Congo, the Democratic Republic of the", @""),
        @"ck" : NSLocalizedString(@"Cook Islands", @""),
        @"cr" : NSLocalizedString(@"Costa Rica", @""),
        @"ci" : NSLocalizedString(@"Côte d'Ivoire", @""),
        @"hr" : NSLocalizedString(@"Croatia", @""),
        @"cu" : NSLocalizedString(@"Cuba", @""),
        @"cw" : NSLocalizedString(@"Curaçao", @""),
        @"cy" : NSLocalizedString(@"Cyprus", @""),
        @"cz" : NSLocalizedString(@"Czech Republic", @""),
        @"dk" : NSLocalizedString(@"Denmark", @""),
        @"dj" : NSLocalizedString(@"Djibouti", @""),
        @"dm" : NSLocalizedString(@"Dominica", @""),
        @"do" : NSLocalizedString(@"Dominican Republic", @""),
        @"ec" : NSLocalizedString(@"Ecuador", @""),
        @"eg" : NSLocalizedString(@"Egypt", @""),
        @"sv" : NSLocalizedString(@"El Salvador", @""),
        @"gq" : NSLocalizedString(@"Equatorial Guinea", @""),
        @"er" : NSLocalizedString(@"Eritrea", @""),
        @"ee" : NSLocalizedString(@"Estonia", @""),
        @"et" : NSLocalizedString(@"Ethiopia", @""),
        @"fk" : NSLocalizedString(@"Falkland Islands (Malvinas)", @""),
        @"fo" : NSLocalizedString(@"Faroe Islands", @""),
        @"fj" : NSLocalizedString(@"Fiji", @""),
        @"fi" : NSLocalizedString(@"Finland", @""),
        @"fr" : NSLocalizedString(@"France", @""),
        @"gf" : NSLocalizedString(@"French Guiana", @""),
        @"pf" : NSLocalizedString(@"French Polynesia", @""),
        @"tf" : NSLocalizedString(@"French Southern Territories", @""),
        @"ga" : NSLocalizedString(@"Gabon", @""),
        @"gm" : NSLocalizedString(@"Gambia", @""),
        @"ge" : NSLocalizedString(@"Georgia", @""),
        @"de" : NSLocalizedString(@"Germany", @""),
        @"gh" : NSLocalizedString(@"Ghana", @""),
        @"gi" : NSLocalizedString(@"Gibraltar", @""),
        @"gr" : NSLocalizedString(@"Greece", @""),
        @"gl" : NSLocalizedString(@"Greenland", @""),
        @"gd" : NSLocalizedString(@"Grenada", @""),
        @"gp" : NSLocalizedString(@"Guadeloupe", @""),
        @"gu" : NSLocalizedString(@"Guam", @""),
        @"gt" : NSLocalizedString(@"Guatemala", @""),
        @"gg" : NSLocalizedString(@"Guernsey", @""),
        @"gn" : NSLocalizedString(@"Guinea", @""),
        @"gw" : NSLocalizedString(@"Guinea-Bissau", @""),
        @"gy" : NSLocalizedString(@"Guyana", @""),
        @"ht" : NSLocalizedString(@"Haiti", @""),
        @"hm" : NSLocalizedString(@"Heard Island and McDonald Islands", @""),
        @"va" : NSLocalizedString(@"Holy See (Vatican City State)", @""),
        @"hn" : NSLocalizedString(@"Honduras", @""),
        @"hk" : NSLocalizedString(@"Hong Kong", @""),
        @"hu" : NSLocalizedString(@"Hungary", @""),
        @"is" : NSLocalizedString(@"Iceland", @""),
        @"in" : NSLocalizedString(@"India", @""),
        @"id" : NSLocalizedString(@"Indonesia", @""),
        @"ir" : NSLocalizedString(@"Iran, Islamic Republic of", @""),
        @"iq" : NSLocalizedString(@"Iraq", @""),
        @"ie" : NSLocalizedString(@"Ireland", @""),
        @"im" : NSLocalizedString(@"Isle of Man", @""),
        @"il" : NSLocalizedString(@"Israel", @""),
        @"it" : NSLocalizedString(@"Italy", @""),
        @"jm" : NSLocalizedString(@"Jamaica", @""),
        @"jp" : NSLocalizedString(@"Japan", @""),
        @"je" : NSLocalizedString(@"Jersey", @""),
        @"jo" : NSLocalizedString(@"Jordan", @""),
        @"kz" : NSLocalizedString(@"Kazakhstan", @""),
        @"ke" : NSLocalizedString(@"Kenya", @""),
        @"ki" : NSLocalizedString(@"Kiribati", @""),
        @"kp" : NSLocalizedString(@"Korea, Democratic People's Republic of", @""),
        @"kr" : NSLocalizedString(@"Korea, Republic of", @""),
        @"kw" : NSLocalizedString(@"Kuwait", @""),
        @"kg" : NSLocalizedString(@"Kyrgyzstan", @""),
        @"la" : NSLocalizedString(@"Lao People's Democratic Republic", @""),
        @"lv" : NSLocalizedString(@"Latvia", @""),
        @"lb" : NSLocalizedString(@"Lebanon", @""),
        @"ls" : NSLocalizedString(@"Lesotho", @""),
        @"lr" : NSLocalizedString(@"Liberia", @""),
        @"ly" : NSLocalizedString(@"Libya", @""),
        @"li" : NSLocalizedString(@"Liechtenstein", @""),
        @"lt" : NSLocalizedString(@"Lithuania", @""),
        @"lu" : NSLocalizedString(@"Luxembourg", @""),
        @"mo" : NSLocalizedString(@"Macao", @""),
        @"mk" : NSLocalizedString(@"Macedonia, The Former Yugoslav Republic of", @""),
        @"mg" : NSLocalizedString(@"Madagascar", @""),
        @"mw" : NSLocalizedString(@"Malawi", @""),
        @"my" : NSLocalizedString(@"Malaysia", @""),
        @"mv" : NSLocalizedString(@"Maldives", @""),
        @"ml" : NSLocalizedString(@"Mali", @""),
        @"mt" : NSLocalizedString(@"Malta", @""),
        @"mh" : NSLocalizedString(@"Marshall Islands", @""),
        @"mq" : NSLocalizedString(@"Martinique", @""),
        @"mr" : NSLocalizedString(@"Mauritania", @""),
        @"mu" : NSLocalizedString(@"Mauritius", @""),
        @"yt" : NSLocalizedString(@"Mayotte", @""),
        @"mx" : NSLocalizedString(@"Mexico", @""),
        @"fm" : NSLocalizedString(@"Micronesia, Federated States of", @""),
        @"md" : NSLocalizedString(@"Moldova, Republic of", @""),
        @"mc" : NSLocalizedString(@"Monaco", @""),
        @"mn" : NSLocalizedString(@"Mongolia", @""),
        @"me" : NSLocalizedString(@"Montenegro", @""),
        @"ms" : NSLocalizedString(@"Montserrat", @""),
        @"ma" : NSLocalizedString(@"Morocco", @""),
        @"mz" : NSLocalizedString(@"Mozambique", @""),
        @"mm" : NSLocalizedString(@"Myanmar", @""),
        @"na" : NSLocalizedString(@"Namibia", @""),
        @"nr" : NSLocalizedString(@"Nauru", @""),
        @"np" : NSLocalizedString(@"Nepal", @""),
        @"nl" : NSLocalizedString(@"Netherlands", @""),
        @"nc" : NSLocalizedString(@"New Caledonia", @""),
        @"nz" : NSLocalizedString(@"New Zealand", @""),
        @"ni" : NSLocalizedString(@"Nicaragua", @""),
        @"ne" : NSLocalizedString(@"Niger", @""),
        @"ng" : NSLocalizedString(@"Nigeria", @""),
        @"nu" : NSLocalizedString(@"Niue", @""),
        @"nf" : NSLocalizedString(@"Norfolk Island", @""),
        @"mp" : NSLocalizedString(@"Northern Mariana Islands", @""),
        @"no" : NSLocalizedString(@"Norway", @""),
        @"om" : NSLocalizedString(@"Oman", @""),
        @"pk" : NSLocalizedString(@"Pakistan", @""),
        @"pw" : NSLocalizedString(@"Palau", @""),
        @"ps" : NSLocalizedString(@"Palestinian Territory, Occupied", @""),
        @"pa" : NSLocalizedString(@"Panama", @""),
        @"pg" : NSLocalizedString(@"Papua New Guinea", @""),
        @"py" : NSLocalizedString(@"Paraguay", @""),
        @"pe" : NSLocalizedString(@"Peru", @""),
        @"ph" : NSLocalizedString(@"Philippines", @""),
        @"pn" : NSLocalizedString(@"Pitcairn", @""),
        @"pl" : NSLocalizedString(@"Poland", @""),
        @"pt" : NSLocalizedString(@"Portugal", @""),
        @"pr" : NSLocalizedString(@"Puerto Rico", @""),
        @"qa" : NSLocalizedString(@"Qatar", @""),
        @"re" : NSLocalizedString(@"Réunion", @""),
        @"ro" : NSLocalizedString(@"Romania", @""),
        @"ru" : NSLocalizedString(@"Russian Federation", @""),
        @"rw" : NSLocalizedString(@"Rwanda", @""),
        @"bl" : NSLocalizedString(@"Saint Barthélemy", @""),
        @"sh" : NSLocalizedString(@"Saint Helena, Ascension and Tristan da Cunha", @""),
        @"kn" : NSLocalizedString(@"Saint Kitts and Nevis", @""),
        @"lc" : NSLocalizedString(@"Saint Lucia", @""),
        @"mf" : NSLocalizedString(@"Saint Martin (French part)", @""),
        @"pm" : NSLocalizedString(@"Saint Pierre and Miquelon", @""),
        @"vc" : NSLocalizedString(@"Saint Vincent and the Grenadines", @""),
        @"ws" : NSLocalizedString(@"Samoa", @""),
        @"sm" : NSLocalizedString(@"San Marino", @""),
        @"st" : NSLocalizedString(@"Sao Tome and Principe", @""),
        @"sa" : NSLocalizedString(@"Saudi Arabia", @""),
        @"sn" : NSLocalizedString(@"Senegal", @""),
        @"rs" : NSLocalizedString(@"Serbia", @""),
        @"sc" : NSLocalizedString(@"Seychelles", @""),
        @"sl" : NSLocalizedString(@"Sierra Leone", @""),
        @"sg" : NSLocalizedString(@"Singapore", @""),
        @"sx" : NSLocalizedString(@"Sint Maarten (Dutch part)", @""),
        @"sk" : NSLocalizedString(@"Slovakia", @""),
        @"si" : NSLocalizedString(@"Slovenia", @""),
        @"sb" : NSLocalizedString(@"Solomon Islands", @""),
        @"so" : NSLocalizedString(@"Somalia", @""),
        @"za" : NSLocalizedString(@"South Africa", @""),
        @"gs" : NSLocalizedString(@"South Georgia and the South Sandwich Islands", @""),
        @"ss" : NSLocalizedString(@"South Sudan", @""),
        @"es" : NSLocalizedString(@"Spain", @""),
        @"lk" : NSLocalizedString(@"Sri Lanka", @""),
        @"sd" : NSLocalizedString(@"Sudan", @""),
        @"sr" : NSLocalizedString(@"Suriname", @""),
        @"sj" : NSLocalizedString(@"Svalbard and Jan Mayen", @""),
        @"sz" : NSLocalizedString(@"Swaziland", @""),
        @"se" : NSLocalizedString(@"Sweden", @""),
        @"ch" : NSLocalizedString(@"Switzerland", @""),
        @"sy" : NSLocalizedString(@"Syrian Arab Republic", @""),
        @"tw" : NSLocalizedString(@"Taiwan, Province of China", @""),
        @"tj" : NSLocalizedString(@"Tajikistan", @""),
        @"tz" : NSLocalizedString(@"Tanzania, United Republic of", @""),
        @"th" : NSLocalizedString(@"Thailand", @""),
        @"tl" : NSLocalizedString(@"Timor-Leste", @""),
        @"tg" : NSLocalizedString(@"Togo", @""),
        @"tk" : NSLocalizedString(@"Tokelau", @""),
        @"to" : NSLocalizedString(@"Tonga", @""),
        @"tt" : NSLocalizedString(@"Trinidad and Tobago", @""),
        @"tn" : NSLocalizedString(@"Tunisia", @""),
        @"tr" : NSLocalizedString(@"Turkey", @""),
        @"tm" : NSLocalizedString(@"Turkmenistan", @""),
        @"tc" : NSLocalizedString(@"Turks and Caicos Islands", @""),
        @"tv" : NSLocalizedString(@"Tuvalu", @""),
        @"ug" : NSLocalizedString(@"Uganda", @""),
        @"ua" : NSLocalizedString(@"Ukraine", @""),
        @"ae" : NSLocalizedString(@"United Arab Emirates", @""),
        @"gb" : NSLocalizedString(@"United Kingdom", @""),
        @"us" : NSLocalizedString(@"United States", @""),
        @"um" : NSLocalizedString(@"United States Minor Outlying Islands", @""),
        @"uy" : NSLocalizedString(@"Uruguay", @""),
        @"uz" : NSLocalizedString(@"Uzbekistan", @""),
        @"vu" : NSLocalizedString(@"Vanuatu", @""),
        @"ve" : NSLocalizedString(@"Venezuela, Bolivarian Republic of", @""),
        @"vn" : NSLocalizedString(@"Viet Nam", @""),
        @"vg" : NSLocalizedString(@"Virgin Islands, British", @""),
        @"vi" : NSLocalizedString(@"Virgin Islands, U.S.", @""),
        @"wf" : NSLocalizedString(@"Wallis and Futuna", @""),
        @"eh" : NSLocalizedString(@"Western Sahara", @""),
        @"ye" : NSLocalizedString(@"Yemen", @""),
        @"zm" : NSLocalizedString(@"Zambia", @""),
        @"zw" : NSLocalizedString(@"Zimbabwe", @"")
    };
    
    // Load the data from the plist
    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"];
    NSDictionary *countryDataReadOnly = [NSDictionary dictionaryWithContentsOfFile:path];
    
    // Associate the country codes and for easier lookup
    _countryData = [NSMutableDictionary dictionaryWithCapacity:countryDataReadOnly.count];
    for (NSString *countryCode in countryDataReadOnly.allKeys) {
        NSMutableDictionary *info = [countryDataReadOnly[countryCode] mutableCopy];
        if ([countryCode isEqualToString:@"world"]) {
            info[@"name"] = NSLocalizedString(@"World", @"");
        }
        else {
            NSString *name = countryNames[countryCode];
            assert(name);
            info[@"name"] = name;
        }
        info[@"code"] = countryCode;
        [_countryData setObject:info forKey:countryCode];
    }
    
    // Create an ordered array with the country data (the whole world comes before the first country)
    _orderedCountryData = [_countryData.allValues sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDictionary *info1 = (NSDictionary *)obj1;
        NSDictionary *info2 = (NSDictionary *)obj2;
        if ([info1[@"code"] isEqualToString:@"world"])
            return NSOrderedAscending;
        else if ([info2[@"code"] isEqualToString:@"world"])
            return NSOrderedDescending;
        else
            return [info1[@"name"] compare:info2[@"name"] options:NSCaseInsensitiveSearch];
    }];
    
    return self;
}

@end
