# CYTHON
from cython cimport *
from cpython cimport *
from libc.stdio cimport *
from libc.stdlib cimport *
from libc.string cimport *
# LOCAL
from rasqal cimport *
from raptor2 cimport *
from cutil cimport *

from rdflib.term import URIRef, Literal, BNode
from util import enum

LiteralType = enum(
    UNKNOWN = UNKNOWN,
    BLANK =BLANK,
    URI = URI,
    STRING = STRING,
    XSD_STRING = XSD_STRING,
    BOOLEAN = BOOLEAN,
    INTEGER = INTEGER,
    FLOAT = FLOAT,
    DOUBLE = DOUBLE,
    DECIMAL = DECIMAL,
    DATETIME = DATETIME,
    UDT = UDT,
    PATTERN = PATTERN,
    QNAME = QNAME,
    VARIABLE = VARIABLE,
    DATE = DATE,
)


numeric_types = {
    LiteralType.BOOLEAN,
    LiteralType.INTEGER,
    LiteralType.FLOAT,
    LiteralType.DOUBLE,
    LiteralType.DECIMAL,
}

py_literal_types = {
    LiteralType.STRING,
    LiteralType.XSD_STRING,
    LiteralType.BOOLEAN,
    LiteralType.INTEGER,
    LiteralType.FLOAT,
    LiteralType.DOUBLE,
    LiteralType.DECIMAL,
    LiteralType.DATETIME,
    LiteralType.UDT,
    LiteralType.DATE,
}

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
        self._hashvalue = 0
        self._rliteral = NULL
        if qliteral and isinstance(qliteral, QueryLiteral):
            self._rliteral = (<QueryLiteral>qliteral)._rliteral

    property language:
        def __get__(self):
            return (<_rasqal_literal*>self._rliteral).language if (<_rasqal_literal*>self._rliteral).language != NULL else None

    property datatype:
        def __get__(self):
            cdef raptor_uri* _dtype = rasqal_literal_datatype(self._rliteral)
            cdef bytes _uri = uri_to_str(_dtype) if _dtype != NULL else None
            return URIRef(_uri) if _uri else None

    property literal_type:
        def __get__(self):
            return (<_rasqal_literal*>self._rliteral).type

    property literal_rdf_type:
        def __get__(self):
            return rasqal_literal_get_rdf_term_type(self._rliteral)

    property literal_type_label:
        def __get__(self):
            cdef char* _label = rasqal_literal_type_label((<_rasqal_literal*>self._rliteral).type)
            cdef bytes _l = _label if _label != NULL else None
            return _l

    cpdef is_rdf_literal(self):
        return rasqal_literal_is_rdf_literal(self._rliteral) > 0

    cpdef as_var(self):
        cdef rasqal_variable* var = rasqal_literal_as_variable(self._rliteral)
        return new_QueryVar(var) if var != NULL else None

    cpdef as_node(self):
        """Turn a literal into a new RDF string, URI or blank literal."""
        cdef rasqal_literal* node = rasqal_literal_as_node(self._rliteral)
        return new_QueryLiteral(node) if node != NULL else None

    def __str__(self):
        return str(self.to_python())

    cpdef debug(self):
        rasqal_literal_print(<rasqal_literal*> self._rliteral, stdout)

    cpdef to_python(self):
        val = self.to_rdflib()
        if isinstance(val, Literal):
            return val.toPython()
        return val

    cpdef to_rdflib(self):
        cdef bytes lbl = None
        cdef rasqal_literal_type _type = (<_rasqal_literal*>self._rliteral).type
        if _type == RASQAL_LITERAL_URI:
            lbl = <char*> rasqal_literal_as_string(self._rliteral)
            return URIRef(lbl)
        elif _type == RASQAL_LITERAL_BLANK:
            lbl = <char*> rasqal_literal_as_string(self._rliteral)
            return BNode(lbl)
        elif _type == RASQAL_LITERAL_VARIABLE:
            return new_QueryVar((<_rasqal_literal*>self._rliteral).value.variable)
        elif _type in py_literal_types:
            lbl = <char*> (<_rasqal_literal*>self._rliteral).string
            return Literal(lbl, lang=self.language, datatype=self.datatype)
        return None

    def __hash__(self):
        if self._hashvalue == 0:
            self._hashvalue = hash(self.to_rdflib())
        return self._hashvalue

    # factory constructor methods
    @classmethod
    def new_typed_literal(cls, world, ltype, value):
        """only intereger typed literals from strings"""
        assert ltype in numeric_types, 'not a numeric type'
        assert isinstance(value, basestring)
        cdef char* _value = value
        cdef rasqal_literal* _literal = rasqal_new_typed_literal((<RasqalWorld>world)._rworld, ltype, _value)
        return new_QueryLiteral(_literal) if _literal != NULL else None

    @classmethod
    def new_bool_literal(cls, world, value):
        assert isinstance(value, (int, long))
        cdef rasqal_literal* _literal = rasqal_new_boolean_literal((<RasqalWorld>world)._rworld, value)
        return new_QueryLiteral(_literal) if _literal != NULL else None

    @classmethod
    def new_decimal_literal(cls, world, value):
        assert isinstance(value, basestring)
        cdef char* _value = value
        cdef rasqal_literal* _literal = rasqal_new_decimal_literal((<RasqalWorld>world)._rworld, _value)
        return new_QueryLiteral(_literal) if _literal != NULL else None

    @classmethod
    def new_double_literal(cls, world, value):
        assert isinstance(value, float)
        cdef rasqal_literal* _literal = rasqal_new_double_literal((<RasqalWorld>world)._rworld, value)
        return new_QueryLiteral(_literal) if _literal != NULL else None

    @classmethod
    def new_integer_literal(cls, world, value):
        assert isinstance(value, (int, long))
        cdef rasqal_literal* _literal = rasqal_new_numeric_literal_from_long((<RasqalWorld>world)._rworld, <rasqal_literal_type>INTEGER, value)
        return new_QueryLiteral(_literal) if _literal != NULL else None

    @classmethod
    def new_simple_literal(cls, world, value):
        assert isinstance(value, basestring)
        cdef char* _value = value
        cdef rasqal_literal* _literal = rasqal_new_simple_literal((<RasqalWorld>world)._rworld, <rasqal_literal_type>BLANK, _value)
        return new_QueryLiteral(_literal) if _literal != NULL else None

    @classmethod
    def new_string_literal(cls, world, value, lang = None, dtype = None):
        assert isinstance(value, basestring)
        cdef char* _value = value
        cdef char* _lang = NULL
        if lang:
            _lang = lang
        cdef raptor_uri* _dtype = NULL
        if dtype:
            _dtype = raptor_new_uri((<RasqalWorld>world).get_raptor_world(), dtype)
        cdef rasqal_literal* _literal = rasqal_new_string_literal((<RasqalWorld>world)._rworld, _value, _lang, _dtype, NULL)
        return new_QueryLiteral(_literal) if _literal != NULL else None

    @classmethod
    def new_uri_literal(cls, world, uri):
        assert isinstance(uri, (basestring, URIRef))
        cdef raptor_uri* _uri = raptor_new_uri((<RasqalWorld>world).get_raptor_world(), uri)
        cdef rasqal_literal* _literal = rasqal_new_uri_literal((<RasqalWorld>world)._rworld, _uri)
        return new_QueryLiteral(_literal) if _literal != NULL else None



cdef rasqal_literal* create_rasqal_literal(rasqal_world *world, object val):
    cdef rasqal_literal* r_lit = NULL
    cdef raptor_uri* uri = NULL
    cdef bytes _str = None
    if isinstance(val, basestring):
        r_lit = rasqal_new_string_literal(world, val, NULL, NULL, NULL)
    elif isinstance(val, int):
        r_lit = rasqal_new_numeric_literal_from_long(world, RASQAL_LITERAL_INTEGER, val)
    elif isinstance(val, long):
        _str = str(val)
        r_lit = rasqal_new_decimal_literal(world, _str)
    elif isinstance(val, bool):
        r_lit = rasqal_new_boolean_literal(world, val)
    elif isinstance(val, float):
        r_lit = rasqal_new_double_literal(world, val)
    elif isinstance(val, URIRef):
        uri = raptor_new_uri(rasqal_world_get_raptor(world), <bytes>val)
        r_lit = rasqal_new_uri_literal(world, uri)
        raptor_free_uri(uri)
    elif isinstance(val, Literal):
        if val.language:
            r_lit = rasqal_new_string_literal(world, val.value, val.language, NULL, NULL)
        elif val.datatype:
            uri = raptor_new_uri(rasqal_world_get_raptor(world), <bytes>val.datatype)
            r_lit = rasqal_new_string_literal(world, val.value, NULL, uri, NULL)
            raptor_free_uri(uri)
        else:
            r_lit = rasqal_new_string_literal(world, val.value, NULL, NULL, NULL)
    elif isinstance(val, BNode):
        r_lit = rasqal_new_simple_literal(world, RASQAL_LITERAL_BLANK, val)
    return r_lit

#-----------------------------------------------------------------------------------------------------------------------
#
# related sequences
#
#-----------------------------------------------------------------------------------------------------------------------
cdef inline Sequence new_QueryVarSequence(rasqal_query* query, raptor_sequence* sequence):
    cdef Sequence seq = QueryVarSequence()
    seq._rquery = query
    seq._rsequence = sequence
    return seq

cdef class QueryVarSequence(Sequence):
    cdef __item__(self, void* seq_item):
        return new_QueryVar(<rasqal_variable*>seq_item)



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

    cpdef set_value(self, val, world):
        if not isinstance(world, RasqalWorld):
            raise ValueError('world must be a RasqalWorld')
        cdef rasqal_world* _world = (<RasqalWorld>world)._rworld
        cdef rasqal_literal* _literal = create_rasqal_literal(_world, val) if val else NULL
        self.bind(_literal)

    cpdef get_value(self, to_python=True):
        cdef QueryLiteral _lit = new_QueryLiteral(self._rvariable.value) if self._rvariable.value != NULL else None
        return _lit.to_python() if to_python and _lit else _lit

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
        if not other:
            return False
        hashvalue_other = hash(other)
        hash_self = self.__hash__()

        if op == 0: # <
            return hash_self < hashvalue_other
        elif op == 2: #==
            return hash_self == hashvalue_other
        elif op == 4: # >
            return hash_self > hashvalue_other
        elif op == 1: # <=
            return hash_self <= hashvalue_other
        elif op == 3: # !=
            return hash_self != hashvalue_other
        elif op == 5: # >=
            return hash_self >= hashvalue_other

    def __hash__(self):
        if self._hashvalue == 0:
            self._hashvalue = hash(self.name)
        return self._hashvalue
