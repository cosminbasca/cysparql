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

from cysparql.varstable import QueryVarsTable
from cysparql import *
from base import BaseTestCase

__author__ = 'basca'

class VarsTableTestCase(BaseTestCase):
    def test_01_create(self):
        query = self.get_query()
        vt = self.get_vt(query)
        self.assertIsInstance(vt, QueryVarsTable)
        del vt

    def test_02_add_new_var(self):
        query = self.get_query()
        vt = self.get_vt(query)
        var = vt.add_new_variable("aVarName")
        self.assertIsInstance(var, QueryVar)
        self.assertEqual(var.name, "aVarName")

    def test_03_getvar_by_name(self):
        query = self.get_query()
        vt = self.get_vt(query)
        vt.add_new_variable("aVarName")
        var = vt["aVarName"]
        self.assertIsInstance(var, QueryVar)
        self.assertEqual(var.name, "aVarName")

    def test_04_add_existing_var(self):
        query = self.get_query()
        vt = self.get_vt(query)
        var = self.get_var(query)
        rv = vt.add_variable(var)
        self.assertEqual(rv, True)
        _var = vt[var.name]
        self.assertIsInstance(var, QueryVar)
        self.assertEqual(_var.name, var.name)

    def test_05_contains_var(self):
        query = self.get_query()
        vt = self.get_vt(query)
        vt.add_new_variable("aVarName")
        self.assertTrue("aVarName" in vt)
        self.assertFalse("anotherVarName" in vt)
