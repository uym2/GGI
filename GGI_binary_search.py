#! /usr/bin/env python

from random import random
from subprocess import check_output,call
from os.path import isfile
from sys import argv


def GGI_binary_search(seq_file,ML_tree,ML_sitelh,sptree,lower=0,upper=100,inc=1,alpha=0.05):
    myList=range(lower,upper+inc,inc)
    myTrees=[None]*len(myList)

    def call_GGI(cons_level):
        cons_tree = sptree + "_cons" + str(cons_level)
        if not isfile(cons_tree):
            call(["collapse_low_support.sh",sptree,cons_tree,str(cons_level)])
        p,t=check_output(["GGI_tree.sh", seq_file, ML_tree, ML_sitelh,cons_tree]).split()
        p=float(p)
        #print("Constraint level: " + str(cons_level))
        #print("P-value: " + str( p))
        #print("Constrained tree: " + t)
        return [p,t]

    def binary_search(l=0,r=None):
        if r is None:
            r = len(myList)-1
        med = int((r+l)/2)
        p,t = call_GGI(myList[med])
        myTrees[med] = t

        if p >= alpha:
            if med == l:
                return med
            return binary_search(l,med-1)
        else:
            if med == r:
                return r+1
            return binary_search(med+1,r) 

    idx = binary_search()

    return [myList[idx],myTrees[idx]] if idx<len(myList) else [None,ML_tree]


seq_file=argv[1]
ML_tree=argv[2]
ML_sitelh=argv[3]
sptree=argv[4]

print(GGI_binary_search(seq_file,ML_tree,ML_sitelh,sptree,lower=50,inc=1)[1])
