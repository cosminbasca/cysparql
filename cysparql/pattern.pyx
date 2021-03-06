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

from cython cimport *
from cpython cimport *
from libc.stdio cimport *
from libc.stdlib cimport *
from libc.string cimport *
from cysparql.rasqal cimport *
from cysparql.raptor2 cimport *
from cysparql.cutil cimport *
from cysparql.util import enum


__author__ = 'basca'

#-----------------------------------------------------------------------------------------------------------------------
#
# the triple pattern
#
#-----------------------------------------------------------------------------------------------------------------------
Operator = enum(
    UNKNOWN = OPERATOR_UNKNOWN,
    BASIC = OPERATOR_BASIC,
    OPTIONAL = OPERATOR_OPTIONAL,
    UNION = OPERATOR_UNION,
    GROUP = OPERATOR_GROUP,
    GRAPH = OPERATOR_GRAPH,
    FILTER = OPERATOR_FILTER,
    LET = OPERATOR_LET,
    SELECT = OPERATOR_SELECT,
    SERVICE = OPERATOR_SERVICE,
    MINUS = OPERATOR_MINUS,
    LAST = OPERATOR_LAST,
)

#-----------------------------------------------------------------------------------------------------------------------
#
# the triple pattern
#
#-----------------------------------------------------------------------------------------------------------------------
cdef TriplePattern new_TriplePattern(rasqal_triple* triple):
    cdef TriplePattern tp = TriplePattern()
    tp._rtriple = triple
    tp.subject_qliteral = new_QueryLiteral(triple.subject) if triple.subject != NULL else None
    tp.predicate_qliteral = new_QueryLiteral(triple.predicate) if triple.predicate != NULL else None
    tp.object_qliteral = new_QueryLiteral(triple.object) if triple.object != NULL else None
    tp.context_qliteral = new_QueryLiteral(triple.origin) if triple.origin != NULL else None
    return tp

cdef class TriplePattern:
    def __cinit__(self, tpattern = None):
        self._rtriple = NULL
        self._idx = 0
        self._hashvalue = 0
        self.subject_qliteral = None
        self.predicate_qliteral = None
        self.object_qliteral = None
        self.context_qliteral = None

        self.__subject__ = None
        self.__predicate__ = None
        self.__object__ = None
        self.__context__ = None

        if tpattern and isinstance(tpattern, TriplePattern):
            self._rtriple = (<TriplePattern>tpattern)._rtriple
            self.subject_qliteral = QueryLiteral((<TriplePattern>tpattern).subject_qliteral)
            self.predicate_qliteral = QueryLiteral((<TriplePattern>tpattern).predicate_qliteral)
            self.object_qliteral = QueryLiteral((<TriplePattern>tpattern).object_qliteral)
            self.context_qliteral = QueryLiteral((<TriplePattern>tpattern).context_qliteral)

    property subject:
        def __get__(self):
            if not self.__subject__:
                self.__subject__ = self.subject_qliteral.to_rdflib()
            return self.__subject__

    property predicate:
        def __get__(self):
            if not self.__predicate__:
                self.__predicate__ = self.predicate_qliteral.to_rdflib()
            return self.__predicate__

    property object:
        def __get__(self):
            if not self.__object__:
                self.__object__ = self.object_qliteral.to_rdflib()
            return self.__object__

    property context:
        def __get__(self):
            if self.context_qliteral == None: return None

            if not self.__context__:
                self.__context__ = self.context_qliteral.to_rdflib()
            return self.__context__


    cpdef debug(self):
        rasqal_triple_print(<rasqal_triple*> self._rtriple, stdout)

    def as_tuple(self):
        return self.subject, self.predicate, self.object

    def __getitem__(self, i):
        if i == 0:
            return self.subject
        elif i == 1:
            return self.predicate
        elif i == 2:
            return self.object
        elif i == 3:
            return self.context
        else:
            raise IndexError('index must be, 0,1,2 or 3 corresponding to "subject", "predicate", "object" or "context"')

    def __str__(self):
        return '< %s, %s, %s ,%s>' % (str(self.subject),
                                      str(self.predicate),
                                      str(self.object),
                                      str(self.context))

    def __repr__(self):
        return self.__str__()

    def __len__(self):
        return 4

    def __iter__(self):
        self._idx = 0
        return self

    def __next__(self):
        if self._idx == 4:
            raise StopIteration
        else:
            item = None
            if self._idx == 0:
                item = self.subject
            elif self._idx == 1:
                item = self.predicate
            elif self._idx == 2:
                item = self.object
            elif self._idx == 3:
                item = self.context
            self._idx += 1
            return item

    def __contains__(self, item):
        if item == self.subject:
            return True
        elif item == self.predicate:
            return True
        elif item == self.object:
            return True
        elif item == self.context:
            return True
        return False

    def n3(self, withvars=True):
        def _n3(itm):
            if itm:
                return itm.n3() if not isinstance(itm, QueryVar) or (isinstance(itm, QueryVar) and withvars) else None
        return _n3(self.subject), _n3(self.predicate), _n3(self.object)

    cdef int pattern_type(self):
        cdef int ptype = 0
        if type(self.subject) is QueryVar: ptype += 1
        if type(self.predicate) is QueryVar: ptype += 1
        if type(self.object) is QueryVar: ptype += 1
        return ptype

    def __hash__(self):
        if self._hashvalue == 0:
            self._hashvalue = hash( (self.subject, self.predicate, self.object, self.context) )
        return self._hashvalue



#-----------------------------------------------------------------------------------------------------------------------
#
# related sequences
#
#-----------------------------------------------------------------------------------------------------------------------
cdef inline Sequence new_TriplePatternSequence(rasqal_query* query, raptor_sequence* sequence, int start=-1, int end=-1, bint owner=False):
    cdef Sequence seq = TriplePatternSequence()
    seq._rquery = query
    seq._rsequence = sequence
    seq._start = start
    seq._end = end
    seq._owner = owner
    return seq

cdef class TriplePatternSequence(Sequence):
    cdef __item__(self, void* seq_item):
        return new_TriplePattern(<rasqal_triple*>seq_item)


cdef inline Sequence new_GraphPatternSequence(rasqal_query* query, raptor_sequence* sequence, int start=-1, int end=-1):
    cdef Sequence seq = GraphPatternSequence()
    seq._rquery = query
    seq._rsequence = sequence
    seq._start = start
    seq._end = end
    return seq

cdef class GraphPatternSequence(Sequence):
    cdef __item__(self, void* seq_item):
        return new_GraphPattern(self._rquery, <rasqal_graph_pattern*>seq_item)


#-----------------------------------------------------------------------------------------------------------------------
#
# the graph pattern
#
#-----------------------------------------------------------------------------------------------------------------------
cdef GraphPattern new_GraphPattern(rasqal_query* query, rasqal_graph_pattern* graphpattern):
    cdef GraphPattern grp = GraphPattern()
    cdef rasqal_literal* _literal = NULL
    cdef rasqal_variable* _variable = NULL
    cdef rasqal_expression* _expression = NULL

    grp._rgraphpattern = graphpattern
    grp._rquery = query

    _literal = rasqal_graph_pattern_get_origin(graphpattern)
    grp.origin = new_QueryLiteral(_literal) if _literal != NULL else None

    _literal = rasqal_graph_pattern_get_service(graphpattern)
    grp.service = new_QueryLiteral(_literal) if _literal != NULL else None

    _variable = rasqal_graph_pattern_get_variable(graphpattern)
    grp.variable = new_QueryVar(_variable) if _variable != NULL else None

    _expression = rasqal_graph_pattern_get_filter_expression(graphpattern)
    grp.filter = new_Filter(_expression) if _expression != NULL else None

    cdef raptor_sequence* triples = rasqal_graph_pattern_get_triples(query, graphpattern)
    if triples != NULL:
        grp.triple_patterns = new_TriplePatternSequence(query, triples, -1, -1, True)
    else:
        grp.triple_patterns = None

    grp.flattened_triple_patterns = new_TriplePatternSequence(query,
        rasqal_graph_pattern_get_flattened_triples(query, graphpattern))

    grp.sub_graph_patterns = new_GraphPatternSequence(query,
        rasqal_graph_pattern_get_sub_graph_pattern_sequence(graphpattern))

    return grp

cdef class GraphPattern:
    def __cinit__(self):
        self._rgraphpattern = NULL
        self._rquery = NULL
        self._idx = 0
        self._hashvalue = 0

        self.service = None
        self.variable = None
        self.filter = None
        self.origin = None
        self.triple_patterns = None
        self.sub_graph_patterns = None
        self.flattened_triple_patterns = None

    def __iter__(self):
        return iter(self.sub_graph_patterns)

    property operator:
        def __get__(self):
            return rasqal_graph_pattern_get_operator(self._rgraphpattern)

    property operator_label:
        def __get__(self):
            cdef int op = rasqal_graph_pattern_get_operator(self._rgraphpattern)
            return Operator.reverse_mapping[op]

    def __getitem__(self, idx):
        return self.sub_graph_patterns[idx]

    def __len__(self):
        return self.sub_graph_patterns.__len__()

    def __hash__(self):
        if self._hashvalue == 0:
            self._hashvalue = rasqal_graph_pattern_get_index(self._rgraphpattern)
        return self._hashvalue

    cpdef debug(self):
        rasqal_graph_pattern_print(self._rgraphpattern, stdout)

    cpdef bint is_optional(self):
        return rasqal_graph_pattern_get_operator(self._rgraphpattern) == RASQAL_GRAPH_PATTERN_OPERATOR_OPTIONAL

    cpdef bint is_basic(self):
        return rasqal_graph_pattern_get_operator(self._rgraphpattern) == RASQAL_GRAPH_PATTERN_OPERATOR_BASIC

    cpdef bint is_union(self):
        return rasqal_graph_pattern_get_operator(self._rgraphpattern) == RASQAL_GRAPH_PATTERN_OPERATOR_UNION

    cpdef bint is_group(self):
        return rasqal_graph_pattern_get_operator(self._rgraphpattern) == RASQAL_GRAPH_PATTERN_OPERATOR_GROUP

    cpdef bint is_graph(self):
        return rasqal_graph_pattern_get_operator(self._rgraphpattern) == RASQAL_GRAPH_PATTERN_OPERATOR_GRAPH

    cpdef bint is_filter(self):
        return rasqal_graph_pattern_get_operator(self._rgraphpattern) == RASQAL_GRAPH_PATTERN_OPERATOR_FILTER

    cpdef bint is_service(self):
        return rasqal_graph_pattern_get_operator(self._rgraphpattern) == RASQAL_GRAPH_PATTERN_OPERATOR_SERVICE

