#! /usr/bin/env python
from sys import argv


outfile=argv[-1]

ntrees=0
nsites=0

count=1
outstrings=[]
for a_file in argv[1:-1]:
    with open(a_file,'r') as fin:
       lines = fin.readlines()
       t,s=[int(x) for x in lines[0].split()]
       ntrees = ntrees+t
       nsites = s
       for line in lines[1:]:
           words = line.split()
           outstrings.append("tre"+str(count)+" ")
           for w in words[1:]:
               outstrings.append(w+" ")
           outstrings.append("\n")
           count = count+1

with open(outfile,'w') as fout:
    fout.write(str(ntrees) + " " + str(nsites) + "\n")
    for w in outstrings:
        fout.write(w)
           
                              
