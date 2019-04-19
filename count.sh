#!/bin/bash

ENUM=$(($(cat $LOCAL_DIR/count)+1))
echo $ENUM > $LOCAL_DIR/count
