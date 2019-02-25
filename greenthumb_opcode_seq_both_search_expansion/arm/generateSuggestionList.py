import sys
import re
import argparse
import operator

def main():
 
  parser = argparse.ArgumentParser()
  parser.add_argument("suggesFile", help="file containing the sequence tokens", type=str)
  parser.add_argument("lineNum", help="line in the program get the seq", type=int)
  args = parser.parse_args()

  suggFile = open(args.suggesFile)
  lineNum = args.lineNum-1
  #print "Line Num ", lineNum
  seqId = False
  for line in suggFile.readlines():
    words = line.split()
    #print words[0]
    if len(words)>0:
      if words[0] == "Token:":
        seqId = words[1]
        #print "SeqId:", seqId
        if(seqId == str(lineNum)):
          startRec = True
          #print "Match"
          #print "Start Rec"
        else:
          #print "Stop Rec"
          startRec = False
      else:
        if startRec == True:
          print words[0]

if __name__ == "__main__":
  main()
