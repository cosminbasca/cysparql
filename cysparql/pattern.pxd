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


cdef class TriplePattern
cdef class GraphPattern

#-----------------------------------------------------------------------------------------------------------------------
#
# the triple pattern
#
#-----------------------------------------------------------------------------------------------------------------------
cdef TriplePattern new_TriplePattern(rasqal_triple* triple)

cdef class TriplePattern:
    cdef rasqal_triple*         _rtriple
    cdef int                    _idx
    cdef public QueryLiteral    subject_qliteral
    cdef public QueryLiteral    predicate_qliteral
    cdef public QueryLiteral    object_qliteral
    cdef public QueryLiteral    context_qliteral

    cdef public object __subject__
    cdef public object __predicate__
    cdef public object __object__
    cdef public object __context__


    cpdef debug(self)
    cdef int pattern_type(self)


#-----------------------------------------------------------------------------------------------------------------------
#
# related sequences
#
#-----------------------------------------------------------------------------------------------------------------------
cdef Sequence new_TriplePatternSequence(rasqal_query* query, raptor_sequence* sequence, int start=*, int end=*)
cdef class TriplePatternSequence(Sequence):
    pass

cdef Sequence new_GraphPatternSequence(rasqal_query* query, raptor_sequence* sequence, int start=*, int end=*)
cdef class GraphPatternSequence(Sequence):
    pass


#-----------------------------------------------------------------------------------------------------------------------
#
# the graph pattern
#
#-----------------------------------------------------------------------------------------------------------------------
cdef GraphPattern new_GraphPattern(rasqal_query* query, rasqal_graph_pattern* gp)

cdef class GraphPattern:
    cdef rasqal_graph_pattern*  _rgraphpattern
    cdef rasqal_query*          _rquery
    cdef int                    _idx
    cdef public QueryLiteral    service
    cdef public QueryVar        variable
    cdef public Filter          filter
    cdef public QueryLiteral    origin

    cdef public Sequence        triple_patterns
    cdef public Sequence        sub_graph_patterns
    cdef public Sequence        flattened_triple_patterns

    cpdef debug(self)
    cpdef bint is_optional(self)
    cpdef bint is_basic(self)
    cpdef bint is_union(self)
    cpdef bint is_group(self)
    cpdef bint is_graph(self)
    cpdef bint is_filter(self)
    cpdef bint is_service(self)

