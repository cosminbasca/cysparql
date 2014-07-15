# CYTHON
from cython cimport *
from cpython cimport *
from libc.stdio cimport *
from libc.stdlib cimport *
from libc.string cimport *

import numpy as np
from collections import defaultdict

_zeros = np.zeros
_sum = np.sum
_max = np.max
_arange = np.arange

# ----------------------------------------------------------------------------------------------------------------------
#
# graph related utilities
#
# ----------------------------------------------------------------------------------------------------------------------
cpdef list get_graph_vertexes(triple_patterns):
    cdef list vertexes = sorted(set([(hash(term), term)
                                     for tp in triple_patterns
                                     for i, term in enumerate((tp[0], tp[2]))]))
    return vertexes

cpdef object get_adjacency_matrix(triple_patterns):
    cdef object tp = None
    cdef object term = None
    cdef int i, j
    cdef dict encoded_vars = {v[0]: i for i, v in enumerate(get_graph_vertexes(triple_patterns))}
    cdef int size = len(encoded_vars)
    cdef object adj_matrix = _zeros((size, size))
    for tp in triple_patterns:
        i = encoded_vars[hash(tp[0])]
        j = encoded_vars[hash(tp[2])]
        adj_matrix[i, j] = 1
        adj_matrix[j, i] = 1
    return adj_matrix

cpdef bint is_star(triple_patterns):
    cdef object adj_matrix = get_adjacency_matrix(triple_patterns)
    cdef int size = len(triple_patterns)
    return _max(_sum(adj_matrix, axis=1)) == size

cpdef list get_stars(triple_patterns):
    cdef list _triple_patterns = triple_patterns if isinstance(triple_patterns, list) else list(triple_patterns)
    cdef list stars = []
    cdef dict encoded_vertexes = {i: v[1] for i, v in enumerate(get_graph_vertexes(triple_patterns))}
    # cdef dict inv_encoded_vertexes = {v:k for k, v in encoded_vertexes.iteritems()}
    cdef object adj_matrix = get_adjacency_matrix(triple_patterns)
    cdef dict vertex_degrees = {encoded_vertexes[i]: d for i, d in enumerate(_sum(adj_matrix, axis=1))}
    cdef object vertex_edges = defaultdict(list)
    # build the vertex - edges dict
    for tp in _triple_patterns:
        vertex_edges[tp[0]].append(tp)
        vertex_edges[tp[2]].append(tp)

    cdef set seen = set()
    cdef object vertex = 0

    cdef list vertex_star = None
    for vertex in sorted(vertex_degrees, key=vertex_degrees.get, reverse=True):
        if vertex not in seen:
            if vertex_degrees[vertex] == 1:
                seen.add(vertex)
            vertex_star = vertex_edges[vertex]
            stars.append(vertex_star)
            # mark the rest of the vertexes as seen
            for tp in vertex_star:
                if vertex_degrees[tp[0]] == 1: seen.add(tp[0])
                if vertex_degrees[tp[2]] == 1: seen.add(tp[2])
    return stars
