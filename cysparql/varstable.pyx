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
from libc.string cimport *
from cysparql.rasqal cimport *
from cysparql.raptor2 cimport *
from cysparql.cutil cimport *
from cysparql.term cimport *


__author__ = 'basca'

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

