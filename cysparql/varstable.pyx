# CYTHON
from cython cimport *
from cpython cimport *
from libc.stdio cimport *
from libc.stdlib cimport *
from libc.string cimport *
# LOCAL
from rasqal cimport *
from raptor2 cimport *
from cutil cimport *
from term cimport *


#-----------------------------------------------------------------------------------------------------------------------
#
# the vars table
#
#-----------------------------------------------------------------------------------------------------------------------
cdef inline QueryVarsTable new_QueryVarsTable(rasqal_world* world):
    cdef QueryVarsTable vt = QueryVarsTable()
    vt._rvtable = rasqal_new_variables_table(world)
    return vt

cdef class QueryVarsTable:
    def __cinit__(self):
        self._rvtable = NULL

    def __dealloc__(self):
        if self._rvtable != NULL:
            rasqal_free_variables_table(self._rvtable)

    cpdef QueryVar add_new_variable(self, bytes name):
        cdef rasqal_variable* v = rasqal_variables_table_add(self._rvtable, RASQAL_VARIABLE_TYPE_NORMAL, name, NULL)
        return new_QueryVar(v)

    cpdef bint add_variable(self, QueryVar var):
        return False if rasqal_variables_table_add_variable(self._rvtable, var._rvariable) > 0 else True

    def __getitem__(self, name):
        cdef char* _name = name
        cdef rasqal_variable* v = rasqal_variables_table_get_by_name(self._rvtable, RASQAL_VARIABLE_TYPE_NORMAL, _name)
        return new_QueryVar(v)

    def __contains__(self, name):
        cdef char* _name = name
        return rasqal_variables_table_contains(self._rvtable, RASQAL_VARIABLE_TYPE_NORMAL, _name)

