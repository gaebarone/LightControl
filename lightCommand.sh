#!/bin/bash

setstatus(){
    echo "$1" > /Users/gaetano/programs/LightControl/status
}


source /Users/gaetano/.profile
echo "Light control" 
date

now=`date +%k%M`

#Get the sunset time of today
sunset=`solunar -c Zurich | grep "Sunset"`
b=`echo ${sunset/"                        Sunset:"/""} | sed -e 's/^[[:space:]]*//'`
b=${b/:/""}

s=`tail -1 /Users/gaetano/Dropbox/House/LightControl/LightCommand.txt`                                                                                               

#s=`tail -1 /Users/gaetano/programs/LightControl/LightCommand.txt`

if [[ $s == *"nothing"* ]] ; then 
    echo "Nothing to do exiting"
    exit 
fi 

cmd=`echo $s | awk '{print $3}'`
zone=`echo $s | awk '{print $2}'`
br=`echo $s | awk '{print $4}'`

echo "setting lights with settings $s"
myMilight.sh -g $zone -c $cmd -b $br
myMilight.sh -g $zone -c $cmd -b $br
myMilight.sh -g $zone -c $cmd -b $br

if [[ $s == *"status"* ]] ; then 
    if [[ $cmd == *"on"* ]] || [[ $cmd == *"off"* ]] ; then 
	setstatus $cmd
    fi
fi 


#echo  "Testing"
#if dtest time --gt '19:00:00' && dtest time --lt '22:30:00'; then
#    echo "Time is between 7 and 7h30 in the morning swithcing lights off"
#    say "Switching lights on"
#    myMilight.sh -g all -c white 25
#fi

