import sys
import re
import argparse
import operator

def decodeLstmEncodings(line):
  regList = ["r0", "r1", "r2", "r3", "r4", "r5", "r6"]
  opCodeList = ["sub", "eor", "and", "add", "orr", "rsb", "asl", "lsl", "asr",
          "lsr", "ror", "mov", "cmp", "bic", "tst", "bfi", "mvn", "movw", "movt"]
  shfOpCodeList = ["lsl", "asr", "lsr", "ror", "asl"]
  baseOp = False
  condOp = False
  shfOp = False
  immSecVal = False
  immVal = False
  line = line.replace('\n','')
  words = line.split('_')
  print words
  if words[0] in opCodeList:
    baseOp = words[0]
  for word in words:
    if word == "c":
      condOp = True
    elif word == "s":
      shfOp = True
    elif word == "i":
      if shfOp == True:
        immSecVal = True
      else:
        immVal = True
  print (baseOp, condOp, shfOp, immVal, immSecVal)
  return (baseOp, condOp, shfOp, immVal, immSecVal)

def main():
 
  parser = argparse.ArgumentParser()
  parser.add_argument("opcodeList", help="file storing the opcodes", type=str)
  parser.add_argument("predFile", help="file containing the coarse predictions", type=str)
  args = parser.parse_args()

  baseList = []
  condList = []
  shfList = []

  opcodeList = open(args.opcodeList+"_base")
  for line in opcodeList.readlines():
    #print line.replace('\n','')
    baseList.append(line.replace('\n', ''))
  opcodeList.close()

  opcodeList = open(args.opcodeList+"_cond")
  for line in opcodeList.readlines():
    #print line.replace('\n','')
    condList.append(line.replace('\n', ''))
  opcodeList.close()

  opcodeList = open(args.opcodeList+"_shf")
  for line in opcodeList.readlines():
    #print line.replace('\n','')
    shfList.append(line.replace('\n', ''))
  opcodeList.close()

  outFile =str(args.predFile)+"_encoded"
  progFile1 = open(outFile, "w")
  progFile = open(args.predFile)
  for line in progFile.readlines():
    (baseOp, condOp, shfOp, immVal, immSecVal) = decodeLstmEncodings(line)
    condOpIndexList = ['-1']
    shfOpIndexList = ['-1']
    baseOpIndex = -1
    if baseOp != False:
      if immVal == True and baseOp != "bfi":
        baseOp = baseOp+"#"
      baseOpIndex = baseList.index(baseOp)
      #look at conditional opcodes
      if condOp == True:
        condOpIndexList.remove('-1')
        for condOps in condList:
          condOpIndexList.append(condList.index(condOps))
      if shfOp == True:
        shfOpIndexList.remove('-1')
        if immSecVal == True:
          for shfOps in shfList:
            if '#' in shfOps:
              shfOpIndexList.append(shfList.index(shfOps))
        else:
          for shfOps in shfList:
            if '#' not in shfOps:
              shfOpIndexList.append(shfList.index(shfOps))
      print baseOp, baseOpIndex
      for cop in condOpIndexList:
        for sop in shfOpIndexList:
          progFile1.write(str(baseOpIndex)+" "+str(cop)+" "+str(sop))
          progFile1.write("\n") 
  progFile.close()
  progFile1.close()
            
if __name__ == "__main__":
  main()
