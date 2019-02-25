import sys
import re
import argparse
import operator

def main():

  parser = argparse.ArgumentParser()
  parser.add_argument("logFile", help="logFile of the program", type=str)
  args = parser.parse_args()

  lFile = open(args.logFile)
  instCnt = 0
  strtCnt = False
  for line in lFile.readlines():
    line = line.replace('\n','')
    words = line.split()
    if len(words) > 1:
      if words[0] == "SIZE":
        strtCnt = True
      elif words[0] == "GROW-FW:":
        strtCnt = False
      elif words[0] == "Icount":
        if strtCnt == True:
          instCnt = instCnt + 1
      elif words[1] == "FOUND!!!":
        print instCnt
        lFile.close()
        break
  lFile.close()

if __name__ == "__main__":
  main()
