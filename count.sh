#!/bin/bash
LOCAL_DIR=$1
ENUM=$(($(cat $LOCAL_DIR/count)+1))
echo $ENUM > $LOCAL_DIR/count
