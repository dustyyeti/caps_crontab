#!/bin/bash

SP="/home/caps/scripts/caps_cronscan"

## Color codes for UI
#. Reset
NC='\033[0m'       # Text Reset

#. Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
LtBlue='\033[1;34m'
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

#. Bold Colors
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

#... random..
IYellow='\033[0;93m'
On_IYellow='\033[47m' 
BPurple='\033[1;35m'
UBlack='\033[4;30m'

On_IBlack='\033[0;100m'

Inv='\e[7m'

BIWhite='\033[1;95m'
BIPurple='\033[1;95m'

Italic='\033[3m'

### DECLARE ARRAYS

declare -a args
declare -a blurbs
declare -a subs
declare -a keys
declare -a cols
declare -a types
declare -a subblurbs

args+=("EXP")
args+=("SCANNERS")
args+=("INT")
args+=("RES")
args+=("REF")
args+=("XFER")
args+=("DELAY")
args+=("LIGHTS")
# args+=("scanner_ID1")
# args+=("UNK2")
# args+=("UNK3")
# args+=("UNK4")

# types+=("STRING")	#EXP
# types+=("INT")		#SCANNERS
# types+=("INT") 		#INT
# types+=("INT")		#RES
# types+=("INT")		#REF
# types+=("TOGGLE")	#XFER
# types+=("INT")		#DELAY
# types+=("TOGGLE")	#LIGHTS

blurbs+=("Experiment Name")
blurbs+=("Scanner Count")
blurbs+=("Scan Interval Time")
blurbs+=("Scan resolution")
blurbs+=("* REF scan every frame")
blurbs+=("* server file transfer")
blurbs+=("series scan delay")
blurbs+=("* use lights")
# blurbs+=("scanner1 ID")
# blurbs+=("something lights")
# blurbs+=("something lights")
# blurbs+=("something lights")

subs+=("_exp")
subs+=("_exp")
subs+=("_exp")
subs+=("_exp")
subs+=("_exp")
subs+=("_exp")
subs+=("_exp")
subs+=("_exp")
# subs+=("_dish")
# subs+=("_lights")
# subs+=("_lights")
# subs+=("_lights")

subblurbs+=("${Inv}_____Experiment Parameters_____${NC} [${Red} WARNING${NC} | ${LtBlue}LAST EXP${NC} | ${Green}new value${NC} ]")
subblurbs+=("${On_IBlack}___________Dish Setup__________${NC}")
subblurbs+=("${BCyan}${Inv}____Neopixel Light Program_____${NC}")

keys=(e s i r z x d l k)

lKeys=${#keys[@]} #: establish length of keys array

declare -i sStart=8 #: scanner id arg starts at index 7

###. flow booleans
stay_TF=true

insert(){
    h='
################## insert ########################
# Usage:
#   insert arr_name index element
#
#   Parameters:
#       arr_name    : Name of the array variable
#       index       : Index to insert at
#       element     : Element to insert
##################################################
    '
    [[ $1 = -h ]] && { echo "$h" >/dev/stderr; return 1; }
    declare -n __arr__=$1   # reference to the array variable
    i=$2                    # index to insert at
    el="$3"                 # element to insert
    # handle errors
    [[ ! "$i" =~ ^[0-9]+$ ]] && { echo "E: insert: index must be a valid integer" >/dev/stderr; return 1; }
    (( $1 < 0 )) && { echo "E: insert: index can not be negative" >/dev/stderr; return 1; }
    # Now insert $el at $i
    __arr__=("${__arr__[@]:0:$i}" "$el" "${__arr__[@]:$i}")


}

spacer (){ #: helps with UI building
	echo
	echo -e ${subblurbs[$isub]}
	printf '.%.0s' {1..31} #....................
	echo
}

eatkeys (){ #: digest user key inputs
		if [[ $1 = $key ]]
		then
			echo
			if [[ ${blurbs[$i]:0:1} = "*" ]] #: if first character is *
			then				
				if [[ ${!args[$i]} = "on" ]]
				then
					eval ${args[$i]}="off"
				else
					eval ${args[$i]}="on"
				fi
			else
				printf "%32s" "New ${blurbs[$i]} > "
				read ${args[$i]}
				echo ${cols[0]}
			fi
			cols[$i]=$Green
		fi
}

### use loop to setup initial colors
for ((i=0;i<$lKeys;i++))
do
	cols+=($LtBlue)
	#declare ${keys[$i]}Col=$LtBlue
done
cols[0]=$Red #: set exp name to warning color

### DISK OPS
#. load last experiment
source ./exp/last.exp #: in one commad, loads all variables
EXP=$(echo $EXP|tr -d '\n') #? what do these lines do??
$INT=$(echo $INT|tr -d '\n')


### insert args based on startup settings
for ((i=0;i<SCANNERS;i++))
do
	y=$sStart
	# echo $i
	# insert args 8 'scanner_ID1'
	 # (( num += x ))
	insert args $y scanner_ID$i
done

echo "${args[@]}"

read
clear
main (){
### main looop --------------------------------------------
	while [ "$stay_TF" = "true" ] 
	do
		clear
		echo -e "${BPurple}"
		printf " CREATE NEW CRONTAB EXPERIMENT "
		echo
		isub=0
		for ((i=0;i<lKeys;i++))
		do
			#: if this is a new subsection, then echo section heading from array
			if [[ $buf != ${subs[$i]} ]] 
			then
				buf=${subs[$i]} #: store the subsection in buf
				if ! [[ $buf = "_lights" && $LIGHTS = "off" ]]
				then
					spacer isub
					((isub++))
				else
					break
				fi
			fi
			printf "%29s" "${blurbs[$i]} ["
			echo -e ${Cyan}${keys[$i]}${NC}"] "${cols[$i]}${!args[$i]}${NC}
		done
		echo
		printf '_%.0s' {1..31}
		echo
		printf "%27s" "set new parameters with ["
		echo -e ${Cyan}${Italic}"key"${NC}"]" 
		printf "%25s" "start program ["
		echo -e ${Cyan}${Italic}"enter"${NC}"]" 

		##! possible light routine
		# if [[ $LIGHTS == "on" ]]
		# then
		# 	printf "%25s" "to program lights ["
		# 	echo -e ${Cyan}${Italic}"enter"${NC}"]" 
		# else
		# 	printf "%25s" "start program ["
		# 	echo -e ${Cyan}${Italic}"enter"${NC}"]" 
		# fi

		echo ""
		printf "%32s" "choice > "
		
	###: USER INPUT
		read -n 1 key
		[[ $key = "" ]] && stay_TF="false" #- enter key

		#: experiment parms list
		for ((i=0;i<lKeys;i++))
		do
			eatkeys ${keys[$i]} #: send the key to check for hotkey
		done
	# sleep 1 #@ this is for debug
	done #: END WHILE stay_TF LOOP

	EROOT=${SP}/exp/
	EP=$EROOT${EXP}
	if [ ! -d "$EP" ]; then
	    mkdir -p $EP
	fi

	### write out $EXP.exp and last.exp record files
	echo "
	writing $EXP.exp:"
	echo "#exp parameters" 2>&1 | tee $EROOT/last.exp
	for arg in "${args[@]}"
	do
	   echo "${arg}=${!arg}" >> $EROOT/last.exp
	done

	cp $EROOT/last.exp $EP/$EXP.exp

	echo 
	echo "working with Directory $EP"

	echo -n "# programatic crontab file generated for CAPS scanner control

	# " > $EP/xtab
	printf '.%.0s' {1..29} >> $EP/xtab
	echo >> $EP/xtab
	for ((i=0;i<lKeys;i++))
	do
		echo -n "#" >> $EP/xtab
		printf "%31s" "${blurbs[$i]}: " >> $EP/xtab
		echo ${!args[$i]} >> $EP/xtab
	done

	echo "
	sp=$SP" >> $EP/xtab
	echo "ep=$EP" >> $EP/xtab

	printf "
	*/$INT * * * * " >> $EP/xtab

	[[ $REF > 0 ]] && \

	printf "\$sp/scan.sh $REF \$ep $DELAY 2>&1 | tee -a \$ep/LOG; " >> $EP/xtab
	[[ $LIGHTS == "on" ]] && \
	printf "\$sp/lights.sh off 2>&1 | tee -a \$ep/LOG; " >> $EP/xtab
	printf "\$sp/scan.sh $RES \$ep $DELAY 2>&1 | tee -a \$ep/LOG; " >> $EP/xtab
	[[ $LIGHTS == "on" ]] && \
	printf "\$sp/lights.sh on 2>&1 | tee -a \$ep/LOG; " >> $EP/xtab
	[[ $XFER == "on" ]] && \
	printf "\$sp/transfer.sh \$ep 2>&1 | tee -a \$ep/LOG; " >> $EP/xtab
	echo >> $EP/xtab ###- blank line needed before EOF
	echo
	echo "xtab exported"
	echo
	echo "install crontab..."
	echo

	crontab $EP/xtab
}

main "$@"