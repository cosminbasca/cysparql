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

from cysparql import Query, disable_rasqal_warnings, get_query_from_console
from cysparql.__version__ import str_version
import argparse
import os

__author__ = 'basca'

# noinspection PyCallingNonCallable
def sparql_info():
    parser = argparse.ArgumentParser(description='Display information about the supplied sparql query')
    parser.add_argument('--plot', dest='plot', action='store_true',
                        help='plot to file (if matplotlib is installed, nothing will happen otherwise)')
    parser.add_argument('--query', dest='query', action='store', type=str, default=None,
                        help='the SPARQL query file (file containing the sparql query). Lines starging with "--" are '
                             'ignored, if None, the query is read from the console')

    args = parser.parse_args()
    disable_rasqal_warnings()

    query_string = None
    if args.query is None:
        query_string = get_query_from_console()
    elif isinstance(args.query, basestring) and os.path.isfile(args.query):
        with open(args.query, 'r+') as QFILE:
            query_string = ''.join([l for l in QFILE if not l.strip().startswith('--')])

    if query_string is None:
        raise ValueError('could not get query')

    query = Query(query_string, pretty=True)

    stars_info = ''.join(['\nStar ({0}): \n\t{1}'.format(i, '\n\t'.join([str(tp) for tp in star]))
                          for i, star in enumerate(query.stars)])

    ascii_info = query.ascii
    if not ascii_info:
        ascii_info = 'could not find asciinet (required for drawing the query diagram)'
    query_info = """
------------------------------------------------------------------------------------------------------------------------
cysparql version {0[version]}

INPUT STRING:
{0[query_string]}

PRETTY STRING:
{0[pretty_query_string]}

------------------------------------------------------------------------------------------------------------------------
VERB            : {0[verb]}
NAME            : {0[name]}
LIMIT           : {0[limit]}
OFFSET          : {0[offset]}
DISTINCT        : {0[distinct]}
EXPLAIN         : {0[explain]}
WILDCARD        : {0[wildcard]}
PREFIXES        : {0[prefixes]}
IS STAR         : {0[is_star]}
VARIABLES       : {0[variables]}
PROJECTIONS     : {0[projections]}

------------------------------------------------------------------------------------------------------------------------
TRIPLE PATTERNS:
{0[triple_patterns]}

STARS:
{0[stars]}

ADJACENCY MATRIX:
{0[adj_matrix]}

------------------------------------------------------------------------------------------------------------------------
DIAGRAM:
{0[ascii]}
------------------------------------------------------------------------------------------------------------------------
    """.format({
        'version': str_version,
        'query_string': query_string,
        'verb': query.verb,
        'name': query.name,
        'limit': query.limit,
        'offset': query.offset,
        'distinct': query.distinct,
        'explain': query.explain,
        'wildcard': query.wildcard,
        'prefixes': [str(prefix) for prefix in query.prefixes],
        'is_star': query.is_star(),
        'pretty_query_string': str(query),
        'variables': [str(var) for var in query.vars],
        'projections': [str(var) for var in query.projections],
        'triple_patterns': '\n'.join([str(tp) for tp in query.triple_patterns]),
        'stars': stars_info,
        'adj_matrix': query.adjacency_matrix,
        'ascii': ascii_info,
    })

    print query_info
