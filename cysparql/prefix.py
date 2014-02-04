from json import load
import os

__author__ = 'basca'

#-----------------------------------------------------------------------------------------------------------------------
#
# simple prefix.,c
#
#-----------------------------------------------------------------------------------------------------------------------
to_sparql_prefix_definition = lambda prefs: '\n'.join([ 'PREFIX %s: <%s>'%(p,u) for p,u in prefs.items() ])

PREFIX_CC_JSON = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'prefix.cc.json')
with open(PREFIX_CC_JSON,'r') as prefix_cc_file:
    PREFIXES = load(prefix_cc_file)
    REVERSE_PREFIXES = {v:k for k, v in PREFIXES.items()}
    print('loaded %s prefixes'%len(PREFIXES))

#-----------------------------------------------------------------------------------------------------------------------
#
# simple prefix.cc API
#
#-----------------------------------------------------------------------------------------------------------------------
def get_prefix(url):
    return REVERSE_PREFIXES.get(url, None)

def get_url_for_prefix(prefix):
    return PREFIXES.get(prefix, None)