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

from rdflib.term import URIRef, Literal, BNode



#-----------------------------------------------------------------------------------------------------------------------
#
# the query literal
#
#-----------------------------------------------------------------------------------------------------------------------
cdef inline QueryLiteral new_QueryLiteral(rasqal_literal* literal):
    cdef QueryLiteral qliteral = QueryLiteral()
    qliteral._rliteral = literal
    return qliteral


cdef class QueryLiteral:
    def __cinit__(self, qliteral = None):
        self._rliteral = NULL
        if qliteral and isinstance(qliteral, QueryLiteral):
            self._rliteral = (<QueryLiteral>qliteral)._rliteral

    property language:
        def __get__(self):
            return self._rliteral.language if self._rliteral.language != NULL else None

    property datatype:
        def __get__(self):
            return uri_to_str(self._rliteral.datatype) if self._rliteral.datatype != NULL else None

    property literal_type:
        def __get__(self):
            return rasqal_literal_type_label(self._rliteral.type)

    cpdef is_rdf_literal(self):
        return rasqal_literal_is_rdf_literal(self._rliteral) > 0

    cpdef as_var(self):
        cdef rasqal_variable* var = rasqal_literal_as_variable(self._rliteral)
        return new_QueryVar(var) if var != NULL else None

    cpdef as_str(self):
        if self._rliteral.type == RASQAL_LITERAL_URI \
            or self._rliteral.type == RASQAL_LITERAL_BLANK:
            return <char*> rasqal_literal_as_string(self._rliteral)
        elif self._rliteral.type == RASQAL_LITERAL_VARIABLE:
            return self._rliteral.value.variable.name if self._rliteral.value.variable.name != NULL else ''
        return ''

    cpdef as_node(self):
        cdef rasqal_literal*node = rasqal_literal_as_node(self._rliteral)
        return new_QueryLiteral(node) if node != NULL else None

    def __str__(self):
        return self.as_str()

    cpdef debug(self):
        rasqal_literal_print(<rasqal_literal*> self._rliteral, stdout)

    cpdef object value(self):
        cdef bytes lbl = None
        if self._rliteral.type == RASQAL_LITERAL_URI:
            lbl = <char*> rasqal_literal_as_string(self._rliteral)
            return URIRef(lbl)
        elif self._rliteral.type == RASQAL_LITERAL_BLANK:
            lbl = <char*> rasqal_literal_as_string(self._rliteral)
            return BNode(lbl)
        elif self._rliteral.type == RASQAL_LITERAL_STRING:
            lbl = <char*> self._rliteral.string
            return Literal(lbl, lang=self.language, datatype=self.datatype)
        elif self._rliteral.type == RASQAL_LITERAL_VARIABLE:
            return new_QueryVar(self._rliteral.value.variable)
        return None



#-----------------------------------------------------------------------------------------------------------------------
#
# the query var
#
#-----------------------------------------------------------------------------------------------------------------------
cdef QueryVar new_QueryVar(rasqal_variable* var):
    cdef QueryVar qvariable = QueryVar()
    qvariable._rvariable = var
    return qvariable


cdef class QueryVar:
    def __cinit__(self, qvar = None):
        self._rvariable = NULL
        if qvar and isinstance(qvar, QueryVar):
            self._rvariable = (<QueryVar>qvar)._rvariable
        self._hashvalue = 0

    property name:
        def __get__(self):
            return self._rvariable.name if self._rvariable.name != NULL else None

    property offset:
        def __get__(self):
            return self._rvariable.offset

    property value:
        def __get__(self):
            return new_QueryLiteral(self._rvariable.value) if self._rvariable.value != NULL else None
        def __set__(self, val):
            cdef rasqal_literal* _literal = NULL # TODO: here convert val to _literal!
            self.bind(_literal)

    cdef bind(self, rasqal_literal* literal):
        rasqal_variable_set_value(self._rvariable, literal)

    cpdef is_unbound(self):
        return self._rvariable.value == NULL

    cpdef debug(self):
        rasqal_variable_print(<rasqal_variable*> self._rvariable, stdout)

    def __str__(self):
        return self.n3()

    def __repr__(self):
        return 'QueryVar(%s, hashcode=%s)' % (self.name, str(self._hashvalue))

    def n3(self):
        """this is not really n3 notation, since variables are not defined in this scope, the method is present
        for compatibility with the n3 methods in rdflib and QueryLiteral"""
        cdef bytes name = self._rvariable.name
        return '?%s' % name

    def __richcmp__(self, other, op):
        if not other:   return False
        cdef long _hashvalue_other = 0
        if isinstance(other, QueryVar):
            _hashvalue_other = (<QueryVar> other)._hashvalue

            if op == 0: # <
                return self._hashvalue < _hashvalue_other
            elif op == 2: #==
                return self._hashvalue == _hashvalue_other
            elif op == 4: # >
                return self._hashvalue > _hashvalue_other
            elif op == 1: # <=
                return self._hashvalue <= _hashvalue_other
            elif op == 3: # !=
                return self._hashvalue != _hashvalue_other
            elif op == 5: # >=
                return self._hashvalue >= _hashvalue_other

    def __hash__(self):
        if self._hashvalue == 0:
            self._hashvalue = hash(self.name)
        return self._hashvalue
