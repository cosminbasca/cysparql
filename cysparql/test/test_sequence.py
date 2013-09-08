from cysparql import *
from base import BaseTestCase
from rdflib.term import *

__author__ = 'basca'

class SequenceTestCase(BaseTestCase):
    def test_01_get(self):
        query = self.get_query()
        self.assertIsInstance(query.vars, Sequence)

    def test_02_len(self):
        query = self.get_query()
        self.assertEqual(len(query.vars), 3)

    def test_03_getitem(self):
        query = self.get_query()
        self.assertEqual(query.vars[0].name, 'label')

    def test_04_iterate(self):
        query = self.get_query()
        for v in query.vars:
            self.assertIsInstance(v, QueryVar)
