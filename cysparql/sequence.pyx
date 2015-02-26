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


__author__ = 'basca'

#-----------------------------------------------------------------------------------------------------------------------
#
# the sequence (read-only)
#
#-----------------------------------------------------------------------------------------------------------------------
cdef class Sequence:
    def __cinit__(self):
        """this class must be subclassed to be of any use. Provide your own factory constructor methods"""
        self._rsequence = NULL
        self._rquery = NULL
        self._owner = False
        self._idx = 0
        self._start = -1
        self._end = -1

    def __dealloc__(self):
        if self._owner:
            raptor_free_sequence(self._rsequence)

    def __getitem__(self, i):
        cdef void* item = raptor_sequence_get_at(<raptor_sequence*> self._rsequence, i)
        return self.__item__(item) if item != NULL else None

    cpdef debug(self):
        raptor_sequence_print(<raptor_sequence*> self._rsequence, stdout)

    cdef __item__(self, void* seq_item):
        return <object> seq_item

    cpdef size(self):
        if self._rsequence != NULL:
            return raptor_sequence_size(<raptor_sequence*> self._rsequence)
        return 0

    def __len__(self):
        return self.size()

    def __iter__(self):
        self._idx = 0 if self._start < 0 else self._start
        return self

    def __next__(self):
        cdef void* item = NULL
        if self._rsequence == NULL:
            raise StopIteration
        if self._idx >= raptor_sequence_size(<raptor_sequence*> self._rsequence):
            raise StopIteration
        if 0 < self._end < self._idx:
            raise StopIteration

        else:
            item = raptor_sequence_get_at(<raptor_sequence*> self._rsequence, self._idx)
            self._idx += 1
            return self.__item__(item) if item != NULL else None



#-----------------------------------------------------------------------------------------------------------------------
#
# a mutable sequence implementation
#
#-----------------------------------------------------------------------------------------------------------------------
cdef class MutableSequence(Sequence):
    def __setitem__(self, i, value):
        raptor_sequence_set_at(<raptor_sequence*> self._rsequence, i, <void*> value)

    def __delitem__(self, i):
        raptor_sequence_delete_at(<raptor_sequence*> self._rsequence, i)

    def __and__(self, other):
        raptor_sequence_join(<raptor_sequence*> self._rsequence, <raptor_sequence*> other)

    def shift(self, data):
        raptor_sequence_shift(<raptor_sequence*> self._rsequence, <void*> data)

    def unshift(self):
        return <object> raptor_sequence_unshift(<raptor_sequence*> self._rsequence)

    def pop(self):
        return <object> raptor_sequence_pop(<raptor_sequence*> self._rsequence)

    def push(self, data):
        raptor_sequence_push(<raptor_sequence*> self._rsequence, <void*> data)