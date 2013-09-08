from cysparql import *
from base import *
from rdflib.term import *

__author__ = 'basca'

class TestQuery(BaseTestCase):
    def test_01_parse(self):
        query = self.get_query()
        self.assertIsInstance(query, Query)

    def test_02_variables(self):
        query = self.get_query()
        all_vars = set(['label', 'lat', 'long'])
        q_vars = set([v.name for v in query.vars])
        self.assertEqual(all_vars, q_vars)
        p_vars = set([v.name for v in query.projections])
        self.assertEqual(all_vars, p_vars)
        b_vars = set([v.name for v in query.binding_vars])
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
        pref_keys = set(['wgs84_pos', 'rdfs'])
        pref_uris = set(['http://www.w3.org/2000/01/rdf-schema#', 'http://www.w3.org/2003/01/geo/wgs84_pos#'])
        for p in prefixes:
            self.assertIsInstance(p, Prefix)
            self.assertIsInstance(p.uri, URIRef)
        qp_keys = set([p.prefix for p in prefixes])
        qp_uris = set([str(p.uri) for p in prefixes])
        self.assertEqual(qp_keys, pref_keys)
        self.assertEqual(qp_uris, pref_uris)