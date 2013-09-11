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


cdef class Prefix

#-----------------------------------------------------------------------------------------------------------------------
#
# related sequences
#
#-----------------------------------------------------------------------------------------------------------------------
cdef Sequence new_PrefixSequence(rasqal_query* query, raptor_sequence* sequence)
cdef class PrefixSequence(Sequence):
    pass

#-----------------------------------------------------------------------------------------------------------------------
#
# the prefix
#
#-----------------------------------------------------------------------------------------------------------------------
cdef Prefix new_Prefix(rasqal_prefix* prefix)

cdef class Prefix:
    cdef rasqal_prefix* _rprefix

    cpdef debug(self)


#-----------------------------------------------------------------------------------------------------------------------
#
# the query wrapper
#
#-----------------------------------------------------------------------------------------------------------------------
cdef class Query:
    # private
    cdef raptor_uri*            _format_uri
    cdef rasqal_query*          _rquery
    # public
    cdef public RasqalWorld     world
    cdef public bytes           query_string
    cdef public GraphPattern    query_graph_pattern

    cdef public Sequence        vars
    cdef public Sequence        projections
    cdef public Sequence        binding_vars
    cdef public Sequence        prefixes
    cdef public Sequence        triple_patterns
    cdef public Sequence        graph_patterns

    cdef public dict            __vars__

    cpdef debug(self)
    cpdef get_bindings_var(self, i)
    cpdef get_var(self, i)
    cpdef has_var(self, bytes name)
    cpdef get_triple(self, i)
    cpdef get_prefix(self, i)
    cpdef QueryVarsTable create_vars_table(self)
    cpdef to_str(self)
