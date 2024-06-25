#!/bin/bash

GPU_USAGE=$(nvidia-settings -q gpuutilization | grep Attribute | awk '{print substr($0, 65, 2)}' | sed 's/[^0-9]*//g')

printf "%3s" "$GPU_USAGE%"
