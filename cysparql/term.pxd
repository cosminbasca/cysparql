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
from cysparql.sequence cimport *
from cysparql.world cimport *


__author__ = 'basca'

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
