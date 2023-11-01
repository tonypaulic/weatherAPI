#!/bin/bash
# requires: xfce4-genmon-plugin wget jq imagemagick 
# call: /path/to/script APIKEY SITENAME LATITUDE LONGITUDE 
#   or:
# call: /path/to/script APIKEY auto
#
# $1 = API Key (https://www.weatherapi.com/signup.aspx)
# $2 = SITENAME (or 'auto')
# $3 = LATITUDE (if auto not used)
# $4 = LONGITUDE (if auto not used)

#######################################################################################################################
##### configurable items
USE_SITEID=1            # if not auto, whether to use the SITEID provided, or the location names as returned by the API
UNIT=metric             # metric or imperial
USE_THEME_ICONS=0       # 0 = no (use images), 1 = yes, use icon theme's weather icons
IMAGE_SIZE=22           # 22, 48, or 128
WEATHER_LINK="https://www.weatherapi.com/weather/q/oshawa-ontario-canada-316180?loc=316180"
#######################################################################################################################

##### test to see if the correct number of paramaters was passed
if [ "$2" != "auto" ] && [ "$#" -ne 4 ]; then 
	echo "Usage: $0 APIKEY SITENAME LATITUDE LONGITUDE"
	echo "or"
	echo "Usage: $0 APIKEY auto (to set weather based on geo-location of public IP address)"
	exit 1
fi

##### script globals 
API_KEY="$1"
if [ "$2" != "auto" ]; then
	SITENAME="$2"
	LATITUDE="$3"
	LONGITUDE="$4"
else
	LATITUDE="$(curl -s ipinfo.io/$(curl ifconfig.co) | grep loc | awk '{print $2}' | tr -d \" | awk -F',' '{print $1}')"
	LONGITUDE="$(curl -s ipinfo.io/$(curl ifconfig.co) | grep loc | awk '{print $2}' | tr -d \" | awk -F',' '{print $2}')"
	USE_SITEID=0
	WEATHER_LINK="https://www.weatherapi.com/weather/"
fi
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
IMAGES_DIR="$SCRIPT_DIR/images/$IMAGE_SIZE"
H1="X-RapidAPI-Key: $API_KEY"
H2="X-RapidAPI-Host: weatherapi-com.p.rapidapi.com"
OD="https://weatherapi-com.p.rapidapi.com/forecast.json?q=$LATITUDE%2C$LONGITUDE&days=3"

# get current month for conditionals
MONTH=$(date +%m)
if [ $LATITUDE = ^-.* ]; then
    case $MONTH in
        05|06|07|08|09|10) COLD=1 ;;
        *) COLD=0 ;;
    esac
else
    case $MONTH in
        01|02|03|04|10|11|12) COLD=1 ;;
        *) COLD=0 ;;
    esac
fi

##### call the weather API
CACHE=$(wget --quiet --method GET --header "$H1" --header "$H2" --output-document - "$OD")

##### parse the results
NAME=$(echo $CACHE | jq ".location.name" | tr -d \")
if [ "$2" == "auto" ]; then WEATHER_LINK="https://www.weatherapi.com/weather/q/$NAME"; fi
    #REGION=$(echo $CACHE | jq ".location.region" | tr -d \")
    #COUNTRY=$(echo $CACHE | jq ".location.country" | tr -d \")
    #LAT=$(echo $CACHE | jq ".location.lat" | tr -d \")
    #LON=$(echo $CACHE | jq ".location.lon" | tr -d \")
    #TIMEZONE=$(echo $CACHE | jq ".location.tz_id" | tr -d \")
    #LOCALTIME_EPOCH=$(echo $CACHE | jq ".location.localtime_epoch" | tr -d \")
    #LOCALTIME=$(echo $CACHE | jq ".location.localtime" | tr -d \")
    #LAST_UPDATED_EPOCH=$(echo $CACHE | jq ".current.last_updated_epoch" | tr -d \")
LAST_UPDATED=$(echo $CACHE | jq ".current.last_updated" | tr -d \")
TEMP_C=$(printf "%.0f\n" "$(echo $CACHE | jq ".current.temp_c" | tr -d \")")
[[ $TEMP_C == "-0" ]] && TEMP_C="0"
TEMP_F=$(printf "%.0f\n" "$(echo $CACHE | jq ".current.temp_f" | tr -d \")")
[[ $TEMP_F == "-0" ]] && TEMP_F="0"
IS_DAY=$(echo $CACHE | jq ".current.is_day" | tr -d \")
CONDITION_TEXT=$(echo $CACHE | jq ".current.condition.text" | tr -d \")
CONDITION_ICON=$(echo $CACHE | jq ".current.condition.icon" | tr -d \")
CONDITION_CODE=$(echo $CACHE | jq ".current.condition.code" | tr -d \")
WIND_MPH=$(echo $CACHE | jq ".current.wind_mph" | tr -d \")
WIND_KPH=$(echo $CACHE | jq ".current.wind_kph" | tr -d \")
    #WIND_DEGREE=$(echo $CACHE | jq ".current.wind_degree" | tr -d \")
WIND_DIR=$(echo $CACHE | jq ".current.wind_dir" | tr -d \" | sed -e 's/W/West/g' -e 's/E/East/g' -e 's/S/South/g' -e 's/N/North/g')
PRESSURE_MB=$(echo $CACHE | jq ".current.pressure_mb" | tr -d \")
PRESSURE_IN=$(echo $CACHE | jq ".current.pressure_in" | tr -d \")
    #PRECIP_MM=$(echo $CACHE | jq ".current.precip_mm" | tr -d \")
    #PRECIP_IN=$(echo $CACHE | jq ".current.precip_in" | tr -d \")
HUMIDITY=$(echo $CACHE | jq ".current.humidity" | tr -d \")
CLOUD=$(echo $CACHE | jq ".current.cloud" | tr -d \")
FEELSLIKE_C=$(printf "%.0f\n" "$(echo $CACHE | jq ".current.feelslike_c" | tr -d \")")
[[ $FEELSLIKE_C == "-0" ]] && FEELSLIKE_C="0"
FEELSLIKE_F=$(printf "%.0f\n" "$(echo $CACHE | jq ".current.feelslike_f" | tr -d \")")
[[ $FEELSLIKE_F == "-0" ]] && FEELSLIKE_F="0"
    #VIS_KM=$(echo $CACHE | jq ".current.vis_km" | tr -d \")
    #VIS_MILES=$(echo $CACHE | jq ".current.vis_miles" | tr -d \")
UV=$(echo $CACHE | jq ".current.uv" | tr -d \")
GUST_MPH=$(echo $CACHE | jq ".current.gust_mph" | tr -d \")
GUST_KPH=$(echo $CACHE | jq ".current.gust_kph" | tr -d \")

WINDCHILL_C=$(printf "%.0f\n" "$(echo $CACHE | jq ".forecast.forecastday[0].hour[$(date +%k)].windchill_c" | tr -d \")")
WINDCHILL_F=$(printf "%.0f\n" "$(echo $CACHE | jq ".forecast.forecastday[0].hour[$(date +%k)].windchill_f" | tr -d \")")
HEATINDEX_C=$(printf "%.0f\n" "$(echo $CACHE | jq ".forecast.forecastday[0].hour[$(date +%k)].heatindex_c" | tr -d \")")
HEATINDEX_F=$(printf "%.0f\n" "$(echo $CACHE | jq ".forecast.forecastday[0].hour[$(date +%k)].heatindex_f" | tr -d \")")

for (( c=0; c<3; c++ ))
do
	    #FDATE[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].date" | tr -d \")
    FMAXTEMP_C[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].day.maxtemp_c" | tr -d \")
    FMAXTEMP_F[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].day.maxtemp_f" | tr -d \")
    FMINTEMP_C[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].day.mintemp_c" | tr -d \")
    FMINTEMP_F[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].day.mintemp_f" | tr -d \")
        #FAVGTEMP_C[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].day.avgtemp_c" | tr -d \")
        #FAVGTEMP_F[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].day.avgtemp_f" | tr -d \")
    FMAXWIND_MPH[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].day.maxwind_mph" | tr -d \")
    FMAXWIND_KPH[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].day.maxwind_kph" | tr -d \")
    FTOTALPRECIP_MM[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].day.totalprecip_mm" | tr -d \")
    FTOTALPRECIP_IN[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].day.totalprecip_in" | tr -d \")
    FTOTALSNOW_CM[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].day.totalsnow_cm" | tr -d \")
        #FAVGVIS_KM[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].day.avgvis_km" | tr -d \")
        #FAVGVIS_MILES[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].day.avgvis_miles" | tr -d \")
        #FAVGHUMIDITY[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].day.avghumidity" | tr -d \")
        #FDAILY_WILL_IT_RAIN[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].day.daily_will_it_rain" | tr -d \")
    FDAILY_CHANCE_OF_RAIN[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].day.daily_chance_of_rain" | tr -d \")
        #FDAILY_WILL_IT_SNOW[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].day.daily_will_it_snow" | tr -d \")
    FDAILY_CHANCE_OF_SNOW[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].day.daily_chance_of_snow" | tr -d \")
        #FDAILY_WILL_IT_RAIN[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].day.daily_will_it_rain" | tr -d \")
    FCONDITION_TEXT[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].day.condition.text" | tr -d \")
    FCONDITION_ICON[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].day.condition.icon" | tr -d \")
    FCONDITION_CODE[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].day.condition.code" | tr -d \")
        #FUV[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].day.uv" | tr -d \")
    FASTRO_SUNRISE[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].astro.sunrise" | tr -d \")
    FASTRO_SUNSET[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].astro.sunset" | tr -d \")
        #FASTRO_MOONRISE[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].astro.moonrise" | tr -d \")
        #FASTRO_MOONSET[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].astro.moonset" | tr -d \")
    FASTRO_MOONPHASE[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].astro.moon_phase" | tr -d \")
    FASTRO_MOON_ILLUMINATION[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].astro.moon_illumination" | tr -d \")
        #FASTRO_IS_MOON_UP[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].astro.is_moon_up" | tr -d \")
        #FASTRO_IS_SUN_UP[$c]=$(echo $CACHE | jq ".forecast.forecastday[$c].astro.is_sun_up" | tr -d \")
done

##### unit processing - prepare metric or imperial measurement
[[ $UNIT == "imperial" ]] && gTEMP_SUFFIX="°F"          || gTEMP_SUFFIX="°C"
[[ $UNIT == "imperial" ]] && gWIND_SUFFIX="mph"         || gWIND_SUFFIX="kph"
[[ $UNIT == "imperial" ]] && gPRESSURE_SUFFIX="in"      || gPRESSURE_SUFFIX="mb"
[[ $UNIT == "imperial" ]] && gPRECIP_SUFFIX="in"        || gPRECIP_SUFFIX="mm"
    #[[ $UNIT == "imperial" ]] && gVIS_SUFFIX="miles"        || gVIS_SUFFIX="km"
[[ $UNIT == "imperial" ]] && gTEMP=$TEMP_F              || gTEMP=$TEMP_C
[[ $UNIT == "imperial" ]] && gWIND=$WIND_MPH            || gWIND=$WIND_KPH
[[ $UNIT == "imperial" ]] && gPRESSURE=$PRESSURE_IN     || gPRESSURE=$PRESSURE_MB
[[ $UNIT == "imperial" ]] && gPRECIP=$PRECIP_IN         || gPRECIP=$PRECIP_MM
[[ $UNIT == "imperial" ]] && gFEELSLIKE=$FEELSLIKE_F    || gFEELSLIKE=$FEELSLIKE_C
    #[[ $UNIT == "imperial" ]] && gVIS=$VIS_MILES            || gVIS=$VIS_KM
[[ $UNIT == "imperial" ]] && gGUST=$GUST_MPH            || gGUST=$GUST_KPH
[[ $UNIT == "imperial" ]] && gWINDCHILL=$WINDCHILL_F    || gWINDCHILL=$WINDCHILL_C
[[ $UNIT == "imperial" ]] && gHEATINDEX=$HEATINDEX_F    || gHEATINDEX=$HEATINDEX_C

for (( c=0; c<3; c++ ))
do
    [[ $UNIT == "imperial" ]] && gFMAXTEMP[c$]=${FMAXTEMP_F[$c]} \
                              || gFMAXTEMP[$c]=${FMAXTEMP_C[$c]}
    [[ $UNIT == "imperial" ]] && gFMINTEMP[c$]=${FMINTEMP_F[$c]} \
                              || gFMINTEMP[$c]=${FMINTEMP_C[$c]}
        #[[ $UNIT == "imperial" ]] && gFAVGTEMP[c$]=${FAVGTEMP_F[$c]} \
        #                          || gFAVGTEMP[$c]=${FAVGTEMP_C[$c]}
        #[[ $UNIT == "imperial" ]] && gFMAXWIND[c$]=${FMAXWIND_MPH[$c]} \
        #                          || gFMAXWIND[$c]=${FMAXWIND_KPH[$c]}
    [[ $UNIT == "imperial" ]] && gFTOTALPRECIP[$c]=${FTOTALPRECIP_IN[$c]} \
                              || gFTOTALPRECIP[$c]=${FTOTALPRECIP_MM[$c]}
        #[[ $UNIT == "imperial" ]] && gFAVGVIS[$c]=${FAVGVIS_MILES[$c]} \
        #                          || gFAVGVIS[$c]=${FAVGVIS_KM[$c]}
    [[ $UNIT == "imperial" ]] && gFASTRO_SUNRISE[$c]=$(date -d "${FASTRO_SUNRISE[$c]}" "+%-I:%M%P") \
                              || gFASTRO_SUNRISE[$c]=$(date -d "${FASTRO_SUNRISE[$c]}" "+%-I:%M%P")
    [[ $UNIT == "imperial" ]] && gFASTRO_SUNSET[$c]=$(date -d "${FASTRO_SUNSET[$c]}" "+%-I:%M%P") \
                              || gFASTRO_SUNSET[$c]=$(date -d "${FASTRO_SUNSET[$c]}" "+%-I:%M%P")
done

##### parse uvindex value into text
case $UV in
    [0-2].*)      	UVSTR="Low"       ;;
    [3-5].*)      	UVSTR="Moderate"  ;;
    [6-7].*)      	UVSTR="High"      ;;
    [8-9].*|10.*)	UVSTR="Very high" ;;
    11.*|12.*) 		UVSTR="Extreme"   ;;
    *)   		UVSTR="Unknown"   ;;
esac

##### prepare the icon to use
if [ $USE_THEME_ICONS -eq 1 ]; then
    case $CONDITION_CODE in
        1006|1009)                                      ICON=weather-overcast-symbolic  ;;    
        1030|1135|1147)                                 ICON=weather-fog-symbolic ;;
        1153|1183)                                      ICON=weather-showers-scattered-symbolic ;;
        1063|1150|1180|1240)                            ICON=weather-showers-scattered-symbolic ;;
        1087)                                           ICON=weather-storm-symbolic ;;
        1003) [[ $IS_DAY -eq 1 ]] && ICON=weather-few-clouds-symbolic || ICON=weather-few-clouds-night-symbolic ;;
        1186|1189|1192|1195|1243|1246)                  ICON=weather-showers-symbolic ;;
        1273|1289)                                      ICON=weather-storm-symbolic   ;;
        1168|1171|1198|1201|1207|1237|1252|1261|1264)   ICON=weather-showers-symbolic ;;
        1069|1072|1204|1249|1276|1279)                  ICON=weather-showers-scattered-symbolic ;;
        1114|1117|1213|1219|1225|1258)                  ICON=weather-snow-symbolic ;;
        1066|1210|1216|1222|1255)                       ICON=weather-snow-symbolic ;;
        1282)                                           ICON=weather-storm-symbolic ;;
        1000) [[ $IS_DAY -eq 1 ]] && ICON=weather-clear-symbolic || ICON=weather-clear-night-symbolic ;;
        *) ICON=wheather-severe-alert-symbolic
    esac
    gICON=$ICON
else
    case $CONDITION_CODE in
        1006|1009)                                      [[ $IS_DAY -eq 1 ]] && ICON=cloud.png                  || ICON=cloud-night.png                 ;;    
        1030|1135|1147)                                 [[ $IS_DAY -eq 1 ]] && ICON=fog.png                    || ICON=fog-night.png                   ;;
        1153|1183)                                      [[ $IS_DAY -eq 1 ]] && ICON=lightrain.png              || ICON=lightrain-night.png             ;;
        1063|1150|1180|1240)                            [[ $IS_DAY -eq 1 ]] && ICON=lightrainsun.png           || ICON=lightrainsun-night.png          ;;
        1087)                                           [[ $IS_DAY -eq 1 ]] && ICON=lightrainthundersun.png    || ICON=lightrainthundersun-night.png   ;;
        1003)                                           [[ $IS_DAY -eq 1 ]] && ICON=partlycloud.png            || ICON=partlycloud-night.png           ;;
        1186|1189|1192|1195|1243|1246)                  [[ $IS_DAY -eq 1 ]] && ICON=rain.png                   || ICON=rain-night.png                  ;;
        1273|1289)                                      [[ $IS_DAY -eq 1 ]] && ICON=rainthunder.png            || ICON=rainthunder-night.png           ;;
        1168|1171|1198|1201|1207|1237|1252|1261|1264)   [[ $IS_DAY -eq 1 ]] && ICON=sleet.png                  || ICON=sleet-night.png                 ;;
        1069|1072|1204|1249|1276|1279)                  [[ $IS_DAY -eq 1 ]] && ICON=sleetsun.png               || ICON=sleetsun-night.png              ;;
        1114|1117|1213|1219|1225|1258)                  [[ $IS_DAY -eq 1 ]] && ICON=snow.png                   || ICON=snow-night.png                  ;;
        1066|1210|1216|1222|1255)                       [[ $IS_DAY -eq 1 ]] && ICON=snowsun.png                || ICON=snowsun-night.png               ;;
        1282)                                           [[ $IS_DAY -eq 1 ]] && ICON=snowthunder.png            || ICON=snowthunder-night.png           ;;
        1000)                                           [[ $IS_DAY -eq 1 ]] && ICON=sun.png                    || ICON=sun-night.png                   ;;
        *) ICON=nodata.png
    esac
    gIMAGE="$IMAGES_DIR/$ICON"
fi

# process moon phase glyph (https://www.unicode.org/L2/L2017/17304-moon-var.pdf)
case ${FASTRO_MOONPHASE[0]} in
    "New Moon")         [[ $LATITUDE = ^-.* ]] && SYMBOL="0001F311" || SYMBOL="0001F315"    ;;
    "Waning Crescent")  [[ $LATITUDE = ^-.* ]] && SYMBOL="0001F312" || SYMBOL="0001F314"    ;;
    "Last Quarter")     [[ $LATITUDE = ^-.* ]] && SYMBOL="0001F313" || SYMBOL="0001F313"    ;;
    "Waning Gibbous")   [[ $LATITUDE = ^-.* ]] && SYMBOL="0001F314" || SYMBOL="0001F312"    ;;
    "Full Moon")        [[ $LATITUDE = ^-.* ]] && SYMBOL="0001F315" || SYMBOL="0001F311"    ;;
    "Waxing Gibbous")   [[ $LATITUDE = ^-.* ]] && SYMBOL="0001F316" || SYMBOL="0001F318"    ;;
    "First Quarter")    [[ $LATITUDE = ^-.* ]] && SYMBOL="0001F317" || SYMBOL="0001F317"    ;;
    "Waxing Crescent")  [[ $LATITUDE = ^-.* ]] && SYMBOL="0001F318" || SYMBOL="0001F316"    ;;
    *)                  SYMBOL="X" ;;
esac

# choose which site name to use in tooltip
[[ $USE_SITEID = 1 ]] && gNAME=$SITENAME || gNAME=$NAME

##### genmon
if [ $USE_THEME_ICONS -eq 1 ]; then
    echo "<icon>$gICON</icon><<txt> $gTEMP$gTEMP_SUFFIX</txt>"
    echo "<iconclick>exo-open $WEATHER_LINK</iconclick><txtclick>exo-open $WEATHER_LINK</txtclick>"
    echo "<css></css>"    
else
    echo "<img>$gIMAGE</img><txt> $gTEMP$gTEMP_SUFFIX</txt>"
    echo "<click>exo-open $WEATHER_LINK</click><txtclick>exo-open $WEATHER_LINK</txtclick>"
    echo "<css>.genmon_imagebutton>image {padding-bottom: 3px}</css>"
fi

echo -e "<tool><big>$gNAME</big>
$gTEMP$gTEMP_SUFFIX <small>and</small> $CONDITION_TEXT

Feels Like:\t$gFEELSLIKE$gTEMP_SUFFIX"

if [ $COLD -eq 0 ]; then 
    if [ $gHEATINDEX -gt $gTEMP -a $gHEATINDEX -gt $gFEELSLIKE ]; then
        echo -e "Heat Index:\t$gHEATINDEX$gTEMP_SUFFIX"
    fi
else
    if [ $gWIND_CHILL -lt $gTEMP -a $gWIND_CHILL -lt $gFEELSLIKE ]; then
        echo -e "Wind Chill:\t\t$gWINDCHILL$gTEMP_SUFFIX"
    fi
fi

echo -e "
Humidity:\t\t$HUMIDITY%
Pressure:\t\t$gPRESSURE $gPRESSURE_SUFFIX
UV:\t\t\t$UV ($UVSTR)

Clouds:\t\t$CLOUD%
Wind:\t\t$gWIND $gWIND_SUFFIX <small>from the</small> $WIND_DIR
Gusting:\t\t$gGUST $gWIND_SUFFIX
 
Precipitation:\t${gFTOTALPRECIP[0]} $gPRECIP_SUFFIX <small>expected</small> (${FDAILY_CHANCE_OF_RAIN[0]}% <small>probability</small>)"

if [ $COLD -eq 1 ]; then
echo -e "Snow:\t\t${FTOTALSNOW_CM[0]} cm"
fi

echo -e "
Sunrise/set:\t${gFASTRO_SUNRISE[0]} / ${gFASTRO_SUNSET[0]}
Moonphase:\t\U$SYMBOL ${FASTRO_MOONPHASE[0]} (${FASTRO_MOON_ILLUMINATION[0]}% <small>illuminated</small>)

Today:\t\t${FCONDITION_TEXT[0]}, high: ${gFMAXTEMP[0]} low: ${gFMINTEMP[0]}
Tomorrow:\t${FCONDITION_TEXT[1]}, high: ${gFMAXTEMP[1]}, low: ${gFMINTEMP[1]}
Next Day:\t\t${FCONDITION_TEXT[2]}, high: ${gFMAXTEMP[2]}, low: ${gFMINTEMP[2]}

<small><i>Last updated: $LAST_UPDATED</i></small></tool>"

exit 0
