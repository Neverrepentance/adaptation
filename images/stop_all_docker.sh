#!/bin/bash


pattern=*
if [ -n "$1" ]; then
  pattern=$1
fi

for name in $(docker ps |grep bash |awk '{print $NF}')
do
  if [[ "$name" == $pattern ]]; then
    docker stop $name
  fi 
done
