# CYTHON
from cython cimport *
from cpython cimport *
from libc.stdio cimport *
from libc.stdlib cimport *
from rasqal cimport *
from cutil cimport *

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
