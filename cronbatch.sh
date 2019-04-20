#!/bin/bash

# a. crontab -l > $tmpfile
#b. edit $tmpfile
#c. crontab $tmpfile
#d. rm $tmpfile //optional


SP="/home/caps/scripts/caps_cronscan/"
EXP=$1
RES=$2
REF=$3

EP=$SP$EXP

# Create experiment direcotry if it doesn't already exist
if [ ! -d "$EP" ]; then
    mkdir -p $EP
fi

crontab -l > $EP/crontab.old

echo "#programatic crontab file generated for CAPS scanner control
#
#" > $EP/xtab

echo "
sp=$SP

res=$2
ref=$3
exp=/home/caps/scripts/caps_cronscan/$1

*/5 * * * * $sp/scan.sh $ref $exp 2>&1 | tee -a $exp/LOG; \
$sp/lights.sh off 2>&1 | tee -a $exp/LOG; \
$sp/scan.sh $res $exp 2>&1 | tee -a $exp/LOG; \
$sp/lights.sh on 2>&1 | tee -a $exp/LOG; \
$sp/transfer.sh $exp 2>&1 | tee -a $exp/LOG; \
$sp/count.sh $exp 2>&1 | tee -a $exp/LOG
" >> $EP/xtab

crontab $EP/xtab
