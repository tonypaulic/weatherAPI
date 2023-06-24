#!/bin/bash
# requires: xfce4-genmon-plugin wget jq imagemagick 
# call: /path/to/script SITENAME LATITUDE LONGITUDE APIKEY
#
# $1 = SITENAME
# $2 = LATITUDE
# $3 = LONGITUDE
# $4 = API Key (https://www.weatherapi.com/signup.aspx)

# test to see if the correct number of paramaters was passed
if [ "$#" -ne 4 ]; then 
	echo "Usage: $0 SITENAME LATITUDE LONGITUDE APIKEY"
	exit 1
fi

# configurable items
UNIT=metric             # metric or imperial
WEATHER_LINK="https://www.weatherapi.com/weather/q/oshawa-ontario-canada-316180?loc=316180"
IMAGE_SIZE=22           #22, 48, or 128

# script globals 
SITENAME="$1"
LATITUDE="$2"
LONGITUDE="$3"
API_KEY="$4"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
IMAGES_DIR="$SCRIPT_DIR/images/$IMAGE_SIZE"
H1="X-RapidAPI-Key: $API_KEY"
H2="X-RapidAPI-Host: weatherapi-com.p.rapidapi.com"
OD="https://weatherapi-com.p.rapidapi.com/forecast.json?q=$LATITUDE%2C$LONGITUDE&days=3"

# call the weather API
CACHE=$(wget    --quiet \
                --method GET \
                --header "$H1" \
                --header "$H2" \
                --output-document \
                - "$OD") 

#parse the results
NAME=$(echo $CACHE | jq ".location.name" | tr -d \")
#REGION=$(echo $CACHE | jq ".location.region" | tr -d \")
#COUNTRY=$(echo $CACHE | jq ".location.country" | tr -d \")
#LAT=$(echo $CACHE | jq ".location.lat" | tr -d \")
#LON=$(echo $CACHE | jq ".location.lon" | tr -d \")
#TIMEZONE=$(echo $CACHE | jq ".location.tz_id" | tr -d \")
#LOCALTIME_EPOCH=$(echo $CACHE | jq ".location.localtime_epoch" | tr -d \")
#LOCALTIME=$(echo $CACHE | jq ".location.localtime" | tr -d \")

#LAST_UPDATED_EPOCH=$(echo $CACHE | jq ".current.last_updated_epoch" | tr -d \")
LAST_UPDATED=$(echo $CACHE | jq ".current.last_updated" | tr -d \")
TEMP_C=$(echo $CACHE | jq ".current.temp_c" | tr -d \")
TEMP_F=$(echo $CACHE | jq ".current.temp_f" | tr -d \")
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
FEELSLIKE_C=$(echo $CACHE | jq ".current.feelslike_c" | tr -d \")
FEELSLIKE_F=$(echo $CACHE | jq ".current.feelslike_f" | tr -d \")
#VIS_KM=$(echo $CACHE | jq ".current.vis_km" | tr -d \")
#VIS_MILES=$(echo $CACHE | jq ".current.vis_miles" | tr -d \")
UV=$(echo $CACHE | jq ".current.uv" | tr -d \")
GUST_MPH=$(echo $CACHE | jq ".current.gust_mph" | tr -d \")
GUST_KPH=$(echo $CACHE | jq ".current.gust_kph" | tr -d \")

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

# parse uvindex value into text
case $UV in
    [0-2])          UVSTR="Low"         ;;
    [3-5])          UVSTR="Moderate"    ;;
    [6-7])          UVSTR="High"        ;;
    [8-9]|10)       UVSTR="Very high"   ;;
    11|12)          UVSTR="Extreme"     ;;
    *)              UVSTR="Unknown"     ;;
esac

# prepare the icon to use
case $CONDITION_CODE in
    1006|1009)                                      [[ $IS_DAY -eq 1 ]] && ICON=cloud.png                  || ICON=cloud-night.png                 ;;    
    1030|1135|1147)                                 [[ $IS_DAY -eq 1 ]] && ICON=fog.png                    || ICON=fog-night.png                   ;;
    1153|1183)                                      [[ $IS_DAY -eq 1 ]] && ICON=lightrain.png              || ICON=lightrain-night.png             ;;
    1063|1150|1180|1240)                            [[ $IS_DAY -eq 1 ]] && ICON=lightrainsun.png           || ICON=lightrainsun-night.png          ;;
    1087)                                           [[ $IS_DAY -eq 1 ]] && ICON=lightrainthundersun.png    || ICON=lightrainthundersun-night.png   ;;
    1003)                                           [[ $IS_DAY -eq 1 ]] && ICON=partlycloud.png            || ICON=partlycloud-night.png           ;;
    1186|1189|1192|1195|1243|1246)                  [[ $IS_DAY -eq 1 ]] && ICON=rain.png                   || ICON=rain-night.png                  ;;
    1273|289)                                       [[ $IS_DAY -eq 1 ]] && ICON=rainthunder.png            || ICON=rainthunder-night.png           ;;
    1168|1171|1198|1201|1207|1237|1252|1261|1264)   [[ $IS_DAY -eq 1 ]] && ICON=sleet.png                  || ICON=sleet-night.png                 ;;
    1069|1072|1204|1249|1276|1279)                  [[ $IS_DAY -eq 1 ]] && ICON=sleetsun.png               || ICON=sleetsun-night.png              ;;
    1114|1117|1213|1219|1225|1258)                  [[ $IS_DAY -eq 1 ]] && ICON=snow.png                   || ICON=snow-night.png                  ;;
    1066|1210|1216|1222|1255)                       [[ $IS_DAY -eq 1 ]] && ICON=snowsun.png                || ICON=snowsun-night.png               ;;
    1282)                                           [[ $IS_DAY -eq 1 ]] && ICON=snowthunder.png            || ICON=snowthunder-night.png           ;;
    1000)                                           [[ $IS_DAY -eq 1 ]] && ICON=sun.png                    || ICON=sun-night.png                   ;;
    *) ICON=nodata.png
esac
gIMAGE="$IMAGES_DIR/$ICON"

# genmon
echo "<img>$gIMAGE</img><txt> $gTEMP$gTEMP_SUFFIX</txt>"
echo "<click>exo-open $WEATHER_LINK</click><txtclick>exo-open $WEATHER_LINK</txtclick>"
echo "<css>.genmon_imagebutton image {padding-bottom: 3px}</css>"
echo -e "<tool><big>$SITENAME</big>
$gTEMP$gTEMP_SUFFIX <small>and</small> $CONDITION_TEXT

Feels Like:\t\t$gFEELSLIKE$gTEMP_SUFFIX

Humidity:\t\t$HUMIDITY %
Pressure:\t\t$gPRESSURE $gPRESSURE_SUFFIX
UV:\t\t\t$UV ($UVSTR)

Clouds:\t\t$CLOUD %
Wind:\t\t$gWIND $gWIND_SUFFIX <small>from the</small> $WIND_DIR
Gusting:\t\t$gGUST $gWIND_SUFFIX
 
Precipitation:\t${gFTOTALPRECIP[0]} $gPRECIP_SUFFIX <small>expected</small> (${FDAILY_CHANCE_OF_RAIN[0]} % <small>probability</small>)
Snow:\t\t${FTOTALSNOW_CM[0]} cm <small>expected</small> (${FDAILY_CHANCE_OF_SNOW[0]} % <small>probability</small>)

Sunrise/set:\t${gFASTRO_SUNRISE[0]} / ${gFASTRO_SUNSET[0]}
Moonphase:\t${FASTRO_MOONPHASE[0]} (${FASTRO_MOON_ILLUMINATION[0]} %)

Today:\t\t${FCONDITION_TEXT[0]}, high: ${gFMAXTEMP[0]} low: ${gFMINTEMP[0]}
Tomorrow:\t\t${FCONDITION_TEXT[1]}, high: ${gFMAXTEMP[1]}, low: ${gFMINTEMP[1]}
Next Day:\t\t${FCONDITION_TEXT[2]}, high: ${gFMAXTEMP[2]}, low: ${gFMINTEMP[2]}

<small><i>Last updated: $LAST_UPDATED</i></small></tool>"

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