#!/bin/bash

#==	This is the script for controlling NEOPIXEL lights via Arduino controller
#  	See Arduino repository for Arduino programming


#..	input parms:
#.	$1 >  on/off  { lower case req }

OPTION=$1

#. hard coded

DEVICE="/dev/ttyACM0" #- Arudino Leonardo signature;
OFF="#000000"

#. red green and blue

R="#FF0000"
G="#00FF00"
B="#0000FF"

#. fixed program

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
=======
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
