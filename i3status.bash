#!/bin/bash

i3status | (read line && echo $line && read line && echo $line && while :
do
  read line

  avail=$(awk '/MemFree/ {print $2}' /proc/meminfo)
  total=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
  buffers=$(awk '/Buffers/ {print $2}' /proc/meminfo)
  cached=$(awk '/Cached/ {print $2}' /proc/meminfo)
  cached=$(echo $cached | cut -d' ' -f 1)
  swaptotal=$(awk '/SwapTotal/ {print $2}' /proc/meminfo) 
  swapfree=$(awk '/SwapFree/ {print $2}' /proc/meminfo)

  governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor | cut -c1)

  cpu=$(awk '/cpu MHz/ {print $4; exit}' /proc/cpuinfo)
  cpu=$(echo $cpu | cut -d '.' -f 1)

  used=$(echo "$total - $avail" | bc)
  used=$(echo "$used - $cached" | bc)
  used=$(echo "$used - $buffers" | bc)
  
  avail=$(echo "scale=2; $avail / 1024 / 1024" | bc)
  avail="$avail GiB"

  total=$(echo "scale=2; $total / 1024 / 1024" | bc)
  total="$total GB"

  used=$(echo "scale=2; $used / 1024 / 1024" | bc)
  used="$used GB"

  swapused=$(echo "$swaptotal - $swapfree" | bc)
  swapused=$(echo "scale=2; $swapused / 1024 / 1024" | bc)
  #swaptotal=$(echo "scale=2; $swaptotal / 1024 / 1024" | bc)

  #mem="[{ \"full_text\": \"RAM: $used/$total SW: $swapused/$swaptotal\" },"

  
  mem="[{ \"full_text\": \"$cpu MHz($governor) RAM:$used/$total($swapused)\" },"
  
 

  echo "${line/[/$mem}" || exit 1
done)