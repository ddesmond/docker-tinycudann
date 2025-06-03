#!/bin/bash
echo "_____ Startup _____"
if [ -e /setup/.setup-init ]; then
  echo "copy files to data"
  mkdir /data/dist && chmod -R 777 /data/dist
  cp -f /opt/dist /data/dist
else
  rm -rf /setup/.setup-init
fi
sleep infinity