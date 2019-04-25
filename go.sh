#!/bin/bash
declare -a KEYS
KEYS=(e i s r l x d)

echo "

=============================
Create new crontab experiment
=============================

"


# echo $EXP

echo "Loading values from last experiment.
"
source ./last.exp
echo "       Experiment Name [e] "$EXP
echo "    scan interval time [i] "$INT
echo "       scan resolution [s] "$RES
echo "reference res (0 none) [r] "$REF
echo "           use lights? [l] "$LIGHTS
echo " server file transfer? [x] "$XFER
echo "     series scan delay [d] "$DELAY
echo ".
.

"
STAY_TF=true
while [ "$STAY_TF" = "true" ] 
do
	read -p "
	[ent] to except or [key] for new values > " -n 1 VAL

	for KEY in "${KEYS[@]}"; do
	    [[ $VAL == $KEY ]] && STAY_TF=false
	done
done
