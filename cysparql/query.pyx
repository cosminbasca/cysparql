# CYTHON
from cython cimport *
from cpython cimport *
from libc.stdio cimport *
from libc.stdlib cimport *
from libc.string cimport *
# LOCAL
from rasqal cimport *
from raptor cimport *

from itertools import *
from rdflib.term import URIRef, Literal, BNode

__author__ = 'Cosmin Basca'
__email__ = 'basca@ifi.uzh.ch; cosmin.basca@gmail.com'

#-----------------------------------------------------------------------------------------------------------------------
# Iterators (directly on rasqal sequences)
#-----------------------------------------------------------------------------------------------------------------------
cdef inline uri_to_str(raptor_uri* u):
    return raptor_uri_as_string(u) if u != NULL else None

cdef class SequenceIterator:
    def __cinit__(self, rq, data):
        self.rq = <rasqal_query*>rq
        self.__idx__ = 0
        self.data = NULL if data is None else <void*>data

    def __iter__(self):
        self.__idx__ = 0
        return self

    cdef raptor_sequence* __seq__(self):
        return NULL

    cdef __item__(self, void* seq_item):
        return None

    def __next__(self):
        cdef raptor_sequence* seq   =  self.__seq__()
        cdef int sz                 = 0
        cdef void* _item            = NULL
        if seq != NULL:
            sz = raptor_sequence_size(seq)
            if self.__idx__ == sz:
                raise StopIteration
            else:
                _item = raptor_sequence_get_at(seq, self.__idx__)
                item = self.__item__(_item)
                self.__idx__ += 1
                return item
        else:
            raise StopIteration

cdef class AllVarsIterator(SequenceIterator):
    cdef raptor_sequence* __seq__(self):
        return rasqal_query_get_all_variable_sequence(self.rq)

    cdef __item__(self, void* seq_item):
        return new_queryvar(<rasqal_variable*>seq_item)


cdef class BoundVarsIterator(SequenceIterator):
    cdef raptor_sequence* __seq__(self):
        return rasqal_query_get_bound_variable_sequence(self.rq)

    cdef __item__(self, void* seq_item):
        return new_queryvar(<rasqal_variable*>seq_item)


cdef class BindingsVarsIterator(SequenceIterator):
    cdef raptor_sequence* __seq__(self):
        return rasqal_query_get_bindings_variables_sequence(self.rq)

    cdef __item__(self, void* seq_item):
        return new_queryvar(<rasqal_variable*>seq_item)


cdef class QueryTripleIterator(SequenceIterator):
    cdef raptor_sequence* __seq__(self):
        return rasqal_query_get_triple_sequence(self.rq)

    cdef __item__(self, void* seq_item):
        return new_triplepattern(<rasqal_triple*>seq_item)


cdef class GraphPatternIterator(SequenceIterator):
    cdef raptor_sequence* __seq__(self):
        return rasqal_graph_pattern_get_sub_graph_pattern_sequence(<rasqal_graph_pattern*>self.data)

    cdef __item__(self, void* seq_item):
        return new_graphpattern(<rasqal_query*>self.rq, <rasqal_graph_pattern*>seq_item)

#-----------------------------------------------------------------------------------------------------------------------
# RASQAL WORLD
#-----------------------------------------------------------------------------------------------------------------------
cdef class RasqalWorld:
    def __cinit__(self):
        self.rw  = rasqal_new_world()

    def __dealloc__(self):
        rasqal_free_world(self.rw)

    def __str__(self):
        return '"RasqalWorld wrapper"'

#-----------------------------------------------------------------------------------------------------------------------
# QUERY LITERAL
#-----------------------------------------------------------------------------------------------------------------------
cdef class QueryLiteral:
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
        return new_queryvar(var) if var != NULL else None

    cpdef as_str(self):
        if self.l.type == RASQAL_LITERAL_URI or self.l.type == RASQAL_LITERAL_BLANK:
            return <char*>rasqal_literal_as_string(self.l)
        elif self.l.type == RASQAL_LITERAL_VARIABLE:
            return self.l.value.variable.name if self.l.value.variable.name != NULL else ''
        return ''

    cpdef as_node(self):
        cdef rasqal_literal* node = rasqal_literal_as_node(self.l)
        return new_queryliteral(node) if node != NULL else None

    def __str__(self):
        return self.as_str()

    cpdef debug(self):
        rasqal_literal_print(<rasqal_literal*>self.l, stdout)

    cpdef object value(self):
        cdef bytes lbl = None
        if self.l.type == RASQAL_LITERAL_URI:
            lbl = <char*>rasqal_literal_as_string(self.l)
            return URIRef(lbl)
        elif self.l.type == RASQAL_LITERAL_BLANK:
            lbl = <char*>rasqal_literal_as_string(self.l)
            return BNode(lbl)
        elif self.l.type == RASQAL_LITERAL_STRING:
            lbl = <char*>self.l.string
            return Literal(lbl, lang=self.language, datatype=self.datatype)
        elif self.l.type == RASQAL_LITERAL_VARIABLE:
            return new_queryvar(self.l.value.variable)
        return None


cdef QueryLiteral new_queryliteral(rasqal_literal* l):
    cdef QueryLiteral ql = QueryLiteral.__new__(QueryLiteral)
    ql.l = l
    return ql
cdef QueryLiteral copy_queryliteral(QueryLiteral ql):
    cdef QueryLiteral copy = QueryLiteral.__new__(QueryLiteral)
    copy.l = ql.l
    return copy

#-----------------------------------------------------------------------------------------------------------------------
# VARIABLE
#-----------------------------------------------------------------------------------------------------------------------
cdef class QueryVar:
    property name:
        def __get__(self):
            return self.var.name if self.var.name != NULL else None

    property offset:
        def __get__(self):
            return self.var.offset

    property value:
        def __get__(self):
            return new_queryliteral(self.var.value) if self.var.value != NULL else None

    cpdef debug(self):
        rasqal_variable_print(<rasqal_variable*>self.var, stdout)

    def __str__(self):
        return self.n3()

    def __repr__(self):
        return 'QueryVar(%s,vid=%s)'%(self.name, str(self.__vid__))

    property resolved:
        def __get__(self):
            return self.__resolved__
        def __set__(self, r):
            self.__resolved__ = r

    property vid:
        def __get__(self):
            return self.__vid__
        def __set__(self, v):
            self.__vid__ = v

    def n3(self):
        return '?%s'%<str>self.var.name # not really valid N3

    cpdef is_not_selective(self):
        return True if self.__sel__ == SELECTIVITY_NO_TRIPLES else False

    cpdef is_all_selective(self):
        return True if self.__sel__ == SELECTIVITY_ALL_TRIPLES else False

    cpdef is_undefined_selective(self):
        return True if self.__sel__ == SELECTIVITY_UNDEFINED else False

    def __richcmp__(QueryVar self, object other, int op):
        if not other: return False
        cdef long lid1 = 0
        cdef long lid2 = 0
        cdef int cmpres = 0

        if type(other) is QueryVar:
            lid1 = self.__vid__
            lid2 = (<QueryVar>other).__vid__

            if op == 0: # <
                return lid1 < lid2
            elif op == 2: #==
                return lid1 == lid2
            elif op == 4: # >
                return lid1 > lid2
            elif op == 1: # <=
                return lid1 <= lid2
            elif op == 3: # !=
                return lid1 != lid2
            elif op == 5: # >=
                return lid1 >= lid2


    def __hash__(self):
        if self.__hashvalue__ == 0:
            self.__hashvalue__ = hash(self.name)
        return self.__hashvalue__


cdef QueryVar new_queryvar(rasqal_variable* var):
    cdef QueryVar v = QueryVar.__new__(QueryVar)
    v.var = var
    v.__vid__ = 0
    return v

cdef QueryVar copy_queryvar(QueryVar var):
    cdef QueryVar copy = QueryVar.__new__(QueryVar)
    copy.__pyid__ = var.__pyid__
    copy.var = var.var
    copy.vid = var.vid
    return copy
#-----------------------------------------------------------------------------------------------------------------------
# FILTER
#-----------------------------------------------------------------------------------------------------------------------
cdef class Filter:
    cpdef debug(self):
        rasqal_expression_print(<rasqal_expression*>self.expression, stdout)

    property operator_label:
        def __get__(self):
            return <bytes>rasqal_expression_op_label(self.expression.op)

cdef inline Filter new_filter(rasqal_expression* expr):
    cdef Filter f       = Filter.__new__(Filter)
    f.expression        = expr
    f.filter_operator   = <FilterExpressionOperator>expr.op
    f.literal           = new_queryliteral(expr.literal) if expr.literal != NULL else None
    f.value             = <bytes>expr.value if expr.value != NULL else None
    f.name              = uri_to_str(expr.name)
    # TODO: fill these lists !
    f.args              = list()
    f.params            = list()
    return f

#-----------------------------------------------------------------------------------------------------------------------
# TRIPLE
#-----------------------------------------------------------------------------------------------------------------------
cdef class TriplePattern:
    cpdef debug(self):
        rasqal_triple_print(<rasqal_triple*>self.t, stdout)

    def as_tuple(self):
        return self.s, self.p, self.o

    def __getitem__(self, i):
        if i == 0:
            return self.s
        elif i == 1:
            return self.p
        elif i == 2:
            return self.o
        elif i == 3:
            return self.c
        else:
            raise IndexError('index must be, 0,1,2 or 3 corresponding to S, P, O or ORIGIN')

    def __str__(self):
        return '< %s, %s, %s ,%s>'%(str(self.s), str(self.p), str(self.o), str(self.c))

    def __repr__(self):
        return self.__str__()

    def __len__(self):
        return 4

    def __iter__(self):
        self.__idx__ = 0
        return self

    def __next__(self):
        if self.__idx__ == 4:
            raise StopIteration
        else:
            item = None
            if self.__idx__ == 0:
                item = self.s
            elif self.__idx__ == 1:
                item = self.p
            elif self.__idx__ == 2:
                item = self.o
            elif self.__idx__ == 3:
                item = self.c
            self.__idx__ += 1
            return item

    def __contains__(self, item):
        if item == self.s:
            return True
        elif item == self.p:
            return True
        elif item == self.o:
            return True
        elif item == self.c:
            return True
        return False

    def n3(self, withvars=True):
        def __n3__(itm):
            if itm:
                return itm.n3() if type(itm) is not QueryVar or (type(itm) is QueryVar and withvars) else None
        return __n3__(self.s), __n3__(self.p), __n3__(self.o)

    cdef int pattern_type(self):
        cdef int ptype = 0
        if type(self.s) is QueryVar: ptype += 1
        if type(self.p) is QueryVar: ptype += 1
        if type(self.o) is QueryVar: ptype += 1
        return ptype

cdef TriplePattern new_triplepattern(rasqal_triple* t):
    cdef TriplePattern tp = TriplePattern.__new__(TriplePattern)
    tp.t        = t
    tp.__idx__  = 0
    tp.s_qliteral         = new_queryliteral(t.subject) if t.subject != NULL else None
    tp.s                  = tp.s_qliteral.value()
    tp.p_qliteral         = new_queryliteral(t.predicate) if t.predicate != NULL else None
    tp.p                  = tp.p_qliteral.value()
    tp.o_qliteral         = new_queryliteral(t.object) if t.object != NULL else None
    tp.o                  = tp.o_qliteral.value()
    tp.c_qliteral         = new_queryliteral(t.origin) if t.origin != NULL else None
    tp.c                  = tp.c_qliteral.value() if tp.c_qliteral else None
    return tp

cdef TriplePattern copy_triplepattern(TriplePattern triple):
    cdef TriplePattern copy = TriplePattern.__new__(TriplePattern)
    copy.t        = triple.t
    copy.__idx__  = triple.__idx__
    copy.s_qliteral         = triple.s_qliteral
    if type(triple.s) is QueryVar:
        copy.s = copy_queryvar(triple.s)
    else:
        copy.s                  = triple.s
    copy.p_qliteral         = triple.p_qliteral
    if type(triple.p) is QueryVar:
        copy.p = copy_queryvar(triple.p)
    else:
        copy.p                  = triple.p
    copy.o_qliteral         = triple.o_qliteral
    if type(triple.o) is QueryVar:
        copy.o = copy_queryvar(triple.o)
    else:
        copy.o                  = triple.o
    copy.c_qliteral         = triple.c_qliteral
    if type(triple.c) is QueryVar:
        copy.c = copy_queryvar(triple.c)
    else:
        copy.c                  = triple.c
    return copy

#-----------------------------------------------------------------------------------------------------------------------
# PREFIX
#-----------------------------------------------------------------------------------------------------------------------
cdef class Prefix:
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
    def __iter__(self):
        return iter(self.triple_patterns)

    def __next__(self):
        if self.__idx__ == len(self.triple_patterns):
            raise StopIteration
        else:
            item = self.triple_patterns[self.__idx__]
            self.__idx__ += 1
            return item

    def __get_triple_patterns__(self):
        triples = []
        cdef rasqal_triple* t = NULL
        cdef TriplePattern trp = None
        for i in count():
            t = rasqal_graph_pattern_get_triple(self.gp, i)
            if t == NULL:
                break
            trp = new_triplepattern(t)
            triples.append(trp)
        return triples
        
    def __get_flattened_triple_patterns__(self):
        cdef raptor_sequence* ts = rasqal_graph_pattern_get_flattened_triples(self.rq, self.gp)
        cdef int sz = 0
        if ts != NULL:
            sz = raptor_sequence_size(ts)
            return [new_triplepattern(<rasqal_triple*>raptor_sequence_get_at(ts, i)) for i in xrange(sz)]
        return []

    def __get_subgraph_patterns__(self):
        cdef raptor_sequence* seq   = rasqal_graph_pattern_get_sub_graph_pattern_sequence(self.gp)
        cdef int sz = 0
        if seq != NULL:
            sz = raptor_sequence_size(seq)
            return [new_graphpattern(self.rq, <rasqal_graph_pattern*>raptor_sequence_get_at(seq, i)) for i in xrange(sz)]
        return []
        
    property operator:
        def __get__(self):
            return rasqal_graph_pattern_get_operator(self.gp)

    cpdef debug(self):
        rasqal_graph_pattern_print(self.gp, stdout)

    cpdef bint is_optional(self):
        return True if rasqal_graph_pattern_get_operator(self.gp) == RASQAL_GRAPH_PATTERN_OPERATOR_OPTIONAL else False

    cpdef bint is_basic(self):
        return True if rasqal_graph_pattern_get_operator(self.gp) == RASQAL_GRAPH_PATTERN_OPERATOR_BASIC else False

    cpdef bint is_union(self):
        return True if rasqal_graph_pattern_get_operator(self.gp) == RASQAL_GRAPH_PATTERN_OPERATOR_UNION else False

    cpdef bint is_group(self):
        return True if rasqal_graph_pattern_get_operator(self.gp) == RASQAL_GRAPH_PATTERN_OPERATOR_GROUP else False

    cpdef bint is_graph(self):
        return True if rasqal_graph_pattern_get_operator(self.gp) == RASQAL_GRAPH_PATTERN_OPERATOR_GRAPH else False

    cpdef bint is_filter(self):
        return True if rasqal_graph_pattern_get_operator(self.gp) == RASQAL_GRAPH_PATTERN_OPERATOR_FILTER else False

    cpdef bint is_service(self):
        return True if rasqal_graph_pattern_get_operator(self.gp) == RASQAL_GRAPH_PATTERN_OPERATOR_SERVICE else False
    
cdef GraphPattern new_graphpattern(rasqal_query* rq, rasqal_graph_pattern* gp):
    cdef GraphPattern grp                       = GraphPattern.__new__(GraphPattern)
    cdef rasqal_literal* __ptr_literal          = NULL
    cdef rasqal_variable* __ptr_variable        = NULL
    cdef rasqal_expression* __ptr_expression    = NULL

    grp.gp                      = gp
    grp.rq                      = rq
    grp.__idx__                 = 0
    grp.triple_patterns         = grp.__get_triple_patterns__()
    grp.sub_graph_patterns      = grp.__get_subgraph_patterns__()
    grp.flattened_triple_patterns= grp.__get_flattened_triple_patterns__()

    __ptr_literal               = rasqal_graph_pattern_get_origin(gp)
    grp.origin                  = new_queryliteral(__ptr_literal) if __ptr_literal != NULL else None

    __ptr_literal               = rasqal_graph_pattern_get_service(gp)
    grp.service                 = new_queryliteral(__ptr_literal) if __ptr_literal != NULL else None

    __ptr_variable              = rasqal_graph_pattern_get_variable(gp)
    grp.variable                = new_queryvar(__ptr_variable) if __ptr_variable != NULL else None

    __ptr_expression            = rasqal_graph_pattern_get_filter_expression(gp)
    grp.filter                  = new_filter(__ptr_expression) if __ptr_expression != NULL else None

    return grp
#-----------------------------------------------------------------------------------------------------------------------
# SEQUENCE
#-----------------------------------------------------------------------------------------------------------------------
cdef class Sequence:
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
#--- QUERY - KEEPS STATE (all are copies)
#-----------------------------------------------------------------------------------------------------------------------
def parse_query(cls, qstr, world=None):
    return new_query(<char*>qstr, <RasqalWorld>world)


cdef class Query:
    def __dealloc__(self):
        rasqal_free_query(self.rq)

    cpdef debug(self):
        rasqal_query_print(self.rq, stdout)

    cpdef get_bindings_var(self, i):
        return QueryVar(<object>rasqal_query_get_bindings_variable(self.rq, i))

    cpdef get_var(self, i):
        return QueryVar(<object>rasqal_query_get_variable(self.rq, i))

    cpdef has_var(self, char* name):
        return True if rasqal_query_has_variable(self.rq, <unsigned char*>name) > 0 else False

    cpdef get_triple(self, i):
        return new_triplepattern(rasqal_query_get_triple(self.rq, i))

    cpdef get_prefix(self, i):
        return Prefix(<object>rasqal_query_get_prefix(self.rq, i))

    def __get_triple_patterns__(self):
        cdef raptor_sequence* ts =  rasqal_query_get_triple_sequence(self.rq)
        cdef int sz = 0
        if ts != NULL:
            sz = raptor_sequence_size(ts)
            return [new_triplepattern(rasqal_query_get_triple(self.rq, i)) for i in xrange(sz)]
        return []

    def __get_prefixes__(self):
        cdef raptor_sequence* ps =  rasqal_query_get_prefix_sequence(self.rq)
        cdef int sz = 0
        if ps != NULL:
            sz = raptor_sequence_size(ps)
            return [Prefix(<object>rasqal_query_get_prefix(self.rq, i)) for i in xrange(sz)]
        return []

    def __get_graph_pattern__(self):
        return new_graphpattern(self.rq, rasqal_query_get_query_graph_pattern(self.rq))

    def __get_graph_patterns__(self):
        cdef raptor_sequence* seq   = rasqal_query_get_graph_pattern_sequence(self.rq)
        cdef int sz = 0
        if seq != NULL:
            sz = raptor_sequence_size(seq)
            return [new_graphpattern(self.rq, <rasqal_graph_pattern*>raptor_sequence_get_at(seq, i)) for i in xrange(sz)]
        return []

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
            cdef int v = rasqal_query_get_verb(self.rq)
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
        return self.triple_patterns[i]

    def __iter__(self):
        return iter(self.triple_patterns)

    def __str__(self):
        return '\n'.join([ 'TRIPLE: %s, %s, %s'%(t[0].n3(), t[1].n3(), t[2].n3()) for t in self ])

    parse = classmethod(parse_query)

cpdef Query new_query(char* query, RasqalWorld world):
    cdef Query ttq = Query.__new__(Query)
    print 1
    if not world:
        ttq.w  = RasqalWorld()
        print 2
    else:
        ttq.w = world
        print 3
    ttq.__idx__ = 0
    print 4
    print 'world wrapper = ',ttq.w
    print 'world pointer = ',<long>ttq.w.rw
    ttq.rq = rasqal_new_query(ttq.w.rw, "sparql", NULL)
    print 5
    rasqal_query_prepare(ttq.rq, <unsigned char*>query, NULL)
    print 6

    ttq.triple_patterns         = ttq.__get_triple_patterns__()
    print 7
    ttq.prefixes                = ttq.__get_prefixes__()
    print 8
    ttq.query_graph_pattern     = ttq.__get_graph_pattern__()
    print 9
    ttq.graph_patterns          = ttq.__get_graph_patterns__()
    print 10
    ttq.vars                    = list(AllVarsIterator(<object>ttq.rq, None))
    print 11
    ttq.bound_vars              = list(BoundVarsIterator(<object>ttq.rq, None))
    print 12
    ttq.projections             = ttq.bound_vars
    print 13
    ttq.binding_vars            = list(BindingsVarsIterator(<object>ttq.rq, None))
    print 14
    print 'return'
    return ttq