#!/bin/bash

SRC_DIR="/home/jijisa/pengrixai/cloudpc/monitor/output"

for file in $(find $SRC_DIR -name 'dstat.log*');
do
  DIR=$(dirname $file)
  f=$(basename $file)
  if [ ! -d "${DIR/monitor/robot}" ];then
    mkdir -p "${DIR/monitor/robot}"
  fi
  echo "Create a html page for ${f} file."
  ./generate_page.sh $file > ${DIR/monitor/robot}/${f/dstat.log-/}.html
done

exit 0
