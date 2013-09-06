# CYTHON
from cython cimport *
from cpython cimport *
from libc.stdio cimport *
from libc.stdlib cimport *
from rasqal cimport *
from util cimport *
from term cimport *
from sequence import *
from filter cimport *
from pattern cimport *


#-----------------------------------------------------------------------------------------------------------------------
#
# the prefix
#
#-----------------------------------------------------------------------------------------------------------------------
cdef class Prefix:
    cdef rasqal_prefix* _rprefix

    cpdef debug(self)


#-----------------------------------------------------------------------------------------------------------------------
#
# related sequences
#
#-----------------------------------------------------------------------------------------------------------------------
cdef class AllVarsIterator(Sequence)
cdef class BoundVarsIterator(Sequence)
cdef class BindingsVarsIterator(Sequence)
cdef class QueryTripleIterator(Sequence)
cdef class GraphPatternIterator(Sequence)

#-----------------------------------------------------------------------------------------------------------------------
#
# the query wrapper
#
#-----------------------------------------------------------------------------------------------------------------------
cdef class Query:
    # private
    cdef rasqal_query*          _rquery
    cdef rasqal_world*          _rworld
    # public
    cdef public bytes           query_string
    cdef public list            vars
    cdef public list            bound_vars
    cdef public list            projections
    cdef public list            binding_vars
    cdef public list            prefixes
    cdef public list            triple_patterns
    cdef public GraphPattern    query_graph_pattern
    cdef public list            graph_patterns

    cpdef debug(self)
    cpdef get_bindings_var(self, i)
    cpdef get_var(self, i)
    cpdef has_var(self, char* name)
    cpdef get_triple(self, i)
    cpdef get_prefix(self, i)
