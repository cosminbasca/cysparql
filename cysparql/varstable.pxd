# CYTHON
from cython cimport *
from cpython cimport *
from libc.stdio cimport *
from libc.stdlib cimport *
from rasqal cimport *
from cutil cimport *
from sequence cimport *
from term cimport *

#-----------------------------------------------------------------------------------------------------------------------
#
# the vars table
#
#-----------------------------------------------------------------------------------------------------------------------
cdef class QueryVarsTable

cdef QueryVarsTable new_QueryVarsTable(rasqal_world* world)

cdef class QueryVarsTable:
    cdef rasqal_variables_table* _rvtable

    cpdef QueryVar add_new_variable(self, bytes name)
    cpdef bint add_variable(self, QueryVar var)

