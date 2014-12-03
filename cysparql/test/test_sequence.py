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

from cysparql import *
from base import BaseTestCase
from rdflib.term import *
from cysparql.sequence import Sequence

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
