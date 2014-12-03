#
# author: Cosmin Basca
#
# Copyright 2010 University of Zurich
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

from cython cimport *
from cpython cimport *
from libc.stdio cimport *
from libc.stdlib cimport *
from cysparql.rasqal cimport *
from cysparql.cutil cimport *
from cysparql.term cimport *
from cysparql.sequence import *
from cysparql.filter cimport *


__author__ = 'basca'

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
    cdef long _hashvalue


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
    cdef long _hashvalue

    cpdef debug(self)
    cpdef bint is_optional(self)
    cpdef bint is_basic(self)
    cpdef bint is_union(self)
    cpdef bint is_group(self)
    cpdef bint is_graph(self)
    cpdef bint is_filter(self)
    cpdef bint is_service(self)

