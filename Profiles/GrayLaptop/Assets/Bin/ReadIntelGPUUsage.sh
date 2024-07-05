#!/bin/bash

gpu=$(sudo intel_gpu_frequency --get)

gpu_cur=$(echo "$gpu" | grep cur | awk '{ print $2 }')
gpu_max=$(echo "$gpu" | grep max | awk '{ print $2 }')

gpu_percent=$(echo "$gpu_cur/$gpu_max*100" | bc -l | cut -d "." -f 1)

printf "%3s" "$gpu_percent%"
