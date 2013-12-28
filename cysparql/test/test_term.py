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
        qlit_val = qlit.to_python()
        self.assertIsInstance(qlit_val, URIRef)
        self.assertEqual(str(qlit_val), 'http://dbpedia.org/resource/Karl_Gebhardt')

    def test_02_variable_literal(self):
        query = self.get_query()
        qlit = self.get_qliteral_var(query)
        self.assertIsInstance(qlit, QueryLiteral)
        qlit_val = qlit.to_python()
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

    def test_05_create_decimal_literal(self):
        w = RasqalWorld()
        tlit = QueryLiteral.new_decimal_literal(w, "1234567890")
        self.assertIsInstance(tlit, QueryLiteral)
        self.assertEqual(tlit.literal_type, LiteralType.DECIMAL)
        self.assertEqual(tlit.literal_type_label.upper(), LiteralType.reverse_mapping[tlit.literal_type])

    def test_06_create_double_literal(self):
        w = RasqalWorld()
        tlit = QueryLiteral.new_double_literal(w, 12231423.12323)
        self.assertIsInstance(tlit, QueryLiteral)
        self.assertEqual(tlit.literal_type, LiteralType.DOUBLE)
        self.assertEqual(tlit.literal_type_label.upper(), LiteralType.reverse_mapping[tlit.literal_type])

    def test_07_create_integer_literal(self):
        w = RasqalWorld()
        tlit = QueryLiteral.new_integer_literal(w, 12231423)
        self.assertIsInstance(tlit, QueryLiteral)
        self.assertEqual(tlit.literal_type, LiteralType.INTEGER)
        self.assertEqual(tlit.literal_type_label.upper(), LiteralType.reverse_mapping[tlit.literal_type])

    def test_08_create_simple_literal(self):
        w = RasqalWorld()
        tlit = QueryLiteral.new_simple_literal(w, "123easDFADAS")
        self.assertIsInstance(tlit, QueryLiteral)
        self.assertEqual(tlit.literal_type, LiteralType.BLANK)
        self.assertEqual(tlit.literal_type_label.upper(), LiteralType.reverse_mapping[tlit.literal_type])

    def test_09_create_string_literal(self):
        w = RasqalWorld()
        tlit = QueryLiteral.new_string_literal(w, "some name", lang="en")
        self.assertIsInstance(tlit, QueryLiteral)
        self.assertEqual(tlit.language, "en")
        self.assertEqual(tlit.literal_type, LiteralType.STRING)
        self.assertEqual(tlit.literal_type_label.upper(), LiteralType.reverse_mapping[tlit.literal_type])

        tlit = QueryLiteral.new_string_literal(w, "45.89", dtype="http://www.w3.org/2001/XMLSchema#float")
        self.assertIsInstance(tlit, QueryLiteral)
        self.assertEqual(tlit.literal_type, LiteralType.FLOAT)
        self.assertEqual(tlit.literal_type_label.upper(), LiteralType.reverse_mapping[tlit.literal_type])

    def test_10_create_string_literal(self):
        w = RasqalWorld()
        tlit = QueryLiteral.new_uri_literal(w, "http://www.w3.org/2001/XMLSchema#float")
        self.assertIsInstance(tlit, QueryLiteral)
        self.assertEqual(tlit.literal_type, LiteralType.URI)
        self.assertEqual(tlit.literal_type_label.upper(), LiteralType.reverse_mapping[tlit.literal_type])

    def test_11_variable_bind(self):
        query = self.get_query()
        qlit = self.get_qliteral_var(query)
        self.assertIsInstance(qlit, QueryLiteral)
        qlit_val = qlit.to_python()
        self.assertIsNone(qlit_val.get_value())
        qlit_val.set_value(20L, query.world)
        self.assertIsInstance(qlit_val.get_value(),long)
        qlit_val.set_value(None, query.world)
        self.assertIsNone(qlit_val.get_value())
