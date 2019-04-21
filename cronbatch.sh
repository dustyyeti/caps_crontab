#!/bin/bash

# a. crontab -l > $tmpfile
#b. edit $tmpfile
#c. crontab $tmpfile
#d. rm $tmpfile //optional


SP="/home/caps/scripts/caps_cronscan/"
EXPNAME=$1
RES=$2
REF=$3

EP=$SP$EXPNAME

# Create experiment direcotry if it doesn't already exist
if [ ! -d "$EP" ]; then
    mkdir -p $EP
fi

crontab -l > $EP/crontab.old

echo "#programatic crontab file generated for CAPS scanner control
#
#" > $EP/xtab

echo "
*/5 * * * * $SP/scan.sh $ref $EP 2>&1 | tee -a $EP/LOG; \
$SP/lights.sh off 2>&1 | tee -a $EP/LOG; \
$SP/scan.sh $res $EP 2>&1 | tee -a $EP/LOG; \
$SP/lights.sh on 2>&1 | tee -a $EP/LOG; \
$SP/transfer.sh $EP 2>&1 | tee -a $EP/LOG; \
$SP/count.sh $EP 2>&1 | tee -a $EP/LOG
" >> $EP/xtab

crontab $EP/xtab
