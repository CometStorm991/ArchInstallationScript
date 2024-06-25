#!/bin/bash

kLFilePath=$HOME/State/KeyboardLayout.txt

if ! [[ -e $kLFilePath ]]
then
    touch "$kLFilePath"
    KeyboardLayout.sh "US"
fi

cat "$kLFilePath"
