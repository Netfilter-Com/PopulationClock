# PopulationClock ![populationclock](Icon.png)


Population Clock is an iOS tool for learning about geography and demographics.

Download app on [iTunes](https://itunes.apple.com/us/app/population-clock-hd/id590689957)

____
The project uses the most recent data from these two trusted sources:

- [World Development Indicators - The World Bank](http://databank.worldbank.org/)
- [The World Factbook - CIA](https://www.cia.gov/library/publications/the-world-factbook/)

____
Besides the iOS app, there are a few Python scripts to execute the following actions:

- Scrape the country descriptions and energy production from the World Factbook.
- Download the most recent indicators from World Databank using their JSON API (Some updates are quarterly and others yearly).
- Generate plist file with all indicators and descriptions to use with Xcode.
- With population growth data, create colored SVG map.
- Generate 8-bit greyscale map with one color per country. This allows us to identify which country was clicked by reading the color of the selected pixel.

____
Here is a list of the metrics displayed in the app. Some countries do not have all the data.

- Access to electricity (% of population)
- Birth rate, crude (per 1,000 people)
- CO2 emissions (kt)
- Death rate, crude (per 1,000 people)
- Energy Production (kWh)
- Fertility rate, total (births per woman)
- Forest area (% of land area)
- GDP (constant LCU)
- GDP growth (annual %)
- GDP per capita (constant LCU)
- Health expenditure, total (% of GDP)
- Internet users (per 100 people)
- Life expectancy at birth, total (years)
- Mobile cellular subscriptions (per 100 people)
- Passenger cars (per 1,000 people)
- Population growth (annual %)
- Population, total
