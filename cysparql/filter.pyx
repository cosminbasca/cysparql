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
from term cimport *

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

