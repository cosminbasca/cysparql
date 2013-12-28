# CYTHON
from cython cimport *
from cpython cimport *
from libc.stdio cimport *
from libc.stdlib cimport *
from rasqal cimport *
from cutil cimport *
from sequence cimport *
from world cimport *


cdef class QueryLiteral
cdef class QueryVar

#-----------------------------------------------------------------------------------------------------------------------
#
# the query literal
#
#-----------------------------------------------------------------------------------------------------------------------
cdef QueryLiteral new_QueryLiteral(rasqal_literal* literal)

cdef class QueryLiteral:
    cdef rasqal_literal* _rliteral
    cdef long _hashvalue

    cpdef is_rdf_literal(self)
    cpdef as_var(self)
    cpdef to_str(self)
    cpdef as_node(self)
    cpdef to_python(self)
    cpdef to_rdflib(self)
    cpdef debug(self)


#-----------------------------------------------------------------------------------------------------------------------
#
# related sequences
#
#-----------------------------------------------------------------------------------------------------------------------
cdef Sequence new_QueryVarSequence(rasqal_query* query, raptor_sequence* sequence)
cdef class QueryVarSequence(Sequence):
    pass

#-----------------------------------------------------------------------------------------------------------------------
#
# the query var
#
#-----------------------------------------------------------------------------------------------------------------------
cdef QueryVar new_QueryVar(rasqal_variable* var)

cdef class QueryVar:
    cdef rasqal_variable* _rvariable
    cdef long _hashvalue

    cdef bind(self, rasqal_literal* literal)
    cpdef is_unbound(self)
    cpdef debug(self)
    cpdef set_value(self, val, world)
    cpdef get_value(self, to_python=*)
