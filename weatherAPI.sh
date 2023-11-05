#!/bin/bash
# This script queries the weatherAPI data service for current and forecast weather data
#   and outputs a self-overwriting notification bubble with weather conditions 
# Requires: curl jq [moon phase glyphs font support like nerd-fonts-symbols] [weatherapi.com free account]

#######################################################################################################################
##### CONFIGURABLE SETTINGS - ADJUST AS NEEDED
#
# USE_SITEID: whether to use the SITE provided (1), or the location names as returned by the API (0)
USE_SITEID=0
#    
# if USE_SITEID=1, specify the SITE      
SITE=Whitby
#
# metric or imperial
UNIT=metric
#
# your personal weatherapi key - signup here: https://www.weatherapi.com/ 
#   put your key into $HOME/.weatherAPI_key or just as variable below
KEY="$(cat $HOME/.weatherAPI_key)"
#
# see request parameter 'q' at https://www.weatherapi.com/docs/
#QLOOKUP="43.6532,-78.3832"
#QLOOKUP="Toronto"
QLOOKUP="L1P"
#QLOOKUP="metar:CYKZ"
#QLOOKUP="iata:YKZ"
#QLOOKUP="auto:ip"
#QLOOKUP="192.168.1.1"
#QLOOKUP="id:xxx"       # not implemented
#
# set webpage for genmon button click
WEATHER_LINK="https://www.weatherapi.com/weather/q/oshawa-ontario-canada-316180?loc=316180"
#######################################################################################################################

# get current month for conditionals. If cold will see windchill, otherwise heat index (if applicable)
MONTH=$(date +%m)
if [ "$LATITUDE" == "^-.*" ]; then
    # southern hemisphere
    case $MONTH in
        05|06|07|08|09|10) COLD=1 ;;
        *) COLD=0 ;;
    esac
else
    # northern hemisphere
    case $MONTH in
        01|02|03|04|10|11|12) COLD=1 ;;
        *) COLD=0 ;;
    esac
fi

##### call the weather API, save output to variable and file
CACHE=$(curl -s -X 'GET' \
  'https://api.weatherapi.com/v1/forecast.json?q='$QLOOKUP'&days=3&alerts=alerts%3Dyes&aqi=aqi%3Dyes&key='$KEY \
  -H 'accept: application/json' | tee /tmp/weather.cache)

##### parse the results (indented & commented out variables exist but not used)
[[ $USE_SITEID -eq 0 ]] && NAME=$(echo $CACHE | jq ".location.name" | tr -d \") || NAME=$SITE
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
TEMP_F=$(printf "%.0f\n" "$(echo $CACHE | jq ".current.temp_f" | tr -d \")")
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
FEELSLIKE_F=$(printf "%.0f\n" "$(echo $CACHE | jq ".current.feelslike_f" | tr -d \")")
    #VIS_KM=$(echo $CACHE | jq ".current.vis_km" | tr -d \")
    #VIS_MILES=$(echo $CACHE | jq ".current.vis_miles" | tr -d \")
UV=$(echo $CACHE | jq ".current.uv" | tr -d \")
GUST_MPH=$(echo $CACHE | jq ".current.gust_mph" | tr -d \")
GUST_KPH=$(echo $CACHE | jq ".current.gust_kph" | tr -d \")
WINDCHILL_C=$(printf "%.0f\n" "$(echo $CACHE | jq ".forecast.forecastday[0].hour[$(date +%k)].windchill_c" | tr -d \")")
WINDCHILL_F=$(printf "%.0f\n" "$(echo $CACHE | jq ".forecast.forecastday[0].hour[$(date +%k)].windchill_f" | tr -d \")")
HEATINDEX_C=$(printf "%.0f\n" "$(echo $CACHE | jq ".forecast.forecastday[0].hour[$(date +%k)].heatindex_c" | tr -d \")")
HEATINDEX_F=$(printf "%.0f\n" "$(echo $CACHE | jq ".forecast.forecastday[0].hour[$(date +%k)].heatindex_f" | tr -d \")")

# forecast data
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
    *)   		    UVSTR="Unknown"   ;;
esac

##### prepare the icon to use
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

# process moon phase glyph (also: https://www.unicode.org/L2/L2017/17304-moon-var.pdf)
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

# remove negative zero temperatures
[[ "$gTEMP" == "-0" ]] && gTEMP="0"
[[ "$gFEELSLIKE" == "-0" ]] && gFEELSLIKE="0"

# do the genmon
echo "<icon>$ICON</icon><txt>$gTEMP$gTEMP_SUFFIX</txt>"
echo "<iconclick>exo-open $WEATHER_LINK</iconclick><txtclick>exo-open $WEATHER_LINK</txtclick>"
echo "<css>.genmon_imagebutton {padding-bottom: 6px} .genmon_valuebutton {padding-top: 2px} image {-gtk-icon-theme: 'elementary-xfce'}</css>" 

# create the tooltip
echo -e "<tool><big><b>$NAME</b></big>\r"
echo -e "$gTEMP$gTEMP_SUFFIX   &amp;   $CONDITION_TEXT\r\rFeels Like:\t\t$gFEELSLIKE$gTEMP_SUFFIX\r\r"
if [ $COLD -eq 0 ]; then 
    if [ ! -z $gHEATINDEX ]; then 
        if [ $gHEATINDEX -gt $gTEMP ] && [ $gHEATINDEX -gt $gFEELSLIKE ]; then
            echo -e "Heat Index:\t\t$gHEATINDEX$gTEMP_SUFFIX\r\r"
        fi
    fi
else
    if [ ! -z $gWIND_CHILL ]; then
        if [ $gWIND_CHILL -lt $gTEMP ] && [ $gWIND_CHILL -lt $gFEELSLIKE ]; then
            echo -e "Wind Chill:\t\t$gWINDCHILL$gTEMP_SUFFIX\r\r"
        fi
    fi
fi
echo -e "Humidity:\t\t$HUMIDITY%\r"
echo -e "Pressure:\t\t$gPRESSURE $gPRESSURE_SUFFIX\r"
echo -e "UV:\t\t\t\t$UV <small>( $UVSTR )</small>\r\r"
echo -e "Clouds:\t\t\t$CLOUD%\r"
echo -e "Wind:\t\t\t$gWIND $gWIND_SUFFIX from the $WIND_DIR\r"
echo -e "Gusting:\t\t$gGUST $gWIND_SUFFIX\r\r"
echo -e "Precipitation:\t${gFTOTALPRECIP[0]} $gPRECIP_SUFFIX expected <small>( ${FDAILY_CHANCE_OF_RAIN[0]}% probability )</small>\r"
if [ $COLD -eq 1 ]; then
    echo -e "Snow:\t\t\t${FTOTALSNOW_CM[0]} cm\r\r"
fi
echo -e "Sunrise/set:\t\t${gFASTRO_SUNRISE[0]} / ${gFASTRO_SUNSET[0]}\r"
echo -e "Moonphase:\t\t$(echo -e \\U$SYMBOL) ${FASTRO_MOONPHASE[0]} <small>( ${FASTRO_MOON_ILLUMINATION[0]}% illuminated )</small>\r\r"
echo -e "Today:\t\t\t${FCONDITION_TEXT[0]}, high: ${gFMAXTEMP[0]} low: ${gFMINTEMP[0]}\r"
echo -e "Tomorrow:\t\t${FCONDITION_TEXT[1]}, high: ${gFMAXTEMP[1]}, low: ${gFMINTEMP[1]}\r"
echo -e "Next Day:\t\t${FCONDITION_TEXT[2]}, high: ${gFMAXTEMP[2]}, low: ${gFMINTEMP[2]}\r\r"
echo -e "<small><i>Last updated: $LAST_UPDATED</i></small></tool>"

exit 0
