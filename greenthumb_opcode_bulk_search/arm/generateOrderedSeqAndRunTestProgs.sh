#!/bin/bash

TP="tp"

for i in `seq 16 17`;
do
  for j in `seq 1 1`;
  do
    echo "Running - " $TP$i$j
    python2 generateInstructionOpcodeVectorFromPredictionsCoarse.py opcodeListFile ../../FNN_setup/resFile$i
    cp ../../FNN_setup/resFile$i"_encoded" dum
    racket optimize.rkt --enum -p -c 1 -t 400 ../../greenthumb_fwd_only/arm/testSuite1/$TP$i".s"
    cp dum orderSeq$TP$i$j
    cp -r output output_$TP$i$j
  done
done
