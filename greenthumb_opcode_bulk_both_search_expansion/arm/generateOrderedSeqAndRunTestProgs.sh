#!/bin/bash

TP="tp"
TOPK="_top_"
TOP="top"

for i in `seq 17 17`;
do
  for j in `seq 1 1`;
  do
    echo "Running - " $TP$i$j >> runLog
    #generating prioritizing sequence
    python2 generateInstructionOpcodeVectorFromPredictionsCoarse.py opcodeListFile ../../FNN_setup/resFile$i
    cp ../../FNN_setup/resFile$i"_encoded" dum
    cp ../../FNN_setup/resFile$i resFile
    #generating pruning sequence
    #python2 generateTopNSugesstions4Pruning.py opcodeListFile ../../FNN_setup/resFile$i OrigOpPool --topK $1
    #cp ../../FNN_setup/resFile$i"_encoded_"$TOP$1 pruneDum
    racket optimize.rkt --enum -p -c 1 -t 200 ../../greenthumb_fwd_only/arm/testSuite1/$TP$i".s"
    cp dum priorOrderSeq$TP$i$j
    cp pruneDum pruneOrderSeq$TP$i$j
    cp -r output output_$TP$i$j$TOPK$1
  done
done
