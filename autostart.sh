#!/bin/bash

#each usb connection will spam multiple lines (3-5 depending on usb mode) - the first few can fail with adb not ready
#only one has to work (usually the 2nd one), and then subsequent lines are ignored to prevent duplicate scrcpy windows

udevadm monitor --environment | grep --line-buffered '^ID_SERIAL.*Android' | while read line ;do
  echo "received $line"
  
  sleep 0.5
  if [ -z "$pid" ] || [ ! -f "/proc/$pid/status" ];then
    "$(dirname "$0")/main.sh" &
    pid=$!
  else
    echo ignoring line
  fi
  
done
