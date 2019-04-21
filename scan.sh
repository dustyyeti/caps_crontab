#!/bin/bash

export SANE_USB_WORKAROUND=1

RESOLUTION=$1
LOCAL_DIR=$2
DELAY=$3

ENUM=$(($(cat $LOCAL_DIR/count)+1))

# Create experiment direcotry if it doesn't already exist
if [ ! -d "$LOCAL_DIR" ]; then
    mkdir -p $LOCAL_DIR
fi

EXPERIMENT_BASENAME=${LOCAL_DIR##*/}
SCAN_FILENAME=$EXPERIMENT_BASENAME_R$RESOLUTION
SCANNER_LIST=$(scanimage -f "%d%n")

date
echo "Scanners:"
echo "$SCANNER_LIST"
echo "Experiment \"$EXPERIMENT_BASENAME\" will be stored in $LOCAL_DIR"
echo "----------------------------------------------------------------"
for scanner in $SCANNER_LIST; do
    scanner_safename=${scanner//:/_}
    FILENAME=$SCAN_FILENAME_$scanner_safename.R$RESOLUTION.$ENUM.tiff

    echo "Scanning on $scanner"
    echo "Saving as $FILENAME"

    scanimage -d $scanner --mode Color --format tiff --resolution $RESOLUTION > $LOCAL_DIR/$FILENAME
    echo "deay for $DELAY seconds"
    sleep $DELAY
done



# echo $ENUM > $LOCAL_DIR/count
