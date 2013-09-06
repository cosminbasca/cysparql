# CYTHON
from cython cimport *
from cpython cimport *
from libc.stdio cimport *
from libc.stdlib cimport *
from libc.string cimport *
# LOCAL
from .rasqal cimport *
from .raptor cimport *

from itertools import *
from rdflib.term import URIRef, Literal, BNode

__author__ = 'Cosmin Basca'
__email__ = 'basca@ifi.uzh.ch; cosmin.basca@gmail.com'

VERB_UNKNOWN = 'UNKNOWN'
VERB_SELECT = 'SELECT'
VERB_CONSTRUCT = 'CONSTRUCT'
VERB_DESCRIBE = 'DESCRIBE'
VERB_ASK = 'ASK'
VERB_DELETE = 'DELETE'
VERB_INSERT = 'INSERT'
VERB_UPDATE = 'UPDATE'

rasqal_warning_level = 50

def disable_rasqal_warnings():
    global rasqal_warning_level
    rasqal_warning_level = 0


#-----------------------------------------------------------------------------------------------------------------------
#
# the prefix
#
#-----------------------------------------------------------------------------------------------------------------------
cdef class Prefix:
    def __cinit__(self):
        self._rprefix = NULL

    property prefix:
        def __get__(self):
            return self.p.prefix if self.p.prefix != NULL else ''

    property uri:
        def __get__(self):
            return uri_to_str(self.p.uri) if self.p.uri != NULL else None

    cpdef debug(self):
        rasqal_prefix_print(<rasqal_prefix*> self.p, stdout)

    def __str__(self):
        return '(%s : %s)' % (self.prefix, self.uri)


cdef class VarSequence(Sequence):
    cdef __item__(self, void* seq_item):
        return new_queryvar(<rasqal_variable*> seq_item)


cdef class TriplePatternSequence(Sequence):
    cdef __item__(self, void* seq_item):
        return new_triplepattern(<rasqal_triple*> seq_item)


cdef class GraphPatternSequence(Sequence):
    cdef __item__(self, void* seq_item):
        return new_graphpattern(<rasqal_query*> self._rquery, <rasqal_graph_pattern*> seq_item)

#-----------------------------------------------------------------------------------------------------------------------
#
# QUERY - KEEPS STATE (all are copies)
#
#-----------------------------------------------------------------------------------------------------------------------
cdef class Query:
    def __cinit__(self, qstring):
        global rasqal_world_set_warning_level
        cdef char* language = 'sparql'
        self._rworld = rasqal_new_world()
        self._rquery = rasqal_new_query(self._rworld, language, NULL)

        # set the warning level
        rasqal_world_set_warning_level(self._rworld, rasqal_warning_level)

        self.query_string = qstring
        cdef char* _qstring = self.query_string

        # parse
        rasqal_query_prepare(self._rquery, <unsigned char*> _qstring, NULL)

        self.triple_patterns = self.__get_triple_patterns__()
        self.prefixes = self.__get_prefixes__()
        self.query_graph_pattern = self.__get_graph_pattern__()
        self.graph_patterns = self.__get_graph_patterns__()
        self.vars = list(AllVarsIterator(self, None))
        self.bound_vars = list(BoundVarsIterator(self, None))
        self.projections = self.bound_vars
        self.binding_vars = list(BindingsVarsIterator(self, None))

    def __dealloc__(self):
        rasqal_free_query(self._rquery)
        rasqal_free_world(self._rworld)

    cpdef debug(self):
        rasqal_query_print(self._rquery, stdout)

    cpdef get_bindings_var(self, i):
        return QueryVar(<object> rasqal_query_get_bindings_variable(self._rquery, i))

    cpdef get_var(self, i):
        return QueryVar(<object> rasqal_query_get_variable(self._rquery, i))

    cpdef has_var(self, char*name):
        return True if rasqal_query_has_variable(self._rquery, <unsigned char*> name) > 0 else False

    cpdef get_triple(self, i):
        return new_triplepattern(rasqal_query_get_triple(self._rquery, i))

    cpdef get_prefix(self, i):
        return Prefix(<object> rasqal_query_get_prefix(self._rquery, i))

    def __get_triple_patterns__(self):
        cdef raptor_sequence*ts = rasqal_query_get_triple_sequence(self._rquery)
        cdef int sz = 0
        if ts != NULL:
            sz = raptor_sequence_size(ts)
            return [new_triplepattern(rasqal_query_get_triple(self._rquery, i)) for i in xrange(sz)]
        return []

    def __get_prefixes__(self):
        cdef raptor_sequence*ps = rasqal_query_get_prefix_sequence(self._rquery)
        cdef int sz = 0
        if ps != NULL:
            sz = raptor_sequence_size(ps)
            return [Prefix(<object> rasqal_query_get_prefix(self._rquery, i)) for i in xrange(sz)]
        return []

    def __get_graph_pattern__(self):
        return new_graphpattern(self._rquery, rasqal_query_get_query_graph_pattern(self._rquery))

    def __get_graph_patterns__(self):
        cdef raptor_sequence*seq = rasqal_query_get_graph_pattern_sequence(self._rquery)
        cdef int sz = 0
        if seq != NULL:
            sz = raptor_sequence_size(seq)
            return [new_graphpattern(self._rquery, <rasqal_graph_pattern*> raptor_sequence_get_at(seq, i)) for i in
                    xrange(sz)]
        return []

    property label:
        def __get__(self):
            return rasqal_query_get_label(self._rquery)

    property limit:
        def __get__(self):
            return rasqal_query_get_limit(self._rquery)

    property name:
        def __get__(self):
            return rasqal_query_get_name(self._rquery)

    property offset:
        def __get__(self):
            return rasqal_query_get_offset(self._rquery)

    property verb:
        def __get__(self):
            cdef int v = rasqal_query_get_verb(self._rquery)
            if v == RASQAL_QUERY_VERB_UNKNOWN:
                return VERB_UNKNOWN
            elif v == RASQAL_QUERY_VERB_SELECT:
                return VERB_SELECT
            elif v == RASQAL_QUERY_VERB_CONSTRUCT:
                return VERB_CONSTRUCT
            elif v == RASQAL_QUERY_VERB_DESCRIBE:
                return VERB_DESCRIBE
            elif v == RASQAL_QUERY_VERB_ASK:
                return VERB_ASK
            elif v == RASQAL_QUERY_VERB_DELETE:
                return VERB_DELETE
            elif v == RASQAL_QUERY_VERB_INSERT:
                return VERB_INSERT
            elif v == RASQAL_QUERY_VERB_UPDATE:
                return VERB_UPDATE

    def __getitem__(self, i):
        return self.triple_patterns[i]

    def __iter__(self):
        return iter(self.triple_patterns)

    def __str__(self):
        return '\n'.join(['TRIPLE: %s, %s, %s' % (t[0].n3(), t[1].n3(), t[2].n3()) for t in self])

