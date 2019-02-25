#!/bin/bash

OUTPUT="output_tp"

for i in `seq 1 $1`;
do
  echo "Program"$i
  python2 countNumofInstructionsFromLogFile_onlySeach.py $OUTPUT$i"1"/0/driver-0.log
done
