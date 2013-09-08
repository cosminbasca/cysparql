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

class BaseTestCase(TestCase):
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
