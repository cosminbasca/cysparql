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


__author__ = 'basca'

#-----------------------------------------------------------------------------------------------------------------------
#
# the rasqal world
#
#-----------------------------------------------------------------------------------------------------------------------
cdef class RasqalWorld:
    cdef rasqal_world*          _rworld

    cpdef bint open(self)
    cpdef bint set_warning_level(self, int wlevel)
    cpdef bint check_query_language(self, bytes name)
    cdef raptor_world* get_raptor_world(self)
