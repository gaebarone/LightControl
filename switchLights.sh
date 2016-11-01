#!/bin/bash

source /Users/gaetano/.bashrc
source /Users/gaetano/.profile
export PUSHBULLET_KEY="o.e5JULHCnvqxodwzTCO2jlgR8poKii4MM"

location=""
status=""
ran=-1
brightNess=""
level=""

getbrightness(){
    if [ -a $1 ] ; then 
	brightNess=`/usr/local/bin/convert $1 -colorspace Gray -format "%[mean]" info:`
	brightNess="${brightNess%%.*}"
    else 
	echo "could not lad brightness from $1"
	brightNess=1000
    fi
}

setstatus(){
    mdate=`date`

    echo "$1 $3 $4" > /Users/gaetano/programs/LightControl/status
    if [[ "$1" == *"on"* ]] ; then 
	echo "Lights are on  $mdate with brightness $4 an command $3" | /usr/local/bin/pb push 
    elif [[ "$1" == *"off"* ]] ; then 
	echo "Lights are off $mdate" | /usr/local/bin/pb push 
    fi

    echo "myMilight.sh $2" > /Users/gaetano/programs/LightControl/current_command.sh
    echo "myMilight.sh $2" >> /Users/gaetano/programs/LightControl/current_command.sh
    echo "myMilight.sh $2" >> /Users/gaetano/programs/LightControl/current_command.sh
    echo "myMilight.sh $2" >> /Users/gaetano/programs/LightControl/current_command.sh
    chmod +x /Users/gaetano/programs/LightControl/current_command.sh
}

function getlocation(){
    location=2
    s=$(tail -1 /Users/gaetano/Dropbox/House/LightControl/location.txt)
    
    if [[ "$s" == *"entered"* ]] ; then 
	location=1
    elif [[ "$s" == *"exited"* ]] ; then 
	location=0
#	if [[ -a /Users/gaetano/Dropbox/House/motion.txt ]] ; then 
#	    rm /Users/gaetano/Dropbox/House/motion.txt
#	fi
    fi
}

getstatus(){
    s=`cat /Users/gaetano/programs/LightControl/status | tail -1 | awk '{print $1}'`
    if [[ "$s" == "off" ]] ; then
	status=1
    elif [[ "$s" == "on" ]] ; then 
	status=0
    fi
    ran=`cat /Users/gaetano/programs/LightControl/status | tail -1 | awk '{print $2}'`
    level=`cat /Users/gaetano/programs/LightControl/status | tail -1 | awk '{print $3}'`
}
echo "############################"
echo "      Light control" 
echo "############################"

date
now=`date +%k%M`

#Get the sunset time of today
sunset=`solunar -c Zurich | grep "Sunset"`
b=`echo ${sunset/"                        Sunset:"/""} | sed -e 's/^[[:space:]]*//'`
b=${b/:/""}

Isunset=`solunar -c Zurich | grep "Sunset" | awk '{print $2}'`
dateSunSet=`date | awk  '{print $1" "$2" "$3" Isunset:00 "$5" "$6}' | sed "s/Isunset/${Isunset}/g"`
sunMidUnix=`date -j -f "%a %b %d %T %Z %Y" "$dateSunSet" "+%s"`


seconds_now=`(date +%s)`
seconds_midnight=`(date -j -f'%Y-%m-%d %H:%M:%S' "$(date +%Y-%m-%d) 00:00:00" +%s)`
minutes_now=$(((seconds_now - seconds_midnight) / 60))
sunMid=$(((sunMidUnix - seconds_midnight) / 60))

echo "Minutes now from midnight $minutes_now" 
echo "Sunset from midnight $sunMid" 

getlocation
getstatus

echo "Sunset time will be:$b"
echo "And my location is $location"
echo "Status $status"
echo "Last command $ran"
TsunSet=$((minutes_now - sunMid ))
TsunSet=${TsunSet#0}
TsunSet=${TsunSet#0}
now=${now#0}
now=${now#0}

echo "Time to subset $TsunSet"
echo "And now is $now"

GetPicture=$((now%10))                                                                                                                                                                                                                                 
getbrightness /Users/gaetano/programs/LightControl/luminosity.jpg
echo "Current Brightness is $brightNess"
stdBR=3200
nDFs=-30
echo "Min Brightness to switch lights on $stdBR"
 
#if [[ $location == 0 ]] ; then 
#    echo "Location is away Locking screen "
#    open -a /Users/gaetano/Desktop/StartScreenSaver.app
#fi 


if [[ $location == 1 ]] ; then 
    echo "Executing commands for in location"

    if [[ ( $status == 0 && $ran == 12) ||  $status == 1 && ( $TsunSet -gt -10 || $TsunSet -lt -800 ) && $ran == 11 ]] ; then
	echo "I just got back and it is dark"
        myMilight.sh -g all -c on
        setstatus on "myMilight.sh -g all -c on" 0 0
	status=0
	ran=0
    fi
    
    if [[ $status == 0 && $ran != 1 ]] ; then 
	if [[ $now -gt 300 && $now -lt 310  ]] ; then  
	    echo "Time is between 3 and 6 in the morning swithcing lights off" 
	    say "Switching lights off"
	    myMilight.sh -g all -c off 
	    myMilight.sh -g all -c off
	    setstatus off "-g all -c off" 1 0
	fi
    fi
    
    if [[ $status == 1 && $ran != 2 ]] ; then 
	if [[ $now -gt 700 && $now -lt 710 ]] ; then 
	echo "Time is between 6h30 and 7h30 in the morning swithcing lights on"
	say "Switching lights on"
	myMilight.sh -g all -c on
	myMilight.sh -g all -c on
	myMilight.sh -g all -c white -b 5
	myMilight.sh -g all -c white -b 5
	setstatus on "-g all -c white -b 5" 2 5
	fi
    fi 
    
    if [[ $now -gt 720 && $now -lt 735 && $ran != 3 ]] ; then
	echo "Time is between 6h30 and 7h30 in the morning swithcing lights on"
	myMilight.sh -g all -c white -b 10
	myMilight.sh -g all -c white -b 10
	setstatus on "-g all -c white -b 10" 3 10
    fi
    
    
#    if [[ $status == 0  && $now -gt 800 && $TsunSet -lt -60 && $ran != 4 ]] ; then 
    if [[ $now -gt 800 && $TsunSet -lt $nDFs ]] ; then
	if [[ $brightNess -lt $stdBR ]] ; then 
#	 first turn the lights on 
	    if [[ $status == 1 ]] ; then myMilight.sh -g all -c on  ; setstatus on "-g all -c on" -1 0 ; fi 
	    getstatus
#	no increase the brightness of the lamps 
	    level=$((level+1))
	    if [[ $level -lt 26 ]] ; then 
		myMilight.sh -g all -c white -b $level 
		setstatus on "-g all -c white -b $level" 3 $level
		imagesnap /Users/gaetano/programs/LightControl/luminosity.jpg
		getbrightness /Users/gaetano/programs/LightControl/luminosity.jpg
	    fi
	    echo "Increasing lightness to $level"
	elif [[ $status == 0 ]] ; then 
	    say "Switching lights off"
            myMilight.sh -g all -c off
            myMilight.sh -g all -c off
            setstatus off "-g all -c off" 4 0
	fi
    fi

    cond=$b 
    cond=$((cond - 30))

#    if [[  ($TsunSet -gt -60 || $TsunSet -lt -876) && $ran -gt 4 && $ran -lt 11 ]] ; then 
#	myMilight.sh -g all -c white -b 20
#        myMilight.sh -g all -c white -b20
#	setstatus on "-g all -c white -b 20" 0 20
#    fi

    if [[ $TsunSet -gt $nDFs && $TsunSet -lt 30 && $ran != 5  ]] ; then 
	myMilight.sh -g all -c on
	myMilight.sh -g all -c on
	myMilight.sh -g all -c on
	myMilight.sh -g all -c on -b 5
	myMilight.sh -g all -c on -b 5
	sleep 2
	myMilight.sh -g all -c on -b 5
	myMilight.sh -g all -c on -b 5
	say "Switching lights on"
	setstatus on "myMilight.sh -g all -c on -b 5" 5 5
    fi
    
    if [[ $TsunSet  -gt 30 && $TsunSet  -lt 60  && $ran != 6 ]] ; then
	
	echo "Time is between 7 and 7h30 in the evening swithcing lights on"
	say "Brightness up"
	myMilight.sh -g all -c white -b 10
	myMilight.sh -g all -c white -b 10
	sleep 2
	myMilight.sh -g all -c white -b 10
	myMilight.sh -g all -c white -b 10
	setstatus on "-g all -c on -b 10" 6 10
    fi

    if [[  $TsunSet -gt 60 &&  $TsunSet -lt 270 && $ran != 7 ]] ; then
	echo "Time is between 7h30 and 7h40 in the evening swithcing lights on"
	say "brightneess full "
	myMilight.sh -g all -c white -b 25
	myMilight.sh -g all -c white -b 25
	sleep 2
	myMilight.sh -g all -c white -b 25
	myMilight.sh -g all -c white -b 25
	setstatus on "-g all -c white -b 25" 7 25
    fi

    if [[ $TsunSet -gt 270 && $TsunSet -lt 300 && $ran != 8 ]] ; then
	echo "Time is between 7h30 and 7h40 in the evening swithcing lights on"
	say "Dimming lights"
	myMilight.sh -g all -c white -b 10
	myMilight.sh -g all -c white -b 10
	sleep 2
	myMilight.sh -g all -c white -b 10
	myMilight.sh -g all -c white -b 10
	setstatus on "-g all -c white -b 10" 8 10
    fi

    if [[ ( $TsunSet  -gt 300 && $now -lt 340 || $TsunSet -lt -876 ) && $ran != 10 ]] ; then  
	echo "Time is between 7h30 and 7h40 in the evening swithcing lights on"
	say "Dimming lights"
	myMilight.sh -g all -c white -b 5
	myMilight.sh -g all -c white -b 5
	sleep 2
	myMilight.sh -g all -c white -b 5
	myMilight.sh -g all -c white -b 5
	setstatus on "-g all -c white -b 5" 10 5
    fi
fi

icond=$((b - 30))
icond=${icond#0}



###########################
# Cases when I leave home 
###########################

if [[ $location == 0 ]]  ; then
    echo "I am way "
######################
# Per hour of the day 
#######################
   
    if [[ ( $TsunSet -gt 15 || $TsunSet -lt -720 ) && $ran != 11 ]] ; then
	echo "and it is night, hence switching off the lights" 
	myMilight.sh -g all -c off 
	sleep 2 
	myMilight.sh -g all -c off
	myMilight.sh -g all -c off
	myMilight.sh -g 3 -c white -b 5
	setstatus on "-g 3 -c white -b 5" 11 5
	#echo "Location is away Locking screen "
##	open -a /Users/gaetano/Desktop/StartScreenSaver.app
	if [[ -a /Users/gaetano/Dropbox/House/motion.txt ]] ; then
            rm /Users/gaetano/Dropbox/House/motion.txt
	fi
	
    elif [[ $TsunSet -lt 0 && $TsunSet -gt -720 && $status == 0 && $ran != 12 ]] ; then
	myMilight.sh -g all -c off
	myMilight.sh -g all -c off
	sleep 2
	myMilight.sh -g all -c off
	myMilight.sh -g all -c off
	setstatus off "-g all -c off" 12 0
	echo "Location is away Locking screen "
#	open -a /Users/gaetano/Desktop/StartScreenSaver.app
	if [[ -a /Users/gaetano/Dropbox/House/motion.txt ]] ; then
            rm /Users/gaetano/Dropbox/House/motion.txt
        fi


    fi
fi 


#echo  "Testing"
#if dtest time --gt '19:00:00' && dtest time --lt '22:30:00'; then
#    echo "Time is between 7 and 7h30 in the morning swithcing lights off"
#    say "Switching lights on"
#    myMilight.sh -g all -c white 25
#fi


echo "############################"
echo ""