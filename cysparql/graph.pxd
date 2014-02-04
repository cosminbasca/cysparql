# CYTHON
from cython cimport *
from cpython cimport *
from libc.stdio cimport *
from libc.stdlib cimport *
from rasqal cimport *
from cutil cimport *
from term cimport *
from sequence import *
from filter cimport *
from pattern cimport *
from varstable cimport *
from world cimport *


# ----------------------------------------------------------------------------------------------------------------------
#
# graph related utilities
#
# ----------------------------------------------------------------------------------------------------------------------
cpdef list get_graph_vertexes(triple_patterns)

cpdef object get_adjacency_matrix(triple_patterns)

cpdef bint is_star(triple_patterns)

cpdef list get_stars(triple_patterns)