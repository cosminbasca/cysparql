from crasqal cimport *
from cython cimport *
from cpython cimport *
from libc.stdio cimport *
from libc.stdlib cimport *
import os
import sys

__author__ = 'Cosmin Basca'
__email__ = 'basca@ifi.uzh.ch; cosmin.basca@gmail.com'

cpdef get_q():
    return Query('''
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

def test_sparql(debug=False):
    q = get_q()
    if debug: q.debug()

cpdef test_struct():
    q = get_q()
    q.debug()
    cdef rasqal_query* rq   = <rasqal_query*>q.rq
    cdef rasqal_variable* v = rasqal_query_get_variable(rq, 0)
    print 'VAR ->',v.name, v.offset, v.usage

def measure_time(nr=1000):
    from timeit import Timer
    t = Timer('test_sparql(debug=False)','from crasqal import test_sparql')
    total_secs = t.timeit(number=nr)
    print 'Query parsing took %s ms, with a total %s seconds for %s runs.'%(str(1000 * total_secs/nr), str(total_secs), str(nr))


def test_sequence():
    q = get_q()
    vars = q.get_all_vars() #get_bound_vars()
    print 'HAVE VARS !'
    print len(vars)
    cdef rasqal_variable* v = <rasqal_variable*>vars[1]
    print 'var -> ',<long>v, v.name
    v = <rasqal_variable*>vars[2]
    print 'var -> ',<long>v, v.name

    print 'test iter'
    for var in vars:
        print 'V ------> ',(<rasqal_variable*>var).name

#-----------------------------------------------------------------------------------------------------------------------
# other types
#-----------------------------------------------------------------------------------------------------------------------

cdef class Sequence:
    cdef raptor_sequence* sq
    cdef int __idx__

    def __cinit__(self, sq):
        self.sq = <raptor_sequence*>sq
        self.__idx__ = 0

    def __del__(self):
        if self.sq != NULL:
            raptor_free_sequence(<raptor_sequence*>self.sq)
        
    def __len__(self):
        return raptor_sequence_size(<raptor_sequence*>self.sq)

    def __setitem__(self, i, value):
        raptor_sequence_set_at(<raptor_sequence*>self.sq, i, <void*>value)

    def __delitem__(self, i):
        raptor_sequence_delete_at(<raptor_sequence*>self.sq, i)

    def __getitem__(self, i):
        return <object>raptor_sequence_get_at(<raptor_sequence*>self.sq, i)
        
    def debug(self):
        raptor_sequence_print(<raptor_sequence*>self.sq, stdout)

    def __and__(self, other):
        raptor_sequence_join(<raptor_sequence*>self.sq, <raptor_sequence*>other)

    def shift(self, data):
        raptor_sequence_shift(<raptor_sequence*>self.sq, <void*>data)

    def unshift(self):
        return <object>raptor_sequence_unshift(<raptor_sequence*>self.sq)

    def pop(self):
        return <object>raptor_sequence_pop(<raptor_sequence*>self.sq)

    def push(self, data):
        raptor_sequence_push(<raptor_sequence*>self.sq, <void*>data)

    def __iter__(self):
        return self

    def __next__(self):
        if self.__idx__ == raptor_sequence_size(<raptor_sequence*>self.sq):
            raise StopIteration
        else:
            item = <object>raptor_sequence_get_at(<raptor_sequence*>self.sq, self.__idx__)
            self.__idx__ += 1
            return item

    
cdef class Query:
    cdef rasqal_world* w
    cdef rasqal_query* rq

    def __cinit__(self):
        self.w  = rasqal_new_world()

    def __init__(self, query):
        self.rq = rasqal_new_query(self.w, "sparql", NULL)
        rasqal_query_prepare(self.rq, query, NULL)

    def __dealloc__(self):
        rasqal_free_world(self.w)
        rasqal_free_query(self.rq)

    def debug(self):
        rasqal_query_print(self.rq, stdout)

    #-----------------------------------------------------------------------------------------------------------
    # query rasqal API
    #-----------------------------------------------------------------------------------------------------------
    cpdef get_all_vars(self):
        return Sequence(<object>rasqal_query_get_all_variable_sequence(self.rq))

    cpdef get_bound_vars(self):
        return Sequence(<object>rasqal_query_get_bound_variable_sequence(self.rq))

    