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
        rasqal_free_query(self._rquery)
        rasqal_free_world(self._rworld)

    cpdef debug(self):
        rasqal_query_print(self._rquery, stdout)

    cpdef get_bindings_var(self, i):
        return new_QueryVar(rasqal_query_get_bindings_variable(self._rquery, i))

    cpdef get_var(self, i):
        return new_QueryVar(rasqal_query_get_variable(self._rquery, i))

    cpdef has_var(self, char*name):
        return True if rasqal_query_has_variable(self._rquery, <unsigned char*> name) > 0 else False

    cpdef get_triple(self, i):
        return new_TriplePattern(rasqal_query_get_triple(self._rquery, i))

    cpdef get_prefix(self, i):
        return new_Prefix(rasqal_query_get_prefix(self._rquery, i))

    cpdef QueryVarsTable create_vars_table(self):
        return new_QueryVarsTable(self._rworld)

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

