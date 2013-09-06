# CYTHON
from cython cimport *
from cpython cimport *
from libc.stdio cimport *
from libc.stdlib cimport *
from rasqal cimport *
from util cimport *
from sequence cimport *


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

    cpdef is_rdf_literal(self)
    cpdef as_var(self)
    cpdef as_str(self)
    cpdef as_node(self)
    cpdef debug(self)
    cpdef object value(self)


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

# TODO: add conversion to and from RdfLib for binding to vars and vice versa