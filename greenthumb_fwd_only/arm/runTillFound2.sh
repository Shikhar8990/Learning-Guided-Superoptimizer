#!/bin/bash
OUTPUT_DIR="output2_"$1"_"$2
TEMP_FILE="tmp2_"$1"_"$2
SUITE="testSuite1/"

# clean all folders and files first
if [ -d "$OUTPUT_DIR" ]; then rm -Rf $OUTPUT_DIR; fi
if [ -f "$TEMP_FILE" ]; then rm -f $TEMP_FILE; fi
mkdir -p $OUTPUT_DIR

# set timeout and print info
LINES="$(wc -l < $SUITE$1".s")"
TIMEOUT=2000

if [ "$LINES" == 2 ]; then
  TIMEOUT=120
elif [ "$LINES" == 3 ]; then
  TIMEOUT=240
elif [ "$LINES" == 4 ]; then
  TIMEOUT=420
elif [ "$LINES" == 5 ]; then
  TIMEOUT=600
elif [ "$LINES" == 6 ]; then
  TIMEOUT=800
elif [ "$LINES" == 7 ]; then
  TIMEOUT=1000
elif [ "$LINES" == 8 ]; then
  TIMEOUT=1400
else
  TIMEOUT=1400
fi

echo $1"_"$2 $LINES $TIMEOUT

# execute optimize script
TTL_TIMEOUT=$(expr $TIMEOUT + 15)
timeout $TTL_TIMEOUT stdbuf -o0 racket optimize.rkt -d $OUTPUT_DIR --enum -p -c 1 -t $TIMEOUT $SUITE$1".s" > $TEMP_FILE

TARGET_FILE=$OUTPUT_DIR/0/best.s
if [ ! -f $TARGET_FILE ]; then
  stdbuf -o0 echo $1 "no solution found" >> synthesislog
else
  cp $TARGET_FILE $1".s.opt"
fi

# clean all folders and files
#if [ -d "$OUTPUT_DIR" ]; then rm -Rf $OUTPUT_DIR; fi
#if [ -f "$TEMP_FILE" ]; then rm -f $TEMP_FILE; fi
