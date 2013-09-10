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

    def test_03_create_typed_literal(self):
        _types = {
            LiteralType.BOOLEAN: "1",
            LiteralType.INTEGER: "10",
            LiteralType.FLOAT: "10.20",
            LiteralType.DOUBLE: "10.20",
            LiteralType.DECIMAL: "11",
        }
        w = RasqalWorld()
        for t, v in _types.items():
            tlit = QueryLiteral.new_typed_literal(w, t, v)
            self.assertIsInstance(tlit, QueryLiteral)
            self.assertEqual(tlit.literal_type, t)
            self.assertEqual(tlit.literal_type_label.upper(), LiteralType.reverse_mapping[tlit.literal_type])

    def test_04_create_bool_literal(self):
        w = RasqalWorld()
        tlit = QueryLiteral.new_bool_literal(w, 1)
        self.assertIsInstance(tlit, QueryLiteral)
        self.assertEqual(tlit.literal_type, LiteralType.BOOLEAN)
        self.assertEqual(tlit.literal_type_label.upper(), LiteralType.reverse_mapping[tlit.literal_type])