# CYTHON
from cython cimport *
from cpython cimport *
from libc.stdio cimport *
from libc.stdlib cimport *
from libc.string cimport *

import numpy as np


# ----------------------------------------------------------------------------------------------------------------------
#
# graph related utilities
#
# ----------------------------------------------------------------------------------------------------------------------
cpdef list get_graph_vertexes(TriplePatternSequence triple_patterns):
    cdef list vertexes = sorted(set([
        (hash(term),term)
        for tp in triple_patterns
        for i, term in enumerate(tp)
        if i == 0 or i == 2
    ]))
    return vertexes


cpdef object get_adjacency_matrix(TriplePatternSequence triple_patterns):
    cdef TriplePattern tp = None
    cdef object term = None
    cdef int i, j
    cdef dict encoded_vars = { v[0]:i for i, v in enumerate(get_graph_vertexes(triple_patterns)) }
    cdef int size = len(encoded_vars)
    cdef object adj_matrix = np.zeros((size, size))
    for tp in triple_patterns:
        i = encoded_vars[hash(tp.subject)]
        j = encoded_vars[hash(tp.object)]
        adj_matrix[i,j] = 1
        adj_matrix[j,i] = 1
    return adj_matrix


cpdef bint is_star(TriplePatternSequence triple_patterns):
    cdef object adj_matrix = get_adjacency_matrix(triple_patterns)
    cdef int size = triple_patterns.size()
    return np.max(np.sum(adj_matrix, axis=1)) == size