#!/bin/bash

### Color codes for UI
# Reset
NC='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
LtBlue='\033[1;34m'
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

### disc ops
# load last experiment
source ./exp/last.exp
EXP=$(echo $EXP|tr -d '\n')
$INT=$(echo $INT|tr -d '\n')

SP="/home/caps/scripts/caps_cronscan"

### declare vars

declare -a KEYS
declare -a BLURBS
declare -a COLS
declare -a ARGS

ARGS+=("EXP")
ARGS+=("INT")
ARGS+=("RES")
ARGS+=("REF")
ARGS+=("LIGHTS")
ARGS+=("XFER")
ARGS+=("DELAY")

BLURBS+=("Experiment Name")
BLURBS+=("Scan Interval Time")
BLURBS+=("scan resolution")
BLURBS+=("reference res (0 none)")
BLURBS+=("use lights?")
BLURBS+=("server file transfer?")
BLURBS+=("series scan delay")

KEYS=(e i s r l x d)
lKeys=${#KEYS[@]} #(( lKeys-- ))

# flow booleans
STAY_TF=true
MATCH_TF=false

for ((i=0;i<$lKeys;i++))
do
	COLS+=($LtBlue)
	#declare ${KEYS[$i]}Col=$LtBlue
done
COLS[0]=$Red


#- main looop
while [ "$STAY_TF" = "true" ] 
do
	clear
	echo -e "\n
=================================
  Create new crontab experiment
================================="
	echo -e " ${Red}WARNING${NC} | ${LtBlue}LAST EXP${NC} | ${Green}new value${NC} "
	echo -e "\n"

	for ((i=0;i<lKeys;i++)) #$lKeys;i++))
	do
		printf "%31s" "${BLURBS[$i]} [${KEYS[$i]}] "
		# ${KEYS[$i]}Col
		echo -e ${COLS[$i]}${!ARGS[$i]}${NC}

		# echo -e ${!KEYS[$i]Col}$EXP${NC}
	done
	echo -e "\n\n"
	read -p "[enter] to except or [key] for new values > " -n 1 key
	[[ $key = "" ]] && STAY_TF="false" #- enter key
	for ((i=0;i<lKeys;i++))
	do	
		if [[ ${KEYS[$i]} = $key ]]; then
			echo
			read -p "New ${BLURBS[$i]} > " ${ARGS[$i]}
			echo ${COLS[0]}
			COLS[$i]=$Green
		fi
	done
done

EP=${SP}/exp/${EXP}
if [ ! -d "$EP" ]; then
    mkdir -p $EP
fi

echo 
echo "working with Directory $EP"

echo "# programatic crontab file generated for CAPS scanner control
#
#" > $EP/xtab

printf "
*/$INT * * * * " >> $EP/xtab

[[ $REF > 0 ]] && \
printf "$SP/scan.sh $REF $EP $DELAY 2>&1 | tee -a $EP/LOG; " >> $EP/xtab
[[ $LIGHTS == "YES" || $LIGHTS == "yes" ]] && \
printf "$SP/lights.sh off 2>&1 | tee -a $EP/LOG; " >> $EP/xtab
printf "$SP/scan.sh $RES $EP $DELAY 2>&1 | tee -a $EP/LOG; " >> $EP/xtab
[[ $LIGHTS == "YES" || $LIGHTS == "yes" ]] && \
printf "$SP/lights.sh on 2>&1 | tee -a $EP/LOG; " >> $EP/xtab
[[ $XFER == "YES" || $LIGHTS == "yes" ]] && \
printf "$SP/transfer.sh $EP 2>&1 | tee -a $EP/LOG; " >> $EP/xtab
printf "$SP/count.sh $EP 2>&1 | tee -a $EP/LOG" >> $EP/xtab
echo
echo "xtab exported"
echo
echo "crontab installed"
crontab $EP/xtab
