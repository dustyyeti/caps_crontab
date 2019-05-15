#!/bin/bash

# Webhook so the script can complain to us in real time
export APP_SLACK_WEBHOOK=https://hooks.slack.com/services/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

RESOLUTION=$1
LOCAL_DIR=$2
DELAY=$3

ENUM=$(($(cat $LOCAL_DIR/count)+1))
EXPERIMENT_BASENAME=${LOCAL_DIR##*/}

export SANE_USB_WORKAROUND=1

echo "==Beginning Scan=="
date
echo "Scan ID: $ENUM"
echo "Experiment \"$EXPERIMENT_BASENAME\" will be stored in $LOCAL_DIR"

# Create experiment direcotry if it doesn't already exist
if [ ! -d "$LOCAL_DIR" ]; then
    echo "$LOCAL_DIR not found, creating..."
    mkdir -p $LOCAL_DIR
fi

SCANNER_LIST=$(scanimage -f "%d%n")
SCANNER_COUNT=$(echo "$SCANNER_LIST" | wc -l)

# Have we stored information about scanner count?
if [ ! -f "$LOCAL_DIR/printers" ]; then
    echo "$SCANNER_COUNT" > "$LOCAL_DIR/scanners"
fi

echo "Found $SCANNER_COUNT/$(cat $LOCAL_DIR/scanners) scanners:"
echo "$SCANNER_LIST"

if [ "$SCANNER_COUNT" -lt "$(cat $LOCAL_DIR/scanners)" ]; then
    slack "[WARNING]: Only detected $SCANNER_COUNT/$(cat $LOCAL_DIR/scanners) scanners."
    slack "RIP Acquisition #$ENUM, ~$(date +%s)"
fi

for scanner in $SCANNER_LIST; do
    scanner_safename=${scanner//:/_}
    FILENAME=$scanner_safename.$(date +%s).tiff

    echo "Scanning $scanner to $FILENAME"

    scanimage -d $scanner --mode Color --format tiff --resolution $RESOLUTION > $LOCAL_DIR/$FILENAME
done
echo "Delaying for $DELAY seconds"
sleep $DELAY

echo $ENUM > $LOCAL_DIR/count
