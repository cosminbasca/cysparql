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
