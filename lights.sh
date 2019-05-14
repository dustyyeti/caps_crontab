#!/bin/bash

OPTION=$1

DEVICE="/dev/ttyACM0"

OFF="#000000"

# red green and blue

R="#FF0000"
G="#00FF00"
B="#0000FF"

LED[0]="$B"
LED[1]="$B"
LED[2]="$B"
LED[3]="$B"
LED[4]="$B"


if [ "$OPTION" == "on" ]; then
	for i in ${!LED[@]}; do
		echo "<+$i*${LED[$i]}>" > $DEVICE
	done
else
	for i in ${!LED[@]}; do
		echo "<+$i*$OFF>" > $DEVICE
	done

fi
