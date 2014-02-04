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
cpdef list get_graph_vertexes(triple_patterns):
    cdef list vertexes = sorted(set([(hash(term),term)
                                     for tp in triple_patterns
                                     for i, term in enumerate((tp.subject, tp.object))]))
    return vertexes


cpdef object get_adjacency_matrix(triple_patterns):
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


cpdef bint is_star(triple_patterns):
    cdef object adj_matrix = get_adjacency_matrix(triple_patterns)
    cdef int size = len(triple_patterns)
    return np.max(np.sum(adj_matrix, axis=1)) == size


cpdef list get_stars(triple_patterns):
    cdef list stars = []
    cdef dict encoded_vertexes = { i:v[1] for i, v in enumerate(get_graph_vertexes(triple_patterns)) }
    cdef object adj_matrix = get_adjacency_matrix(triple_patterns)
    cdef object vertex_degrees = { d:encoded_vertexes[i] for i,d in enumerate(np.sum(adj_matrix, axis=1)) }
    cdef object vertex = 0

    cdef list _triple_patterns = list(triple_patterns)
    cdef list vertex_star = None
    for d in sorted(vertex_degrees.keys(), reverse=True):
        # this is the vertex with the highest degree (representing the biggest star
        vertex = vertex_degrees[d]
        vertex_star = [tp for tp in _triple_patterns if vertex in tp]
        if len(vertex_star):
            _triple_patterns[:] = [tp for tp in _triple_patterns if vertex not in tp]
            stars.append(vertex_star)
    return stars