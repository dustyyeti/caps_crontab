#!/bin/bash

##. Color codes for UI
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
BYellow='\033[1;33m' 
UYellow='\033[4;33m'
IYellow='\033[0;93m'
On_IYellow='\033[47m' 
TESTIT='\e[7m'
UBlack='\033[4;30m'

On_IBlack='\033[0;100m'

BACK='\033[40m'
UGreen='\033[4;32m'
FORE='\033[1;92m'
IWhite='\033[0;97m'
Inv='\e[7m'

BIWhite='\033[1;97m'

##. DISK OPS
#. load last experiment
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
	echo -e "\n${BIWhite}
                                  
 CREATE NEW CRONTAB EXPERIMENT   ${NC}"
	echo ""

	echo -e "${Inv}    Experiment Parameters      ${Red} WARNING${NC} | ${LtBlue}LAST EXP${NC} | ${Green}new value${NC} "
	printf '\xE2\x98\xA0%.0s' {1..30}
	# printf '\/%.0s' {1..31}
	echo ""
	# echo -e "\n"
	for ((i=0;i<lKeys;i++)) #$lKeys;i++))
	do
		# echo -e "${On_IBlack}"
		printf "%29s" "${BLURBS[$i]} ["
		echo -e ${Cyan}${KEYS[$i]}${NC}"] "${COLS[$i]}${!ARGS[$i]}${NC}
		# ${KEYS[$i]}Col
		# echo -e ${NC}" "${COLS[$i]}${!ARGS[$i]}${NC}

		# echo -e ${!KEYS[$i]Col}$EXP${NC}
	done
	# echo -e "  ____________________________"
	echo ""
	if [[ $LIGHTS == "yes" ]]
	then
		printf "%29s" "to program lights [enter] "
	else
		printf "%29s" "start program [enter] "
	fi
	echo ""
	printf "%29s" "set new parameters [key] "
	echo ""
	printf "%31s" "[ENTER / key] choice > "
	read -n 1 key
	[[ $key = "" ]] && STAY_TF="false" #- enter key
	for ((i=0;i<lKeys;i++))
	do	
		if [[ ${KEYS[$i]} = $key ]]; then
			echo
			printf "%31s" "New ${BLURBS[$i]} > "
			read ${ARGS[$i]}
			echo ${COLS[0]}
			COLS[$i]=$Green
		fi
	done
done


EROOT=${SP}/exp/
EP=$EROOT${EXP}
if [ ! -d "$EP" ]; then
    mkdir -p $EP
fi

### write out last.exp file

touch $EROOT/test
echo "
writing last.exp:"

echo "EXP=$EXP INT=$INT RES=$RES REF=$REF LIGHTS=$LIGHTS XFER=$XFER DELAY=$DELAY" 2>&1 | tee $EROOT/last.exp

echo 
echo "working with Directory $EP"

echo "# programatic crontab file generated for CAPS scanner control
#
# ==============
# Experiment Job: $EXP
#
" > $EP/xtab

for ((i=0;i<lKeys;i++)) #$lKeys;i++))
do
	printf "%31s" "#" "${BLURBS[$i]}: " >> $EP/xtab
	echo ${!ARGS[$i]} >> $EP/xtab
done

echo "sp=$SP" >> $EP/xtab
echo "ep=$EP" >> $EP/xtab

printf "
*/$INT * * * * " >> $EP/xtab

[[ $REF > 0 ]] && \

printf "\$sp/scan.sh $REF \$ep $DELAY 2>&1 | tee -a \$ep/LOG; " >> $EP/xtab
[[ $LIGHTS == "YES" || $LIGHTS == "yes" ]] && \
printf "\$sp/lights.sh off 2>&1 | tee -a \$ep/LOG; " >> $EP/xtab
printf "\$sp/scan.sh $RES \$ep $DELAY 2>&1 | tee -a \$ep/LOG; " >> $EP/xtab
[[ $LIGHTS == "YES" || $LIGHTS == "yes" ]] && \
printf "\$sp/lights.sh on 2>&1 | tee -a \$ep/LOG; " >> $EP/xtab
[[ $XFER == "YES" || $LIGHTS == "yes" ]] && \
printf "\$sp/transfer.sh \$ep 2>&1 | tee -a \$ep/LOG; " >> $EP/xtab
echo >> $EP/xtab ###- blank line needed before EOF
echo
echo "xtab exported"
echo
echo "install crontab..."
echo

crontab $EP/xtab
