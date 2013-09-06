# CYTHON
from cython cimport *
from cpython cimport *
from libc.stdio cimport *
from libc.stdlib cimport *
from libc.string cimport *
# LOCAL
from rasqal cimport *
from raptor cimport *
from util cimport *

cdef class Sequence:
    def __cinit__(self):
        """this class must be subclassed to be of any use. Provide your own factory constructor methods"""
        self._rsequence = NULL
        self._rquery = NULL
        self._idx = 0

    def __len__(self):
        return raptor_sequence_size(<raptor_sequence*> self._rsequence)

    def __setitem__(self, i, value):
        raptor_sequence_set_at(<raptor_sequence*> self._rsequence, i, <void*> value)

    def __delitem__(self, i):
        raptor_sequence_delete_at(<raptor_sequence*> self._rsequence, i)

    def __getitem__(self, i):
        return <object> raptor_sequence_get_at(<raptor_sequence*> self._rsequence, i)

    cpdef debug(self):
        raptor_sequence_print(<raptor_sequence*> self._rsequence, stdout)

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

    cdef __item__(self, void* seq_item):
        return <object> seq_item

    def __iter__(self):
        self._idx = 0
        return self

    def __next__(self):
        cdef void* item = NULL
        if self._idx == raptor_sequence_size(<raptor_sequence*> self._rsequence):
            raise StopIteration
        else:
            item = raptor_sequence_get_at(<raptor_sequence*> self._rsequence, self._idx)
            self._idx += 1
            return self.__item__(item)
