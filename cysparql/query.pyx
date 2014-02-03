# CYTHON
from cython cimport *
from cpython cimport *
from libc.stdio cimport *
from libc.stdlib cimport *
from libc.string cimport *
# LOCAL
from rasqal cimport *
from raptor2 cimport *

from rdflib.term import URIRef
from exceptions import QueryParseException
import hashlib
import numpy as np
import networkx as nx
from draw import ScarletRed, plot_query

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

#-----------------------------------------------------------------------------------------------------------------------
#
# related sequences
#
#-----------------------------------------------------------------------------------------------------------------------
cdef inline Sequence new_PrefixSequence(rasqal_query* query, raptor_sequence* sequence):
    cdef Sequence seq = PrefixSequence()
    seq._rquery = query
    seq._rsequence = sequence
    return seq

cdef class PrefixSequence(Sequence):
    cdef __item__(self, void* seq_item):
        return new_Prefix(<rasqal_prefix*>seq_item)


#-----------------------------------------------------------------------------------------------------------------------
#
# the prefix
#
#-----------------------------------------------------------------------------------------------------------------------
cdef Prefix new_Prefix(rasqal_prefix* prefix):
    cdef Prefix pref = Prefix()
    pref._rprefix = prefix
    return pref

cdef class Prefix:
    def __cinit__(self):
        self._rprefix = NULL

    property prefix:
        def __get__(self):
            return self._rprefix.prefix if self._rprefix.prefix != NULL else ''

    property uri:
        def __get__(self):
            return URIRef(uri_to_str(self._rprefix.uri)) if self._rprefix.uri != NULL else None

    cpdef debug(self):
        rasqal_prefix_print(<rasqal_prefix*> self._rprefix, stdout)

    def __str__(self):
        return 'Prefix(%s : %s)' % (self.prefix, self.uri)


#-----------------------------------------------------------------------------------------------------------------------
#
# the query
#
#-----------------------------------------------------------------------------------------------------------------------
cdef class Query:
    def __cinit__(self, qstring, world = None):
        cdef char* language = 'sparql'
        self.world = world if world is not None else RasqalWorld()

        self._rquery = rasqal_new_query(self.world._rworld, language, NULL)
        self._format_uri = raptor_new_uri(self.world.get_raptor_world(), 'http://www.w3.org/TR/2006/CR-rdf-sparql-query-20060406/')

        cdef char* _qstring = qstring

        # parse
        cdef int success = rasqal_query_prepare(self._rquery, <unsigned char*> _qstring, NULL)
        if success != 0:
            raise QueryParseException('rasqal failure code = %s'%success)

        # setup query
        self.query_graph_pattern = new_GraphPattern(self._rquery,
            rasqal_query_get_query_graph_pattern(self._rquery))

        # the sequences
        self.triple_patterns = new_TriplePatternSequence(self._rquery,
            rasqal_query_get_triple_sequence(self._rquery))

        self.prefixes = new_PrefixSequence(self._rquery,
            rasqal_query_get_prefix_sequence(self._rquery))

        self.graph_patterns = new_GraphPatternSequence(self._rquery,
            rasqal_query_get_graph_pattern_sequence(self._rquery))

        self.vars = new_QueryVarSequence(self._rquery,
            rasqal_query_get_all_variable_sequence(self._rquery))

        self.projections = new_QueryVarSequence(self._rquery,
            rasqal_query_get_bound_variable_sequence(self._rquery))

        self.binding_vars = new_QueryVarSequence(self._rquery,
            rasqal_query_get_bindings_variables_sequence(self._rquery))

        self.__vars__ = None

    def __dealloc__(self):
        if self._rquery != NULL:
            rasqal_free_query(self._rquery)
        if self._format_uri != NULL:
            raptor_free_uri(self._format_uri)

    cdef void* get_user_data(self):
        return rasqal_query_get_user_data(self._rquery)

    cdef void set_user_data(self, void* data):
        rasqal_query_set_user_data(self._rquery, data)

    cpdef debug(self):
        rasqal_query_print(self._rquery, stdout)

    cpdef get_bindings_var(self, i):
        return new_QueryVar(rasqal_query_get_bindings_variable(self._rquery, i))

    cpdef get_variable(self, i):
        return new_QueryVar(rasqal_query_get_variable(self._rquery, i))

    cpdef set_variable(self, bytes name, QueryLiteral value):
        cdef char* _name = name
        return True if rasqal_query_set_variable(self._rquery, _name, value._rliteral) == 0 else False

    cpdef has_variable(self, bytes name):
        cdef unsigned char* _name = name
        cdef int rv = rasqal_query_has_variable2(self._rquery, RASQAL_VARIABLE_TYPE_NORMAL, _name)
        return True if rv > 0 else False

    cpdef get_triple(self, i):
        return new_TriplePattern(rasqal_query_get_triple(self._rquery, i))

    cpdef get_prefix(self, i):
        return new_Prefix(rasqal_query_get_prefix(self._rquery, i))

    cpdef QueryVarsTable create_vars_table(self):
        return new_QueryVarsTable(self.world._rworld)

    property variables:
        def __get__(self):
            if not self.__vars__:
                self.__vars__ = dict([(v.name, v) for v in self.vars])
            return self.__vars__

    property label:
        def __get__(self):
            return rasqal_query_get_label(self._rquery)

    property limit:
        def __get__(self):
            return rasqal_query_get_limit(self._rquery)
        def __set__(self, val):
            assert isinstance(val, (long, int))
            rasqal_query_set_limit(self._rquery, val)

    property name:
        def __get__(self):
            return rasqal_query_get_name(self._rquery)

    property offset:
        def __get__(self):
            return rasqal_query_get_offset(self._rquery)
        def __set__(self, val):
            assert isinstance(val, (long, int))
            rasqal_query_set_offset(self._rquery, val)

    property distinct:
        def __get__(self):
            return True if rasqal_query_get_distinct(self._rquery) != 0 else False
        def __set__(self, val):
            rasqal_query_set_distinct(self._rquery, 1 if val else 0)

    property explain:
        def __get__(self):
            return True if rasqal_query_get_explain(self._rquery) != 0 else False
        def __set__(self, val):
            rasqal_query_set_explain(self._rquery, 0 if val else 1)

    property wildcard:
        def __get__(self):
            return True if rasqal_query_get_wildcard(self._rquery) != 0 else False
        def __set__(self, val):
            rasqal_query_set_wildcard(self._rquery, 0 if val else 1)

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

    cpdef to_str(self):
        cdef raptor_world* rap_world = self.world.get_raptor_world()
        cdef void* _str_buffer = NULL
        cdef size_t _str_buffer_len
        cdef raptor_iostream* rap_iostr =  raptor_new_iostream_to_string(rap_world, &_str_buffer, &_str_buffer_len, NULL)
        # cdef raptor_iostream* rap_iostr =  raptor_new_iostream_to_file_handle(rap_world, stdout)
        if rap_iostr == NULL: return ''

        cdef int rv = rasqal_query_write(rap_iostr, self._rquery, self._format_uri, NULL)
        raptor_free_iostream(rap_iostr)
        cdef bytes _repr = <bytes>''
        if rv == 0:
            _repr = (<char*>_str_buffer)[:_str_buffer_len]

        if _str_buffer != NULL:
            free(_str_buffer)
        return _repr

    def __str__(self):
        return self.to_str()


    cpdef list get_graph_vertexes(self):
        cdef list vertexes = list(set([(hash(term),term) for tp in self.triple_patterns for i, term in enumerate(tp) if i == 0 or i == 2]))
        vertexes.sort()
        return vertexes

    cpdef to_adjacency_matrix(self):
        cdef TriplePattern tp = None
        cdef object term = None
        cdef int i, j
        cdef list encoded_vars = [v[0] for v in self.get_graph_vertexes()]
        cdef int size = len(encoded_vars)
        cdef object adj_matrix = np.zeros((size, size))
        for tp in self.triple_patterns:
            i = encoded_vars.index(hash(tp.subject))
            j = encoded_vars.index(hash(tp.object))
            adj_matrix[i,j] = 1
            adj_matrix[j,i] = 1
        return adj_matrix

    property adacency_matrix:
        def __get__(self):
            return self.to_adjacency_matrix()

    cpdef to_graph(self):
        cdef object G = nx.DiGraph()
        cdef TriplePattern tp = None
        cdef int i, j
        for tp in self.triple_patterns:
            G.add_edge(tp.subject, tp.object, predicate=tp.predicate)
        return G

    property graph:
        def __get__(self):
            return self.to_graph()

    def query_id(self):
        m = hashlib.md5()
        m.update(self.to_str())
        return m.hexdigest()

    def plot(self, qname = None, location=None, highlight=None, highlight_color=ScarletRed.light,
               highlight_alpha=0.7, alpha=0.7, suffix=None, show=False, ext='pdf', prefixes=None,
               aspect_ratio=(2.7 / 4.0), scale=1.9, show_predicates=False):
        if qname is None:
            qname = 'Query#%s'%self.query_id()
        plot_query(self, qname, location=location, highlight=highlight, highlight_color= highlight_color,
                   highlight_alpha=highlight_alpha, alpha=alpha, suffix=suffix, show=show, ext=ext, prefixes=prefixes,
                   aspect_ratio=aspect_ratio, scale=scale, show_predicates=show_predicates)