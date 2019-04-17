#/bin/bash

LOCAL_DIR=$1
EXPERIMENT_BASENAME=${LOCAL_DIR##*/}

if [ ! -d "/run/user/1001/gvfs/smb-share:server=mnemosyne,share=experiments/$EXPERIMENT_BASENAME" ]; then
    mkdir -p /run/user/1001/gvfs/smb-share:server=mnemosyne,share=data/CAPS/$( hostname )/scannerData/$EXPERIMENT_BASENAME
fi

for f in $LOCAL_DIR/*.tiff; do
    cp "$f" /run/user/1001/gvfs/smb-share:server=mnemosyne,share=data/CAPS/$(hostname)/scannerData/$EXPERIMENT_BASENAME/
	
    if [ -f "/run/user/1001/gvfs/smb-share:server=mnemosyne,share=data/CAPS/$(hostname)/scannerData/$EXPERIMENT_BASENAME/${f##*/}" ] ; then
      rm $f
      echo "File was copied successfully, removing local copy!"
    else
      echo "Mnemosyne not reached, local file not removed!"
    fi
done
