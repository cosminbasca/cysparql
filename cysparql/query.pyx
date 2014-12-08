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

from warnings import warn
from cython cimport *
from cpython cimport *
from libc.stdio cimport *
from libc.stdlib cimport *
from libc.string cimport *
from cysparql.rasqal cimport *
from cysparql.raptor2 cimport *
from cysparql.util import prettify
from cysparql.exceptions import QueryParseException
from cysparql.draw import ScarletRed, plot_query
from rdflib.term import URIRef
import networkx as nx
import numpy as np
import hashlib


__author__ = 'basca'

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
    def __cinit__(self, qstring, pretty=False, world = None):
        cdef char* language = 'sparql'
        self.world = world if world is not None else RasqalWorld()

        self.pretty = pretty
        self._rquery = rasqal_new_query(self.world._rworld, language, NULL)
        self._format_uri = raptor_new_uri(self.world.get_raptor_world(), 'http://www.w3.org/TR/2006/CR-rdf-sparql-query-20060406/')

        if self.pretty:
            qstring = prettify(qstring)
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

        self._vars = None
        self._namespaces = None
        self._unique_id = None

    def __dealloc__(self):
        if self._rquery != NULL:
            rasqal_free_query(self._rquery)
        if self._format_uri != NULL:
            raptor_free_uri(self._format_uri)

    def __reduce__(self):
        return Query, (self.to_string(), self.pretty)

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

    @property
    def namespaces(self):
        if not self._namespaces:
            self._namespaces = {p.prefix:p.uri for p in self.prefixes}
        return self._namespaces

    @property
    def variables(self):
        if not self._vars:
            self._vars = {v.name:v for v in self.vars}
        return self._vars

    @property
    def label(self):
        return rasqal_query_get_label(self._rquery)

    @property
    def limit(self):
        return rasqal_query_get_limit(self._rquery)

    @limit.setter
    def limit(self, val):
        if not isinstance(val, (long, int)):
            raise ValueError('val must be a long or an int')
        rasqal_query_set_limit(self._rquery, val)

    @property
    def name(self):
        return rasqal_query_get_name(self._rquery)

    @property
    def offset(self):
        return rasqal_query_get_offset(self._rquery)

    @offset.setter
    def offset(self, val):
        if not isinstance(val, (long, int)):
            raise ValueError('val must be a long or an int')
        rasqal_query_set_offset(self._rquery, val)

    @property
    def distinct(self):
        return True if rasqal_query_get_distinct(self._rquery) != 0 else False

    @distinct.setter
    def distinct(self, val):
        rasqal_query_set_distinct(self._rquery, 1 if val else 0)

    @property
    def explain(self):
        return True if rasqal_query_get_explain(self._rquery) != 0 else False

    @explain.setter
    def explain(self, val):
        rasqal_query_set_explain(self._rquery, 0 if val else 1)

    @property
    def wildcard(self):
        return True if rasqal_query_get_wildcard(self._rquery) != 0 else False

    @wildcard.setter
    def wildcard(self, val):
        rasqal_query_set_wildcard(self._rquery, 0 if val else 1)

    @property
    def verb(self):
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

    cpdef to_string(self):
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
        return self.to_string()

    cpdef list get_graph_vertexes(self):
        return get_graph_vertexes(self.triple_patterns)

    cpdef get_adjacency_matrix(self):
        return get_adjacency_matrix(self.triple_patterns)

    @property
    def adjacency_matrix(self):
        return self.get_adjacency_matrix()

    cpdef bint is_star(self):
        return is_star(self.triple_patterns)

    @property
    def stars(self):
        return get_stars(self.triple_patterns)

    # noinspection PyUnresolvedReferences
    cpdef to_graph(self):
        cdef object G = nx.DiGraph()
        cdef TriplePattern tp = None
        cdef int i, j
        for tp in self.triple_patterns:
            G.add_edge(tp.subject, tp.object, predicate=tp.predicate)
        return G

    @property
    def graph(self):
        return self.to_graph()

    @property
    def unique_id(self):
        if not self._unique_id:
            self._unique_id = hashlib.sha1(self.to_string().upper()).hexdigest()
        return self._unique_id

    @property
    def ascii(self):
        try:
            import asciinet
            return asciinet.graph_to_ascii(self.to_graph())
        except ImportError, e:
            warn('could not import asciinet')
        return None

    def plot(self, qname = None, location=None, highlight=None, highlight_color=ScarletRed.light,
               highlight_alpha=0.7, alpha=0.7, suffix=None, show=False, ext='pdf', aspect_ratio=(2.7 / 4.0),
               scale=1.9, show_predicates=False, matplotlib_backend='TkAgg', layout='shell', arrows=False):
        if qname is None:
            qname = 'Query#%s'%self.unique_id

        prefixes = { p.prefix:str(p.uri) for p in self.prefixes}
        plot_query(self, qname, location=location, highlight=highlight, highlight_color= highlight_color,
                   highlight_alpha=highlight_alpha, alpha=alpha, suffix=suffix, show=show, ext=ext, prefixes=prefixes,
                   aspect_ratio=aspect_ratio, scale=scale, show_predicates=show_predicates,
                   matplotlib_backend=matplotlib_backend, layout=layout, arrows=arrows)
