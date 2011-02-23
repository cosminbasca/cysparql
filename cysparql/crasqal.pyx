from crasqal cimport *
from cython cimport *
from cpython cimport *
from libc.stdio cimport *
from libc.stdlib cimport *
import os
import sys

__author__ = 'Cosmin Basca'
__email__ = 'basca@ifi.uzh.ch; cosmin.basca@gmail.com'

cpdef get_q():
    return Query('''
SELECT ?title_other ?title ?author
WHERE {
        ?paper <http://www.aktors.org/ontology/portal#has-title> ?title .
        ?paper <http://www.aktors.org/ontology/portal#has-author> ?author .
        ?paper <http://www.aktors.org/ontology/portal#article-of-journal> ?journal .
        ?paper <http://www.aktors.org/ontology/portal#has-date> <http://www.aktors.org/ontology/date#2009> .
        ?paper_other <http://www.aktors.org/ontology/portal#article-of-journal> ?journal .
        ?paper_other <http://www.aktors.org/ontology/portal#has-title> ?title_other .
} LIMIT 100
    ''')

cpdef get_q2():
    return Query('''
SELECT ?seed ?modified ?common_taxon
WHERE {
        ?cluster <http://www.w3.org/2000/01/rdf-schema#label> ?label .
        ?cluster <http://purl.uniprot.org/core/member> ?member .
        ?member <http://purl.uniprot.org/core/seedFor> ?seed .
        ?seed <http://purl.uniprot.org/core/modified> ?modified .
        ?cluster <http://purl.uniprot.org/core/commonTaxon> ?common_taxon .
        ?cluster <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.uniprot.org/core/Cluster> .
} LIMIT 100
    ''')


def benchmark_query(debug=False):
    q = get_q()
    if debug: q.debug()

def benchmark(nr=1000):
    from timeit import Timer
    t = Timer('benchmark_query(debug=False)','from crasqal import benchmark_query')
    total_secs = t.timeit(number=nr)
    print 'Query parsing took %s ms, with a total %s seconds for %s runs.'%(str(1000 * total_secs/nr), str(total_secs), str(nr))

#-----------------------------------------------------------------------------------------------------------------------
# other types
#-----------------------------------------------------------------------------------------------------------------------
cdef inline uri_to_str(raptor_uri* u):
    return raptor_uri_as_string(u) if u != NULL else None

cdef class SequenceItemType:
    pass

cdef class SequenceIterator:
    cdef rasqal_query* rq
    cdef void* data
    cdef int __idx__

    def __cinit__(self, rq, data):
        self.rq = <rasqal_query*>rq
        self.__idx__ = 0
        self.data = NULL if data is None else <void*>data
        
    def __iter__(self):
        self.__idx__ = 0
        return self

    cdef inline raptor_sequence* __seq__(self):
        return NULL

    def __item__(self, seq_item):
        return SequenceItemType()

    def __next__(self):
        cdef raptor_sequence* seq =  self.__seq__()
        cdef int sz = 0
        if seq != NULL:
            sz = raptor_sequence_size(seq)
            if self.__idx__ == sz:
                raise StopIteration
            else:
                item = self.__item__(<object>raptor_sequence_get_at(seq, self.__idx__))
                self.__idx__ += 1
                return item
        else:
            raise StopIteration


#-----------------------------------------------------------------------------------------------------------------------
# RDF TYPES
#-----------------------------------------------------------------------------------------------------------------------
cdef class IdContainer:
    cdef long __numid__
    cdef bytes __hashid__

    def __cinit__(self):
        self.__numid__ = 0
        self.__hashid__ = None

    property numeric_id:
        def __get__(self):
            return self.__numid__

        def __set__(self, v):
            self.__numid__ = <long>v

    property hash_id:
        def __get__(self):
            return self.__hashid__

        def __set__(self, v):
            self.__hashid__ = v

cdef class Term(IdContainer):
    def __val__(self):
        return None

    property value:
        def __get__(self):
            return self.__val__()

    def n3(self):
        return ''

    
cdef class Uri(Term):
    cdef bytes __uri__

    def __cinit__(self, u):
        self.__uri__ = u

    def __val__(self):
        return self.__uri__

    def n3(self):
        return '<%s>'%self.__uri__

    property uri:
        def __get__(self):
            return self.__uri__


cdef class BNode(Uri):
    def n3(self):
        return '_:%s'%<str>self.uri

    property id:
        def __get__(self):
            return <str>self.uri


cdef class Literal(Term):
    cdef bytes val
    cdef bytes lang
    cdef Uri dtype
    
    def __cinit__(self, val, lang, dtype):
        self.val = val
        if dtype:
            self.lang = None
            self.dtype = dtype if type(dtype) is Uri else Uri(dtype)
        else:
            self.dtype = None
            self.lang = lang if lang else None

    property lang:
        def __get__(self):
            return self.lang if self.lang is not None else None

    property datatype:
        def __get__(self):
            return self.dtype

    def __val__(self):
        return self.val

    def n3(self):
        repr = '%s'%self.val
        if self.lang is not None:
            repr += '@%s'%self.lang
        elif self.dtype:
            repr += '^^%s'%self.dtype.n3()
        return repr

#-----------------------------------------------------------------------------------------------------------------------
# QUERY LITERAL
#-----------------------------------------------------------------------------------------------------------------------
cdef class QueryLiteral:
    cdef rasqal_literal* l

    def __cinit__(self, l):
        self.l = <rasqal_literal*>l
    
    property language:
        def __get__(self):
            return self.l.language if self.l.language != NULL else None

    property datatype:
        def __get__(self):
            return uri_to_str(self.l.datatype) if self.l.datatype != NULL else None

    property type:
        def __get__(self):
            return self.l.type

    property type_label:
        def __get__(self):
            return rasqal_literal_type_label(self.l.type)

    cpdef is_rdf_literal(self):
        return True if rasqal_literal_is_rdf_literal(self.l) > 0 else False

    cpdef as_var(self):
        cdef rasqal_variable* var = rasqal_literal_as_variable(self.l)
        return Variable(<object>var) if var != NULL else None

    cpdef as_str(self):
        if self.l.type == RASQAL_LITERAL_URI or self.l.type == RASQAL_LITERAL_BLANK:
            return rasqal_literal_as_string(self.l)
        elif self.l.type == RASQAL_LITERAL_VARIABLE:
            return self.l.value.variable.name if self.l.value.variable.name != NULL else ''
        return ''

    cpdef as_node(self):
        cdef rasqal_literal* node = rasqal_literal_as_node(self.l)
        return QueryLiteral(<object>node) if node != NULL else None

    def __str__(self):
        return self.as_str()

    property value:
        def __get__(self):
            if self.l.type == RASQAL_LITERAL_URI:
                #return rasqal_literal_as_string(self.l)
                return Uri(rasqal_literal_as_string(self.l))
            elif self.l.type == RASQAL_LITERAL_BLANK:
                return BNode(rasqal_literal_as_string(self.l))
            elif self.l.type == RASQAL_LITERAL_STRING:
                return Literal(<object>self.l.string, None, None)
            #elif self.l.type == RASQAL_LITERAL_INTEGER:
            #    return self.l.value.integer
            #elif self.l.type == RASQAL_LITERAL_FLOAT or self.l.type == RASQAL_LITERAL_DOUBLE:
            #    return self.l.value.floating
            elif self.l.type == RASQAL_LITERAL_VARIABLE:
                return Variable(<object>self.l.value.variable)
            return None
            
    cpdef debug(self):
        rasqal_literal_print(<rasqal_literal*>self.l, stdout)

#-----------------------------------------------------------------------------------------------------------------------
# VARIABLE
#-----------------------------------------------------------------------------------------------------------------------
ctypedef public enum Selectivity:
    SELECTIVITY_UNDEFINED = -2
    SELECTIVITY_ALL_TRIPLES = -1
    SELECTIVITY_NO_TRIPLES = 0

cdef class Variable(IdContainer):
    cdef rasqal_variable* var
    cdef bint __resolved__
    cdef long __sel__

    def __cinit__(self, var):
        self.var = <rasqal_variable*>var
        self.__resolved__ = False
        self.__sel__ = -2
        self.__id__.numid = 0 # ids should be != 0 for vars

    property name:
        def __get__(self):
            return self.var.name if self.var.name != NULL else None

    property offset:
        def __get__(self):
            return self.var.offset

    property value:
        def __get__(self):
            return QueryLiteral(<object>self.var.value) if self.var.value != NULL else None

    cpdef debug(self):
        rasqal_variable_print(<rasqal_variable*>self.var, stdout)

    def __str__(self):
        return '(VAR %s, resolved=%s, selectivity=%s, id=%s)'%(self.name, bool(self.__resolved__), str(self.__sel__), str(self.__id__.numid))

    property resolved:
        def __get__(self):
            return self.__resolved__

        def __set__(self, v):
            self.__resolved__ = v

    property selectivity:
        def __get__(self):
            return self.__sel__

        def __set__(self, v):
            self.__sel__ = <long>v

    def n3(self):
        # not really valid N3
        return '?%s'%<str>self.var.name

    cpdef is_not_selective(self):
        return True if self.__sel__ == SELECTIVITY_NO_TRIPLES else False

    cpdef is_all_selective(self):
        return True if self.__sel__ == SELECTIVITY_ALL_TRIPLES else False

    cpdef is_undefined_selective(self):
        return True if self.__sel__ == SELECTIVITY_UNDEFINED else False

    property id:
        def __get__(self):
            return self.numeric_id

        def __set__(self,v):
            self.numeric_id = <long>v



#-----------------------------------------------------------------------------------------------------------------------
# TRIPLE
#-----------------------------------------------------------------------------------------------------------------------
cdef class Triple:
    cdef rasqal_triple* t
    cdef int __idx__

    def __cinit__(self, t):
        self.t = <rasqal_triple*>t
        self.__idx__ = 0

    property s:
        def __get__(self):
            return QueryLiteral(<object>self.t.subject) if self.t.subject != NULL else None

    property p:
        def __get__(self):
            return QueryLiteral(<object>self.t.predicate) if self.t.predicate != NULL else None

    property o:
        def __get__(self):
            return QueryLiteral(<object>self.t.object) if self.t.object != NULL else None

    property origin:
        def __get__(self):
            return QueryLiteral(<object>self.t.origin) if self.t.origin != NULL else None

    cpdef debug(self):
        rasqal_triple_print(<rasqal_triple*>self.t, stdout)

    def as_tuple(self):
        return (self.s.value, self.p.value, self.o.value)

    def __getitem__(self, i):
        if i == 0:
            return self.s.value
        elif i == 1:
            return self.p.value
        elif i == 2:
            return self.o.value
        elif i == 3:
            return self.origin.value if self.origin else None
        else:
            raise IndexError('index must be, 0,1,2 or 3 corresponding to S, P, O or ORIGIN')

    def __str__(self):
        return '< %s, %s, %s >'%(str(self.s.value),str(self.p.value),str(self.o.value))

    def __iter__(self):
        self.__idx__ = 0
        return self

    def __next__(self):
        if self.__idx__ == 4:
            raise StopIteration
        else:
            item = None
            if self.__idx__ == 0:
                item = <object>self.s.value
            elif self.__idx__ == 1:
                item = <object>self.p.value
            elif self.__idx__ == 2:
                item = <object>self.o.value
            elif self.__idx__ == 3:
                item = <object>self.origin.value if self.origin else None
            self.__idx__ += 1
            return item

    cdef inline __simple_selectivity_estimation__(self):
        return min([v.selectivity for v in self if type(v) is Variable])

    property selectivity:
        def __get__(self):
            return self.__simple_selectivity_estimation__()

    cpdef encode(self, sid, pid, oid, numeric=False):
        accesor = 'numeric_id' if numeric else 'hash_id'
        setattr(self.s.value, accesor, sid)
        setattr(self.p.value, accesor, pid)
        setattr(self.o.value, accesor, oid)



#-----------------------------------------------------------------------------------------------------------------------
# PREFIX
#-----------------------------------------------------------------------------------------------------------------------
cdef class Prefix:
    cdef rasqal_prefix* p

    def __cinit__(self, p):
        self.p = <rasqal_prefix*>p

    property prefix:
        def __get__(self):
            return self.p.prefix if self.p.prefix != NULL else ''

    property uri:
        def __get__(self):
            return uri_to_str(self.p.uri) if self.p.uri != NULL else None

    cpdef debug(self):
        rasqal_prefix_print(<rasqal_prefix*>self.p, stdout)

    def __str__(self):
        return '(%s : %s)'%(self.prefix, self.uri)

    
#-----------------------------------------------------------------------------------------------------------------------
# GRAPH PATERN
#-----------------------------------------------------------------------------------------------------------------------
cdef class GraphPatternIterator(SequenceIterator):
    cdef inline raptor_sequence* __seq__(self):
        return rasqal_graph_pattern_get_sub_graph_pattern_sequence(<rasqal_graph_pattern*>self.data)

    def __item__(self, seq_item):
        return GraphPattern(<object>self.rq, seq_item)

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

cdef class GraphPattern:
    cdef rasqal_graph_pattern* gp
    cdef rasqal_query* rq
    cdef int __idx__

    def __cinit__(self, rq, gp):
        self.gp = <rasqal_graph_pattern*>gp
        self.rq = <rasqal_query*>rq
        self.__idx__ = 0

    def __iter__(self):
        self.__idx__ = 0
        return self

    def __next__(self):
        cdef raptor_sequence* ts =  rasqal_graph_pattern_get_flattened_triples(self.rq, self.gp)
        cdef int sz = 0
        if ts != NULL:
            sz = raptor_sequence_size(ts)
            if self.__idx__ == sz:
                raise StopIteration
            else:
                item = Triple(<object>rasqal_graph_pattern_get_triple(self.gp, self.__idx__))
                self.__idx__ += 1
                return item
        else:
            raise StopIteration

    property triples:
        def __get__(self):
            cdef raptor_sequence* ts = rasqal_graph_pattern_get_flattened_triples(self.rq, self.gp)
            cdef int sz = 0
            if ts != NULL:
                sz = raptor_sequence_size(ts)
                return [Triple(<object>raptor_sequence_get_at(ts, i)) for i in xrange(sz)]
            return []

    property sub_graph_patterns:
        def __get__(self):
            return GraphPatternIterator(<object>self.rq, <object>self.gp)

    property operator:
        def __get__(self):
            return rasqal_graph_pattern_get_operator(self.gp)

    cpdef is_optional(self):
        return True if rasqal_graph_pattern_get_operator(self.gp) == RASQAL_GRAPH_PATTERN_OPERATOR_OPTIONAL else False

    cpdef is_basic(self):
        return True if rasqal_graph_pattern_get_operator(self.gp) == RASQAL_GRAPH_PATTERN_OPERATOR_BASIC else False

    cpdef is_union(self):
        return True if rasqal_graph_pattern_get_operator(self.gp) == RASQAL_GRAPH_PATTERN_OPERATOR_UNION else False

    cpdef is_group(self):
        return True if rasqal_graph_pattern_get_operator(self.gp) == RASQAL_GRAPH_PATTERN_OPERATOR_GROUP else False

    cpdef is_graph(self):
        return True if rasqal_graph_pattern_get_operator(self.gp) == RASQAL_GRAPH_PATTERN_OPERATOR_GRAPH else False

    cpdef is_filter(self):
        return True if rasqal_graph_pattern_get_operator(self.gp) == RASQAL_GRAPH_PATTERN_OPERATOR_FILTER else False

    cpdef is_service(self):
        return True if rasqal_graph_pattern_get_operator(self.gp) == RASQAL_GRAPH_PATTERN_OPERATOR_SERVICE else False

#-----------------------------------------------------------------------------------------------------------------------
# SEQUENCE
#-----------------------------------------------------------------------------------------------------------------------
cdef class Sequence:
    cdef raptor_sequence* sq
    cdef int __idx__

    def __cinit__(self, sq):
        self.sq = <raptor_sequence*>sq
        self.__idx__ = 0
        
    def __len__(self):
        return raptor_sequence_size(<raptor_sequence*>self.sq)

    def __setitem__(self, i, value):
        raptor_sequence_set_at(<raptor_sequence*>self.sq, i, <void*>value)

    def __delitem__(self, i):
        raptor_sequence_delete_at(<raptor_sequence*>self.sq, i)

    def __getitem__(self, i):
        return <object>raptor_sequence_get_at(<raptor_sequence*>self.sq, i)
        
    cpdef debug(self):
        raptor_sequence_print(<raptor_sequence*>self.sq, stdout)

    def __and__(self, other):
        raptor_sequence_join(<raptor_sequence*>self.sq, <raptor_sequence*>other)

    def shift(self, data):
        raptor_sequence_shift(<raptor_sequence*>self.sq, <void*>data)

    def unshift(self):
        return <object>raptor_sequence_unshift(<raptor_sequence*>self.sq)

    def pop(self):
        return <object>raptor_sequence_pop(<raptor_sequence*>self.sq)

    def push(self, data):
        raptor_sequence_push(<raptor_sequence*>self.sq, <void*>data)

    def __iter__(self):
        self.__idx__ = 0
        return self

    def __next__(self):
        if self.__idx__ == raptor_sequence_size(<raptor_sequence*>self.sq):
            raise StopIteration
        else:
            item = <object>raptor_sequence_get_at(<raptor_sequence*>self.sq, self.__idx__)
            self.__idx__ += 1
            return item


#-----------------------------------------------------------------------------------------------------------------------
# QUERY
#-----------------------------------------------------------------------------------------------------------------------
cdef class AllVarsIterator(SequenceIterator):
    cdef inline raptor_sequence* __seq__(self):
        return rasqal_query_get_all_variable_sequence(self.rq)

    def __item__(self, seq_item):
        return Variable(seq_item)


cdef class BoundVarsIterator(SequenceIterator):
    cdef inline raptor_sequence* __seq__(self):
        return rasqal_query_get_bound_variable_sequence(self.rq)

    def __item__(self, seq_item):
        return Variable(seq_item)


cdef class BindingsVarsIterator(SequenceIterator):
    cdef inline raptor_sequence* __seq__(self):
        return rasqal_query_get_bindings_variables_sequence(self.rq)

    def __item__(self, seq_item):
        return Variable(seq_item)


cdef class QueryTripleIterator(SequenceIterator):
    cdef inline raptor_sequence* __seq__(self):
        return rasqal_query_get_triple_sequence(self.rq)

    def __item__(self, seq_item):
        return Triple(seq_item)

cdef class RasqalWorld:
    cdef rasqal_world* rw

    def __cinit__(self):
        self.rw  = rasqal_new_world()

    def __dealloc__(self):
        rasqal_free_world(self.rw)

    def __str__(self):
        return '"RasqalWorld wrapper"'

cdef class Query:
    cdef RasqalWorld w
    cdef rasqal_query* rq
    cdef int __idx__
    
    def __cinit__(self, query, world=None):
        self.w  = RasqalWorld() if not world else world
        self.__idx__ = 0

    def __init__(self, query, world=None):
        self.rq = rasqal_new_query(self.w.rw, "sparql", NULL)
        rasqal_query_prepare(self.rq, <unsigned char*>query, NULL)

    def __dealloc__(self):
        rasqal_free_query(self.rq)

    cpdef debug(self):
        rasqal_query_print(self.rq, stdout)

    property vars:
        def __get__(self):
            return AllVarsIterator(<object>self.rq, None)
            
    property bound_vars:
        def __get__(self):
            return BoundVarsIterator(<object>self.rq, None)

    property projections:
        def __get__(self):
            return BoundVarsIterator(<object>self.rq, None)

    property binding_vars:
        def __get__(self):
            return BindingsVarsIterator(<object>self.rq, None)

    cpdef get_bindings_var(self, i):
        return Variable(<object>rasqal_query_get_bindings_variable(self.rq, i))

    cpdef get_var(self, i):
        return Variable(<object>rasqal_query_get_variable(self.rq, i))

    cpdef has_var(self, char* name):
        return True if rasqal_query_has_variable(self.rq, <unsigned char*>name) > 0 else False

    cpdef get_triple(self, i):
        return Triple(<object>rasqal_query_get_triple(self.rq, i))

    cpdef get_prefix(self, i):
        return Prefix(<object>rasqal_query_get_prefix(self.rq, i))

    property prefixes:
        def __get__(self):
            cdef raptor_sequence* ps =  rasqal_query_get_prefix_sequence(self.rq)
            cdef int sz = 0
            if ps != NULL:
                sz = raptor_sequence_size(ps)
                return [Prefix(<object>rasqal_query_get_prefix(self.rq, i)) for i in xrange(sz)]
            return []

    property graph_pattern:
        def __get__(self):
            return GraphPattern(<object>self.rq, <object>rasqal_query_get_query_graph_pattern(self.rq))

    property label:
        def __get__(self):
            return rasqal_query_get_label(self.rq)
    
    property limit:
        def __get__(self):
            return rasqal_query_get_limit(self.rq)
    
    property name:
        def __get__(self):
            return rasqal_query_get_name(self.rq)

    property offset:
        def __get__(self):
            return rasqal_query_get_offset(self.rq)

    property verb:
        def __get__(self):
            v = rasqal_query_get_verb(self.rq)
            if v == RASQAL_QUERY_VERB_UNKNOWN:
                return 'unknown'
            elif v == RASQAL_QUERY_VERB_SELECT:
                return 'select'
            elif v == RASQAL_QUERY_VERB_CONSTRUCT:
                return 'construct'
            elif v == RASQAL_QUERY_VERB_DESCRIBE:
                return 'describe'
            elif v == RASQAL_QUERY_VERB_ASK:
                return 'ask'
            elif v == RASQAL_QUERY_VERB_DELETE:
                return 'delete'
            elif v == RASQAL_QUERY_VERB_INSERT:
                return 'insert'
            elif v == RASQAL_QUERY_VERB_UPDATE:
                return 'update'

    def __getitem__(self, i):
        return Triple(<object>rasqal_query_get_triple(self.rq, i))

    def __iter__(self):
        return QueryTripleIterator(<object>self.rq, None)
    
    property triples:
        def __get__(self):
            cdef raptor_sequence* ts =  rasqal_query_get_triple_sequence(self.rq)
            cdef int sz = 0
            if ts != NULL:
                sz = raptor_sequence_size(ts)
                return [Triple(<object>rasqal_query_get_triple(self.rq, i)) for i in xrange(sz)]
            return []

    def __str__(self):
        return '\n'.join([ 'TRIPLE: %s, %s, %s'%(t[0].value.n3(), t[1].value.n3(), t[2].value.n3()) for t in self ])
