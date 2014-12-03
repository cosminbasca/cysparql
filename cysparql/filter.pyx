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
from cysparql.term cimport *


__author__ = 'basca'

#-----------------------------------------------------------------------------------------------------------------------
#
# the filter pattern
#
#-----------------------------------------------------------------------------------------------------------------------
cdef inline Filter new_Filter(rasqal_expression* expr):
    cdef Filter _filter = Filter()
    _filter._rexpression = expr

    _filter.filter_operator = <FilterExpressionOperator> expr.op
    _filter.literal = new_QueryLiteral(expr.literal) if expr.literal != NULL else None
    _filter.value = <bytes> expr.value if expr.value != NULL else None
    _filter.name = uri_to_str(expr.name)
    # TODO: fill these lists !
    _filter.args = list()
    _filter.params = list()

    return _filter


cdef class Filter:
    def __cinit__(self):
        self._rexpression = NULL

    cpdef debug(self):
        rasqal_expression_print(<rasqal_expression*> self._rexpression, stdout)

    property operator_label:
        def __get__(self):
            return rasqal_expression_op_label(self._rexpression.op)

