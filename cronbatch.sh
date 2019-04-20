#!/bin/bash

# a. crontab -l > $tmpfile
#b. edit $tmpfile
#c. crontab $tmpfile
#d. rm $tmpfile

crontab -l > xtab

echo "sp=/home/caps/scripts/caps_cronscan/

res=400
ref=100
exp=/home/caps/scripts/caps_cronscan/exp0000

*/5 * * * * $sp/scan.sh $ref $exp 2>&1 | tee -a $exp/LOG; \
$sp/lights.sh off 2>&1 | tee -a $exp/LOG; \
$sp/scan.sh $res $exp 2>&1 | tee -a $exp/LOG; \
$sp/lights.sh on 2>&1 | tee -a $exp/LOG; \
$sp/transfer.sh $exp 2>&1 | tee -a $exp/LOG; \
$sp/count.sh $exp 2>&1 | tee -a $exp/LOG
" >> xtab