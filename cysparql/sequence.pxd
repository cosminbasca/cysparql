# CYTHON
from cython cimport *
from cpython cimport *
from libc.stdio cimport *
from libc.stdlib cimport *
from rasqal cimport *
from raptor2 cimport *
from cutil cimport *


#-----------------------------------------------------------------------------------------------------------------------
#
# the sequence
#
#-----------------------------------------------------------------------------------------------------------------------
cdef class Sequence:
    cdef raptor_sequence*       _rsequence
    cdef rasqal_query*          _rquery
    cdef int                    _idx
    cdef int                    _start
    cdef int                    _end

    cpdef debug(self)
    cdef __item__(self, void* seq_item)


#-----------------------------------------------------------------------------------------------------------------------
#
# a mutable sequence implementation
#
#-----------------------------------------------------------------------------------------------------------------------
cdef class MutableSequence(Sequence):
    pass