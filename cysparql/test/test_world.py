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

from cysparql.world import RasqalWorld
from cysparql import *
from base import BaseTestCase
from rdflib.term import *

__author__ = 'basca'

class WorldTestCase(BaseTestCase):
    def test_01_crete(self):
        world = RasqalWorld()
        self.assertIsInstance(world, RasqalWorld)
        del world

    def test_02_set_warn_level(self):
        world = RasqalWorld(auto_open=False)
        for i in xrange(100):
            self.assertTrue(world.set_warning_level(i))
        self.assertFalse(world.set_warning_level(-10))
        self.assertFalse(world.set_warning_level(110))
        self.assertTrue(world.open())

    def test_03_check_sparql_language(self):
        world = RasqalWorld()
        self.assertTrue(world.check_query_language('sparql'))
        self.assertFalse(world.check_query_language('sql'))
