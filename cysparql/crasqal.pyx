from crasqal cimport *
from cython cimport *
from cpython cimport *
from libc.stdio cimport *
from libc.stdlib cimport *
import os
import sys

__author__ = 'Cosmin Basca'
__email__ = 'basca@ifi.uzh.ch; cosmin.basca@gmail.com'

def test_sparql(debug=False):
    q = Query('''
SELECT ?title_other ?title ?author
WHERE {
        ?paper <http://www.aktors.org/ontology/portal#has-title> ?title .
        ?paper <http://www.aktors.org/ontology/portal#has-author> ?author .
        ?paper <http://www.aktors.org/ontology/portal#article-of-journal> ?journal .
        ?paper <http://www.aktors.org/ontology/portal#has-date> <http://www.aktors.org/ontology/date#2009> .
        ?paper_other <http://www.aktors.org/ontology/portal#article-of-journal> ?journal .
        ?paper_other <http://www.aktors.org/ontology/portal#has-title> ?title_other .
} LIMIT 100
    ''')
    if debug: q.debug()

def measure_time(nr=1000):
    from timeit import Timer
    t = Timer('test_sparql(debug=False)','from crasqal import test_sparql')
    total_secs = t.timeit(number=nr)
    print 'Query parsing took %s ms, with a total %s seconds for %s runs.'%(str(1000 * total_secs/nr), str(total_secs), str(nr))

cdef class Query:
    cdef rasqal_world* w
    cdef rasqal_query* rq

    def __cinit__(self):
        self.w  = rasqal_new_world()

    def __init__(self, query):
        self.rq = rasqal_new_query(self.w, "sparql", NULL)
        rasqal_query_prepare(self.rq, <char*>query, NULL)

    def __dealloc__(self):
        rasqal_free_world(self.w)
        rasqal_free_query(self.rq)

    def debug(self):
        rasqal_query_print(self.rq, stdout)