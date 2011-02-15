from crasqal cimport *
from cython cimport *
from cpython cimport *
from libc.stdio cimport *
from libc.stdlib cimport *
import os
import sys

__author__ = 'Cosmin Basca'
__email__ = 'basca@ifi.uzh.ch; cosmin.basca@gmail.com'

def test_sparql():
    test_parse(''' SELECT ?name WHERE {<http://someinsatnce.com> ?p ?name} ''')

cpdef test_parse(query):
    cdef rasqal_world* world    = rasqal_new_world()
    cdef raptor_world* rw       = rasqal_world_get_raptor(world)
    cdef raptor_uri *base_uri   = raptor_new_uri(rw, "http://example.org/foo")
    cdef rasqal_query *rq       = rasqal_new_query(world, "sparql", NULL)
    rasqal_query_prepare(rq, <char*>query, base_uri)
    rasqal_query_print(rq, stdout)
    rasqal_free_world(<rasqal_world*>world)
