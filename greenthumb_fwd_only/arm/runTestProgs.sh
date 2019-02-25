#!/bin/bash
#copying files from the green thumb directories
OUTPUT_FILE="AllCMD.txt"
if [ -f "$OUTPUT_FILE" ]; then rm -f $OUTPUT_FILE; fi
touch $OUTPUT_FILE

declare -a progLoc=("tp16"
                    "tp17")
: '
                    "tp1"
                    "tp2"
                    "tp3"
                    "tp4"
                    "tp5"
                    "tp6"
                    "tp7"
                    "tp8"
                    "tp9"
                    "tp10"
                    "tp11"
                    "tp12"
                    "tp13"
                    "tp14"
                    "tp15") '

for prog in "${progLoc[@]}"
do
  for i in `seq 1 5`;
  do 
    echo $prog$i
    bash runTillFound2.sh $prog $i
    #echo "bash runTillFound2.sh $prog $i" >> $OUTPUT_FILE
  done    
done

#cat $OUTPUT_FILE | parallel -j 21
#rm $OUTPUT_FILE
