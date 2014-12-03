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

from json import load
import os


__author__ = 'basca'

#-----------------------------------------------------------------------------------------------------------------------
#
# load prefix.cc
#
#-----------------------------------------------------------------------------------------------------------------------
to_sparql_prefix_definition = lambda prefs: '\n'.join([ 'PREFIX %s: <%s>'%(p,u) for p,u in prefs.items() ])

PREFIX_CC_JSON = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'prefix.cc.json')
with open(PREFIX_CC_JSON,'r') as prefix_cc_file:
    _NS = load(prefix_cc_file)
    _REVERSE_NS = {v:k for k, v in _NS.items()}
    print('loaded %s prefixes'%len(_NS))

#-----------------------------------------------------------------------------------------------------------------------
#
# simple prefix (namespace) API
#
#-----------------------------------------------------------------------------------------------------------------------
def get_namespace_prefix(url):
    return _REVERSE_NS.get(url, None)


def get_namespace_url(prefix):
    return _NS.get(prefix, None)


def add_namespace(prefix, uri):
    global _NS, _REVERSE_NS
    _NS[prefix]=uri
    _REVERSE_NS[uri]=prefix


def remove_namespace(prefix):
    global _NS, _REVERSE_NS
    uri = _NS.get(prefix)
    if uri:
        del _NS[prefix]
        del _REVERSE_NS[uri]