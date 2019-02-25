import sys
import re
import argparse
import operator

def main():
 
  parser = argparse.ArgumentParser()
  parser.add_argument("fileProg", help="file name of the program", type=str)
  args = parser.parse_args()

  fname = args.fileProg
  outFile = open(fname, "w")

  outFile.write("3 -1 5")
  outFile.write("\n")
  outFile.write("3 -1 6")

if __name__ == "__main__":
  main()
