#!/bin/bash

bnFilePath="/sys/class/backlight/intel_backlight/brightness"
brightness=$(cat $bnFilePath)

minBrightness=0
maxBrightness=96000

setBrightness() {
    newBrightness=$1

    if [[ $newBrightness -gt $maxBrightness ]]
    then
        newBrightness=$maxBrightness
        echo "Requested brightness is greater than ${maxBrightness}. Setting brightness to ${maxBrightness}."
    fi
    
    if [[ $newBrightness -lt $minBrightness ]]
    then
        newBrightness=$minBrightness
        echo "Requested brightness is less than ${minBrightness}. Setting brightness to ${minBrightness}."
    fi

    echo $newBrightness > $bnFilePath
}

changeBrightness() {
    newBrightness=$(($1 + $brightness))
    
    if [[ $newBrightness -gt $maxBrightness ]]
    then
        newBrightness=$maxBrightness
        echo "Requested brightness is greater than ${maxBrightness}. Setting brightness to ${maxBrightness}."
    fi
    
    if [[ $newBrightness -lt $minBrightness ]]
    then
        newBrightness=$minBrightness
        echo "Requested brightness is less than ${minBrightness}. Setting brightness to ${minBrightness}."
    fi

    echo $newBrightness > $bnFilePath
}

while getopts ":s:c:" option
do
    case $option in
        s) 
            setBrightness $OPTARG 
            exit;;
        c)
            changeBrightness $OPTARG
            exit;;
        \?) 
            echo "Invalid option $OPTARG"
    esac
done
