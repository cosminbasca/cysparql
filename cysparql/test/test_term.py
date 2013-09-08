from cysparql import *
from base import BaseTestCase
from rdflib.term import *

__author__ = 'basca'

class TermTestCase(BaseTestCase):
    def get_qliteral_uri(self, query):
        tp = list(query.triple_patterns)[0]
        return tp.subject_qliteral

    def get_qliteral_var(self, query):
        tp = list(query.triple_patterns)[0]
        return tp.object_qliteral

    def test_01_uri_literal(self):
        query = self.get_query()
        qlit = self.get_qliteral_uri(query)
        self.assertIsInstance(qlit, QueryLiteral)
        qlit_val = qlit.value()
        self.assertIsInstance(qlit_val, URIRef)
        self.assertEqual(str(qlit_val), 'http://dbpedia.org/resource/Karl_Gebhardt')

    def test_02_variable_literal(self):
        query = self.get_query()
        qlit = self.get_qliteral_var(query)
        self.assertIsInstance(qlit, QueryLiteral)
        qlit_val = qlit.value()
        self.assertIsInstance(qlit_val, QueryVar)
        self.assertEqual(qlit_val.name, 'lat')
