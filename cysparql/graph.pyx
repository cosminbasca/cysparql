# CYTHON
from cython cimport *
from cpython cimport *
from libc.stdio cimport *
from libc.stdlib cimport *
from libc.string cimport *

import numpy as np

_zeros = np.zeros
_sum = np.sum
_max = np.max

# ----------------------------------------------------------------------------------------------------------------------
#
# graph related utilities
#
# ----------------------------------------------------------------------------------------------------------------------
cpdef list get_graph_vertexes(triple_patterns):
    cdef list vertexes = sorted(set([(hash(term),term)
                                     for tp in triple_patterns
                                     # for i, term in enumerate((tp.subject, tp.object))]))
                                     for i, term in enumerate((tp[0], tp[2]))]))
    return vertexes


cpdef object get_adjacency_matrix(triple_patterns):
    # cdef TriplePattern tp = None
    cdef object tp = None
    cdef object term = None
    cdef int i, j
    cdef dict encoded_vars = { v[0]:i for i, v in enumerate(get_graph_vertexes(triple_patterns)) }
    cdef int size = len(encoded_vars)
    cdef object adj_matrix = _zeros((size, size))
    for tp in triple_patterns:
        # i = encoded_vars[hash(tp.subject)]
        # j = encoded_vars[hash(tp.object)]
        i = encoded_vars[hash(tp[0])]
        j = encoded_vars[hash(tp[2])]
        adj_matrix[i,j] = 1
        adj_matrix[j,i] = 1
    return adj_matrix


cpdef bint is_star(triple_patterns):
    cdef object adj_matrix = get_adjacency_matrix(triple_patterns)
    cdef int size = len(triple_patterns)
    return _max(_sum(adj_matrix, axis=1)) == size


cpdef list get_stars(triple_patterns):
    cdef list stars = []
    cdef dict encoded_vertexes = { i:v[1] for i, v in enumerate(get_graph_vertexes(triple_patterns)) }
    cdef object adj_matrix = get_adjacency_matrix(triple_patterns)
    cdef object vertex_degrees = { d:encoded_vertexes[i] for i,d in enumerate(_sum(adj_matrix, axis=1)) }
    cdef object vertex = 0

    cdef list _triple_patterns = triple_patterns if isinstance(triple_patterns, list) else list(triple_patterns)
    cdef list vertex_star = None
    for d in sorted(vertex_degrees.keys(), reverse=True):
        # this is the vertex with the highest degree (representing the biggest star
        vertex = vertex_degrees[d]
        vertex_star = [tp for tp in _triple_patterns if vertex in tp]
        if len(vertex_star):
            _triple_patterns[:] = [tp for tp in _triple_patterns if vertex not in tp]
            stars.append(vertex_star)
    return stars