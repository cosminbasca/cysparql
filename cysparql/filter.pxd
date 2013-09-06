# CYTHON
from cython cimport *
from cpython cimport *
from libc.stdio cimport *
from libc.stdlib cimport *
from rasqal cimport *
from util cimport *
from term cimport *

cdef class Filter

#-----------------------------------------------------------------------------------------------------------------------
#
# the filter pattern
#
#-----------------------------------------------------------------------------------------------------------------------
cdef Filter new_Filter(rasqal_expression* expr)

cdef class Filter:
    cdef rasqal_expression* _rexpression
    cdef public FilterExpressionOperator filter_operator
    cdef public QueryLiteral literal
    cdef public bytes value
    cdef public bytes name
    cdef public list args
    cdef public list params

    cpdef debug(self)

