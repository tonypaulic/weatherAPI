# weatherAPI

This is a genmon bash script to query and display weather data using the weatherAPI (https://rapidapi.com/weatherapi/api/weatherapi-com/).

**Requires:** xfce4-genmon-plugin wget jq 
   - imagemagick - if using weather images
   - weather icon set - if using images (https://github.com/kevin-hanselman/xfce4-weather-mono-icons) - note: these images are incuded here
   - icon theme with weather icons - if USE_THEME_ICONS set

Note: depending on the font your are using, you may need to adjust the number of "\t" (tabs) in the tooltip string to get the readings to line up properly.

**How To:**

  1. Clone this repository to your local machine
  2. edit the weatherAPI.sh script file and make any necessarry changes to the "configurable items" section:
       - USE_SITEID = whether to use the SITE name you pass in to this command (1) or the one returned by the API (0)
       - UNIT = 'metric' or 'imperial'
       - WEATHER_LINK = the URL of webpage to open when plugin is clicked
       - USE_THEME_ICONS = '1' if you want to use your icon theme's weather icons, '0' to use included images
       - IMAGE_SIZE = 22, 48, or 128
  4. Add the genmon plugin to the panel
  5. Set in it's properties:
     - if specifying exact latitude/longitude coordinates:
        - command = /path/to/weatherAPI.sh APIKEY SITENAME LATITUDE LONGITUDE
         - APIKEY - you will need to register and obtain an APIKEY from https://rapidapi.com/weatherapi/api/weatherapi-com/
         - SITE is the name of your town/city
         - LATITUDE/LONGITUDE - hopefully self explanatory
     - if running in "auto" mode - location based on geo-location of ip address:
        - command = /path/to/weatherAPI.sh APIKEY auto
         - APIKEY - you will need to register and obtain an APIKEY from https://rapidapi.com/weatherapi/api/weatherapi-com/
  6. Uncheck label
  7. Period = 900 (or whatever refresh value you want - weatherAPI allows 1 million refreshes per month with free subscription_
  8. click on Save

**Screenshot:**

![screenshot of plugin](screenshot.png)
