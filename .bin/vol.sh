#!/bin/bash
vol=$(echo "`amixer get Master | sed -n 's/^.*\[\([0-9]\+\)%.*/\1/p'`" | uniq )
sleep 1
notify-send "$vol"