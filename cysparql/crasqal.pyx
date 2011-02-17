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


#-----------------------------------------------------------------------------------------------------------------------
# QUERY LITERAL
#-----------------------------------------------------------------------------------------------------------------------
cdef class Literal:
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
        return Literal(<object>node) if node != NULL else None

    def __str__(self):
        return self.as_str()

    property value:
        def __get__(self):
            if self.l.type == RASQAL_LITERAL_URI or self.l.type == RASQAL_LITERAL_BLANK:
                return rasqal_literal_as_string(self.l)
            elif self.l.type == RASQAL_LITERAL_INTEGER:
                return self.l.value.integer
            elif self.l.type == RASQAL_LITERAL_FLOAT or self.l.type == RASQAL_LITERAL_DOUBLE:
                return self.l.value.floating
            elif self.l.type == RASQAL_LITERAL_VARIABLE:
                return Variable(<object>self.l.value.variable)
            return None
            
    cpdef debug(self):
        rasqal_literal_print(<rasqal_literal*>self.l, stdout)


#-----------------------------------------------------------------------------------------------------------------------
# VARIABLE
#-----------------------------------------------------------------------------------------------------------------------
cdef class Variable:
    cdef rasqal_variable* var
    cdef bint __resolved__

    def __cinit__(self, var):
        self.var = <rasqal_variable*>var
        self.__resolved__ = False

    property name:
        def __get__(self):
            return self.var.name if self.var.name != NULL else None

    property offset:
        def __get__(self):
            return self.var.offset

    property value:
        def __get__(self):
            return Literal(<object>self.var.value) if self.var.value != NULL else None

    cpdef debug(self):
        rasqal_variable_print(<rasqal_variable*>self.var, stdout)

    def __str__(self):
        return '(VAR %s, %s)'%(self.name, bool(self.__resolved__))

    property resolved:
        def __get__(self):
            return self.__resolved__

        def __set__(self, v):
            self.__resolved__ = v


#-----------------------------------------------------------------------------------------------------------------------
# TRIPLE
#-----------------------------------------------------------------------------------------------------------------------
cdef class Triple:
    cdef rasqal_triple* t

    def __cinit__(self, t):
        self.t = <rasqal_triple*>t

    property s:
        def __get__(self):
            return Literal(<object>self.t.subject) if self.t.subject != NULL else None

    property p:
        def __get__(self):
            return Literal(<object>self.t.predicate) if self.t.predicate != NULL else None

    property o:
        def __get__(self):
            return Literal(<object>self.t.object) if self.t.object != NULL else None

    property origin:
        def __get__(self):
            return Literal(<object>self.t.origin) if self.t.origin != NULL else None

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
        else:
            raise IndexError('index must be, 0,1 or 2 corresponding to S, P or O')

    def __str__(self):
        return '[%s, %s, %s]'%(str(self.s.value),str(self.p.value),str(self.o.value))



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
cdef class AllVarsIterator:
    cdef rasqal_query* rq
    cdef int __idx__

    def __cinit__(self, rq):
        self.rq = <rasqal_query*>rq
        self.__idx__ = 0

    def __iter__(self):
        self.__idx__ = 0
        return self

    cdef inline raptor_sequence* __vars_seq__(self):
        return rasqal_query_get_all_variable_sequence(self.rq)

    def __next__(self):
        cdef raptor_sequence* vs =  self.__vars_seq__()
        cdef int sz = 0
        if vs != NULL:
            sz = raptor_sequence_size(vs)
            if self.__idx__ == sz:
                raise StopIteration
            else:
                item = Variable(<object>raptor_sequence_get_at(vs, self.__idx__))
                self.__idx__ += 1
                return item
        else:
            raise StopIteration

cdef class BoundVarsIterator(AllVarsIterator):
    cdef inline raptor_sequence* __vars_seq__(self):
        return rasqal_query_get_bound_variable_sequence(self.rq)


cdef class BindingsVarsIterator(AllVarsIterator):
    cdef inline raptor_sequence* __vars_seq__(self):
        return rasqal_query_get_bindings_variables_sequence(self.rq)
        

cdef class Query:
    cdef rasqal_world* w
    cdef rasqal_query* rq
    cdef int __idx__

    def __cinit__(self):
        self.w  = rasqal_new_world()
        self.__idx__ = 0

    def __init__(self, query):
        self.rq = rasqal_new_query(self.w, "sparql", NULL)
        rasqal_query_prepare(self.rq, <unsigned char*>query, NULL)

    def __dealloc__(self):
        rasqal_free_world(self.w)
        rasqal_free_query(self.rq)

    cpdef debug(self):
        rasqal_query_print(self.rq, stdout)

    property vars:
        def __get__(self):
            return AllVarsIterator(<object>self.rq)

    property bound_vars:
        def __get__(self):
            return BoundVarsIterator(<object>self.rq)

    property projections:
        def __get__(self):
            return BoundVarsIterator(<object>self.rq)

    property binding_vars:
        def __get__(self):
            return BindingsVarsIterator(<object>self.rq)

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

    def __iter__(self):
        self.__idx__ = 0
        return self

    def __next__(self):
        cdef raptor_sequence* ts =  rasqal_query_get_triple_sequence(self.rq)
        cdef int sz = 0
        if ts != NULL:
            sz = raptor_sequence_size(ts)
            if self.__idx__ == sz:
                raise StopIteration
            else:
                item = GraphPattern(<object>self.rq, <object>rasqal_query_get_graph_pattern(self.rq, self.__idx__))
                self.__idx__ += 1
                return item
        else:
            raise StopIteration

    property triples:
        def __get__(self):
            cdef raptor_sequence* ts =  rasqal_query_get_triple_sequence(self.rq)
            cdef int sz = 0
            if ts != NULL:
                sz = raptor_sequence_size(ts)
                return [Triple(<object>rasqal_query_get_triple(self.rq, i)) for i in xrange(sz)]
            return []
