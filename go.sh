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

declare -a ARGS
declare -a BLURBS
declare -a SUB
declare -a KEYS
declare -a COLS
declare -a TYPE
declare -a SUBBLURBS

ARGS+=("EXP")
ARGS+=("SCANNERS")
ARGS+=("INT")
ARGS+=("RES")
ARGS+=("REF")
ARGS+=("XFER")
ARGS+=("DELAY")
ARGS+=("LIGHTS")
# ARGS+=("scanner_ID1")
# ARGS+=("UNK2")
# ARGS+=("UNK3")
# ARGS+=("UNK4")

# TYPE+=("STRING")	#EXP
# TYPE+=("INT")		#SCANNERS
# TYPE+=("INT") 		#INT
# TYPE+=("INT")		#RES
# TYPE+=("INT")		#REF
# TYPE+=("TOGGLE")	#XFER
# TYPE+=("INT")		#DELAY
# TYPE+=("TOGGLE")	#LIGHTS

BLURBS+=("Experiment Name")
BLURBS+=("Scanner Count")
BLURBS+=("Scan Interval Time")
BLURBS+=("Scan resolution")
BLURBS+=("* REF scan every frame")
BLURBS+=("* server file transfer")
BLURBS+=("series scan delay")
BLURBS+=("* use lights")
# BLURBS+=("scanner1 ID")
# BLURBS+=("something lights")
# BLURBS+=("something lights")
# BLURBS+=("something lights")

SUB+=("_exp")
SUB+=("_exp")
SUB+=("_exp")
SUB+=("_exp")
SUB+=("_exp")
SUB+=("_exp")
SUB+=("_exp")
SUB+=("_exp")
# SUB+=("_dish")
# SUB+=("_lights")
# SUB+=("_lights")
# SUB+=("_lights")

SUBBLURBS+=("${Inv}_____Experiment Parameters_____${NC} [${Red} WARNING${NC} | ${LtBlue}LAST EXP${NC} | ${Green}new value${NC} ]")
SUBBLURBS+=("${On_IBlack}___________Dish Setup__________${NC}")
SUBBLURBS+=("${BCyan}${Inv}____Neopixel Light Program_____${NC}")

KEYS=(e s i r z x d l k)

lKeys=${#KEYS[@]} #: establish length of KEYS array

declare -i sStart=8 #: scanner id arg starts at index 7

###. flow booleans
STAY_TF=true
MATCH_TF=false

Insert(){
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

Spacer (){ #: helps with UI building
	echo
	echo -e ${SUBBLURBS[$isub]}
	printf '.%.0s' {1..31} #....................
	echo
}

EatKeys (){ #: digest user key inputs
		if [[ $1 = $key ]]
		then
			echo
			if [[ ${BLURBS[$i]:0:1} = "*" ]] #: if first character is *
			then				
				if [[ ${!ARGS[$i]} = "on" ]]
				then
					eval ${ARGS[$i]}="off"
				else
					eval ${ARGS[$i]}="on"
				fi
			else
				printf "%32s" "New ${BLURBS[$i]} > "
				read ${ARGS[$i]}
				echo ${COLS[0]}
			fi
			COLS[$i]=$Green
		fi
}

### use loop to setup initial colors
for ((i=0;i<$lKeys;i++))
do
	COLS+=($LtBlue)
	#declare ${KEYS[$i]}Col=$LtBlue
done
COLS[0]=$Red #: set exp name to warning color

### DISK OPS
#. load last experiment
source ./exp/last.exp #: in one commad, loads all variables
EXP=$(echo $EXP|tr -d '\n') #? what do these lines do??
$INT=$(echo $INT|tr -d '\n')


### Insert ARGS based on startup settings
for ((i=0;i<SCANNERS;i++))
do
	y=$sStart
	# echo $i
	# Insert ARGS 8 'scanner_ID1'
	 # (( num += x ))
	Insert ARGS $y scanner_ID$i
done

echo "${ARGS[@]}"

read
clear
main (){
### main looop --------------------------------------------
	while [ "$STAY_TF" = "true" ] 
	do
		clear
		echo -e "${BPurple}"
		printf " CREATE NEW CRONTAB EXPERIMENT "
		echo
		# boo=$(printf "%29s" "${BLURBS[$i]} [")

		# echo "$boo"
		isub=0
		for ((i=0;i<lKeys;i++))
		do
			# echo sub $sub
			# echo "SUB[i]" $SUB[$i]
			if [[ $sub != ${SUB[$i]} ]]
			then
				sub=${SUB[$i]}
				if ! [[ $sub = "_lights" && $LIGHTS = "off" ]]
				then
					Spacer isub
					((isub++))
				else
					break
				fi
			fi
			printf "%29s" "${BLURBS[$i]} ["
			echo -e ${Cyan}${KEYS[$i]}${NC}"] "${COLS[$i]}${!ARGS[$i]}${NC}
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
		[[ $key = "" ]] && STAY_TF="false" #- enter key

		#: experiment parms list
		for ((i=0;i<lKeys;i++))
		do
			EatKeys ${KEYS[$i]} #: send the key to check for hotkey
		done
	# sleep 1 #@ this is for debug
	done #: END WHILE STAY_TF LOOP

	EROOT=${SP}/exp/
	EP=$EROOT${EXP}
	if [ ! -d "$EP" ]; then
	    mkdir -p $EP
	fi

	### write out $EXP.exp and last.exp record files
	echo "
	writing $EXP.exp:"
	echo "#exp parameters" 2>&1 | tee $EROOT/last.exp
	for arg in "${ARGS[@]}"
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
		printf "%31s" "${BLURBS[$i]}: " >> $EP/xtab
		echo ${!ARGS[$i]} >> $EP/xtab
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