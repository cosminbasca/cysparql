from json import load
import os

__author__ = 'basca'

#-----------------------------------------------------------------------------------------------------------------------
#
# simple prefix.cc
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
# simple prefix.cc API
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