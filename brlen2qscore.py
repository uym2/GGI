#! /usr/bin/env python

from sys import argv
from dendropy import Tree
from math import log ,exp

treefile = argv[1]
outfile = argv[2]

tree = Tree.get_from_path(treefile,"newick")

def brlen2qscore(d):
    return 1-2*exp((-1)*d)/3

for node in tree.postorder_node_iter():
    if not node.is_leaf() and node.edge_length is not None:
        node.label = brlen2qscore(node.edge_length)*100

tree.write_to_path(outfile,"newick")
