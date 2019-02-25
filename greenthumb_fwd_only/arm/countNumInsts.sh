#!/bin/bash

# number of programs
# number of iterations
OUTPUT="output2_tp"

for i in `seq 1 $1`;
do
  echo "Program"$i
  for j in `seq 1 $2`;
  do
    python2 countNumofInstructionsFromLogFile_onlysearch.py $OUTPUT$i"_"$j/0/driver-0.log
    python2 countNumofInstructionsFromLogFile.py $OUTPUT$i"_"$j/0/driver-0.log
  done
done
