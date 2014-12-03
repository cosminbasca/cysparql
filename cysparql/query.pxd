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
from cysparql.pattern cimport *
from cysparql.varstable cimport *
from cysparql.world cimport *
from cysparql.graph cimport *


__author__ = 'basca'

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
    cdef str                    _unique_id
    # public
    cdef readonly bint          pretty
    cdef public RasqalWorld     world
    cdef public GraphPattern    query_graph_pattern

    cdef public Sequence        vars
    cdef public Sequence        projections
    cdef public Sequence        binding_vars
    cdef public Sequence        prefixes
    cdef public Sequence        triple_patterns
    cdef public Sequence        graph_patterns

    cdef public dict            _vars
    cdef public dict            _namespaces

    cdef void* get_user_data(self)
    cdef void set_user_data(self, void* data)
    cpdef debug(self)
    cpdef get_bindings_var(self, i)
    cpdef get_variable(self, i)
    cpdef set_variable(self, bytes name, QueryLiteral value)
    cpdef has_variable(self, bytes name)
    cpdef get_triple(self, i)
    cpdef get_prefix(self, i)
    cpdef QueryVarsTable create_vars_table(self)
    cpdef to_string(self)
    cpdef list get_graph_vertexes(self)
    cpdef get_adjacency_matrix(self)
    cpdef bint is_star(self)
    cpdef to_graph(self)
