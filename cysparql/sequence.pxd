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
from cysparql.raptor2 cimport *
from cysparql.cutil cimport *


__author__ = 'basca'

#-----------------------------------------------------------------------------------------------------------------------
#
# the sequence
#
#-----------------------------------------------------------------------------------------------------------------------
cdef class Sequence:
    cdef bint                   _owner
    cdef raptor_sequence*       _rsequence
    cdef rasqal_query*          _rquery
    cdef int                    _idx
    cdef int                    _start
    cdef int                    _end

    cpdef debug(self)
    cdef __item__(self, void* seq_item)
    cpdef size(self)


#-----------------------------------------------------------------------------------------------------------------------
#
# a mutable sequence implementation
#
#-----------------------------------------------------------------------------------------------------------------------
cdef class MutableSequence(Sequence):
    pass