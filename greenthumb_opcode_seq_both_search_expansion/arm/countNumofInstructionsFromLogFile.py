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
  for line in lFile.readlines():
    line = line.replace('\n','')
    words = line.split()
    if len(words) > 1:
      if words[0] == "Icount":
        instCnt = words[2]
      if words[1] == "FOUND!!!":
        print instCnt
        lFile.close()
        break

if __name__ == "__main__":
  main()
