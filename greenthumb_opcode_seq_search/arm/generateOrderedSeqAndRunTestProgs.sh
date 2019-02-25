#!/bin/bash

TP="tp"
SUGG_PATH="/workspace/ssingh/experimentalSetup/pytorch-seq2seq/"
RESFILE="resFile"
DUM="dum"
TOKENFILE="tokenFile"


for i in `seq 16 17`; #programId
do
  for j in `seq 1 1`; #number of times to run
  do
    numLine=$(wc -l < ../../greenthumb_fwd_only/arm/testSuite1/$TP$i".s")
    echo $numLine
    for k in `seq 1 $numLine`;
    do
      python2 generateSuggestionList.py $SUGG_PATH$RESFILE$i $k > $TOKENFILE$k
      python2 generateInstructionOpcodeVectorFromPredictionsCoarse.py opcodeListFile $TOKENFILE$k
      cp $TOKENFILE$k"_encoded" $DUM$k
    done
    echo "Running - " $TP$i$j
    racket optimize.rkt --enum -p -c 1 -t 200 ../../greenthumb_fwd_only/arm/testSuite1/$TP$i".s"
    for l in `seq 1 $numLine`;
    do
      cp $DUM$l orderSeq$TP"_"$i"_"$j"_"$l
    done
    cp -r output output_$TP"_"$i"_"$j
  done
done
