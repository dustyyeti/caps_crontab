#!/bin/bash

OPTION=$1

DEVICE="/dev/ttyACM0"

OFF="#000000"

# red green and blue

R="#FF0000"
G="#00FF00"
B="#0000FF"

LED[0]="$OFF"
LED[1]="$R"
LED[2]="$R"
LED[3]="#F0F0FF"
LED[4]="#00FF00"
LED[5]="#00FF00"
LED[6]="#00FF00"
LED[7]="#00FF00"
LED[8]="#00FF00"
LED[9]="#00FF00"
LED[10]="#00FF00"
LED[11]="#00FF00"

if [ "$OPTION" == "on" ]; then
	for i in ${!LED[@]}; do
		echo "<+$i*${LED[$i]}>" > $DEVICE
	done
else
	for i in ${!LED[@]}; do
		echo "<+$i*$OFF>" > $DEVICE
	done

fi
