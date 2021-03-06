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

from base import *
from rdflib.term import *

__author__ = 'basca'

class TestEncodedQuery(BaseTestCase):
    def test_01_variables(self):
        query = EncodedQuery(self.star_query_s)
        all_vars = {'s', 'o1', 'o2', 'o3'}
        all_enc_vars = {-1, -2, -3, -4}
        self.assertEqual(all_vars, {query.decode(ev) for ev in all_enc_vars})
        self.assertEqual(all_vars, {query.decode(ev) for ev in query.encoded_projections})

    def test_02_triple_patterns(self):
        query = EncodedQuery(self.star_query_s)
        tpatterns = list(query.triple_patterns)
        self.assertEquals(len(tpatterns), 4)
        self.assertEquals(len(query.encoded_triple_patterns), 4)
        for i in xrange(len(tpatterns)):
            e_tpattern = query.encoded_triple_patterns[i]
            self.assertIsInstance(e_tpattern, tuple)
            self.assertEqual(len(e_tpattern), 3)
            self.assertIsInstance(e_tpattern[0], int)
            self.assertIsInstance(e_tpattern[1], str)
            self.assertEqual(query.decode(e_tpattern[1]), URIRef('http://example.org#link'))

