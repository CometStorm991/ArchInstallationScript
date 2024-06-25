#!/bin/bash

GPU_TEMP=$(nvidia-settings -q gpucoretemp -t)

printf "%3s" "$GPU_TEMP°C"
