#!/bin/bash

# $1 = SITENAME
# $2 = LATITUDE
# $3 = LONGITUDE

# test to see if the correct number of paramaters was passed
if [ "$#" -ne 4 ]; then 
	echo "Usage: $0 SITENAME LATITUDE LONGITUDE APIKEY"
	exit 1
fi

# script globals 
SITENAME="$1"
LATITUDE="$2"
LONGITUDE="$3"
API_KEY="$4"

H1="X-RapidAPI-Key: $API_KEY"
H2="X-RapidAPI-Host: weatherapi-com.p.rapidapi.com"
OD="https://weatherapi-com.p.rapidapi.com/current.json?q=$LATITUDE%2C$LONGITUDE"

WEATHER_LINK="https://www.weatherapi.com/weather/q/oshawa-ontario-canada-316180?loc=316180"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
IMAGES_DIR="$SCRIPT_DIR/icons"
CACHE_DIR="$HOME/.cache/weatherAPI"
CACHE_FILE="$CACHE_DIR/weather.tmp"
TEMP_UNIT=metric        # metric or imperial
WIND_UNIT=metric        # metric or imperial

# make sure tmp cache dir exists or delete contents
[[ -d "$CACHE_DIR" ]] && rm -rf $CACHE_DIR/* || mkdir -p $CACHE_DIR

# call the weather API
wget  --quiet \
        --method GET \
        --header "$H1" \
        --header "$H2" \
        --output-document \
        - "$OD" \
        -O $CACHE_FILE

if [ ! -s $CACHE_FILE ]; then 
	echo "No content in file"
	exit 1
fi

#parse the results
NAME=$(jq '.location.name' $CACHE_FILE | tr -d \")
REGION=$(jq '.location.region' $CACHE_FILE | tr -d \")
COUNTRY=$(jq '.location.country' $CACHE_FILE | tr -d \")
LAT=$(jq '.location.lat' $CACHE_FILE | tr -d \")
LON=$(jq '.location.lon' $CACHE_FILE | tr -d \")
TIMEZONE=$(jq '.location.tz_id' $CACHE_FILE | tr -d \")
LOCALTIME_EPOCH=$(jq '.location.localtime_epoch' $CACHE_FILE | tr -d \")
LOCALTIME=$(jq '.location.localtime' $CACHE_FILE | tr -d \")
LAST_UPDATED_EPOCH=$(jq '.current.last_updated_epoch' $CACHE_FILE | tr -d \")
LAST_UPDATED=$(jq '.current.last_updated' $CACHE_FILE | tr -d \")
TEMP_C=$(jq '.current.temp_c' $CACHE_FILE | tr -d \")
TEMP_F=$(jq '.current.temp_f' $CACHE_FILE | tr -d \")
IS_DAY=$(jq '.current.is_day' $CACHE_FILE | tr -d \")
CONDITION_TEXT=$(jq '.current.condition.text' $CACHE_FILE | tr -d \")
CONDITION_ICON=$(jq '.current.condition.icon' $CACHE_FILE | tr -d \")
CONDITION_CODE=$(jq '.current.condition.code' $CACHE_FILE | tr -d \")
WIND_MPH=$(jq '.current.wind_mph' $CACHE_FILE | tr -d \")
WIND_KPH=$(jq '.current.wind_kph' $CACHE_FILE | tr -d \")
WIND_DEGREE=$(jq '.current.wind_degree' $CACHE_FILE | tr -d \")
WIND_DIR=$(jq '.current.wind_dir' $CACHE_FILE | tr -d \")
PRESSURE_MB=$(jq '.current.pressure_mb' $CACHE_FILE | tr -d \")
PRESSURE_IN=$(jq '.current.pressure_in' $CACHE_FILE | tr -d \")
PRECIP_MM=$(jq '.current.precip_mm' $CACHE_FILE | tr -d \")
PRECIP_IN=$(jq '.current.precip_in' $CACHE_FILE | tr -d \")
HUMIDITY=$(jq '.current.humidity' $CACHE_FILE | tr -d \")
CLOUD=$(jq '.current.cloud' $CACHE_FILE | tr -d \")
FEELSLIKE_C=$(jq '.current.feelslike_c' $CACHE_FILE | tr -d \")
FEELSLIKE_F=$(jq '.current.feelslike_f' $CACHE_FILE | tr -d \")
VIS_KM=$(jq '.current.vis_km' $CACHE_FILE | tr -d \")
VIS_MILES=$(jq '.current.vis_miles' $CACHE_FILE | tr -d \")
UV=$(jq '.current.uv' $CACHE_FILE | tr -d \")
GUST_MPH=$(jq '.current.gust_mph' $CACHE_FILE | tr -d \")
GUST_KPH=$(jq '.current.gust_kph' $CACHE_FILE | tr -d \")

