#!/bin/bash

SP="/home/caps/scripts/caps_cronscan"
dish_cnt=6

### DECLARE VARIABLES
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
##. Arrays
declare -a args
declare -a blurbs
declare -a subs
declare -a keys
declare -a cols
declare -a subblurbs
declare -a func
declare -a opts
declare -a subvals #: the value to store in the associated EXP ARG, if different than user input
declare -a trueopts

keys=(e s i r z x y l a f o)

opts+=("*")
opts+=("i/1..9")
opts+=("I/minutes")
opts+=("C/100/300/600")
opts+=("T/on/off")
opts+=("on/off")
opts+=("seconds")
opts+=("on/off")
opts+=("*")
opts+=("*")
opts+=("*")

subvals+=("")
subvals+=("")
subvals+=("")
subvals+=("")
subvals+=("")
subvals+=("")
subvals+=("")
subvals+=("")
subvals+=("")
subvals+=("")
subvals+=("")

trueopts+=("")
trueopts+=("")
trueopts+=("")
trueopts+=("")
trueopts+=("")
trueopts+=("")
trueopts+=("")
trueopts+=("")
trueopts+=("")
trueopts+=("")
trueopts+=("")

args+=("EXP")
args+=("SCANNERS")
args+=("INT")
args+=("RES")
args+=("REF")
args+=("XFER")
args+=("DELAY")
args+=("LIGHTS")
args+=("SPECIES")
args+=("FOODS")
args+=("OTHER")

blurbs+=("Exp Name")
blurbs+=("Scanner Count")
blurbs+=("Scan Interval Time")
blurbs+=("Scan resolution")
blurbs+=("* REF scan every frame")
blurbs+=("* server file transfer")
blurbs+=("series scan delay")
blurbs+=("* use lights")
blurbs+=("test animals")
blurbs+=("food sources")
blurbs+=("note other setup")

subs+=("_exp")
subs+=("_exp")
subs+=("_exp")
subs+=("_exp")
subs+=("_exp")
subs+=("_exp")
subs+=("_exp")
subs+=("_exp")
subs+=("_exp")
subs+=("_exp")
subs+=("_exp")

# types+=("str")	#EXP
# types+=("int")		#SCANNERS
# types+=("int") 		#INT
# types+=("choice")		#RES
# types+=("tog")		#REF
# types+=("tog")	#XFER
# types+=("int")		#DELAY
# types+=("tog")	#LIGHTS
# types+=("str")
# types+=("str")
# types+=("str")

# func+=("")
# func+=("update")
# func+=("")
# func+=("")
# func+=("")
# func+=("")
# func+=("")
# func+=("")


subblurbs+=("${Inv}_____Experiment Parameters_____${NC} [${Red} WARNING${NC} | ${LtBlue}LAST EXP${NC} | ${Green}new value${NC} ]")
subblurbs+=("${On_IBlack}___________Dish Setup__________${NC}")
subblurbs+=("${BCyan}${Inv}____Neopixel Light Program_____${NC}")

##. flow booleans
stay_TF=true



insert(){
    local i
    [[ $1 = -h ]] && { echo "$h" >/dev/stderr; return 1; }
    declare -n __arr__=$1   # reference to the array variable
    i=$2                    # index to insert at
    el="$3"                 # element to insert
    # handle errors
    [[ ! "$i" =~ ^[0-9]+$ ]] && { echo "E: insert: index must be a valid integer" >/dev/stderr; return 1; }

    #? the following line throws errors sporatically, when ingesting special characters in the 0th index
    # (( "$1" < 0 )) && { echo "E: insert: index can not be negative" >/dev/stderr; return 1; }
    # Now insert $el at $i
    __arr__=("${__arr__[@]:0:$i}" "$el" "${__arr__[@]:$i}")
}

spacer (){ #: helps with UI building
	echo
	echo -e ${subblurbs[$isub]}
	printf '.%.0s' {1..31} #....................
	echo
}
eatinput (){
	# echo eatinput function
	# echo trueopts ${trueopts[$i]}
	local -a thisopt
	thisopt=(${trueopts[$i]//// }) #: store options into array, incl type marker
	specopt=(${trueopts[$i]//// })
	local op=${opts[$i]:0:1} #: the type marker
	local limit=1
	local -a uinput
	local secret=1
	local subz=0
	local q uvalue k
	# echo thisopt 2 ${thisopt[3]}
	# echo 
	# echo i= $i
	# echo "options for this argument thisopt = ( ${thisopt[@]} )"
	# echo op $op
	case $op in
		"C")
			IFS="/"
			subz=1
			set -- "${subvals[$i]}" 
			local -a svals=($*)
			unset IFS
			;;
		"*")
			limit=30 #: arbitray high limit for string entry
			secret=0
			;;
		*)
			;;
	esac
	# read -s -n 1 k
	# return

	# local do_TF=1
		# echo limit $limit
		# echo len ${#uinput[@]}

	while [ ${#uinput[@]} -lt $limit ]
	do
		# IFS="" #set this so that blank space strings can be entered in args
		# echo while limit loop
		if [[ $secret -eq 1 ]] #: single key trigger with readout substitution
		then
			# echo secret loop, read single key
			# echo k: $k
			read -s -n 1 k #{!args[$i]} #k #now check for valid key 
			# echo k now: $k

			##: VALID KEY SECTION ----------------------
			for q in "${!thisopt[@]}"
			do
				# echo args: $k #{args[$i]}
				if [[ ${thisopt[$q]} = *$k* ]] #: if key occurs in the valid set
				then
					# echo $uvalue
					uvalue=${svals[$q]} #: user; index matching key stroke
					# boob="hit"
					# echo oh ${boob: -1}
					# echo $uvalue
					# echo $uvalue
					# echo ${uvalue: -1}
					if [[ ${uvalue: -1} = ^ ]] #: add the key pressed to the final ARG string
					then
						uvalue=${uvalue::-1}$k
					fi
					# echo ${specopt[$q]}
					# # echo ${thisopt[$q]}
					# echo $k
					echo $uvalue
					limit=-1
				else
					#reject input, don't leave
					# echo not this one
					a=a
				fi
			done
		else #: not a single key trigger
			read ${args[$i]}
			limit=-1
		fi #: end of secret

		##: loop through single key inputs, add to cumulative array
		#! temp disable,

		# if [[ ${opt[*]} =~ $k ]]
		# then
		# 	uinput+=(k)
		# else
		# 	return
		# 	a=a
		# fi
	done #: character input limit hit, or enter key
	#!! need enter key exit still
	#!! readkey must be -n 1 for this to work
	if [[ $subz -eq 1 ]] #- temporary
	then
		# unset IFS
		# IFS=""
		# echo -------------------
		# echo $uvalue #{svals[$uvalue]}
		eval "${args[$i]}"="$uvalue" #: set the EXP variables
	fi
	# echo "limit reached" #- TRACER

}
eatkeys (){ #: digest user key inputs
	# echo eatkeys function
	if [[ $key = "x" ]]
	then
		exit
	fi
	if [[ $key = "" ]] #enter
	then
		echo no change
		sleep 1
		return
	fi
	myvar=abc
	size=$((${#opts[$i]}+2))
	# size=(( "${#opts[$i]}-2)) 
	printf "%$((32-$size))s" "${blurbs[$i]} [" #[${opts[$i]:2}] > "
	echo -e "${Cyan}${Italic}${opts[$i]:2}${NC}] > \c"

		# if [[ $1 = "d" ]]
		# then
		# 	dish_TF="true"
		# 	read -s -n 1 ${args[$i]}
		# 	newkey=${!args[$i]}
		# 	eatkeys $newkey
		# else
		# 	read ${args[$i]}
		# fi
	eatinput

	# local op=${opt[0]}
	# case $op in
	# 	"C")
	# 		echo choice!

	# 		;;
	# 	*)
	# 		;;
	# esac
	# if [[ ${opt:0:1} = "C" ]] #: limited options for input to choose from
	# then
	# 	# local limits=(${opt//// })
	# 	# echo b ${limits[@]}
	# 	echo ${opt[@]}

	# fi

	# IN="bla@some.com;john@home.com"
	# arrIN=(${IN//;/ })
	# if [[ dish_TF = "true NOT" ]] 
	# then
	# 	case $1 in
 # 			"")
	# 			echo no change
	# 			;;
	#     	" ")
	# 			echo no change
	# 			;;
	#     	=)
	# 			# ${args[$i]}="POS CTRL" && echo ${args[$i]}
	# 			echo pos control #| read args[$i]
	# 			;;
	#     	-)
	# 			echo neg control
	# 			;;
	# 		1|2|3|4|5|6|7|8|9)
	# 			echo exp grp $newkey
	# 			;;
	# 	     *)
	# 	        echo nada
	#           	;;
	# 	esac
	# 	dish_TF="false"
	# 	return
	# fi

	#: routine for toggles
	# if [[ ${blurbs[$i]:0:1} = "*" ]] #: if first character is *
	# if [[ ${opts[$i]} = "[off/on]" ]] 
	# if [[ ${types[$i]} = "tog" ]] 
	# then				
	# 	if [[ ${!args[$i]} = "on" ]]
	# 	then
	# 		eval ${args[$i]}="off"
	# 	else
	# 		eval ${args[$i]}="on"
	# 	fi
	#/ end toggles
	# else
	# 	printf "%32s" "${blurbs[$i]} [${opts[$i]}] > "
	# 	if [[ $1 = "d" ]]
	# 	then
	# 		dish_TF="true"
	# 		read -s -n 1 ${args[$i]}
	# 		newkey=${!args[$i]}
	# 		eatkeys $newkey
	# 	else
	# 		read ${args[$i]}
	# 	fi
	# fi
	cols[$i]=$Green
	update #: run update to check for changes to the arrays (eg scanner count change)
}

init_colors (){
### use loop to setup initial colors
	for ((i=0;i<lKeys;i++))
	do
		cols+=($LtBlue)
	done
	cols[0]=$Red
}

load_parms (){
### DISK OPS
	#. load last experiment
	source ./exp/last.exp #: in one commad, loads all variables
	EXP=$(echo $EXP|tr -d '\n') #? what do these lines do??
	INT=$(echo $INT|tr -d '\n')
	remember_scanners=0
}

update (){
	if [[ remember_scanners -ne SCANNERS ]] #: number of scanners has changed
	#: delete all args related to old scanner count
	then
		local i j ins ini inj
		local ins=11 #: insert point in arrays (index padding)
		local xindex=$((remember_scanners*dish_cnt+remember_scanners))
		#: hunt down dish entries and remove them
		for ((i=((lKeys-1));i>0;i--)) #((i=0;i<lKeys;i++))
		do
			if [[ ${subs[$i]} = "_dish" ]]
			then
				unset args[$i]
				unset blurbs[$i]
				unset keys[$i]
				unset subs[$i]	
				unset opts[$i]
				unset types[$i]
			fi
		done
		remember_scanners=$SCANNERS #: reset scanner count memory
		### insert args based on startup settings
		for ((i=1;i<$(( SCANNERS+1 ));i++))
		do
			ini=$((ins+((i-1))*2+((i-1))*dish_cnt))
			insert args $(( ini )) SCANNER${i}_ID
			insert blurbs $(( ini )) "Scanner${i} ID"
			insert keys $(( ini )) k
			insert subs $(( ini )) "_dish"
			insert opts $(( ini )) "*"
			insert cols $(( ini )) "$LtBlue"
			insert trueopts $(( ini )) ""
			insert subvals $(( ini )) ""

			((ini++))
			insert args $(( ini )) TEMPLATE${i}_ID
			insert blurbs $(( ini )) "Template${i} ID"
			insert keys $(( ini )) t
			insert subs $(( ini )) "_dish"
			insert opts $(( ini )) "*"
			insert cols $(( ini )) "$LtBlue"
			insert trueopts $(( ini )) ""
			insert subvals $(( ini )) ""
			for ((j=1;j<$(( dish_cnt+1 ));j++))
			do
				#! FORMAT for MATH: a=$(( 4 + 5 ))
				inj=$((ini+j))
				insert args $(( inj )) "DISH${i}_${j}"
				insert keys $(( inj )) d
				insert blurbs $(( inj )) "S${i} Dish${j}"
				insert subs $(( inj )) "_dish"
				insert opts $(( inj )) "C/-/=/1..9"
				insert cols $(( inj )) "$LtBlue"
				insert subvals $(( inj )) "C/neg-control/pos-control/exp-group^"
				insert trueopts $(( inj )) "C/-/=/123456789"

			done
		done
	fi
}

cronit (){
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

main (){
### main looop --------------------------------------------
while [ "$stay_TF" = "true" ] 
	lKeys=${#keys[@]} #: establish length of keys array
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
		printf '_%.0s' {1..31}
		echo -e "\n"
		printf "%25s" "set new parameters with ["
		echo -e ${Cyan}${Italic}"key"${NC}"]" 
		printf "%23s" "start program ["
		echo -e ${Cyan}${Italic}"enter"${NC}"]" 
		echo
		printf "%32s" "choice > "
		
##. USER INPUT
		read -n 1 key
		echo
		if [[ $key = "" ]] #: enter key runs cronit function, then exits
		then
			cronit
			exit
		fi
		for ((i=0;i<lKeys;i++)) #: find all instances of the hotkey
		do
			if [[ ${keys[$i]} = $key ]]
			then
				eatkeys #: send the index of the key from allowable options to process
			fi
		done
	# sleep 1 #@ this is for debug
	done #: END WHILE stay_TF LOOP
} #......................................... end main

lKeys=${#keys[@]} #: establish length of keys array

init_colors
load_parms
update
main "$@"

####!!!  nice tricks ----------------------------------------------------------------
# for key in "${!a[@]}"     # expand the array indexes to a list of words
# do 
#   map[${a[$key]}]="$key"  # exchange the value ${a[$key]} with the index $key
# done
#-- except it doesn't work!!!!