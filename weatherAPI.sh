#!/bin/bash

# $1 = SITENAME
# $2 = LATITUDE
# $3 = LONGITUDE

# test to see if the correct number of paramaters was passed
if [ "$#" -ne 4 ]; then 
	echo "Usage: $0 SITENAME LATITUDE LONGITUDE APIKEY"
	exit 1
fi

# configurable items
UNIT=metric             # metric or imperial
WEATHER_LINK="https://www.weatherapi.com/weather/q/oshawa-ontario-canada-316180?loc=316180"

# script globals 
SITENAME="$1"
LATITUDE="$2"
LONGITUDE="$3"
API_KEY="$4"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
IMAGES_DIR="$SCRIPT_DIR/icons"
CACHE_DIR="$HOME/.cache/weatherAPI"
CACHE_FILE="$CACHE_DIR/weather.tmp"
H1="X-RapidAPI-Key: $API_KEY"
H2="X-RapidAPI-Host: weatherapi-com.p.rapidapi.com"
OD="https://weatherapi-com.p.rapidapi.com/forecast.json?q=$LATITUDE%2C$LONGITUDE&days=3"

# make sure tmp cache dir exists 
[[ -d "$CACHE_DIR" ]] || mkdir -p $CACHE_DIR

# call the weather API
wget  --quiet \
        --method GET \
        --header "$H1" \
        --header "$H2" \
        --output-document \
        - "$OD" \
        -O $CACHE_FILE

#parse the results
NAME=$(jq ".location.name" $CACHE_FILE | tr -d \")
REGION=$(jq ".location.region" $CACHE_FILE | tr -d \")
COUNTRY=$(jq ".location.country" $CACHE_FILE | tr -d \")
LAT=$(jq ".location.lat" $CACHE_FILE | tr -d \")
LON=$(jq ".location.lon" $CACHE_FILE | tr -d \")
TIMEZONE=$(jq ".location.tz_id" $CACHE_FILE | tr -d \")
LOCALTIME_EPOCH=$(jq ".location.localtime_epoch" $CACHE_FILE | tr -d \")
LOCALTIME=$(jq ".location.localtime" $CACHE_FILE | tr -d \")

LAST_UPDATED_EPOCH=$(jq ".current.last_updated_epoch" $CACHE_FILE | tr -d \")
LAST_UPDATED=$(jq ".current.last_updated" $CACHE_FILE | tr -d \")
TEMP_C=$(jq ".current.temp_c" $CACHE_FILE | tr -d \")
TEMP_F=$(jq ".current.temp_f" $CACHE_FILE | tr -d \")
IS_DAY=$(jq ".current.is_day" $CACHE_FILE | tr -d \")
CONDITION_TEXT=$(jq ".current.condition.text" $CACHE_FILE | tr -d \")
CONDITION_ICON=$(jq ".current.condition.icon" $CACHE_FILE | tr -d \")
CONDITION_CODE=$(jq ".current.condition.code" $CACHE_FILE | tr -d \")
WIND_MPH=$(jq ".current.wind_mph" $CACHE_FILE | tr -d \")
WIND_KPH=$(jq ".current.wind_kph" $CACHE_FILE | tr -d \")
WIND_DEGREE=$(jq ".current.wind_degree" $CACHE_FILE | tr -d \")
WIND_DIR=$(jq ".current.wind_dir" $CACHE_FILE | tr -d \")
PRESSURE_MB=$(jq ".current.pressure_mb" $CACHE_FILE | tr -d \")
PRESSURE_IN=$(jq ".current.pressure_in" $CACHE_FILE | tr -d \")
PRECIP_MM=$(jq ".current.precip_mm" $CACHE_FILE | tr -d \")
PRECIP_IN=$(jq ".current.precip_in" $CACHE_FILE | tr -d \")
HUMIDITY=$(jq ".current.humidity" $CACHE_FILE | tr -d \")
CLOUD=$(jq ".current.cloud" $CACHE_FILE | tr -d \")
FEELSLIKE_C=$(jq ".current.feelslike_c" $CACHE_FILE | tr -d \")
FEELSLIKE_F=$(jq ".current.feelslike_f" $CACHE_FILE | tr -d \")
VIS_KM=$(jq ".current.vis_km" $CACHE_FILE | tr -d \")
VIS_MILES=$(jq ".current.vis_miles" $CACHE_FILE | tr -d \")
UV=$(jq ".current.uv" $CACHE_FILE | tr -d \")
GUST_MPH=$(jq ".current.gust_mph" $CACHE_FILE | tr -d \")
GUST_KPH=$(jq ".current.gust_kph" $CACHE_FILE | tr -d \")

for (( c=0; c<3; c++ ))
do
	FDATE[$c]=$(jq ".forecast.forecastday[$c].date" $CACHE_FILE | tr -d \")
    FMAXTEMP_C[$c]=$(jq ".forecast.forecastday[$c].day.maxtemp_c" $CACHE_FILE | tr -d \")
    FMAXTEMP_F[$c]=$(jq ".forecast.forecastday[$c].day.maxtemp_f" $CACHE_FILE | tr -d \")
    FMINTEMP_C[$c]=$(jq ".forecast.forecastday[$c].day.mintemp_c" $CACHE_FILE | tr -d \")
    FMINTEMP_F[$c]=$(jq ".forecast.forecastday[$c].day.mintemp_f" $CACHE_FILE | tr -d \")
    FAVGTEMP_C[$c]=$(jq ".forecast.forecastday[$c].day.avgtemp_c" $CACHE_FILE | tr -d \")
    FAVGTEMP_F[$c]=$(jq ".forecast.forecastday[$c].day.avgtemp_f" $CACHE_FILE | tr -d \")
    FMAXWIND_MPH[$c]=$(jq ".forecast.forecastday[$c].day.maxwind_mph" $CACHE_FILE | tr -d \")
    FMAXWIND_KPH[$c]=$(jq ".forecast.forecastday[$c].day.maxwind_kph" $CACHE_FILE | tr -d \")
    FTOTALPRECIP_MM[$c]=$(jq ".forecast.forecastday[$c].day.totalprecip_mm" $CACHE_FILE | tr -d \")
    FTOTALPRECIP_IN[$c]=$(jq ".forecast.forecastday[$c].day.totalprecip_in" $CACHE_FILE | tr -d \")
    FTOTALSNOW_CM[$c]=$(jq ".forecast.forecastday[$c].day.totalsnow_cm" $CACHE_FILE | tr -d \")
    FAVGVIS_KM[$c]=$(jq ".forecast.forecastday[$c].day.avgvis_km" $CACHE_FILE | tr -d \")
    FAVGVIS_MILES[$c]=$(jq ".forecast.forecastday[$c].day.avgvis_miles" $CACHE_FILE | tr -d \")
    FAVGHUMIDITY[$c]=$(jq ".forecast.forecastday[$c].day.avghumidity" $CACHE_FILE | tr -d \")
    FDAILY_WILL_IT_RAIN[$c]=$(jq ".forecast.forecastday[$c].day.daily_will_it_rain" $CACHE_FILE | tr -d \")
    FDAILY_CHANCE_OF_RAIN[$c]=$(jq ".forecast.forecastday[$c].day.daily_chance_of_rain" $CACHE_FILE | tr -d \")
    FDAILY_WILL_IT_SNOW[$c]=$(jq ".forecast.forecastday[$c].day.daily_will_it_snow" $CACHE_FILE | tr -d \")
    FDAILY_CHANCE_OF_SNOW[$c]=$(jq ".forecast.forecastday[$c].day.daily_chance_of_snow" $CACHE_FILE | tr -d \")
    FDAILY_WILL_IT_RAIN[$c]=$(jq ".forecast.forecastday[$c].day.daily_will_it_rain" $CACHE_FILE | tr -d \")
    FCONDITION_TEXT[$c]=$(jq ".forecast.forecastday[$c].day.condition.text" $CACHE_FILE | tr -d \")
    FCONDITION_ICON[$c]=$(jq ".forecast.forecastday[$c].day.condition.icon" $CACHE_FILE | tr -d \")
    FCONDITION_CODE[$c]=$(jq ".forecast.forecastday[$c].day.condition.code" $CACHE_FILE | tr -d \")
    FUV[$c]=$(jq ".forecast.forecastday[$c].day.uv" $CACHE_FILE | tr -d \")
    FASTRO_SUNRISE[$c]=$(jq ".forecast.forecastday[$c].astro.sunrise" $CACHE_FILE | tr -d \")
    FASTRO_SUNSET[$c]=$(jq ".forecast.forecastday[$c].astro.sunset" $CACHE_FILE | tr -d \")
    FASTRO_MOONRISE[$c]=$(jq ".forecast.forecastday[$c].astro.moonrise" $CACHE_FILE | tr -d \")
    FASTRO_MOONSET[$c]=$(jq ".forecast.forecastday[$c].astro.moonset" $CACHE_FILE | tr -d \")
    FASTRO_MOONPHASE[$c]=$(jq ".forecast.forecastday[$c].astro.moon_phase" $CACHE_FILE | tr -d \")
    FASTRO_MOON_ILLUMINATION[$c]=$(jq ".forecast.forecastday[$c].astro.moon_illumination" $CACHE_FILE | tr -d \")
    FASTRO_IS_MOON_UP[$c]=$(jq ".forecast.forecastday[$c].astro.is_moon_up" $CACHE_FILE | tr -d \")
    FASTRO_IS_SUN_UP[$c]=$(jq ".forecast.forecastday[$c].astro.is_sun_up" $CACHE_FILE | tr -d \")
done

# unit processing - prepare metric or imperial measurement
case $UNIT in
    metric)
        gTEMP_SUFFIX="°C"
        gWIND_SUFFIX="kph"
        gPRESSURE_SUFFIX="mb"
        gPRECIP_SUFFIX="mm"
        gVIS_SUFFIX="km"
        gTEMP=$TEMP_C
        gWIND=$WIND_KPH
        gPRESSURE=$PRESSURE_MB
        gPRECIP=$PRECIP_MM
        gFEELSLIKE=$FEELSLIKE_C
        gVIS=$VIS_KM
        gGUST=$GUST_KPH
        for (( c=0; c<3; c++ ))
        do
            gFMAXTEMP[$c]=${FMAXTEMP_C[$c]}
            gFMINTEMP[$c]=${FMINTEMP_C[$c]}
            gFAVGTEMP[$c]=${FAVGTEMP_C[$c]}
            gFMAXWIND[$c]=${FMAXWIND_KPH[$c]}
            gFTOTALPRECIP[$c]=${FTOTALPRECIP_MM[$c]}
            gFAVGVIS[$c]=${FAVGVIS_KM[$c]}
            gFASTRO_SUNRISE[$c]=$(date -d "${FASTRO_SUNRISE[$c]}" "+%-I:%M%P")
            gFASTRO_SUNSET[$c]=$(date -d "${FASTRO_SUNSET[$c]}" "+%-I:%M%P")
        done
    ;;
    imperial)
        gTEMP_SUFFIX="°F"
        gWIND_SUFFIX="mph"
        gPRESSURE_SUFFIX="in"
        gPRECIP_SUFFIX="in"
        gVIS_SUFFIX="miles"
        gTEMP=$TEMP_F
        gWIND=$WIND_MPH
        gPRESSURE=$PRESSURE_IN
        gPRECIP=$PRECIP_IN
        gFEELSLIKE=$FEELSLIKE_F
        gVIS=$VIS_MILES
        gGUST=$GUST_MPH
        for (( c=0; c<3; c++ ))
        do
            gFMAXTEMP[c$]=${FMAXTEMP_F[$c]}
            gFMINTEMP[c$]=${FMINTEMP_F[$c]}
            gFAVGTEMP[c$]=${FAVGTEMP_F[$c]}
            gFMAXWIND[c$]=${FMAXWIND_MPH[$c]}
            gFTOTALPRECIP[$c]=${FTOTALPRECIP_IN[$c]}
            gFAVGVIS[$c]=${FAVGVIS_MILES[$c]}
            gFASTRO_SUNRISE[$c]=$(date -d "${FASTRO_SUNRISE[$c]}" "+%-I:%M%P")
            gFASTRO_SUNSET[$c]=$(date -d "${FASTRO_SUNSET[$c]}" "+%-I:%M%P")
        done
    ;;
esac

# format dates


# parse uvindex value into text
case $UV in
    [0-2])          UVSTR="Low"         ;;
    [3-5])          UVSTR="Moderate"    ;;
    [6-7])          UVSTR="High"        ;;
    [8-9]|10)       UVSTR="Very high"   ;;
    11|12)          UVSTR="Extreme"     ;;
    *)              UVSTR="Unknown"     ;;
esac


# genmon
echo "<img>http:$CONDITION_ICON</img><txt> $gTEMP$gTEMP_SUFFIX</txt>"
echo "<click>exo-open $WEATHER_LINK</click><txtclick>exo-open $WEATHER_LINK</txtclick>"
echo "<css></css>"
echo -e "<tool><big>$SITENAME</big>
$gTEMP$gTEMP_SUFFIX <small>and</small> $CONDITION_TEXT

Feels Like:\t\t$gFEELSLIKE$gTEMP_SUFFIX

Humidity:\t\t$HUMIDITY %
Pressure:\t\t$gPRESSURE $gPRESSURE_SUFFIX
UV:\t\t$UV ($UVSTR)

Clouds:\t\t$CLOUD %
Wind:\t\t$gWIND $gWIND_SUFFIX <small>from the</small>$WIND_DIR
Gusting:\t$gGUST $gWIND_SUFFIX

Precipitation:\t${gFTOTALPRECIP[0]} $gPRECIP_SUFFIX

Sunrise/set:\t${gFASTRO_SUNRISE[0]} / ${gFASTRO_SUNSET[0]}
Moonphase:\t${FASTRO_MOONPHASE[0]} (${FASTRO_MOON_ILLUMINATION[0]} %)

Today:\t${FCONDITION_TEXT[0]}, high: ${gFMAXTEMP[0]} low: ${gFMINTEMP[0]}
Tomorrow:\t${FCONDITION_TEXT[1]}, high: ${gFMAXTEMP[1]}, low: ${gFMINTEMP[1]}
Next Day:\t${FCONDITION_TEXT[2]}, high: ${gFMAXTEMP[2]}, low: ${gFMINTEMP[2]}

<small><i>$LAST_UPDATED</i></small></tool>"

exit 0

# debug
echo "NAME=$NAME"
echo "REGION=$REGION"
echo "COUNTRY=$COUNTRY"
echo "LAT=$LAT"
echo "LON=$LON"
echo "TIMEZONE=$TIMEZONE"
echo "LOCALTIME_EPOCH=$LOCALTIME_EPOCH"
echo "LOCALTIME=$LOCALTIME"
echo
echo "LAST_UPDATED_EPOCH=$LAST_UPDATED_EPOCH"
echo "LAST_UPDATED=$LAST_UPDATED"
echo "TEMP_C=$TEMP_C"
echo "TEMP_F=$TEMP_F"
echo "IS_DAY=$IS_DAY"
echo "CONDITION_TEXT=$CONDITION_TEXT"
echo "CONDITION_ICON=$CONDITION_ICON"
echo "CONDITION_CODE=$CONDITION_CODE"
echo "WIND_MPH=$WIND_MPH"
echo "WIND_KPH=$WIND_KPH"
echo "WIND_DEGREE=$WIND_DEGREE"
echo "WIND_DIR=$WIND_DIR"
echo "PRESSURE_MB=$PRESSURE_MB"
echo "PRESSURE_IN=$PRESSURE_IN"
echo "PRECIP_MM=$PRECIP_MM"
echo "PRECIP_IN=$PRECIP_IN"
echo "HUMIDITY=$HUMIDITY"
echo "CLOUD=$CLOUD"
echo "FEELSLIKE_C=$FEELSLIKE_C"
echo "FEELSLIKE_F=$FEELSLIKE_F"
echo "VIS_KM=$VIS_KM"
echo "VIS_MILES=$VIS_MILES"
echo "UV=$UV"
echo "GUST_MPH=$GUST_MPH"
echo "GUST_KPH=$GUST_KPH"
echo

for (( c=0; c<3; c++ ))
do
	echo "FDATE[$c]=${FDATE[$c]}"
    echo "FMAXTEMP_C[$c]=${FMAXTEMP_C[$c]}"
    echo "FMAXTEMP_F[$c]=${FMAXTEMP_F[$c]}"
    echo "FMINTEMP_C[$c]=${FMINTEMP_C[$c]}"
    echo "FMINTEMP_F[$c]=${FMINTEMP_F[$c]}"
    echo "FAVGTEMP_C[$c]=${FAVGTEMP_C[$c]}"
    echo "FAVGTEMP_F[$c]=${FAVGTEMP_F[$c]}"
    echo "FMAXWIND_MPH[$c]=${FMAXWIND_MPH[$c]}"
    echo "FMAXWIND_KPH[$c]=${FMAXWIND_KPH[$c]}"
    echo "FTOTALPRECIP_MM[$c]=${FTOTALPRECIP_MM[$c]}"
    echo "FTOTALPRECIP_IN[$c]=${FTOTALPRECIP_IN[$c]}"
    echo "FTOTALSNOW_CM[$c]=${FTOTALSNOW_CM[$c]}"
    echo "FAVGVIS_KM[$c]=${FAVGVIS_KM[$c]}"
    echo "FAVGVIS_MILES[$c]=${FAVGVIS_MILES[$c]}"
    echo "FAVGHUMIDITY[$c]=${FAVGHUMIDITY[$c]}"
    echo "FDAILY_WILL_IT_RAIN[$c]=${FDAILY_WILL_IT_RAIN[$c]}"
    echo "FDAILY_CHANCE_OF_RAIN[$c]=${FDAILY_CHANCE_OF_RAIN[$c]}"
    echo "FDAILY_WILL_IT_SNOW[$c]=${FDAILY_WILL_IT_SNOW[$c]}"
    echo "FDAILY_CHANCE_OF_SNOW[$c]=${FDAILY_CHANCE_OF_SNOW[$c]}"
    echo "FDAILY_WILL_IT_RAIN[$c]=${FDAILY_WILL_IT_RAIN[$c]}"
    echo "FCONDITION_TEXT[$c]=${FCONDITION_TEXT[$c]}"
    echo "FCONDITION_ICON[$c]=${FCONDITION_ICON[$c]}"
    echo "FCONDITION_CODE[$c]=${FCONDITION_CODE[$c]}"
    echo "FUV[$c]=${FUV[$c]}"
    echo "FASTRO_SUNRISE[$c]=${FASTRO_SUNRISE[$c]}"
    echo "FASTRO_SUNSET[$c]=${FASTRO_SUNSET[$c]}"
    echo "FASTRO_MOONRISE[$c]=${FASTRO_MOONRISE[$c]}"
    echo "FASTRO_MOONSET[$c]=${FASTRO_MOONSET[$c]}"
    echo "FASTRO_MOONPHASE[$c]=${FASTRO_MOONPHASE[$c]}"
    echo "FASTRO_MOON_ILLUMINATION[$c]=${FASTRO_MOON_ILLUMINATION[$c]}"
    echo "FASTRO_IS_MOON_UP[$c]=${FASTRO_IS_MOON_UP[$c]}"
    echo "FASTRO_IS_SUN_UP[$c]=${FASTRO_IS_SUN_UP[$c]}"
    echo
done