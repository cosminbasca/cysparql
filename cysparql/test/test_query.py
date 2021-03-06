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

from cysparql.pattern import GraphPattern, Operator, TriplePattern
from cysparql.query import Query, Prefix
from cysparql.varstable import QueryVarsTable
from base import *
from rdflib.term import *

__author__ = 'basca'

class TestQuery(BaseTestCase):
    def test_01_parse(self):
        query = self.get_query()
        self.assertIsInstance(query, Query)

    def test_02_variables(self):
        query = self.get_query()
        all_vars = {'label', 'lat', 'long'}
        q_vars = {v.name for v in query.vars}
        self.assertEqual(all_vars, q_vars)
        p_vars = {v.name for v in query.projections}
        self.assertEqual(all_vars, p_vars)
        b_vars = {v.name for v in query.binding_vars}
        self.assertTrue(len(b_vars) == 0)

    def test_03_triple_patterns(self):
        query = self.get_query()
        tpatterns = list(query.triple_patterns)
        self.assertEquals(len(tpatterns), 3)
        # <http://dbpedia.org/resource/Karl_Gebhardt> rdfs:label ?label .
        # <http://dbpedia.org/resource/Karl_Gebhardt> wgs84_pos:lat ?lat .
        # <http://dbpedia.org/resource/Karl_Gebhardt> wgs84_pos:long ?long
        for i in xrange(len(tpatterns)):
            self.assertIsInstance(tpatterns[i].subject, URIRef)
            self.assertIsInstance(tpatterns[i].predicate, URIRef)
            self.assertIsInstance(tpatterns[i].object, QueryVar)
            self.assertEqual(str(tpatterns[i].subject), 'http://dbpedia.org/resource/Karl_Gebhardt')

    def test_04_graph_pattern(self):
        query = self.get_query()
        gp = query.query_graph_pattern
        self.assertIsInstance(gp, GraphPattern)
        self.assertEqual(gp.operator, Operator.GROUP)
        operators = [Operator.BASIC, Operator.OPTIONAL, Operator.FILTER]
        for i, g in enumerate(gp):
            self.assertEqual(g.operator, operators[i])

    def test_05_sub_graph_pattern(self):
        query = self.get_query()
        gp = query.query_graph_pattern
        g = list(gp.sub_graph_patterns)[0]
        tps = list(g.triple_patterns)
        self.assertEqual(len(tps), 1)
        self.assertIsInstance(tps[0], TriplePattern)
        self.assertIsInstance(tps[0].object, QueryVar)
        self.assertEqual(tps[0].object.name, 'label')

    def test_06_prefix(self):
        query = self.get_query()
        prefixes = list(query.prefixes)
        self.assertEqual(len(prefixes), 2)
        pref_keys = {'wgs84_pos', 'rdfs'}
        pref_uris = {'http://www.w3.org/2000/01/rdf-schema#', 'http://www.w3.org/2003/01/geo/wgs84_pos#'}
        for p in prefixes:
            self.assertIsInstance(p, Prefix)
            self.assertIsInstance(p.uri, URIRef)
        qp_keys = {p.prefix for p in prefixes}
        qp_uris = {str(p.uri) for p in prefixes}
        self.assertEqual(qp_keys, pref_keys)
        self.assertEqual(qp_uris, pref_uris)

    def test_07_limit(self):
        query = self.get_query()
        self.assertEqual(query.limit, -1)

    def test_08_offset(self):
        query = self.get_query()
        self.assertEqual(query.offset, -1)

    def test_09_verb(self):
        query = self.get_query()
        self.assertEqual(query.verb, 'SELECT')

    def test_10_label(self):
        query = self.get_query()
        self.assertEqual(query.label, 'SPARQL 1.1 (DRAFT) Query and Update Languages')

    def test_11_getitem(self):
        query = self.get_query()
        tp = query[0]
        self.assertIsInstance(tp, TriplePattern)
        self.assertEqual(str(tp.subject), 'http://dbpedia.org/resource/Karl_Gebhardt')
        self.assertIsInstance(tp.object, QueryVar)
        self.assertEqual(tp.object.name, 'lat')

    def test_12_iter(self):
        query = self.get_query()
        for tp in query:
            self.assertIsInstance(tp, TriplePattern)

    def test_13_create_vars_table(self):
        query = self.get_query()
        vt = query.create_vars_table()
        self.assertIsInstance(vt, QueryVarsTable)

    def test_14_has_variable(self):
        query = self.get_query()
        self.assertTrue(query.has_variable('label'))
        self.assertFalse(query.has_variable('latX'))

    def test_15_star(self):
        star_s = Query(self.star_query_s)
        star_o = Query(self.star_query_o)
        no_star = Query(self.not_star_query)

        self.assertTrue(star_s.is_star())
        self.assertTrue(star_o.is_star())
        self.assertFalse(no_star.is_star())