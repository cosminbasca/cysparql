# CYTHON
from cython cimport *
from cpython cimport *
from libc.stdio cimport *
from libc.stdlib cimport *
from .rasqal cimport *

__author__ = 'Cosmin Basca'
__email__ = 'basca@ifi.uzh.ch; cosmin.basca@gmail.com'

#-----------------------------------------------------------------------------------------------------------------------
# Enums - CONSTANTS
#-----------------------------------------------------------------------------------------------------------------------
ctypedef public enum Selectivity:
    SELECTIVITY_UNDEFINED = -2
    SELECTIVITY_ALL_TRIPLES = -1
    SELECTIVITY_NO_TRIPLES = 0

ctypedef public enum TPatternType:
    TYPE_0_BOUND = 0
    TYPE_1_BOUND = 1
    TYPE_2_UNBOUND = 2
    TYPE_3_UNBOUND = 3

ctypedef public enum GraphPatternOperator:
    OPERATOR_UNKNOWN = RASQAL_GRAPH_PATTERN_OPERATOR_UNKNOWN
    OPERATOR_BASIC = RASQAL_GRAPH_PATTERN_OPERATOR_BASIC
    OPERATOR_OPTIONAL = RASQAL_GRAPH_PATTERN_OPERATOR_OPTIONAL
    OPERATOR_UNION = RASQAL_GRAPH_PATTERN_OPERATOR_UNION
    OPERATOR_GROUP = RASQAL_GRAPH_PATTERN_OPERATOR_GROUP
    OPERATOR_GRAPH = RASQAL_GRAPH_PATTERN_OPERATOR_GRAPH
    OPERATOR_FILTER = RASQAL_GRAPH_PATTERN_OPERATOR_FILTER
    OPERATOR_LET = RASQAL_GRAPH_PATTERN_OPERATOR_LET
    OPERATOR_SELECT = RASQAL_GRAPH_PATTERN_OPERATOR_SELECT
    OPERATOR_SERVICE = RASQAL_GRAPH_PATTERN_OPERATOR_SERVICE
    OPERATOR_MINUS = RASQAL_GRAPH_PATTERN_OPERATOR_MINUS
    OPERATOR_LAST = RASQAL_GRAPH_PATTERN_OPERATOR_LAST

ctypedef public enum FilterExpressionOperator:
    FLT_OPERATOR_EXPR_UNKNOWN = RASQAL_EXPR_UNKNOWN
    FLT_OPERATOR_EXPR_AND = RASQAL_EXPR_AND
    FLT_OPERATOR_EXPR_OR = RASQAL_EXPR_OR
    FLT_OPERATOR_EXPR_EQ = RASQAL_EXPR_EQ
    FLT_OPERATOR_EXPR_NEQ = RASQAL_EXPR_NEQ
    FLT_OPERATOR_EXPR_LT = RASQAL_EXPR_LT
    FLT_OPERATOR_EXPR_GT = RASQAL_EXPR_GT
    FLT_OPERATOR_EXPR_LE = RASQAL_EXPR_LE
    FLT_OPERATOR_EXPR_GE = RASQAL_EXPR_GE
    FLT_OPERATOR_EXPR_UMINUS = RASQAL_EXPR_UMINUS
    FLT_OPERATOR_EXPR_PLUS = RASQAL_EXPR_PLUS
    FLT_OPERATOR_EXPR_MINUS = RASQAL_EXPR_MINUS
    FLT_OPERATOR_EXPR_STAR = RASQAL_EXPR_STAR
    FLT_OPERATOR_EXPR_SLASH = RASQAL_EXPR_SLASH
    FLT_OPERATOR_EXPR_REM = RASQAL_EXPR_REM
    FLT_OPERATOR_EXPR_STR_EQ = RASQAL_EXPR_STR_EQ
    FLT_OPERATOR_EXPR_STR_NEQ = RASQAL_EXPR_STR_NEQ
    FLT_OPERATOR_EXPR_STR_MATCH = RASQAL_EXPR_STR_MATCH
    FLT_OPERATOR_EXPR_STR_NMATCH = RASQAL_EXPR_STR_NMATCH
    FLT_OPERATOR_EXPR_TILDE = RASQAL_EXPR_TILDE
    FLT_OPERATOR_EXPR_BANG = RASQAL_EXPR_BANG
    FLT_OPERATOR_EXPR_LITERAL = RASQAL_EXPR_LITERAL
    FLT_OPERATOR_EXPR_FUNCTION = RASQAL_EXPR_FUNCTION
    FLT_OPERATOR_EXPR_BOUND = RASQAL_EXPR_BOUND
    FLT_OPERATOR_EXPR_STR = RASQAL_EXPR_STR
    FLT_OPERATOR_EXPR_LANG = RASQAL_EXPR_LANG
    FLT_OPERATOR_EXPR_DATATYPE = RASQAL_EXPR_DATATYPE
    FLT_OPERATOR_EXPR_ISURI = RASQAL_EXPR_ISURI
    FLT_OPERATOR_EXPR_ISBLANK = RASQAL_EXPR_ISBLANK
    FLT_OPERATOR_EXPR_ISLITERAL = RASQAL_EXPR_ISLITERAL
    FLT_OPERATOR_EXPR_CAST = RASQAL_EXPR_CAST
    FLT_OPERATOR_EXPR_ORDER_COND_ASC = RASQAL_EXPR_ORDER_COND_ASC
    FLT_OPERATOR_EXPR_ORDER_COND_DESC = RASQAL_EXPR_ORDER_COND_DESC
    FLT_OPERATOR_EXPR_LANGMATCHES = RASQAL_EXPR_LANGMATCHES
    FLT_OPERATOR_EXPR_REGEX = RASQAL_EXPR_REGEX
    FLT_OPERATOR_EXPR_GROUP_COND_ASC = RASQAL_EXPR_GROUP_COND_ASC
    FLT_OPERATOR_EXPR_GROUP_COND_DESC = RASQAL_EXPR_GROUP_COND_DESC
    FLT_OPERATOR_EXPR_COUNT = RASQAL_EXPR_COUNT
    FLT_OPERATOR_EXPR_VARSTAR = RASQAL_EXPR_VARSTAR
    FLT_OPERATOR_EXPR_SAMETERM = RASQAL_EXPR_SAMETERM
    FLT_OPERATOR_EXPR_SUM = RASQAL_EXPR_SUM
    FLT_OPERATOR_EXPR_AVG = RASQAL_EXPR_AVG
    FLT_OPERATOR_EXPR_MIN = RASQAL_EXPR_MIN
    FLT_OPERATOR_EXPR_MAX = RASQAL_EXPR_MAX
    FLT_OPERATOR_EXPR_COALESCE = RASQAL_EXPR_COALESCE
    FLT_OPERATOR_EXPR_IF = RASQAL_EXPR_IF
    FLT_OPERATOR_EXPR_URI = RASQAL_EXPR_URI
    FLT_OPERATOR_EXPR_IRI = RASQAL_EXPR_IRI
    FLT_OPERATOR_EXPR_STRLANG = RASQAL_EXPR_STRLANG
    FLT_OPERATOR_EXPR_STRDT = RASQAL_EXPR_STRDT
    FLT_OPERATOR_EXPR_BNODE = RASQAL_EXPR_BNODE
    FLT_OPERATOR_EXPR_GROUP_CONCAT = RASQAL_EXPR_GROUP_CONCAT
    FLT_OPERATOR_EXPR_SAMPLE = RASQAL_EXPR_SAMPLE
    FLT_OPERATOR_EXPR_IN = RASQAL_EXPR_IN
    FLT_OPERATOR_EXPR_NOT_IN = RASQAL_EXPR_NOT_IN
    FLT_OPERATOR_EXPR_ISNUMERIC = RASQAL_EXPR_ISNUMERIC
    FLT_OPERATOR_EXPR_YEAR = RASQAL_EXPR_YEAR
    FLT_OPERATOR_EXPR_MONTH = RASQAL_EXPR_MONTH
    FLT_OPERATOR_EXPR_DAY = RASQAL_EXPR_DAY
    FLT_OPERATOR_EXPR_HOURS = RASQAL_EXPR_HOURS
    FLT_OPERATOR_EXPR_MINUTES = RASQAL_EXPR_MINUTES
    FLT_OPERATOR_EXPR_SECONDS = RASQAL_EXPR_SECONDS
    FLT_OPERATOR_EXPR_TIMEZONE = RASQAL_EXPR_TIMEZONE
    FLT_OPERATOR_EXPR_CURRENT_DATETIME = RASQAL_EXPR_CURRENT_DATETIME
    FLT_OPERATOR_EXPR_NOW = RASQAL_EXPR_NOW
    FLT_OPERATOR_EXPR_FROM_UNIXTIME = RASQAL_EXPR_FROM_UNIXTIME
    FLT_OPERATOR_EXPR_TO_UNIXTIME = RASQAL_EXPR_TO_UNIXTIME
    FLT_OPERATOR_EXPR_CONCAT = RASQAL_EXPR_CONCAT
    FLT_OPERATOR_EXPR_STRLEN = RASQAL_EXPR_STRLEN
    FLT_OPERATOR_EXPR_SUBSTR = RASQAL_EXPR_SUBSTR
    FLT_OPERATOR_EXPR_UCASE = RASQAL_EXPR_UCASE
    FLT_OPERATOR_EXPR_LCASE = RASQAL_EXPR_LCASE
    FLT_OPERATOR_EXPR_STRSTARTS = RASQAL_EXPR_STRSTARTS
    FLT_OPERATOR_EXPR_STRENDS = RASQAL_EXPR_STRENDS
    FLT_OPERATOR_EXPR_CONTAINS = RASQAL_EXPR_CONTAINS
    FLT_OPERATOR_EXPR_ENCODE_FOR_URI = RASQAL_EXPR_ENCODE_FOR_URI
#    FLT_OPERATOR_EXPR_TZ = RASQAL_EXPR_TZ
#    FLT_OPERATOR_EXPR_RAND = RASQAL_EXPR_RAND
#    FLT_OPERATOR_EXPR_ABS = RASQAL_EXPR_ABS
#    FLT_OPERATOR_EXPR_ROUND = RASQAL_EXPR_ROUND
#    FLT_OPERATOR_EXPR_CEIL = RASQAL_EXPR_CEIL
#    FLT_OPERATOR_EXPR_FLOOR = RASQAL_EXPR_FLOOR

#-----------------------------------------------------------------------------------------------------------------------
# Iterators (directly on rasqal sequences)
#-----------------------------------------------------------------------------------------------------------------------
cdef uri_to_str(raptor_uri* u)

cdef class SequenceIterator:
    cdef rasqal_query*      rq
    cdef void*              data
    cdef int                __idx__

    cdef raptor_sequence* __seq__(self)
    cdef object __item__(self, void* itm)

cdef class AllVarsIterator(SequenceIterator):
    cdef raptor_sequence* __seq__(self)

cdef class BoundVarsIterator(SequenceIterator):
    cdef raptor_sequence* __seq__(self)

cdef class BindingsVarsIterator(SequenceIterator):
    cdef raptor_sequence* __seq__(self)

cdef class QueryTripleIterator(SequenceIterator):
    cdef raptor_sequence* __seq__(self)

cdef class GraphPatternIterator(SequenceIterator):
    cdef raptor_sequence* __seq__(self)

#-----------------------------------------------------------------------------------------------------------------------
# RASQAL WORLD
#-----------------------------------------------------------------------------------------------------------------------
cdef class RasqalWorld:
    cdef rasqal_world* rw

#-----------------------------------------------------------------------------------------------------------------------
# QUERY LITERAL
#-----------------------------------------------------------------------------------------------------------------------
cdef class QueryLiteral:
    cdef rasqal_literal* l

    cpdef is_rdf_literal(self)
    cpdef as_var(self)
    cpdef as_str(self)
    cpdef as_node(self)
    cpdef debug(self)
    cpdef object value(self)

cdef QueryLiteral new_queryliteral(rasqal_literal* l)
cdef QueryLiteral copy_queryliteral(QueryLiteral ql)

#-----------------------------------------------------------------------------------------------------------------------
# VARIABLE
#-----------------------------------------------------------------------------------------------------------------------
cdef class QueryVar:
    cdef rasqal_variable* var
    cdef long __hashvalue__
    cdef long __vid__

    cpdef debug(self)
    cpdef is_not_selective(self)
    cpdef is_all_selective(self)
    cpdef is_undefined_selective(self)

cdef QueryVar new_queryvar(rasqal_variable* var)
cdef QueryVar copy_queryvar(QueryVar var)

#-----------------------------------------------------------------------------------------------------------------------
# FILTER Expression
#-----------------------------------------------------------------------------------------------------------------------
cdef class Filter:
    cdef rasqal_expression* expression
    cdef public FilterExpressionOperator filter_operator
    cdef public QueryLiteral literal
    cdef public bytes value
    cdef public bytes name
    cdef public list args
    cdef public list params

    cpdef debug(self)

cdef Filter new_filter(rasqal_expression* expr)

#-----------------------------------------------------------------------------------------------------------------------
# TRIPLE
#-----------------------------------------------------------------------------------------------------------------------
cdef class TriplePattern:
    cdef rasqal_triple*       t
    cdef int                    __idx__
    cdef public QueryLiteral    s_qliteral
    cdef public QueryLiteral    p_qliteral
    cdef public QueryLiteral    o_qliteral
    cdef public QueryLiteral    c_qliteral
    cdef public object          s
    cdef public object          p
    cdef public object          o
    cdef public object          c

    cpdef debug(self)
    cdef int pattern_type(self)

cdef TriplePattern new_triplepattern(rasqal_triple* t)
cdef TriplePattern copy_triplepattern(TriplePattern triple)

#-----------------------------------------------------------------------------------------------------------------------
# PREFIX
#-----------------------------------------------------------------------------------------------------------------------
cdef class Prefix:
    cdef rasqal_prefix*        p

    cpdef debug(self)

#-----------------------------------------------------------------------------------------------------------------------
# GRAPH PATERN
#-----------------------------------------------------------------------------------------------------------------------
cdef class GraphPattern:
    cdef rasqal_graph_pattern*  gp
    cdef rasqal_query*          rq
    cdef int                    __idx__
    cdef public list            triple_patterns
    cdef public list            sub_graph_patterns
    cdef public list            flattened_triple_patterns
    cdef public QueryLiteral    origin
    cdef public QueryLiteral    service
    cdef public QueryVar        variable
    cdef public Filter          filter

    cpdef debug(self)
    cpdef bint is_optional(self)
    cpdef bint is_basic(self)
    cpdef bint is_union(self)
    cpdef bint is_group(self)
    cpdef bint is_graph(self)
    cpdef bint is_filter(self)
    cpdef bint is_service(self)

cdef GraphPattern new_graphpattern(rasqal_query* rq, rasqal_graph_pattern* gp)

#-----------------------------------------------------------------------------------------------------------------------
# SEQUENCE
#-----------------------------------------------------------------------------------------------------------------------
cdef class Sequence:
    cdef raptor_sequence*       sq
    cdef int                    __idx__

    cpdef debug(self)

#-----------------------------------------------------------------------------------------------------------------------
#--- QUERY - KEEPS STATE (all are copies)
#-----------------------------------------------------------------------------------------------------------------------
cdef class Query:
    cdef RasqalWorld            w
    cdef rasqal_query*          rq
    cdef int                    __idx__
    cdef public list            vars
    cdef public list            bound_vars
    cdef public list            projections
    cdef public list            binding_vars
    cdef public list            prefixes
    cdef public list            triple_patterns
    cdef public GraphPattern    query_graph_pattern
    cdef public list            graph_patterns

    cpdef debug(self)
    cpdef get_bindings_var(self, i)
    cpdef get_var(self, i)
    cpdef has_var(self, char* name)
    cpdef get_triple(self, i)
    cpdef get_prefix(self, i)
    
cpdef Query new_query(char* query, RasqalWorld world)