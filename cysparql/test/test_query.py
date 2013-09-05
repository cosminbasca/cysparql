import traceback
from pytools import distinct_pairs

__author__ = 'basca'

from unittest import TestCase
import functools
import os
import shutil
import tempfile
from cysparql import *
import logging
import binascii
from pandas.core.frame import DataFrame, Series
from rdflib.term import Literal as rdflib_Literal
from rdflib.term import URIRef as rdflib_URIRef
from rdflib.term import BNode as rdflib_BNode

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
        cls.q_spo_2 = '''select ?o where {<http://richard.cyganiak.de/foaf.rdf>   <http://xmlns.com/foaf/0.1/name>  ?o                 } LIMIT 1'''
        cls.q_spo_1 = '''select ?p where {<http://richard.cyganiak.de/foaf.rdf>   ?p                                ?o                 } LIMIT 1'''
        cls.q_sop_2 = '''select ?p where {<http://richard.cyganiak.de/foaf.rdf>   ?p                                "Richard Cyganiak" } LIMIT 1'''
        cls.q_sop_1 = '''select ?o where {<http://richard.cyganiak.de/foaf.rdf>   ?p                                ?o                 } LIMIT 1'''
        cls.q_pos_2 = '''select ?s where {?s                                      <http://xmlns.com/foaf/0.1/name>  "Richard Cyganiak" } LIMIT 1'''
        cls.q_pos_1 = '''select ?o where {?s                                      <http://xmlns.com/foaf/0.1/name>  ?o                 } LIMIT 1'''
        cls.q_pso_1 = '''select ?s where {?s                                      <http://xmlns.com/foaf/0.1/name>  ?o                 } LIMIT 1'''
        cls.q_osp_1 = '''select ?s where {?s                                      ?p                                 "Libby Miller"     } LIMIT 1'''
        cls.q_ops_1 = '''select ?p where {?s                                      ?p                                 "Libby Miller"     } LIMIT 1'''
        cls.q_circular = '''
        select ?m1 ?m2 ?m3 where
        {
            ?p1 <http://xmlns.com/foaf/0.1/knows> ?p2.
            ?p2 <http://xmlns.com/foaf/0.1/knows> ?p3.
            ?p3 <http://xmlns.com/foaf/0.1/knows> ?p1.
            ?p1 <http://xmlns.com/foaf/0.1/name> ?m1.
            ?p2 <http://xmlns.com/foaf/0.1/name> ?m2.
            ?p3 <http://xmlns.com/foaf/0.1/name> ?m3.
        }
        '''
        disable_rasqal_warnings()

    @classmethod
    def tearDownClass(cls):
        pass

    def test_parse(self):
        q = Query(self.q_spo_1)
        q = Query(self.q_spo_2)
        q = Query(self.q_sop_1)
        q = Query(self.q_sop_2)
        q = Query(self.q_pos_1)
        q = Query(self.q_pos_2)
        q = Query(self.q_pso_1)
        q = Query(self.q_ops_1)
