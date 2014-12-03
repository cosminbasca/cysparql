#
# author: Cosmin Basca
#
# Copyright 2010 University of Zurich
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

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

        cls.star_query_s = """
        PREFIX example: <http://example.org#>
        SELECT * WHERE {
        ?s example:link ?o1 .
        ?s example:link ?o2 .
        ?s example:link ?o3 .
        ?s example:link "TEST"
        }
        """

        cls.star_query_o = """
        PREFIX example: <http://example.org#>
        SELECT * WHERE {
        ?s1 example:link ?o .
        ?s2 example:link ?o .
        ?s3 example:link ?o .
        example:X example:link ?o
        }
        """

        cls.not_star_query= """
        PREFIX example: <http://example.org#>
        SELECT * WHERE {
        ?s1 example:link ?o .
        ?s2 example:link ?o1 .
        ?s3 example:link ?o .
        example:X example:link ?o
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
