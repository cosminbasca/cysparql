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
from cysparql.util import get_rasqal_warning_level
import warnings


__author__ = 'basca'

#-----------------------------------------------------------------------------------------------------------------------
#
# the rasqal world
#
#-----------------------------------------------------------------------------------------------------------------------
cdef class RasqalWorld:
    def __cinit__(self, auto_open=True, default_wlevel = -1):
        self._rworld = rasqal_new_world()
        if default_wlevel > 0:
            self.set_warning_level(default_wlevel)
        else:
            self.set_warning_level(get_rasqal_warning_level())
        if auto_open:
            self.open()

    def __dealloc__(self):
        if self._rworld != NULL:
            rasqal_free_world(self._rworld)

    cpdef bint open(self):
        return False if rasqal_world_open(self._rworld) != 0 else True


    cpdef bint set_warning_level(self, int wlevel):
        if wlevel < 0 or wlevel > 100:
            warnings.warn("warning level was not set, must be an integer number in the [0, 100] interval!")
            return False
        return False if rasqal_world_set_warning_level(self._rworld, wlevel) != 0 else True

    cpdef bint check_query_language(self, bytes name):
        cdef char* _name = name
        return True if rasqal_language_name_check(self._rworld, _name) != 0 else False

    cdef raptor_world* get_raptor_world(self):
        return rasqal_world_get_raptor(self._rworld)
