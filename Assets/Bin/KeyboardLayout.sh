#!/bin/bash

kLFilePath=$HOME/State/KeyboardLayout.txt

if [[ $1 = US ]]
then
    setxkbmap -model pc105 -layout us -variant ,
    echo US > $kLFilePath
elif [[ $1 = INTL ]]
then
    setxkbmap -model pc105 -layout us -variant intl
    echo INTL > $kLFilePath
else
    echo "Invalid option $1"
    exit 1
fi

