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


__author__ = 'basca'

# ----------------------------------------------------------------------------------------------------------------------
#
# graph related utilities
#
# ----------------------------------------------------------------------------------------------------------------------
cpdef list get_graph_vertexes(triple_patterns)

cpdef object get_adjacency_matrix(triple_patterns)

cpdef bint is_star(triple_patterns)

cpdef list get_stars(triple_patterns)