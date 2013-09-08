import traceback
from unittest import TestCase
import functools
from cysparql import *

__author__ = 'basca'

def catch_exception(func):
    @functools.wraps
    def wrapper(*args, **kwargs):
        try:
            func(*args, **kwargs)
        except Exception, e:
            print 'Have exception in [%s]: %s, \ntraceback = \n%s'%(func.__name__, e, traceback.format_exc())
    return wrapper

class TestDb(TestCase):
    @classmethod
    def setUpClass(cls):
        cls.query = """
        PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX wgs84_pos: <http://www.w3.org/2003/01/geo/wgs84_pos#>
SELECT *
FROM <http://dbpedia.org>
WHERE {
        <http://dbpedia.org/resource/Karl_Gebhardt> rdfs:label ?label .
        OPTIONAL {
            <http://dbpedia.org/resource/Karl_Gebhardt> wgs84_pos:lat ?lat .
            <http://dbpedia.org/resource/Karl_Gebhardt> wgs84_pos:long ?long
        }
        FILTER (lang(?label) = 'en')
}
        """
        disable_rasqal_warnings()

    @classmethod
    def tearDownClass(cls):
        pass

    def get_query(self):
        return Query(self.query)

    def get_var(self, query):
        return list(query.projections)[0]

    def get_vt(self, query):
        return query.create_vars_table()

    def test_01_create(self):
        query = self.get_query()
        vt = self.get_vt(query)
        self.assertIsInstance(vt, QueryVarsTable)
        del vt

    def test_02_add_new_var(self):
        query = self.get_query()
        vt = self.get_vt(query)
        var = vt.add_new_variable("aVarName")
        self.assertIsInstance(var, QueryVar)
        self.assertEqual(var.name, "aVarName")

    def test_03_getvar_by_name(self):
        query = self.get_query()
        vt = self.get_vt(query)
        vt.add_new_variable("aVarName")
        var = vt["aVarName"]
        self.assertIsInstance(var, QueryVar)
        self.assertEqual(var.name, "aVarName")

    def test_04_add_existing_var(self):
        query = self.get_query()
        vt = self.get_vt(query)
        var = self.get_var(query)
        rv = vt.add_variable(var)
        self.assertEqual(rv, True)
        _var = vt[var.name]
        self.assertIsInstance(var, QueryVar)
        self.assertEqual(_var.name, var.name)

    def test_05_contains_var(self):
        query = self.get_query()
        vt = self.get_vt(query)
        vt.add_new_variable("aVarName")
        self.assertTrue("aVarName" in vt)
        self.assertFalse("anotherVarName" in vt)
