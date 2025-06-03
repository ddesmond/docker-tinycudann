#!/bin/bash
echo "_____ Startup _____"
if [ -e /opt/dist/tinycudann-1.7-py3.10.egg-info ]; then
  echo "copy files to data"
  mkdir /data/dist && chmod -R 777 /data/dist
  ls -la /opt/dist
  cp -rf /opt/dist /data/dist
  ls -la /data/dist
else
  rm -rf /setup/.setup-init
fi
echo "_____ Done _____"