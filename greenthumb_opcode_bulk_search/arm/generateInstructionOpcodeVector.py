import sys
import re
import argparse
import operator

def generateLstmEncodings(line):
  regList = ["r0", "r1", "r2", "r3", "r4", "r5", "r6"]
  opCodeList = ["sub", "eor", "and", "add", "orr", "rsb", "asl", "lsl", "asr",
          "lsr", "ror", "mov", "cmp", "bic", "tst", "bfi", "mvn", "movw", "movt"]
  shfOpCodeList = ["lsl", "asr", "lsr", "ror", "asl"]

  foundOp = None
  baseOp = None
  shfOp = None
  condOp = None
  foundReg = False
  foundOpcode = False
  immVal = False
  immSecVal = False
  words = line.replace(',','').replace('#','').split()
  #print words[0]
  for word in words:
    for element in opCodeList:
      if word.find(element) != -1:
        foundOpcode = True
        if foundOp == None:
          if words.index(word) < 2:
            foundOp = word
            baseOp = element
            if len(word) != len(element):
              condOp = word.replace(element, '')
        else:
          #print "Must be a second opcode"
          shfOp = element
    if word in regList:
      foundReg = True
    if (foundReg == False) and (foundOpcode == False):
      if word.isalpha() == False:
        if shfOp == None:
          immVal = True
        else:
          immSecVal = True
    foundOpcode = False
    foundReg = False
  return (baseOp, condOp, shfOp, immVal, immSecVal)

def main():
 
  parser = argparse.ArgumentParser()
  parser.add_argument("opcodeList", help="file storing the opcodes", type=str)
  parser.add_argument("programFile", help="file containing the program", type=str)
  args = parser.parse_args()

  baseOp = -1
  condOp = -1
  shfOp = -1 

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

  outFile = args.programFile+"_encoded"
  progFile1 = open(outFile, "w")
  progFile = open(args.programFile)
  for line in progFile.readlines():
    (baseOp, condOp, shfOp, immVal, immSecVal) = generateLstmEncodings(line)
    #print baseOp, condOp, shfOp, immVal, immSecVal
    #if baseOp != None:
    #  baseOpIndex = baseList.index(baseOp)
    if baseOp != None:
      if immVal == True:
        baseOp = baseOp+"#"
      elif shfOp != None:
        if immSecVal == True:
          shfOp = shfOp+"#"
    #print baseOp, condOp, shfOp
    baseOpIndex = -1
    condOpIndex = -1
    shfOpIndex = -1
    if baseOp != None:
      baseOpIndex = baseList.index(baseOp)
    if condOp != None:
      condOpIndex = condList.index(condOp)
    if shfOp != None:
      shfOpIndex = shfList.index(shfOp)
    progFile1.write("("+str(baseOpIndex)+" "+str(condOpIndex)+" "+str(shfOpIndex)+")")
    progFile1.write("\n")
  progFile.close()
  progFile1.close()
            
if __name__ == "__main__":
  main()
