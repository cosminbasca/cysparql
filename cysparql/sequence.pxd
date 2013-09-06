# CYTHON
from cython cimport *
from cpython cimport *
from libc.stdio cimport *
from libc.stdlib cimport *
from rasqal cimport *
from util cimport *


cdef class Sequence:
    cdef raptor_sequence*       _rsequence
    cdef rasqal_query*          _rquery
    cdef int                    _idx

    cpdef debug(self)
    cdef __item__(self, void* seq_item)
